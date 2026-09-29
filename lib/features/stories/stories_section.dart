import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../core/error_mapper.dart';
import '../../l10n_gen/app_localizations.dart';
import '../../models/models.dart';
import '../../repositories/story_repository.dart';
import '../../services/storage_service.dart';

/// Horizontal stories strip shown at the top of the home feed.
class StoriesSection extends StatefulWidget {
  const StoriesSection({super.key});
  @override
  State<StoriesSection> createState() => _StoriesSectionState();
}

class _StoriesSectionState extends State<StoriesSection> {
  final _repo = StoryRepository();
  List<Story> _stories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final s = await _repo.active();
      if (!mounted) return;
      setState(() {
        _stories = s;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createSheet() async {
    final l = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.text_fields, color: NexColors.accent),
            title: Text(l.storyTextHint),
            onTap: () async {
              Navigator.pop(context);
              final c = TextEditingController();
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  content: TextField(controller: c, maxLines: 3,
                      decoration: InputDecoration(hintText: l.storyTextHint)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.cancel)),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l.publish)),
                  ],
                ),
              );
              if (ok == true && c.text.trim().isNotEmpty) {
                try {
                  await _repo.createText(c.text.trim());
                  _load();
                } catch (e) {
                  if (mounted) showSnack(context, friendlyError(e, l));
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo, color: NexColors.accent),
            title: Text(l.addStory),
            onTap: () async {
              Navigator.pop(context);
              final res = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
              if (res == null) return;
              try {
                final url = await StorageService.upload(
                    file: File(res.path), bucket: 'story-media', ext: res.path.split('.').last.toLowerCase());
                await _repo.createMedia(mediaUrl: url, type: 'image');
                _load();
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
    if (_loading) return const SizedBox(height: 96);
    final mine = _stories.where((s) => s.isMine).toList();
    final others = _stories.where((s) => !s.isMine).toList();
    return SizedBox(
      height: 104,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          GestureDetector(
            onTap: _createSheet,
            child: SizedBox(
              width: 68,
              child: Column(children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: NexTheme.accentGradient,
                  ),
                  child: const Icon(Icons.add, color: Colors.black),
                ),
                const SizedBox(height: 4),
                Text(l.addStory, style: const TextStyle(fontSize: 10), overflow: TextOverflow.ellipsis),
              ]),
            ),
          ),
          for (final s in [...mine, ...others])
            GestureDetector(
              onLongPress: () async {
                if (!s.isMine) return;
                final l2 = AppLocalizations.of(context);
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    content: Text(l2!.delete),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l2.cancel)),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l2.delete)),
                    ],
                  ),
                );
                if (ok == true) {
                  await _repo.delete(s.id);
                  _load();
                }
              },
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => StoryViewerScreen(stories: _stories, initial: s)));
              },
              child: SizedBox(
                width: 68,
                child: Column(children: [
                  Container(
                    width: 66, height: 66,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: s.seenByMe
                          ? const LinearGradient(colors: [NexColors.line, NexColors.line])
                          : NexTheme.accentGradient,
                    ),
                    child: CircleAvatar(
                      backgroundColor: NexColors.surfaceHi,
                      backgroundImage: (s.user.avatarUrl ?? '').isNotEmpty
                          ? NetworkImage(s.user.avatarUrl!)
                          : null,
                      child: (s.user.avatarUrl ?? '').isEmpty
                          ? Text(s.user.firstName.isNotEmpty ? s.user.firstName[0] : '?',
                              style: const TextStyle(color: NexColors.accent, fontWeight: FontWeight.w800))
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(s.user.firstName,
                      style: const TextStyle(fontSize: 10), overflow: TextOverflow.ellipsis),
                ]),
              ),
            ),
        ],
      ),
    );
  }
}

/// Full-screen story viewer; records a view (story_views) on open.
class StoryViewerScreen extends StatefulWidget {
  final List<Story> stories;
  final Story initial;
  const StoryViewerScreen({super.key, required this.stories, required this.initial});
  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> {
  late int _idx;
  final _repo = StoryRepository();

  @override
  void initState() {
    super.initState();
    _idx = widget.stories.indexWhere((s) => s.id == widget.initial.id);
    _markViewed();
  }

  Future<void> _markViewed() async {
    try {
      await _repo.view(widget.stories[_idx].id);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final s = widget.stories[_idx];
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (d) {
          if (d.globalPosition.dx < MediaQuery.of(context).size.width / 2) {
            if (_idx > 0) setState(() { _idx--; _markViewed(); });
          } else {
            if (_idx < widget.stories.length - 1) {
              setState(() { _idx++; _markViewed(); });
            } else {
              Navigator.pop(context);
            }
          }
        },
        child: SafeArea(
          child: Column(children: [
            Row(children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: ProfileAvatar(profile: s.user, radius: 16),
              ),
              Expanded(child: Text(s.user.fullName, style: const TextStyle(color: Colors.white))),
              if (s.isMine)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                  onPressed: () async {
                    await _repo.delete(s.id);
                    if (mounted) Navigator.pop(context);
                  },
                ),
              IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context)),
            ]),
            Expanded(
              child: Center(
                child: s.mediaUrl != null
                    ? InteractiveViewer(child: Image.network(s.mediaUrl!))
                    : Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(s.content ?? '',
                            style: const TextStyle(color: Colors.white, fontSize: 26, height: 1.5),
                            textAlign: TextAlign.center),
                      ),
              ),
            ),
            if (s.isMine)
              Padding(
                padding: const EdgeInsets.all(16),
                child: FutureBuilder<int>(
                  future: _repo.viewerCount(s.id),
                  builder: (context, snap) => Text(
                    '${snap.data ?? 0} ${l.views}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}
