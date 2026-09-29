import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../models/models.dart';

class SocialRepository {
  SupabaseClient get _c => SupabaseService.client;
  String get _uid => SupabaseService.currentUserId!;

  // ---------- Follow ----------
  Future<bool> isFollowing(String other) async {
    final r = await _c
        .from('follows')
        .select('follower_id')
        .eq('follower_id', _uid)
        .eq('following_id', other)
        .limit(1);
    return r.isNotEmpty;
  }

  Future<void> follow(String other) =>
      _c.from('follows').insert({'follower_id': _uid, 'following_id': other});

  Future<void> unfollow(String other) => _c
      .from('follows')
      .delete()
      .eq('follower_id', _uid)
      .eq('following_id', other);

  Future<List<int>> counts(String userId) async {
    final results = await Future.wait([
      _c.from('follows').select('follower_id').eq('following_id', userId).limit(500),
      _c.from('follows').select('following_id').eq('follower_id', userId).limit(500),
      _c.from('friendships').select('id').or('user_a.eq.$userId,user_b.eq.$userId').limit(500),
    ]);
    return [(results[0] as List).length, (results[1] as List).length, (results[2] as List).length];
  }

  Future<List<Profile>> followers(String userId) async {
    final rows = await _c
        .from('follows')
        .select('profiles!follows_follower_id_fkey(*)')
        .eq('following_id', userId)
        .limit(50);
    return rows
        .map<Profile>((r) =>
            Profile.fromJson(Map<String, dynamic>.from((r as Map)['profiles'] as Map)))
        .toList();
  }

  Future<List<Profile>> following(String userId) async {
    final rows = await _c
        .from('follows')
        .select('profiles!follows_following_id_fkey(*)')
        .eq('follower_id', userId)
        .limit(50);
    return rows
        .map<Profile>((r) =>
            Profile.fromJson(Map<String, dynamic>.from((r as Map)['profiles'] as Map)))
        .toList();
  }

  // ---------- Friend requests / friendships ----------
  Future<FriendRequestState?> requestStatus(String other) async {
    final rows = await Future.wait([
      _c.from('friend_requests').select('id,status,sender_id,receiver_id')
          .eq('sender_id', _uid).eq('receiver_id', other)
          .neq('status', 'declined').order('created_at', ascending: false).limit(1),
      _c.from('friend_requests').select('id,status,sender_id,receiver_id')
          .eq('sender_id', other).eq('receiver_id', _uid)
          .neq('status', 'declined').order('created_at', ascending: false).limit(1),
    ]);
    final candidates = [
      ...(rows[0] as List),
      ...(rows[1] as List),
    ];
    if (candidates.isEmpty) return null;
    final row = Map<String, dynamic>.from(candidates.first as Map);
    return FriendRequestState(id: row['id'] as String, status: row['status'] as String, sentByMe: row['sender_id'] == _uid);
  }

  Future<FriendRequestState> sendFriendRequest(String other) async {
    final row = await _c.from('friend_requests')
        .insert({'sender_id': _uid, 'receiver_id': other})
        .select('id,status,sender_id,receiver_id')
        .single();
    return FriendRequestState(
      id: row['id'] as String,
      status: row['status'] as String,
      sentByMe: row['sender_id'] == _uid,
    );
  }

  Future<void> cancelFriendRequest(String requestId) =>
      _c.from('friend_requests').delete().eq('id', requestId).eq('sender_id', _uid);

  Future<void> acceptFriendRequest(String requestId) async {
    final row = await _c
        .from('friend_requests')
        .select('sender_id,receiver_id')
        .eq('id', requestId)
        .single();
    final a = row['sender_id'] as String;
    final b = row['receiver_id'] as String;
    await _c.from('friend_requests').update({'status': 'accepted'}).eq('id', requestId);
    await _c.from('friendships').insert({
      'user_a': a.compareTo(b) < 0 ? a : b,
      'user_b': a.compareTo(b) < 0 ? b : a,
    });
  }

  Future<void> declineFriendRequest(String requestId) =>
      _c.from('friend_requests').update({'status': 'declined'}).eq('id', requestId);

  Future<void> removeFriend(String other) async {
    final lo = _uid.compareTo(other) < 0 ? _uid : other;
    final hi = _uid.compareTo(other) < 0 ? other : _uid;
    await _c.from('friendships').delete().eq('user_a', lo).eq('user_b', hi);
  }

  Future<bool> isFriend(String other) async {
    final lo = _uid.compareTo(other) < 0 ? _uid : other;
    final hi = _uid.compareTo(other) < 0 ? other : _uid;
    final r = await _c
        .from('friendships')
        .select('id')
        .eq('user_a', lo)
        .eq('user_b', hi)
        .limit(1);
    return r.isNotEmpty;
  }

  Future<List<Profile>> friends() async {
    final rows = await _c
        .from('friendships')
        .select('user_a,user_b')
        .or('user_a.eq.$_uid,user_b.eq.$_uid')
        .limit(100);
    final ids = <String>[];
    for (final r in rows) {
      final m = r as Map;
      ids.add(m['user_a'] == _uid ? m['user_b'] as String : m['user_a'] as String);
    }
    if (ids.isEmpty) return [];
    final profiles = await _c.from('profiles').select().inFilter('id', ids);
    return profiles
        .map<Profile>((p) => Profile.fromJson(Map<String, dynamic>.from(p)))
        .toList();
  }

  Future<List<FriendRequest>> pendingRequests() async {
    final rows = await _c
        .from('friend_requests')
        .select('id,created_at,profiles!friend_requests_sender_id_fkey(*)')
        .eq('receiver_id', _uid)
        .eq('status', 'pending')
        .order('created_at', ascending: false)
        .limit(50);
    return rows
        .map<FriendRequest>((r) => FriendRequest.fromJson(Map<String, dynamic>.from(r)))
        .toList();
  }

  // ---------- Blocking ----------
  Future<bool> amIBlockedByOrBlocking(String other) async {
    final rows = await _c
        .from('blocks')
        .select('blocker_id,blocked_id')
        .or('blocker_id.eq.$_uid,blocked_id.eq.$_uid')
        .or('blocker_id.eq.$other,blocked_id.eq.$other')
        .limit(1);
    // rows may include unrelated pairs; filter client-side precisely:
    return rows.any((r) {
      final m = r as Map;
      final pair = {m['blocker_id'] as String, m['blocked_id'] as String};
      return pair.contains(_uid) && pair.contains(other);
    });
  }

  Future<void> block(String other) async {
    await _c.from('blocks').upsert(
      {'blocker_id': _uid, 'blocked_id': other},
      onConflict: 'blocker_id,blocked_id',
      ignoreDuplicates: true,
    );
  }

  Future<void> unblock(String other) =>
      _c.from('blocks').delete().eq('blocker_id', _uid).eq('blocked_id', other);

  Future<List<Profile>> blockedList() async {
    final rows = await _c
        .from('blocks')
        .select('profiles!blocks_blocked_id_fkey(*)')
        .eq('blocker_id', _uid)
        .limit(100);
    return rows
        .map<Profile>((r) =>
            Profile.fromJson(Map<String, dynamic>.from((r as Map)['profiles'] as Map)))
        .toList();
  }
}

class FriendRequestState {
  final String id;
  final String status;
  final bool sentByMe;

  const FriendRequestState({required this.id, required this.status, required this.sentByMe});
  bool get isPending => status == 'pending';
}
