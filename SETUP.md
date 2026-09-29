# NEXORA — Setup Guide

**Connect. Share. Discover.**

A global social network built with **Flutter** + **Supabase (PostgreSQL, Auth, Storage, Realtime)**.
Arabic (RTL) and English (LTR) are supported out of the box.

---

## 1. Create the Supabase project

1. Create a project at [supabase.com](https://supabase.com).
2. Open **SQL Editor** and run, in order:
   - `supabase/migrations/0001_init.sql` — tables, indexes, RLS, triggers, RPCs, realtime publication.
   - `supabase/migrations/0002_storage.sql` — storage buckets + storage policies.
   - `supabase/migrations/0003_social_security.sql` — حماية انتقالات طلبات الصداقة.
   - `supabase/migrations/0004_founder_cleanup.sql` — إعدادات التنظيف الإداري.
   - `supabase/migrations/0005_weekly_cleanup.sql` — التنظيف الأسبوعي.
   - `supabase/migrations/0006_post_ownership_and_social_visibility.sql` — إصلاح تعديل/حذف المنشورات والتحقق من الملكية.
   - `supabase/migrations/0007_harden_post_rpc_execute_permissions.sql` — قصر دوال المنشورات على المستخدمين المسجلين.
   - `supabase/migrations/0008_fix_post_media_storage_and_relationship_visibility.sql` — إصلاح bucket الصور والفيديو وقصر الظهور على المتابعين/الأصدقاء.
   - `supabase/migrations/0009_admin_account_status_rpc.sql` — وظائف المدير لإيقاف/استعادة الحسابات عبر RPC محمي.
   - `supabase/migrations/0010_relationship_visibility_and_account_stats.sql` — إحصائيات الحسابات ومنع المنشورات والرسائل دون متابعة أو صداقة.
   - `supabase/migrations/0011_arabic_default_locale.sql` — جعل العربية اللغة الافتراضية.
   - `supabase/migrations/0012_remove_admin_post_visibility_bypass.sql` — إزالة تجاوز صلاحية ظهور منشورات الإدارة.
   - `supabase/migrations/0013_restore_admin_post_moderation_access.sql` — استعادة صلاحية الإشراف الإداري المناسبة.
   - `supabase/migrations/0014_cleanup_secret_service_role_view.sql` — إتاحة تحقق سر التنظيف لدور الخدمة فقط.
3. Enable **Email** auth in *Authentication → Providers* (email confirmation optional; disable it for faster testing or configure SMTP for production).
4. Realtime is already configured for `messages`, `notifications`, `conversations` (the migration adds them to `supabase_realtime` publication).

## 2. Promote an administrator

Admin rights live server-side in `public.admin_roles` — **never** granted by the client.

```sql
insert into public.admin_roles (user_id)
values ('<USER_UUID_OF_ADMIN>');
```

The Flutter admin panel checks `public.is_admin()` through an RPC; a non-admin
cannot read admin data because RLS denies it at the database level.

## 3. Push notifications (optional, Android)

1. Create a Firebase project, add an Android app with package `com.nexora.nexora`, download `google-services.json` into `android/app/`.
2. Deploy the FCM edge function:
   ```bash
   supabase functions deploy push
   supabase secrets set FCM_SERVER_KEY=<server key>
   ```
3. Create the queue + token tables (service-role only, no RLS policies for clients):
   ```sql
   create table public.push_queue (
     id uuid primary key default gen_random_uuid(),
     user_id uuid not null,
     type text not null,
     title text not null,
     body text not null,
     reference_id uuid,
     created_at timestamptz not null default now()
   );
   create table public.device_tokens (
     user_id uuid primary key references public.profiles(id) on delete cascade,
     token text not null,
     updated_at timestamptz not null default now()
   );
   ```
4. Add a database webhook on `push_queue` (INSERT) that calls the `push` function.

## 4. Configure the Flutter app

The app reads its Supabase credentials from `--dart-define` (never hardcode keys, and the service-role key must never ship with the app):

```bash
flutter pub get
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR-PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_PUBLIC_ANON_KEY
```

## 5. Build release APK

```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://YOUR-PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_PUBLIC_ANON_KEY
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

## 6. Security model summary

| Layer | Enforcement |
|---|---|
| Profiles / posts / comments | RLS: read via `can_view_post()` (public / followers / friends / private), write own rows only |
| Messaging | RLS via `in_conversation()` — users can only touch conversations they belong to |
| Notifications / settings | Owner-only RLS |
| Admin | `admin_roles` + `is_admin()` SECURITY DEFINER; no client policy allows writes |
| Storage | Bucket policies: public read for avatars/posts, owner-scoped path prefix `auth.uid()` for writes |
| Blocking | `is_blocked_with()` respected inside feed, comments, follows, and conversation creation |

## 7. Project structure

```
lib/
  core/            config, theme, l10n delegates, error mapping, network monitor
  models/          profile, post, comment, message, story, notification …
  services/        supabase client, storage service, realtime service
  repositories/    all SQL/Supabase queries live here (never in widgets)
  features/        auth, home, profile, posts, comments, friends, messages,
                   notifications, stories, search, settings, admin
```
