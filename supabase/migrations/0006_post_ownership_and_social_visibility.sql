-- NEXORA post ownership and social visibility hardening.
-- Apply after migrations 0001..0005 in the Supabase SQL editor.

-- Keep the intended privacy model explicit: owners always see their posts;
-- followers/friends see restricted posts; public posts remain visible unless blocked.
create or replace function public.can_view_post(
  p_owner uuid,
  p_visibility post_visibility
) returns boolean
language sql stable security definer set search_path = public
as $$
  select case
    when auth.uid() = p_owner then true
    when public.is_blocked_with(p_owner) then false
    when p_visibility = 'public' then true
    when p_visibility = 'private' then false
    when p_visibility = 'followers' then exists (
      select 1 from public.follows f
      where f.follower_id = auth.uid() and f.following_id = p_owner
    )
    when p_visibility = 'friends' then exists (
      select 1 from public.friendships fr
      where (fr.user_a = auth.uid() and fr.user_b = p_owner)
         or (fr.user_b = auth.uid() and fr.user_a = p_owner)
    )
    else false
  end;
$$;

-- These RPCs make ownership checks explicit and avoid the silent zero-row
-- behavior that can occur when an RLS UPDATE policy is missing in production.
create or replace function public.update_post(
  p_post_id uuid,
  p_content text default null,
  p_visibility post_visibility default null
) returns boolean
language plpgsql security definer set search_path = public
as $$
declare affected integer;
begin
  if auth.uid() is null then raise exception 'not authenticated'; end if;
  if not public.account_status_ok() then raise exception 'account is not active'; end if;
  if not exists (
    select 1 from public.posts
    where id = p_post_id and user_id = auth.uid() and not is_deleted
  ) then
    raise exception 'post not found or not owned';
  end if;

  update public.posts
  set content = coalesce(p_content, content),
      visibility = coalesce(p_visibility, visibility),
      updated_at = now()
  where id = p_post_id and user_id = auth.uid() and not is_deleted;
  get diagnostics affected = row_count;
  return affected > 0;
end;
$$;

create or replace function public.delete_post(p_post_id uuid)
returns boolean
language plpgsql security definer set search_path = public
as $$
declare affected integer;
begin
  if auth.uid() is null then raise exception 'not authenticated'; end if;
  if not public.account_status_ok() then raise exception 'account is not active'; end if;

  update public.posts
  set is_deleted = true, updated_at = now()
  where id = p_post_id and user_id = auth.uid() and not is_deleted;
  get diagnostics affected = row_count;
  if affected = 0 then raise exception 'post not found or not owned'; end if;
  return affected > 0;
end;
$$;

grant execute on function public.update_post(uuid,text,post_visibility) to authenticated;
grant execute on function public.delete_post(uuid) to authenticated;
revoke execute on function public.update_post(uuid,text,post_visibility) from public;
revoke execute on function public.delete_post(uuid) from public;
revoke execute on function public.can_view_post(uuid,post_visibility) from public;
grant execute on function public.can_view_post(uuid,post_visibility) to authenticated;

-- Reassert owner-only direct table writes for clients that do not use the RPCs.
drop policy if exists posts_update on public.posts;
create policy posts_update on public.posts for update to authenticated
  using (user_id = auth.uid() and public.account_status_ok())
  with check (user_id = auth.uid());

drop policy if exists posts_delete on public.posts;
create policy posts_delete on public.posts for delete to authenticated
  using (user_id = auth.uid() or public.is_admin());
