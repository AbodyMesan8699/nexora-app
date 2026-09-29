# NEXORA

تطبيق اجتماعي مبني بـ Flutter يتيح مشاركة المنشورات والتفاعل واكتشاف الحسابات والتواصل داخل التطبيق.

## المصدر والإعداد

- إعداد Flutter وSupabase: [SETUP.md](SETUP.md)
- آلية تحديث Android عبر GitHub Releases والتوقيع: [GITHUB_UPDATES_AR.md](GITHUB_UPDATES_AR.md)
- إعداد Supabase المرفق هو إعداد عميل عام (`anon_key`) للمشروع المحدد؛ لا تضع مفتاح `service_role` أو أي سر خاص في التطبيق أو المستودع.

## بناء Android ARM64

```bash
flutter pub get
flutter test
flutter build apk --release --target-platform android-arm64 --split-per-abi
```

استخدم الملف `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`. توقيع إصدار النشر يعتمد على `android/key.properties` المحلي غير المتعقب بواسطة Git؛ راجع دليل التحديثات قبل إنشاء إصدار للمستخدمين.
