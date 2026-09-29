-- Legacy-compatible administrator account controls.
-- Keeps authorization in PostgreSQL and prevents an administrator from
-- suspending their own account through the client.
create or replace function public.admin_set_account_status(
  p_user_id uuid,
  p_status account_status
) returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  result jsonb;
begin
  if not public.is_admin() then
    raise exception 'not authorized';
  end if;
  if p_user_id = auth.uid() then
    raise exception 'cannot change own account status';
  end if;
  update public.profiles
  set account_status = p_status,
      updated_at = now(),
      is_online = false
  where id = p_user_id
  returning jsonb_build_object('id', id, 'account_status', account_status)
  into result;
  if result is null then
    raise exception 'user not found';
  end if;
  return result;
end;
$$;

revoke execute on function public.admin_set_account_status(uuid, account_status) from public;
grant execute on function public.admin_set_account_status(uuid, account_status) to authenticated;
