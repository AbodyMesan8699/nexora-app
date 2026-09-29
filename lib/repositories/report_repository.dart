import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

/// Report submissions from the client. RLS allows only inserting rows with
/// reporter_id = auth.uid(); reviewing is admin-only (see AdminRepository).
class ReportRepository {
  SupabaseClient get _c => SupabaseService.client;
  String get _uid => SupabaseService.currentUserId!;

  Future<void> submit({
    required String targetType,
    required String targetId,
    required String reason,
    String? description,
  }) =>
      _c.from('reports').insert({
        'reporter_id': _uid,
        'target_type': targetType,
        'target_id': targetId,
        'reason': reason,
        if (description != null && description.isNotEmpty) 'description': description,
      });
}
