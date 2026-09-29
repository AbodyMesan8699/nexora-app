import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../models/models.dart';

class MessageRepository {
  SupabaseClient get _c => SupabaseService.client;
  String get _uid => SupabaseService.currentUserId!;

  /// Starts (or returns the existing) 1:1 conversation. DB function enforces
  /// block rules; returns null when blocked.
  Future<String?> startConversation(String other) async {
    final res = await _c.rpc('start_conversation', params: {'other': other});
    return res as String?;
  }

  Future<List<Conversation>> conversations() async {
    final rows = await _c
        .from('conversation_members')
        .select(
            'conversation_id,last_read_at,'
            'conversations(id,updated_at,'
            'conversation_members(user_id,'
            'profiles(id,first_name,last_name,username,avatar_url,is_verified,bio,created_at,account_status)))')
        .eq('user_id', _uid)
        .order('conversations(updated_at)', ascending: false)
        .limit(50);

    final result = <Conversation>[];
    for (final r in rows) {
      final conv = (r as Map)['conversations'] as Map;
      final members =
          List<Map<String, dynamic>>.from((conv['conversation_members'] as List? ?? []));
      final profiles = members
          .map<Profile>((m) =>
              Profile.fromJson(Map<String, dynamic>.from((m as Map)['profiles'] as Map)))
          .where((p) => p.id != _uid)
          .toList();
      final convId = conv['id'] as String;
      final lastRow = await _c
          .from('messages')
          .select()
          .eq('conversation_id', convId)
          .order('created_at', ascending: false)
          .limit(1);
      final lastMsg = lastRow.isEmpty
          ? null
          : Message.fromJson(Map<String, dynamic>.from(lastRow.first), _uid);
      // unread = messages newer than my last_read_at not sent by me
      final lastRead = r['last_read_at'] as String;
      final unreadRows = await _c
          .from('messages')
          .select('id')
          .eq('conversation_id', convId)
          .neq('sender_id', _uid)
          .gt('created_at', lastRead)
          .limit(50);
      result.add(Conversation(
        id: convId,
        updatedAt: DateTime.parse(conv['updated_at'] as String),
        others: profiles,
        unreadCount: unreadRows.length,
        lastMessage: lastMsg,
      ));
    }
    result.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return result;
  }

  Future<Profile?> otherMember(String conversationId) async {
    final rows = await _c
        .from('conversation_members')
        .select('profiles(id,first_name,last_name,username,avatar_url,is_verified,bio,created_at,account_status)')
        .eq('conversation_id', conversationId)
        .neq('user_id', _uid)
        .limit(1);
    if (rows.isEmpty) return null;
    return Profile.fromJson(
        Map<String, dynamic>.from((rows.first as Map)['profiles'] as Map));
  }

  Future<List<Message>> messages(String conversationId,
      {int limit = 30, DateTime? before}) async {
    var q = _c
        .from('messages')
        .select()
        .eq('conversation_id', conversationId);
    if (before != null) q = q.lt('created_at', before.toIso8601String());
    final rows = List<Map<String, dynamic>>.from(
        await q.order('created_at', ascending: false).limit(limit));
    return rows.map((m) => Message.fromJson(m, _uid)).toList().reversed.toList();
  }

  Future<void> send({
    required String conversationId,
    required String content,
    String type = 'text',
    String? mediaUrl,
  }) =>
      _c.from('messages').insert({
        'conversation_id': conversationId,
        'sender_id': _uid,
        'content': content,
        'message_type': type,
        if (mediaUrl != null) 'media_url': mediaUrl,
      });

  Future<void> edit(String messageId, String content) =>
      _c.from('messages').update({
        'content': content,
        'edited_at': DateTime.now().toIso8601String(),
      }).eq('id', messageId);

  Future<void> delete(String messageId) =>
      _c.from('messages').update({'deleted_at': DateTime.now().toIso8601String()}).eq('id', messageId);

  Future<void> markRead(String conversationId) => _c
      .from('conversation_members')
      .update({'last_read_at': DateTime.now().toIso8601String()})
      .eq('conversation_id', conversationId)
      .eq('user_id', _uid);
}
