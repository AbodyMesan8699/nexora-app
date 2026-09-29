-- Enable the already-deployed cleanup function with an internal secret.
-- The secret is generated and stored server-side; it is never put in the APK or shown in logs.
create schema if not exists private;
create table if not exists private.private_cleanup_config (
  id boolean primary key default true check (id = true),
  secret text not null
);
insert into private.private_cleanup_config(id, secret)
values (true, encode(gen_random_bytes(32), 'hex'))
on conflict (id) do nothing;
revoke all on schema private from public;
revoke all on private.private_cleanup_config from public;
grant usage on schema private to service_role;
grant select on private.private_cleanup_config to service_role;
create extension if not exists pg_net with schema extensions;
create extension if not exists pg_cron with schema extensions;
do $$
begin
  if exists (select 1 from cron.job where jobname = 'nexora-weekly-cleanup') then
    perform cron.unschedule('nexora-weekly-cleanup');
  end if;
end $$;
select cron.schedule(
  'nexora-weekly-cleanup',
  '0 3 * * 0',
  $$select net.http_post(
    url := 'https://kqpkhtmckrmvkigldbky.supabase.co/functions/v1/cleanup-expired-posts',
    headers := jsonb_build_object('Content-Type','application/json','x-cron-secret',(select secret from private.private_cleanup_config where id=true)),
    body := '{}'::jsonb
  );$$
);
