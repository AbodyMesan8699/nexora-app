import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../models/models.dart';

/// Global search (users / usernames / posts) with ILIKE + trigram-friendly
/// prefixes, server-side limits and pagination — never a full-table scan.
class SearchRepository {
  SupabaseClient get _c => SupabaseService.client;
  String get _uid => SupabaseService.currentUserId!;

  Future<List<Profile>> users(String query, {int limit = 20, int offset = 0}) async {
    final q = query.trim();
    if (q.isEmpty) return [];
    final rows = await _c
        .from('profiles')
        .select('id,first_name,last_name,username,avatar_url,is_verified,bio,created_at,account_status')
        .or('username.ilike.$q%,first_name.ilike.$q%,last_name.ilike.$q%,'
            'first_name.ilike.%$q%,last_name.ilike.%$q%')
        .neq('id', _uid)
        .range(offset, offset + limit - 1);
    return rows.map<Profile>((r) => Profile.fromJson(Map<String, dynamic>.from(r))).toList();
  }

  Future<List<Post>> posts(String query, {int limit = 20, int offset = 0}) async {
    final q = query.trim();
    if (q.isEmpty) return [];
    final rows = await _c
        .from('posts')
        .select('id,user_id,content,location,feeling,visibility,created_at,'
                'profiles!posts_user_id_fkey(id,first_name,last_name,username,avatar_url,is_verified,created_at,account_status),'
                'post_media(id,media_url,media_type,thumbnail_url)')
        .ilike('content', '%$q%')
        .eq('visibility', 'public')
        .eq('is_deleted', false)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
    return rows
        .map<Post>((r) => Post.fromJson(Map<String, dynamic>.from(r), _uid))
        .toList();
  }
}
