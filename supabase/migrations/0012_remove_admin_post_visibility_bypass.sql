-- Administrators must follow the same post visibility rules as every other user.
-- Moderation actions still use protected RPCs/tables; admin status must not
-- bypass can_view_post for the home feed.
drop policy if exists posts_admin_read on public.posts;
