import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../models/models.dart';

class ProfileRepository {
  SupabaseClient get _c => SupabaseService.client;

  Future<Profile> get(String id) async {
    final row = await _c.from('profiles').select().eq('id', id).single();
    return Profile.fromJson(row);
  }

  Future<Profile> getMyProfile() => get(SupabaseService.currentUserId!);

  Future<String?> getLocale(String id) async {
    final row = await _c
        .from('profiles')
        .select('locale')
        .eq('id', id)
        .single();
    return row['locale'] as String?;
  }

  Future<void> update(String id, Map<String, dynamic> fields) async {
    fields['updated_at'] = DateTime.now().toIso8601String();
    // RLS restricts this to the owner; passing someone else's id fails at DB level.
    await _c.from('profiles').update(fields).eq('id', id);
  }

  Future<void> setOnline(bool online) async {
    final uid = SupabaseService.currentUserId;
    if (uid == null) return;
    await _c
        .from('profiles')
        .update({
          'is_online': online,
          'last_active': DateTime.now().toIso8601String(),
        })
        .eq('id', uid);
  }

  Future<bool> isUsernameAvailable(String username) async {
    final rows = await _c
        .from('profiles')
        .select('id')
        .eq('username', username.toLowerCase())
        .limit(1);
    return rows.isEmpty;
  }

  Future<UserSettings> getSettings(String userId) async {
    final rows = await _c
        .from('user_settings')
        .select()
        .eq('user_id', userId)
        .limit(1);
    if (rows.isEmpty) return UserSettings(userId: userId);
    return UserSettings.fromJson(rows.first);
  }

  Future<void> saveSettings(UserSettings s) async {
    await _c.from('user_settings').upsert({
      'user_id': s.userId,
      'profile_visibility': s.profileVisibility,
      'message_privacy': s.messagePrivacy,
      'follow_privacy': s.followPrivacy,
      'online_status_visible': s.onlineStatusVisible,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  /// Presence respecting each user's privacy setting (DB-enforced helper).
  Future<Map<String, dynamic>> presenceOf(String userId) async {
    final res = await _c.rpc('profile_status', params: {'p': userId});
    if (res == null) return {'is_online': false, 'last_active': null};
    return Map<String, dynamic>.from(res as Map);
  }
}
