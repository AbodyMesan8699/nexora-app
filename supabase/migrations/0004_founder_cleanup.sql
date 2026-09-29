-- NEXORA founder cleanup system.
-- Apply after 0001_init.sql, 0002_storage.sql and 0003_social_security.sql.

create table if not exists public.cleanup_settings (
  id boolean primary key default true check (id = true),
  enabled boolean not null default true,
  retention_days integer not null default 7 check (retention_days in (1,3,7,14,30,90,0)),
  weekly_day integer not null default 0 check (weekly_day between 0 and 6),
  weekly_hour integer not null default 3 check (weekly_hour between 0 and 23),
  updated_at timestamptz not null default now(),
  updated_by uuid references auth.users(id)
);

insert into public.cleanup_settings(id) values (true) on conflict (id) do nothing;

create table if not exists public.cleanup_logs (
  id uuid primary key default gen_random_uuid(),
  executed_at timestamptz not null default now(),
  posts_deleted integer not null default 0,
  media_deleted integer not null default 0,
  errors_count integer not null default 0,
  execution_status text not null check (execution_status in ('completed','partial','failed')),
  executed_by uuid references auth.users(id),
  details jsonb not null default '{}'::jsonb
);

alter table public.cleanup_settings enable row level security;
alter table public.cleanup_logs enable row level security;

drop policy if exists cleanup_settings_admin_select on public.cleanup_settings;
create policy cleanup_settings_admin_select on public.cleanup_settings for select to authenticated using (public.is_admin());
drop policy if exists cleanup_settings_admin_update on public.cleanup_settings;
create policy cleanup_settings_admin_update on public.cleanup_settings for update to authenticated using (public.is_admin()) with check (public.is_admin());
drop policy if exists cleanup_logs_admin_select on public.cleanup_logs;
create policy cleanup_logs_admin_select on public.cleanup_logs for select to authenticated using (public.is_admin());

-- The founder UUID is bound to the existing Auth identity, not an email check in Flutter.
insert into public.admin_roles(user_id)
select id from auth.users where lower(email) = lower('newalhaqli@gmail.com')
on conflict (user_id) do nothing;

create or replace function public.get_cleanup_settings()
returns jsonb language sql stable security definer set search_path = public as $$
  select case when public.is_admin() then
    (select to_jsonb(s) from public.cleanup_settings s where s.id = true)
  else null end;
$$;

create or replace function public.update_cleanup_settings(
  p_enabled boolean, p_retention_days integer, p_weekly_day integer default 0, p_weekly_hour integer default 3
) returns jsonb language plpgsql security definer set search_path = public as $$
declare result jsonb;
begin
  if not public.is_admin() then raise exception 'not authorized'; end if;
  if p_retention_days not in (0,1,3,7,14,30,90) then raise exception 'invalid retention'; end if;
  update public.cleanup_settings set enabled=p_enabled, retention_days=p_retention_days,
    weekly_day=p_weekly_day, weekly_hour=p_weekly_hour, updated_at=now(), updated_by=auth.uid()
    where id=true returning to_jsonb(cleanup_settings.*) into result;
  return result;
end $$;

-- The Edge Function performs Storage API deletion before removing DB records.
-- Configure pg_cron to call the Edge Function with CRON_CLEANUP_SECRET after deploying it.
-- Example (run only after setting project URL and secret in Supabase Vault):
-- select cron.schedule('nexora-weekly-cleanup', '0 3 * * 0', $$select net.http_post(...);$$);
