# Nexora — Development Handoff

## الوضع الحالي

هذا مشروع Flutter كامل لتطبيق Nexora مربوط بمشروع Supabase التالي:

- **Supabase URL:** `https://kqpkhtmckrmvkigldbky.supabase.co`
- **Project ref:** `kqpkhtmckrmvkigldbky`
- **Public anon key:** موجود في `supabase.public.json` ويمكن تضمينه في تطبيق العميل.

تم إصلاح خطأ الإشعارات `PGRST201` الناتج عن وجود علاقتين بين `notifications` و`profiles`. يجب استخدام العلاقة الصريحة:

```dart
profiles!notifications_actor_id_fkey(...)
```

## التشغيل والبناء

```bash
flutter pub get
flutter run \
  --dart-define=SUPABASE_URL=https://kqpkhtmckrmvkigldbky.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=$(python3 -c "import json;print(json.load(open('supabase.public.json'))['anon_key'])")
```

لبناء APK ARM64:

```bash
flutter build apk --release --split-per-abi \
  --dart-define=SUPABASE_URL=https://kqpkhtmckrmvkigldbky.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<PUBLIC_ANON_KEY>
```

الناتج يكون في:

```text
build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

## تعليمات مهمة لأي أداة تطوير

لا تسأل عن مصدر المشروع أو الملف المضغوط. اعتبر هذا المجلد هو المصدر الكامل، وابدأ مباشرةً من `lib/main.dart` وملفات `lib/repositories/` و`supabase/migrations/`. قبل أي تعديل:

1. شغّل `flutter pub get`.
2. افحص اتصال Supabase باستخدام القيم الموجودة في `supabase.public.json`.
3. لا تستبدل المفتاح العام بمفتاح آخر.
4. لا تستخدم أي `service_role` أو `sb_secret` داخل APK أو Git أو الواجهة الأمامية.
5. بعد التعديل شغّل `flutter analyze` ثم ابنِ APK ARM64.
6. اختبر تسجيل الدخول، الخلاصة، الإشعارات، البحث، الملف الشخصي، الرسائل، وإنشاء منشور.
7. عند وجود علاقات Supabase متعددة، استخدم اسم foreign key صراحةً في `select` مثل `profiles!notifications_actor_id_fkey(...)`.

## قاعدة البيانات والمالك

لتعيين الحساب المالك، شغّل الملف `supabase/owner_assignment.sql` من SQL Editor في Supabase. هذا الملف لا يحتوي على أي مفتاح سري.

## الأمان

مفتاح `anon`/`publishable` مصمم للاستخدام في تطبيقات العميل مع RLS. أما `service_role` و`sb_secret` فهما مفاتيح إدارية حساسة ولا ينبغي إرسالها إلى أدوات التطوير العامة أو وضعها داخل التطبيق. إذا احتاجت أداة إلى صلاحيات إدارية، استخدم Edge Function أو متغيرًا سريًا في خادم خاص.
