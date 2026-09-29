-- Keep post RPCs callable only by signed-in users.
revoke execute on function public.update_post(uuid,text,post_visibility) from public, anon;
revoke execute on function public.delete_post(uuid) from public, anon;
revoke execute on function public.can_view_post(uuid,post_visibility) from public, anon;
grant execute on function public.update_post(uuid,text,post_visibility) to authenticated;
grant execute on function public.delete_post(uuid) to authenticated;
grant execute on function public.can_view_post(uuid,post_visibility) to authenticated;
