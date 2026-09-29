-- Restore post-media storage and require a relationship for every non-owner post.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('post-media', 'post-media', true, 52428800,
  array['image/jpeg','image/png','image/webp','image/heic','video/mp4','video/webm','video/quicktime'])
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "pub-read-post-media" on storage.objects;
create policy "pub-read-post-media" on storage.objects for select
  using (bucket_id = 'post-media');
drop policy if exists "own-write-post-media" on storage.objects;
create policy "own-write-post-media" on storage.objects for insert
  with check (bucket_id = 'post-media' and auth.uid()::text = split_part(name, '/', 1));
drop policy if exists "own-update-post-media" on storage.objects;
create policy "own-update-post-media" on storage.objects for update
  using (bucket_id = 'post-media' and auth.uid()::text = split_part(name, '/', 1));
drop policy if exists "own-delete-post-media" on storage.objects;
create policy "own-delete-post-media" on storage.objects for delete
  using (bucket_id = 'post-media' and auth.uid()::text = split_part(name, '/', 1));

-- No media moderation worker is deployed in this project; show uploaded media immediately.
alter table public.post_media alter column moderation_status set default 'approved';
update public.post_media set moderation_status = 'approved' where moderation_status = 'pending';

create or replace function public.can_view_post(p_owner uuid, p_visibility post_visibility)
returns boolean language sql stable security definer set search_path = public as $$
  select case
    when auth.uid() = p_owner then true
    when public.is_blocked_with(p_owner) then false
    when p_visibility = 'private' then false
    when p_visibility = 'friends' then exists (
      select 1 from public.friendships fr
      where (fr.user_a = auth.uid() and fr.user_b = p_owner)
         or (fr.user_b = auth.uid() and fr.user_a = p_owner))
    when p_visibility in ('public', 'followers') then
      exists (select 1 from public.follows f
              where f.follower_id = auth.uid() and f.following_id = p_owner)
      or exists (select 1 from public.friendships fr
                 where (fr.user_a = auth.uid() and fr.user_b = p_owner)
                    or (fr.user_b = auth.uid() and fr.user_a = p_owner))
    else false
  end;
$$;
revoke execute on function public.can_view_post(uuid,post_visibility) from public, anon;
grant execute on function public.can_view_post(uuid,post_visibility) to authenticated;
