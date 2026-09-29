-- Run in Supabase SQL Editor as project owner.
-- This uses no API keys and is safe to keep with the source.

-- Assign the existing Nexora owner account.
insert into public.admin_roles (user_id)
select id from auth.users where lower(email) = lower('newalhaqli@gmail.com')
on conflict (user_id) do nothing;

-- Make the first future account an owner when no owner exists.
create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
declare
  v_username text;
begin
  v_username := lower(regexp_replace(coalesce(new.raw_user_meta_data->>'username',''), '[^a-z0-9_.]', '', 'g'));
  if length(v_username) < 3 then
    v_username := 'user_' || replace(left(new.id::text, 8), '-', '');
  end if;
  if length(v_username) > 24 then
    v_username := left(v_username, 24);
  end if;
  if exists (select 1 from public.profiles where username = v_username) then
    v_username := 'user_' || replace(left(new.id::text, 8), '-', '');
  end if;

  insert into public.profiles (id, first_name, last_name, username, email)
  values (new.id, coalesce(new.raw_user_meta_data->>'first_name',''),
          coalesce(new.raw_user_meta_data->>'last_name',''), v_username, new.email)
  on conflict (id) do nothing;

  insert into public.user_settings (user_id) values (new.id)
  on conflict (user_id) do nothing;

  if not exists (select 1 from public.admin_roles) then
    insert into public.admin_roles (user_id) values (new.id)
    on conflict (user_id) do nothing;
  end if;
  return new;
end;
$$;
