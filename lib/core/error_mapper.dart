import 'package:flutter/foundation.dart';
import '../l10n_gen/app_localizations.dart';

/// Maps backend/technical exceptions to friendly, localized messages.
/// Raw PostgreSQL / Supabase errors are NEVER shown to the user.
String friendlyError(Object error, AppLocalizations l) {
  debugPrint('[Nexora error] ${error.runtimeType}: $error');
  final s = error.toString().toLowerCase();
  if (s.contains('password') && (s.contains('weak') || s.contains('at least'))) {
    return 'كلمة المرور ضعيفة أو قصيرة. استخدم 8 أحرف على الأقل.';
  }
  if (s.contains('email') && (s.contains('invalid') || s.contains('format'))) {
    return 'صيغة البريد الإلكتروني غير صحيحة.';
  }
  if (s.contains('email provider') || s.contains('signups not allowed')) {
    return 'التسجيل بالبريد الإلكتروني غير مفعّل في الخادم حاليًا.';
  }
  if (s.contains('user already registered') || s.contains('already registered')) {
    return 'هذا البريد مسجل مسبقًا. استخدم تسجيل الدخول أو استعادة كلمة المرور.';
  }
  if (s.contains('database error') || s.contains('trigger') || s.contains('postgres')) {
    return 'تعذر حفظ ملف الحساب في قاعدة البيانات. حاول مرة أخرى بعد قليل.';
  }
  if (s.contains('socket') ||
      s.contains('connection') ||
      s.contains('timeout') ||
      s.contains('network')) {
    return l.errorNetwork;
  }
  if (s.contains('invalid login credentials') ||
      s.contains('email not confirmed') ||
      s.contains('invalid_credentials')) {
    return l.errorAuth;
  }
  if (s.contains('duplicate key') || s.contains('already')) {
    return l.errorGeneric;
  }
  if (s.contains('row-level security') || s.contains('permission')) {
    return l.errorGeneric;
  }
  return l.errorGeneric;
}

/// Technical detail for logs/debugging only — never rendered in the UI.
String debugDetail(Object error) => error.toString();
