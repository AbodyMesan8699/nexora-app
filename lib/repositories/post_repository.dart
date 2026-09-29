import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../services/storage_service.dart';
import '../models/models.dart';

class PostRepository {
  SupabaseClient get _c => SupabaseService.client;
  String get _uid => SupabaseService.currentUserId!;

  static const _select =
      'id,user_id,content,location,feeling,visibility,created_at,updated_at,'
      'profiles!posts_user_id_fkey(id,first_name,last_name,username,avatar_url,is_verified,bio,created_at,account_status),'
      'post_media(id,media_url,media_type,thumbnail_url),'
      'post_likes(user_id),'
      'comments(count),'
      'shares(count),'
      'saved_posts(user_id)';

  /// Cursor pagination by created_at — never loads the whole feed.
  /// Cursor pagination by created_at — never loads the whole feed.
  /// Visibility is enforced by the posts_select RLS policy (can_view_post).
  Future<List<Post>> feed({int limit = 10, DateTime? before}) async {
    var q = _c.from('posts').select(_select).eq('is_deleted', false);
    if (before != null) q = q.lt('created_at', before.toIso8601String());
    final rows = await q.order('created_at', ascending: false).limit(limit);
    return _hydrate(List<Map<String, dynamic>>.from(rows));
  }

  Future<List<Post>> userPosts(
    String userId, {
    int limit = 10,
    DateTime? before,
  }) async {
    var q = _c
        .from('posts')
        .select(_select)
        .eq('user_id', userId)
        .eq('is_deleted', false);
    if (before != null) q = q.lt('created_at', before.toIso8601String());
    final rows = await q.order('created_at', ascending: false).limit(limit);
    return _hydrate(List<Map<String, dynamic>>.from(rows));
  }

  Future<List<Post>> savedPosts({int limit = 10, DateTime? before}) async {
    var q = _c
        .from('saved_posts')
        .select('created_at,posts($_select)')
        .eq('user_id', _uid);
    if (before != null) q = q.lt('created_at', before.toIso8601String());
    final rows = List<Map<String, dynamic>>.from(
      await q.order('created_at', ascending: false).limit(limit),
    );
    return rows
        .map(
          (r) =>
              Post.fromJson(Map<String, dynamic>.from(r['posts'] as Map), _uid),
        )
        .toList();
  }

  Future<Post> byId(String id) async {
    final row = await _c.from('posts').select(_select).eq('id', id).single();
    final list = await _hydrate([row]);
    return list.first;
  }

  Future<List<Post>> _hydrate(List<Map<String, dynamic>> rows) async {
    if (rows.isEmpty) return [];
    final posts = rows.map((r) => Post.fromJson(r, _uid)).toList();
    // Batch like/save state for my own user in one query to minimize round-trips.
    final ids = posts.map((p) => p.id).toList();
    final mine = await _c
        .from('post_likes')
        .select('post_id')
        .eq('user_id', _uid)
        .inFilter('post_id', ids);
    final liked = (mine as List)
        .map((r) => (r as Map)['post_id'] as String)
        .toSet();
    return posts.map((p) => p.copyWith(isLiked: liked.contains(p.id))).toList();
  }

  Future<String> create({
    required String content,
    String? location,
    String? feeling,
    String visibility = 'public',
    List<File> images = const [],
    File? video,
  }) async {
    final res = await _c
        .from('posts')
        .insert({
          'user_id': _uid,
          'content': content,
          'location': location,
          'feeling': feeling,
          'visibility': visibility,
        })
        .select('id')
        .single();
    final postId = res['id'] as String;

    final media = <Map<String, dynamic>>[];
    for (final f in images) {
      final url = await StorageService.upload(
        file: f,
        bucket: 'post-media',
        ext: f.path.split('.').last.toLowerCase(),
      );
      media.add({'post_id': postId, 'media_url': url, 'media_type': 'image'});
    }
    if (video != null) {
      final url = await StorageService.upload(
        file: video,
        bucket: 'post-media',
        ext: video.path.split('.').last.toLowerCase(),
      );
      media.add({'post_id': postId, 'media_url': url, 'media_type': 'video'});
    }
    if (media.isNotEmpty) await _c.from('post_media').insert(media);
    return postId;
  }

  Future<void> update(String id, {String? content, String? visibility}) async {
    // The RPC performs an explicit owner check and reports a failure instead
    // of allowing a production RLS mismatch to look like a successful update.
    final result = await _c.rpc(
      'update_post',
      params: {
        'p_post_id': id,
        'p_content': content,
        'p_visibility': visibility,
      },
    );
    if (result != true) throw Exception('post update was not applied');
  }

  Future<void> delete(String id) async {
    // Soft-delete keeps referential integrity for media/comments while the
    // database function guarantees that only the author can delete.
    final result = await _c.rpc('delete_post', params: {'p_post_id': id});
    if (result != true) throw Exception('post delete was not applied');
  }

  Future<void> like(String postId) async {
    try {
      await _c.from('post_likes').insert({'post_id': postId, 'user_id': _uid});
    } catch (_) {
      await _c
          .from('post_likes')
          .delete()
          .eq('post_id', postId)
          .eq('user_id', _uid);
    }
  }

  Future<void> save(String postId) async {
    try {
      await _c.from('saved_posts').insert({'post_id': postId, 'user_id': _uid});
    } catch (_) {
      await _c
          .from('saved_posts')
          .delete()
          .eq('post_id', postId)
          .eq('user_id', _uid);
    }
  }

  Future<void> share(String postId) =>
      _c.from('shares').insert({'post_id': postId, 'user_id': _uid});
}

extension _PostX on Post {
  Post copyWith({bool? isLiked, bool? isSaved}) => Post(
    id: id,
    userId: userId,
    user: user,
    content: content,
    location: location,
    feeling: feeling,
    visibility: visibility,
    createdAt: createdAt,
    isLiked: isLiked ?? this.isLiked,
    isSaved: isSaved ?? this.isSaved,
    isMine: isMine,
    likeCount: likeCount,
    commentCount: commentCount,
    shareCount: shareCount,
    media: media,
  );
}
