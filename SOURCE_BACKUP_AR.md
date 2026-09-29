# نسخة مصدر NEXORA — تعليمات الحفظ

تحتوي هذه النسخة على مصدر Flutter، وموارد Android، والاختبارات، وملفات Supabase Functions وmigrations، وملفات الترجمة.

## الإعدادات المحفوظة

- إعداد المشروع محفوظ في `supabase.public.json` ويشير إلى مشروع Supabase الأصلي `kqpkhtmckrmvkigldbky`.
- حافظ على `SUPABASE_URL` و`anon_key` كما هما؛ لا تستبدلهما بمشروع آخر.
- المفتاح الموجود هو المفتاح العام `anon_key` المخصص لتطبيق العميل. **لا تضف أبدًا** مفتاح `service_role` أو سر cron إلى التطبيق أو إلى ملف عام.
- أسرار Edge Functions تبقى في إعدادات Supabase الخادمية، ولا يتضمنها أرشيف المصدر.

## إعادة البناء على جهاز جديد

1. ثبّت Flutter وAndroid SDK وJDK المتوافقة مع المشروع.
2. من مجلد المشروع شغّل `flutter pub get`.
3. اقرأ عنوان Supabase والمفتاح العام من `supabase.public.json`، ثم ابنِ APK ‏ARM64:

```bash
flutter build apk --release --target-platform android-arm64 \
  --dart-define=SUPABASE_URL='<القيمة المحفوظة في supabase.public.json>' \
  --dart-define=SUPABASE_ANON_KEY='<anon_key المحفوظ في supabase.public.json>'
```

4. يوجد المخرج عادةً في `build/app/outputs/flutter-apk/app-release.apk`.

## قاعدة البيانات والتنظيف

- ملفات migrations مرتبة في `supabase/migrations/` من `0001` حتى `0014`.
- وظيفة التنظيف موجودة في `supabase/functions/cleanup-expired-posts/index.ts`؛ تحذف ملفات Storage أولًا، وتبقي سجل المنشور قابلًا لإعادة المحاولة إذا فشل حذف ملف.
- لا تضع أسرار الإنتاج في ملفات المصدر. إعدادات السر الخاص تُدار خادميًا في Supabase.

## ما استُبعد من الأرشيف

استُبعدت مجلدات `build/` و`.dart_tool/` وملفات كاش Gradle وملفات السجل والمخرجات المولدة؛ يعيد Flutter وGradle إنشاءها عند الحاجة.
