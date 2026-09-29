import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const url = Deno.env.get('SUPABASE_URL')!;
const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const cronSecret = Deno.env.get('CRON_CLEANUP_SECRET') ?? '';
const admin = createClient(url, serviceKey, { auth: { persistSession: false } });

function storageRef(raw: string): { bucket: string; path: string } | null {
  try {
    const pathname = new URL(raw).pathname;
    const marker = '/storage/v1/object/';
    const i = pathname.indexOf(marker);
    if (i < 0) return null;
    const rest = pathname.slice(i + marker.length).split('/');
    if (rest[0] === 'public' || rest[0] === 'sign' || rest[0] === 'authenticated') rest.shift();
    const bucket = rest.shift();
    if (!bucket || rest.length === 0) return null;
    return { bucket, path: decodeURIComponent(rest.join('/')) };
  } catch (_) {
    return null;
  }
}

async function matchesPrivateSecret(value: string): Promise<boolean> {
  // The public-schema view is SELECT-granted to service_role only; the secret table remains private.
  const { data, error } = await admin
    .from('private_cleanup_config')
    .select('secret')
    .eq('id', true)
    .maybeSingle();
  return !error && !!data && data.secret === value;
}

async function authorized(req: Request): Promise<string | null> {
  const headerSecret = req.headers.get('x-cron-secret') ?? '';
  if (headerSecret && (headerSecret === cronSecret || await matchesPrivateSecret(headerSecret))) {
    return null;
  }

  const token = req.headers.get('authorization')?.replace(/^Bearer\s+/i, '');
  if (!token) throw new Error('unauthorized');
  const { data: user, error } = await admin.auth.getUser(token);
  if (error || !user.user) throw new Error('unauthorized');
  const { data: role } = await admin
    .from('admin_roles')
    .select('user_id')
    .eq('user_id', user.user.id)
    .maybeSingle();
  if (!role) throw new Error('forbidden');
  return user.user.id;
}

Deno.serve(async (req) => {
  if (req.method !== 'POST') return new Response('Method Not Allowed', { status: 405 });
  try {
    const executedBy = await authorized(req);
    const { data: settings, error: settingsError } = await admin
      .from('cleanup_settings')
      .select('*')
      .eq('id', true)
      .single();
    if (settingsError) throw settingsError;
    if (!settings.enabled || settings.retention_days === 0) {
      return Response.json({ skipped: true, reason: 'disabled' });
    }

    const cutoff = new Date(Date.now() - settings.retention_days * 86400000).toISOString();
    let postsDeleted = 0;
    let mediaDeleted = 0;
    let errors = 0;
    const details: Array<Record<string, unknown>> = [];

    while (true) {
      const { data: posts, error } = await admin
        .from('posts')
        .select('id,created_at,post_media(media_url,thumbnail_url)')
        .eq('is_deleted', false)
        .lt('created_at', cutoff)
        .order('created_at', { ascending: true })
        .limit(100);
      if (error) throw error;
      if (!posts || posts.length === 0) break;

      for (const post of posts) {
        const refs = new Map<string, string[]>();
        let storageDeleteFailed = false;
        for (const media of (post.post_media ?? [])) {
          for (const raw of [media.media_url, media.thumbnail_url]) {
            if (!raw) continue;
            const ref = storageRef(raw);
            if (!ref) {
              errors++;
              storageDeleteFailed = true;
              details.push({ post_id: post.id, error: 'unparseable_storage_url' });
              continue;
            }
            const list = refs.get(ref.bucket) ?? [];
            if (!list.includes(ref.path)) list.push(ref.path);
            refs.set(ref.bucket, list);
          }
        }
        for (const [bucket, paths] of refs) {
          const { error: removeError } = await admin.storage.from(bucket).remove(paths);
          if (removeError) {
            errors += paths.length;
            storageDeleteFailed = true;
            details.push({ post_id: post.id, bucket, error: removeError.message });
          } else {
            mediaDeleted += paths.length;
          }
        }
        // Keep the post and its media rows retryable if Storage could not delete every file.
        if (storageDeleteFailed) continue;

        const { error: deleteError } = await admin.from('posts').delete().eq('id', post.id);
        if (deleteError) {
          errors++;
          details.push({ post_id: post.id, error: deleteError.message });
        } else {
          postsDeleted++;
        }
      }
    }

    const status = errors === 0 ? 'completed' : (postsDeleted > 0 ? 'partial' : 'failed');
    await admin.from('cleanup_logs').insert({
      posts_deleted: postsDeleted,
      media_deleted: mediaDeleted,
      errors_count: errors,
      execution_status: status,
      executed_by: executedBy,
      details,
    });
    return Response.json({
      posts_deleted: postsDeleted,
      media_deleted: mediaDeleted,
      errors_count: errors,
      status,
    });
  } catch (error) {
    return Response.json(
      { error: error instanceof Error ? error.message : String(error) },
      { status: 400 },
    );
  }
});
