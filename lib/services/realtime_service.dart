import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Central Realtime management (messages + notifications channels).
class RealtimeService {
  static final RealtimeService _i = RealtimeService._();
  factory RealtimeService() => _i;
  RealtimeService._();

  RealtimeChannel? _messagesChannel;
  RealtimeChannel? _notificationsChannel;
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _notificationController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messageEvents => _messageController.stream;
  Stream<Map<String, dynamic>> get notificationEvents =>
      _notificationController.stream;

  SupabaseClient get _c => Supabase.instance.client;

  void subscribeMessages(String conversationId, void Function() onChange) {
    _messagesChannel?.unsubscribe();
    _messagesChannel = _c
        .channel('messages:$conversationId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          callback: (_) => onChange(),
        )
        .subscribe();
  }

  void unsubscribeMessages() {
    _messagesChannel?.unsubscribe();
    _messagesChannel = null;
  }

  void subscribeNotifications(void Function(Map<String, dynamic> row) onInsert) {
    unsubscribeNotifications();
    _notificationsChannel = _c
        .channel('notifications:me')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          callback: (payload) {
            final row = payload.newRecord;
            if (row.isNotEmpty) _notificationController.add(row);
          },
        )
        .subscribe();
  }

  void unsubscribeNotifications() {
    _notificationsChannel?.unsubscribe();
    _notificationsChannel = null;
  }
}
