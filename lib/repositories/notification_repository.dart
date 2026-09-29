import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../models/models.dart';

class NotificationRepository {
  SupabaseClient get _c => SupabaseService.client;
  String get _uid => SupabaseService.currentUserId!;

  Future<List<NexNotification>> list({int limit = 30, int offset = 0}) async {
    final rows = await _c
        .from('notifications')
        // notifications has two profile foreign keys (user_id and actor_id).
        // Explicitly select actor_id to avoid PostgREST PGRST201 ambiguity.
        .select('*,profiles!notifications_actor_id_fkey(id,first_name,last_name,username,avatar_url,is_verified,bio,created_at,account_status)')
        .eq('user_id', _uid)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
    return rows
        .map<NexNotification>((r) => NexNotification.fromJson(Map<String, dynamic>.from(r)))
        .toList();
  }

  Future<int> unreadCount() async {
    final rows = await _c
        .from('notifications')
        .select('id')
        .eq('user_id', _uid)
        .eq('is_read', false)
        .limit(99);
    return rows.length;
  }

  Future<void> markAllRead() =>
      _c.from('notifications').update({'is_read': true}).eq('user_id', _uid);

  Future<void> markRead(String id) =>
      _c.from('notifications').update({'is_read': true}).eq('id', id);
}
