# Founder cleanup setup

The founder cleanup system is active in the Nexora Supabase project.

## Active server configuration

- Migration `0004_founder_cleanup` is applied.
- Migration `0005_weekly_cleanup` is applied.
- Founder role is assigned to the existing Auth user whose email is `newalhaqli@gmail.com`.
- Default retention is enabled at 7 days.
- Edge Function `cleanup-expired-posts` is deployed and active.
- `pg_cron` job `nexora-weekly-cleanup` is active with schedule `0 3 * * 0` (weekly, Sunday at 03:00, database timezone).
- A random 64-character secret is generated server-side in `private.private_cleanup_config`. It is not embedded in the APK, not printed in logs, and not exposed to client users. The cron request reads it internally and sends it as `x-cron-secret`.

## Rotation

To rotate the secret without revealing it, run this only in the Supabase SQL Editor:

```sql
update private.private_cleanup_config
set secret = encode(gen_random_bytes(32), 'hex')
where id = true;
```

The weekly job automatically reads the new value on its next run. No APK rebuild is required.

## Application

The APK contains the founder dashboard, settings, manual cleanup confirmation, and cleanup log viewer. Manual cleanup is authorized by `admin_roles`; scheduled cleanup is authorized by the private server-side secret. The Service Role key is available only to the Edge Function runtime and is never included in the mobile app.
