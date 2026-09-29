import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../models/models.dart';

class CommentRepository {
  SupabaseClient get _c => SupabaseService.client;
  String get _uid => SupabaseService.currentUserId!;

  Future<List<Comment>> list(String postId, {int limit = 20, DateTime? before}) async {
    var q = _c
        .from('comments')
        .select('id,post_id,parent_id,user_id,content,created_at,'
                'profiles!comments_user_id_fkey(id,first_name,last_name,username,avatar_url,is_verified),'
                'comment_likes(user_id)')
        .eq('post_id', postId)
        .eq('is_deleted', false);
    if (before != null) q = q.lt('created_at', before.toIso8601String());
    final rows = await q.order('created_at', ascending: false).limit(limit);
    return rows
        .map<Comment>((r) => Comment.fromJson(Map<String, dynamic>.from(r), _uid))
        .toList();
  }

  Future<void> create({required String postId, String? parentId, required String content}) =>
      _c.from('comments').insert({
        'post_id': postId,
        'user_id': _uid,
        if (parentId != null) 'parent_id': parentId,
        'content': content,
      });

  Future<void> delete(String id) async {
    // RLS: delete own comment; admins may delete any via their policy.
    await _c.from('comments').update({'is_deleted': true}).eq('id', id);
  }

  Future<void> like(String commentId) async {
    try {
      await _c.from('comment_likes').insert({'comment_id': commentId, 'user_id': _uid});
    } catch (_) {
      await _c
          .from('comment_likes')
          .delete()
          .eq('comment_id', commentId)
          .eq('user_id', _uid);
    }
  }
}
