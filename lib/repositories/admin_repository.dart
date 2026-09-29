import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../models/models.dart';

class ReportRepository {
  SupabaseClient get _c => SupabaseService.client;
  String get _uid => SupabaseService.currentUserId!;

  Future<void> submit({
    required String targetType,
    required String targetId,
    required String reason,
    String? description,
  }) => _c.from('reports').insert({
    'reporter_id': _uid,
    'target_type': targetType,
    'target_id': targetId,
    'reason': reason,
    if (description != null && description.isNotEmpty)
      'description': description,
  });
}

/// Admin operations. Every call below relies on RLS + is_admin(); a
/// non-admin simply gets an empty/denied result — never trusted client-side.
class AdminRepository {
  SupabaseClient get _c => SupabaseService.client;

  Future<bool> isAdmin() async {
    try {
      final res = await _c.rpc('is_admin');
      return res == true;
    } catch (_) {
      return false;
    }
  }

  Future<AdminStats?> stats() async {
    final res = await _c.rpc('admin_stats');
    if (res == null) return null;
    return AdminStats.fromJson(Map<String, dynamic>.from(res as Map));
  }

  Future<List<Report>> pendingReports() async {
    final rows = await _c
        .from('reports')
        .select()
        .inFilter('status', ['pending'])
        .order('created_at', ascending: true)
        .limit(50);
    return rows
        .map<Report>((r) => Report.fromJson(Map<String, dynamic>.from(r)))
        .toList();
  }

  Future<List<Report>> reviewedReports() async {
    final rows = await _c
        .from('reports')
        .select()
        .inFilter('status', ['reviewed', 'dismissed', 'actioned'])
        .order('reviewed_at', ascending: false)
        .limit(50);
    return rows
        .map<Report>((r) => Report.fromJson(Map<String, dynamic>.from(r)))
        .toList();
  }

  Future<void> reviewReport(String id, String status) => _c
      .from('reports')
      .update({
        'status': status,
        'reviewed_at': DateTime.now().toIso8601String(),
        'reviewed_by': SupabaseService.currentUserId,
      })
      .eq('id', id);

  Future<void> deletePost(String id) =>
      _c.from('posts').update({'is_deleted': true}).eq('id', id);

  Future<void> deleteComment(String id) =>
      _c.from('comments').update({'is_deleted': true}).eq('id', id);

  Future<void> setAccountStatus(String userId, String status) => _c.rpc(
    'admin_set_account_status',
    params: {'p_user_id': userId, 'p_status': status},
  );

  Future<List<Map<String, dynamic>>> recentUsers() async {
    final rows = await _c
        .from('profiles')
        .select('id,first_name,last_name,username,account_status,created_at')
        .order('created_at', ascending: false)
        .limit(20);
    return List<Map<String, dynamic>>.from(rows);
  }

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final builder = _c
        .from('profiles')
        .select(
          'id,first_name,last_name,username,email,account_status,created_at',
        );
    final q = query.trim();
    final filtered = q.isEmpty
        ? builder
        : builder.or(
            'first_name.ilike.%$q%,last_name.ilike.%$q%,username.ilike.%$q%,email.ilike.%$q%',
          );
    final rows = await filtered
        .order('created_at', ascending: false)
        .limit(100);
    return List<Map<String, dynamic>>.from(rows);
  }

  Future<Map<String, dynamic>?> cleanupSettings() async {
    final res = await _c.rpc('get_cleanup_settings');
    return res == null ? null : Map<String, dynamic>.from(res as Map);
  }

  Future<void> updateCleanupSettings({
    required bool enabled,
    required int retentionDays,
  }) async {
    await _c.rpc(
      'update_cleanup_settings',
      params: {
        'p_enabled': enabled,
        'p_retention_days': retentionDays,
        'p_weekly_day': 0,
        'p_weekly_hour': 3,
      },
    );
  }

  Future<Map<String, dynamic>> runCleanup() async {
    final res = await _c.functions.invoke('cleanup-expired-posts', body: {});
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<List<Map<String, dynamic>>> cleanupLogs() async {
    final rows = await _c
        .from('cleanup_logs')
        .select()
        .order('executed_at', ascending: false)
        .limit(10);
    return List<Map<String, dynamic>>.from(rows);
  }
}
