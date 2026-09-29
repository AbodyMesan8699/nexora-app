import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../models/models.dart';

class StoryRepository {
  SupabaseClient get _c => SupabaseService.client;
  String get _uid => SupabaseService.currentUserId!;

  /// Active (non-expired) stories from me + people I follow. RLS also
  /// filters expiration server-side.
  Future<List<Story>> active() async {
    final followingRows = await _c
        .from('follows')
        .select('following_id')
        .eq('follower_id', _uid)
        .limit(200);
    final ids = [for (final r in followingRows) (r as Map)['following_id'] as String];
    ids.add(_uid);
    final rows = await _c
        .from('stories')
        .select('*,profiles!stories_user_id_fkey(id,first_name,last_name,username,avatar_url,is_verified),'
                'story_views(user_id)')
        .gt('expires_at', DateTime.now().toIso8601String())
        .inFilter('user_id', ids)
        .order('created_at', ascending: true)
        .limit(100);
    return rows.map<Story>((r) => Story.fromJson(Map<String, dynamic>.from(r), _uid)).toList();
  }

  Future<List<Story>> mine() async {
    final rows = await _c
        .from('stories')
        .select('*,profiles!stories_user_id_fkey(id,first_name,last_name,username,avatar_url,is_verified),'
                'story_views(user_id)')
        .eq('user_id', _uid)
        .gt('expires_at', DateTime.now().toIso8601String())
        .order('created_at', ascending: false);
    return rows.map<Story>((r) => Story.fromJson(Map<String, dynamic>.from(r), _uid)).toList();
  }

  Future<String> createText(String content) async {
    final res = await _c
        .from('stories')
        .insert({'user_id': _uid, 'content': content})
        .select('id')
        .single();
    return res['id'] as String;
  }

  Future<void> createMedia({required String mediaUrl, required String type, String? content}) =>
      _c.from('stories').insert({
        'user_id': _uid,
        'media_url': mediaUrl,
        'media_type': type,
        if (content != null && content.isNotEmpty) 'content': content,
      });

  Future<void> delete(String id) => _c.from('stories').delete().eq('id', id);

  Future<void> view(String storyId) => _c.from('story_views').upsert({
        'story_id': storyId,
        'user_id': _uid,
        'viewed_at': DateTime.now().toIso8601String(),
      });

  Future<int> viewerCount(String storyId) async {
    final rows = await _c
        .from('story_views')
        .select('user_id')
        .eq('story_id', storyId)
        .limit(500);
    return rows.length;
  }
}
