import 'package:flutter/material.dart';
import '../../core/widgets.dart';

import '../../l10n_gen/app_localizations.dart';
import '../../models/models.dart';
import '../../repositories/notification_repository.dart';
import '../../repositories/post_repository.dart';
import '../profile/profile_screen.dart';
import '../comments/comments_screen.dart';
import '../posts/report_helper.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _repo = NotificationRepository();
  List<NexNotification> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _repo.list();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
      await _repo.markAllRead();
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  void _open(NexNotification n) {
    if (n.type == 'message') return;
    if (n.type == 'friend_request' || n.type == 'friend_accepted' || n.type == 'follow') {
      if (n.actorId != null) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(userId: n.actorId!)));
      }
      return;
    }
    if (n.referenceId != null) {
      // reference may be a post or a comment; open comments for both.
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => _RefCommentsShell(postId: n.referenceId!)));
    }
  }

  String friendlyGeneric(String raw, AppLocalizations l) =>
      raw.contains('network') || raw.contains('connection') ? l.errorNetwork : l.errorGeneric;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.notifications)),
      body: _loading
          ? ListView(children: const [SkeletonCard(), SkeletonCard(), SkeletonCard()])
          : _error != null
              ? ErrorState(message: friendlyGeneric(_error!, l), onRetry: _load)
              : _items.isEmpty
                  ? EmptyState(icon: Icons.notifications_none, message: l.notificationsEmpty)
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const Divider(indent: 72),
                        itemBuilder: (context, i) {
                          final n = _items[i];
                          return ListTile(
                            onTap: () => _open(n),
                            leading: n.actor != null
                                ? ProfileAvatar(profile: n.actor, radius: 20)
                                : const CircleAvatar(child: Icon(Icons.notifications)),
                            title: Text(_textFor(n, l),
                                style: TextStyle(
                                    fontWeight: n.isRead ? FontWeight.w400 : FontWeight.w700)),
                            subtitle: Text(timeAgo(n.createdAt, l),
                                style: const TextStyle(fontSize: 11, color: Color(0xFF9AA0AB))),
                            trailing: n.isRead
                                ? null
                                : Container(
                                    width: 8, height: 8,
                                    decoration: const BoxDecoration(
                                        color: Color(0xFFFF7A1A), shape: BoxShape.circle),
                                  ),
                          );
                        },
                      ),
                    ),
    );
  }

  String _textFor(NexNotification n, AppLocalizations l) {
    final who = n.actor?.fullName ?? '';
    switch (n.type) {
      case 'friend_request':
        return '$who ${l.sentYouFriendRequest}';
      case 'friend_accepted':
        return '$who ${l.acceptedYourRequest}';
      case 'like':
        return '$who ${l.likedYourPost}';
      case 'comment':
        return '$who ${l.commentedOnYourPost}';
      case 'reply':
        return '$who ${l.repliedToYourComment}';
      case 'share':
        return '$who ${l.sharedYourPost}';
      case 'follow':
        return '$who ${l.newFollower}';
      case 'message':
        return '$who ${l.sentYouMessage}';
      case 'story_view':
        return '$who ${l.viewedYourStory}';
      default:
        return who;
    }
  }
}

/// Opens the comments screen for a referenced post id.
class _RefCommentsShell extends StatelessWidget {
  final String postId;
  const _RefCommentsShell({required this.postId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: PostRepository().byId(postId),
      builder: (context, snap) {
        if (snap.hasError || !snap.hasData) {
          return Scaffold(body: EmptyState(icon: Icons.search_off, message: ''));
        }
        return CommentsScreen(post: snap.data as dynamic);
      },
    );
  }
}
