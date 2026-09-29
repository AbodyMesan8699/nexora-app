import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../core/error_mapper.dart';
import '../../l10n_gen/app_localizations.dart';
import '../../models/models.dart';
import '../../repositories/message_repository.dart';
import '../../services/realtime_service.dart';
import '../../services/supabase_service.dart';

/// Real-time 1:1 chat backed by Supabase Realtime on the messages table.
class ChatScreen extends StatefulWidget {
  final String conversationId;
  const ChatScreen({super.key, required this.conversationId});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _repo = MessageRepository();
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _messages = <Message>[];
  bool _loading = true, _sending = false;
  Profile? _other;

  @override
  void initState() {
    super.initState();
    _loadOtherMember();
    _load();
    RealtimeService().subscribeMessages(widget.conversationId, _onRealtime);
  }

  Future<void> _loadOtherMember() async {
    try {
      final other = await _repo.otherMember(widget.conversationId);
      if (mounted) setState(() => _other = other);
    } catch (e) {
      debugPrint('[Nexora chat member] $e');
    }
  }

  @override
  void dispose() {
    RealtimeService().unsubscribeMessages();
    super.dispose();
  }

  Future<void> _onRealtime() async {
    await _load(initial: false);
  }

  Future<void> _load({bool initial = true}) async {
    try {
      final before = initial ? null : null;
      final msgs = await _repo.messages(widget.conversationId, limit: 30, before: before);
      if (!mounted) return;
      setState(() {
        _messages
          ..clear()
          ..addAll(msgs);
        _loading = false;
      });
      await _repo.markRead(widget.conversationId);
      if (_scroll.hasClients) {
        await Future.delayed(const Duration(milliseconds: 50));
        if (_scroll.hasClients && mounted) {
          _scroll.jumpTo(_scroll.position.maxScrollExtent);
        }
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _send() async {
    final l = AppLocalizations.of(context)!;
    final text = _input.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await _repo.send(conversationId: widget.conversationId, content: text);
      _input.clear();
      await _load(initial: false);
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e, l));
    }
    if (mounted) setState(() => _sending = false);
  }

  void _msgMenu(Message m) {
    final l = AppLocalizations.of(context)!;
    if (!m.isMine) return;
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: Text(l.edit),
            onTap: () async {
              Navigator.pop(context);
              final c = TextEditingController(text: m.content);
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  content: TextField(controller: c),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.cancel)),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l.save)),
                  ],
                ),
              );
              if (ok == true) {
                try {
                  await _repo.edit(m.id, c.text.trim());
                  await _load(initial: false);
                } catch (e) {
                  if (mounted) showSnack(context, friendlyError(e, l));
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Color(0xFFE5484D)),
            title: Text(l.delete),
            onTap: () async {
              Navigator.pop(context);
              try {
                await _repo.delete(m.id);
                await _load(initial: false);
              } catch (e) {
                if (mounted) showSnack(context, friendlyError(e, l));
              }
            },
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final myId = SupabaseService.currentUserId ?? '';
    return Scaffold(
      appBar: AppBar(
        title: _other == null
            ? Text(l.messages)
            : Row(children: [
                ProfileAvatar(profile: _other, radius: 17),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(_other!.fullName, overflow: TextOverflow.ellipsis),
                ),
              ]),
      ),
      body: Column(children: [
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  controller: _scroll,
                  itemCount: _messages.length,
                  itemBuilder: (context, i) {
                    final m = _messages[i];
                    final mine = m.senderId == myId;
                    return Align(
                      alignment: mine ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
                      child: GestureDetector(
                        onLongPress: () => _msgMenu(m),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.72),
                          decoration: BoxDecoration(
                            gradient: mine ? NexTheme.accentGradient : null,
                            color: mine ? null : NexColors.surface,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: m.isDeleted
                              ? Text(l.deleteMessageConfirm.replaceAll('?', ''),
                                  style: const TextStyle(
                                      color: Color(0xFF9AA0AB), fontStyle: FontStyle.italic))
                              : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(m.content,
                                      style: TextStyle(color: mine ? Colors.black : NexColors.text)),
                                  if (m.editedAt != null)
                                    Text(l.edited,
                                        style: TextStyle(
                                            fontSize: 10, color: mine ? Colors.black54 : NexColors.textDim)),
                                ]),
                        ),
                      ),
                    );
                  },
                ),
        ),
        SafeArea(
          child: Row(children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _input,
                  decoration: InputDecoration(hintText: l.typeMessage, isDense: true),
                  onSubmitted: (_) => _send(),
                ),
              ),
            ),
            IconButton(
              onPressed: _sending ? null : _send,
              icon: const Icon(Icons.send, color: NexColors.accent),
            ),
          ]),
        ),
      ]),
    );
  }
}
