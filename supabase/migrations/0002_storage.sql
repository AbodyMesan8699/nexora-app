-- NEXORA — storage buckets + policies
-- Run in Supabase SQL editor (buckets are created here, not via client).

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types) values
  ('profile-images', 'profile-images', true, 5242880,  array['image/jpeg','image/png','image/webp']),
  ('cover-images',   'cover-images',   true, 10485760, array['image/jpeg','image/png','image/webp']),
  ('post-media',     'post-media',     true, 52428800, array['image/jpeg','image/png','image/webp','video/mp4','video/webm']),
  ('message-media',  'message-media',  false, 52428800, array['image/jpeg','image/png','image/webp','video/mp4']),
  ('story-media',    'story-media',    false, 26214400, array['image/jpeg','image/png','image/webp','video/mp4'])
on conflict (id) do nothing;

-- Helper: user owns path when first path segment equals their uid
create or replace function storage.owner_matches(name text) returns boolean
language sql stable as $$
  select auth.uid()::text = split_part(name, '/', 1);
$$;

-- Public read buckets (avatars, covers, post media)
create policy "pub-read-profile-images" on storage.objects for select
  using (bucket_id = 'profile-images');
create policy "pub-read-cover-images" on storage.objects for select
  using (bucket_id = 'cover-images');
create policy "pub-read-post-media" on storage.objects for select
  using (bucket_id = 'post-media');

-- Owner-only write/update/delete, path must start with auth.uid()
create policy "own-write-profile-images" on storage.objects for insert
  with check (bucket_id = 'profile-images' and storage.owner_matches(name));
create policy "own-update-profile-images" on storage.objects for update
  using (bucket_id = 'profile-images' and storage.owner_matches(name));
create policy "own-delete-profile-images" on storage.objects for delete
  using (bucket_id = 'profile-images' and storage.owner_matches(name));

create policy "own-write-cover-images" on storage.objects for insert
  with check (bucket_id = 'cover-images' and storage.owner_matches(name));
create policy "own-update-cover-images" on storage.objects for update
  using (bucket_id = 'cover-images' and storage.owner_matches(name));
create policy "own-delete-cover-images" on storage.objects for delete
  using (bucket_id = 'cover-images' and storage.owner_matches(name));

create policy "own-write-post-media" on storage.objects for insert
  with check (bucket_id = 'post-media' and storage.owner_matches(name));
create policy "own-update-post-media" on storage.objects for update
  using (bucket_id = 'post-media' and storage.owner_matches(name));
create policy "own-delete-post-media" on storage.objects for delete
  using (bucket_id = 'post-media' and storage.owner_matches(name));

-- Private buckets: read only by owner or conversation member / story owner relationship
create policy "own-read-message-media" on storage.objects for select
  using (bucket_id = 'message-media' and storage.owner_matches(name));
create policy "own-write-message-media" on storage.objects for insert
  with check (bucket_id = 'message-media' and storage.owner_matches(name));
create policy "own-delete-message-media" on storage.objects for delete
  using (bucket_id = 'message-media' and storage.owner_matches(name));

create policy "own-read-story-media" on storage.objects for select
  using (bucket_id = 'story-media' and storage.owner_matches(name));
create policy "own-write-story-media" on storage.objects for insert
  with check (bucket_id = 'story-media' and storage.owner_matches(name));
create policy "own-delete-story-media" on storage.objects for delete
  using (bucket_id = 'story-media' and storage.owner_matches(name));
