import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config.dart';

/// Single Supabase entry point. The client app only ever uses the public
/// anon key — the service-role key never enters the mobile codebase.
class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> init() async {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
      realtimeClientOptions: const RealtimeClientOptions(eventsPerSecond: 4),
    );
  }

  static String? get currentUserId => client.auth.currentUser?.id;

  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  static Future<void> updatePresence(bool online) async {
    final uid = currentUserId;
    if (uid == null) return;
    try {
      await client
          .from('profiles')
          .update({'is_online': online, 'last_active': DateTime.now().toIso8601String()})
          .eq('id', uid);
    } catch (_) {}
  }
}
