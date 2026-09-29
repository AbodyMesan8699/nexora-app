import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../core/error_mapper.dart';
import '../../l10n_gen/app_localizations.dart';
import '../../models/models.dart';
import '../../repositories/comment_repository.dart';
import '../posts/report_helper.dart';
import '../profile/profile_screen.dart';

/// Comments + replies with pagination, likes, delete-own, report.
class CommentsScreen extends StatefulWidget {
  final Post post;
  const CommentsScreen({super.key, required this.post});
  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final _repo = CommentRepository();
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _comments = <Comment>[];
  Comment? _replyTo;
  bool _loading = true, _done = false, _sending = false;

  @override
  void initState() {
    super.initState();
    _load();
    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 300) _load();
    });
  }

  Future<void> _load() async {
    if (_loading && _comments.isNotEmpty) return;
    setState(() => _loading = true);
    try {
      final before = _comments.isEmpty ? null : _comments.last.createdAt;
      final batch = await _repo.list(widget.post.id, limit: 20, before: before);
      if (!mounted) return;
      setState(() {
        _comments.addAll(batch);
        _done = batch.length < 20;
        _loading = false;
      });
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
      await _repo.create(postId: widget.post.id, parentId: _replyTo?.id, content: text);
      _input.clear();
      _replyTo = null;
      if (mounted) {
        setState(() {
          _comments.clear();
          _done = false;
        });
        await _load();
      }
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e, l));
    }
    if (mounted) setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.comments)),
      body: Column(children: [
        Expanded(
          child: _comments.isEmpty && !_loading
              ? EmptyState(icon: Icons.chat_bubble_outline, message: l.noCommentsYet)
              : ListView.builder(
                  controller: _scroll,
                  itemCount: _comments.length + (_loading ? 1 : 0),
                  itemBuilder: (context, i) {
                    if (i >= _comments.length) return const SkeletonCard(height: 70);
                    final c = _comments[i];
                    return ListTile(
                      onTap: () {
                        setState(() => _replyTo = c);
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                      leading: GestureDetector(
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => ProfileScreen(userId: c.userId))),
                        child: ProfileAvatar(profile: c.user, radius: 18),
                      ),
                      title: Row(children: [
                        Text('@${c.user.username}',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        const SizedBox(width: 6),
                        Text(timeAgo(c.createdAt, l),
                            style: const TextStyle(color: Color(0xFF9AA0AB), fontSize: 11)),
                      ]),
                      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        if (c.parentId != null)
                          Text(l.reply,
                              style: const TextStyle(color: Color(0xFFFF7A1A), fontSize: 11)),
                        Text(c.content),
                      ]),
                      trailing: PopupMenuButton<String>(
                        onSelected: (v) async {
                          if (v == 'like') await _repo.like(c.id);
                          if (v == 'del' && c.isMine) await _repo.delete(c.id);
                          if (v == 'report') {
                            showModalBottomSheet(
                              context: context,
                              builder: (_) => ReportSheetHolder(
                                  targetType: 'comment', targetId: c.id, title: l.report),
                            );
                          }
                          _load();
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(value: 'like', child: Text('${l.like} (${c.likeCount})')),
                          if (c.isMine) PopupMenuItem(value: 'del', child: Text(l.delete)),
                          if (!c.isMine) PopupMenuItem(value: 'report', child: Text(l.report)),
                        ],
                      ),
                    );
                  },
                ),
        ),
        if (_replyTo != null)
          Container(
            color: NexColors.surfaceHi,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(children: [
              Text('${l.reply}: @${_replyTo!.user.username}',
                  style: const TextStyle(fontSize: 12, color: NexColors.accent)),
              const Spacer(),
              IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () => setState(() => _replyTo = null)),
            ]),
          ),
        SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Row(children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _input,
                    decoration: InputDecoration(hintText: l.writeComment, isDense: true),
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
        ),
      ]),
    );
  }
}
