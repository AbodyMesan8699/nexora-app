-- Restore moderation visibility for administrators.
-- The founder/admin dashboard must be able to review all posts and take
-- moderation actions; ordinary users remain governed by can_view_post.
create policy posts_admin_read on public.posts for select
  using (public.is_admin());
