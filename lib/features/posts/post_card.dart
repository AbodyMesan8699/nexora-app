import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../core/error_mapper.dart';
import '../../l10n_gen/app_localizations.dart';
import '../../models/models.dart';
import '../../repositories/post_repository.dart';
import '../profile/profile_screen.dart';
import '../comments/comments_screen.dart';
import 'report_helper.dart';

/// A feed post card: profile header, media, actions (like/comment/share/save/edit/delete/report).
class PostCard extends StatefulWidget {
  final Post post;
  final VoidCallback? onChanged;
  const PostCard({super.key, required this.post, this.onChanged});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late Post _post;
  final _repo = PostRepository();

  @override
  void initState() {
    super.initState();
    _post = widget.post;
  }

  @override
  void didUpdateWidget(covariant PostCard old) {
    super.didUpdateWidget(old);
    _post = widget.post;
  }

  Future<void> _toggleLike() async {
    setState(() {
      _post = _likeCopy(!_post.isLiked);
    });
    try {
      await _repo.like(_post.id);
    } catch (e) {
      if (mounted) setState(() => _post = _likeCopy(_post.isLiked));
      if (mounted) showSnack(context, friendlyError(e, AppLocalizations.of(context)!));
    }
    widget.onChanged?.call();
  }

  Post _likeCopy(bool liked) {
    final base = _post;
    // lightweight manual copy
    return Post(
      id: base.id, userId: base.userId, user: base.user, content: base.content,
      location: base.location, feeling: base.feeling, visibility: base.visibility,
      createdAt: base.createdAt, isLiked: liked, isSaved: base.isSaved, isMine: base.isMine,
      likeCount: base.likeCount + (liked && !base.isLiked ? 1 : (!liked && base.isLiked ? -1 : 0)),
      commentCount: base.commentCount, shareCount: base.shareCount, media: base.media,
    );
  }

  Future<void> _share() async {
    final l = AppLocalizations.of(context)!;
    try {
      await _repo.share(_post.id);
      if (mounted) showSnack(context, l.sharePost);
      widget.onChanged?.call();
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e, l));
    }
  }

  Future<void> _save() async {
    try {
      await _repo.save(_post.id);
      widget.onChanged?.call();
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e, AppLocalizations.of(context)!));
    }
  }

  Future<void> _delete() async {
    final l = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.deletePost),
        content: Text(l.deletePostConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.cancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l.delete)),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _repo.delete(_post.id);
      widget.onChanged?.call();
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e, l));
    }
  }

  void _report() {
    final l = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (_) => ReportSheetHolder(targetType: 'post', targetId: _post.id, title: l.reportPost),
    );
  }

  void _edit() {
    final l = AppLocalizations.of(context)!;
    final c = TextEditingController(text: _post.content);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: c, maxLines: 4),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () async {
                try {
                  await _repo.update(_post.id, content: c.text.trim());
                  if (context.mounted) Navigator.pop(context);
                  widget.onChanged?.call();
                } catch (e) {
                  if (context.mounted) showSnack(context, friendlyError(e, l));
                }
              },
              child: Text(l.saveChanges),
            ),
          ]),
        ),
      ),
    );
  }

  void _openComments() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => CommentsScreen(post: _post)));
  }

  void _openAuthor() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ProfileScreen(userId: _post.userId)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ListTile(
          onTap: _openAuthor,
          leading: ProfileAvatar(profile: _post.user, radius: 20),
          title: Row(children: [
            Flexible(child: Text(_post.user.fullName, overflow: TextOverflow.ellipsis)),
            if (_post.user.isVerified) ...[
              const SizedBox(width: 4),
              const VerifiedBadge(size: 15),
            ],
          ]),
          subtitle: Text('@${_post.user.username} · ${timeAgo(_post.createdAt, l)}'),
          trailing: PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'edit' && _post.isMine) _edit();
              if (v == 'delete' && _post.isMine) _delete();
              if (v == 'save') _save();
              if (v == 'report' && !_post.isMine) _report();
            },
            itemBuilder: (_) => [
              if (_post.isMine)
                PopupMenuItem(value: 'edit', child: Text(l.editPost)),
              if (_post.isMine)
                PopupMenuItem(value: 'delete', child: Text(l.deletePost)),
              PopupMenuItem(value: 'save', child: Text(_post.isSaved ? l.unsavePost : l.savePost)),
              if (!_post.isMine)
                PopupMenuItem(value: 'report', child: Text(l.reportPost)),
            ],
          ),
        ),
        if (_post.content.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(_post.content),
          ),
        if (_post.location != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(children: [
              const Icon(Icons.place_outlined, size: 14, color: NexColors.textDim),
              const SizedBox(width: 4),
              Text(_post.location!, style: const TextStyle(color: NexColors.textDim, fontSize: 12)),
            ]),
          ),
        if (_post.media.isNotEmpty)
          _PostMediaGrid(media: _post.media),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(children: [
            _Action(
              icon: _post.isLiked ? Icons.favorite : Icons.favorite_border,
              color: _post.isLiked ? NexColors.accent : NexColors.textDim,
              label: '${_post.likeCount}',
              onTap: _toggleLike,
            ),
            _Action(icon: Icons.chat_bubble_outline, label: '${_post.commentCount}', onTap: _openComments),
            _Action(icon: Icons.share_outlined, label: '${_post.shareCount}', onTap: _share),
            const Spacer(),
            IconButton(
              icon: Icon(
                _post.isSaved ? Icons.bookmark : Icons.bookmark_border,
                color: _post.isSaved ? NexColors.accent : NexColors.textDim,
                size: 20,
              ),
              onPressed: _save,
            ),
          ]),
        ),
        const SizedBox(height: 4),
      ]),
    );
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;
  const _Action({required this.icon, required this.label, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(children: [
          Icon(icon, size: 20, color: color ?? NexColors.textDim),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: NexColors.textDim, fontSize: 13)),
        ]),
      ),
    );
  }
}

class _PostMediaGrid extends StatelessWidget {
  final List<PostMedia> media;
  const _PostMediaGrid({required this.media});

  @override
  Widget build(BuildContext context) {
    if (media.length == 1) {
      final m = media.first;
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: m.mediaType == 'video'
              ? _NetworkVideo(url: m.mediaUrl, height: 220, width: double.infinity)
              : Image.network(m.mediaUrl, fit: BoxFit.cover,
                  height: 260, width: double.infinity, errorBuilder: (_, __, ___) => const SizedBox()),
        ),
      );
    }
    return SizedBox(
      height: 220,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          for (final m in media)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: m.mediaType == 'video'
                    ? _NetworkVideo(url: m.mediaUrl, height: 220, width: 200)
                    : Image.network(m.mediaUrl, fit: BoxFit.cover, width: 220,
                        errorBuilder: (_, __, ___) => const SizedBox()),
              ),
            ),
        ],
      ),
    );
  }
}

class _NetworkVideo extends StatefulWidget {
  final String url;
  final double height;
  final double width;

  const _NetworkVideo({required this.url, required this.height, required this.width});

  @override
  State<_NetworkVideo> createState() => _NetworkVideoState();
}

class _NetworkVideoState extends State<_NetworkVideo> {
  late final VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (mounted) setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: _controller.value.isInitialized
          ? Stack(fit: StackFit.expand, children: [
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
              Center(
                child: IconButton.filled(
                  icon: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: () {
                    setState(() {
                      _controller.value.isPlaying ? _controller.pause() : _controller.play();
                    });
                  },
                ),
              ),
            ])
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

/// Shared report sheet lives in report_helper.dart (ReportSheetHolder).
