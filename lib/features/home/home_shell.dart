import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../l10n_gen/app_localizations.dart';
import '../../models/models.dart';
import '../../repositories/notification_repository.dart';
import '../../services/realtime_service.dart';
import '../../services/supabase_service.dart';
import '../../state/app_state.dart';
import '../discover/discover_screen.dart';
import '../feed/feed_screen.dart';
import '../messages/conversations_screen.dart';
import '../profile/profile_screen.dart';
import '../notifications/notifications_screen.dart';
import '../posts/create_post_screen.dart';

/// Main navigation: Home / Discover / Create / Notifications / Messages / Profile.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  StreamSubscription? _notifSub;

  @override
  void initState() {
    super.initState();
    AppState().loadMe();
    _refreshUnread();
    _notifSub = RealtimeService()
        .notificationEvents
        .listen((_) => _refreshUnread());
    RealtimeService().subscribeNotifications((row) => _refreshUnread());
    SupabasePresence.setOnline(true);
  }

  Future<void> _refreshUnread() async {
    try {
      final n = await NotificationRepository().unreadCount();
      if (mounted) {
        AppState().unreadNotifications = n;
        AppState().notifyListeners();
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _notifSub?.cancel();
    RealtimeService().unsubscribeNotifications();
    SupabasePresence.setOnline(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final pages = [
      const FeedScreen(),
      const DiscoverScreen(),
      null, // create opens a route
      const NotificationsScreen(),
      const ConversationsScreen(),
      const ProfileScreen(),
    ];
    return Scaffold(
      body: IndexedStack(
        index: _index == 2 ? 0 : _index,
        children: [
          pages[0]!,
          pages[1]!,
          pages[0]!,
          pages[3]!,
          pages[4]!,
          pages[5]!,
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          if (i == 2) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const CreatePostScreen()));
            return;
          }
          setState(() => _index = i);
          if (i == 3) _refreshUnread();
        },
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: l.home),
          NavigationDestination(icon: const Icon(Icons.explore_outlined), selectedIcon: const Icon(Icons.explore), label: l.discover),
          NavigationDestination(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  gradient: NexTheme.accentGradient,
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.add, color: Colors.black, size: 22),
            ),
            label: l.create,
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: AppState().unreadNotifications > 0,
              label: Text('${AppState().unreadNotifications}'),
              child: const Icon(Icons.notifications_outlined),
            ),
            selectedIcon: const Icon(Icons.notifications),
            label: l.notifications,
          ),
          NavigationDestination(icon: const Icon(Icons.chat_bubble_outline), selectedIcon: const Icon(Icons.chat_bubble), label: l.messages),
          NavigationDestination(icon: const Icon(Icons.person_outline), selectedIcon: const Icon(Icons.person), label: l.profile),
        ],
      ),
    );
  }
}
