import 'package:flutter/material.dart';
import '../../core/widgets.dart';

import '../../l10n_gen/app_localizations.dart';
import '../../models/models.dart';
import '../../repositories/message_repository.dart';
import 'chat_screen.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});
  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final _repo = MessageRepository();
  List<Conversation> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _friendly(String raw, AppLocalizations l) =>
      raw.contains('network') || raw.contains('connection') ? l.errorNetwork : l.errorGeneric;

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _repo.conversations();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.messages)),
      body: _loading
          ? ListView(children: const [SkeletonCard(), SkeletonCard()])
          : _error != null
              ? ErrorState(message: _friendly(_error!, l), onRetry: _load)
              : _items.isEmpty
                  ? EmptyState(icon: Icons.chat_bubble_outline, message: l.noResults)
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const Divider(indent: 72),
                        itemBuilder: (context, i) {
                          final c = _items[i];
                          final other = c.others.isNotEmpty ? c.others.first : null;
                          return ListTile(
                            onTap: () async {
                              await Navigator.push(context, MaterialPageRoute(
                                  builder: (_) => ChatScreen(conversationId: c.id)));
                              _load();
                            },
                            leading: ProfileAvatar(profile: other, radius: 24),
                            title: Text(c.title, overflow: TextOverflow.ellipsis),
                            subtitle: Text(
                              c.lastMessage?.content ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Color(0xFF9AA0AB)),
                            ),
                            trailing: c.unreadCount > 0
                                ? Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                        color: Color(0xFFFF7A1A), shape: BoxShape.circle),
                                    child: Text('${c.unreadCount}',
                                        style: const TextStyle(
                                            fontSize: 11, color: Colors.black, fontWeight: FontWeight.w800)),
                                  )
                                : null,
                          );
                        },
                      ),
                    ),
    );
  }
}
