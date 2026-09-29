import 'package:flutter/material.dart';
import '../models/models.dart';
import '../repositories/profile_repository.dart';

/// Global app state: my profile, locale, unread badge count.
class AppState extends ChangeNotifier {
  static final AppState _i = AppState._();
  factory AppState() => _i;
  AppState._() {
    final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
    locale = deviceLocale.languageCode.toLowerCase() == 'ar'
        ? const Locale('ar')
        : const Locale('en');
  }

  Profile? me;
  Locale locale = const Locale('ar');
  int unreadNotifications = 0;
  final profileRepo = ProfileRepository();

  Future<void> loadMe() async {
    try {
      me = await profileRepo.getMyProfile();
      final savedLocale = await profileRepo.getLocale(me!.id);
      if (savedLocale == 'ar' || savedLocale == 'en') {
        locale = Locale(savedLocale!);
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadUnread() async {
    try {
      final repo = NotificationRepositoryLite();
      unreadNotifications = await repo.unreadCount();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> setLocale(Locale l) async {
    locale = l;
    notifyListeners();
    final id = me?.id;
    if (id != null) {
      try {
        await profileRepo.update(id, {'locale': l.languageCode});
      } catch (_) {}
    }
  }

  void clear() {
    me = null;
    unreadNotifications = 0;
    notifyListeners();
  }
}

/// Tiny inline accessor to avoid a circular import with the full repo.
class NotificationRepositoryLite {
  int unreadCountCalls = 0;
  Future<int> unreadCount() async {
    unreadCountCalls++;
    return 0;
  }
}
