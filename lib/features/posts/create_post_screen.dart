import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../core/error_mapper.dart';
import '../../l10n_gen/app_localizations.dart';
import '../../repositories/post_repository.dart';
import '../../services/storage_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});
  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _content = TextEditingController();
  final _location = TextEditingController();
  final _repo = PostRepository();
  final _images = <File>[];
  File? _video;
  String _visibility = 'public';
  bool _busy = false;

  Future<void> _pickImages() async {
    final res = await ImagePicker().pickMultiImage(imageQuality: 80);
    if (res.isNotEmpty) setState(() => _images.addAll(res.take(6 - _images.length).map((x) => File(x.path))));
  }

  Future<void> _pickVideo() async {
    final res = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (res != null) setState(() => _video = File(res.path));
  }

  Future<void> _publish() async {
    final l = AppLocalizations.of(context)!;
    if (_content.text.trim().isEmpty && _images.isEmpty && _video == null) return;
    setState(() => _busy = true);
    try {
      await _repo.create(
        content: _content.text.trim(),
        location: _location.text.trim().isEmpty ? null : _location.text.trim(),
        visibility: _visibility,
        images: _images,
        video: _video,
      );
      if (!mounted) return;
      showSnack(context, l.postCreated);
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e, l));
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.create), actions: [
        TextButton(
          onPressed: _busy ? null : _publish,
          child: Text(l.publish,
              style: const TextStyle(color: NexColors.accent, fontWeight: FontWeight.w700)),
        ),
      ]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _content,
            maxLines: 6,
            decoration: InputDecoration(hintText: l.whatsOnYourMind, border: InputBorder.none, filled: false),
          ),
          Row(children: [
            IconButton(
              onPressed: _pickImages,
              icon: const Icon(Icons.image_outlined, color: NexColors.accent),
              tooltip: l.media,
            ),
            IconButton(
              onPressed: _pickVideo,
              icon: const Icon(Icons.videocam_outlined, color: NexColors.accent),
              tooltip: l.media,
            ),
            Expanded(
              child: TextField(
                controller: _location,
                decoration: InputDecoration(hintText: l.addLocation, isDense: true),
              ),
            ),
          ]),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: Text(l.visibilityEveryone),
                selected: _visibility == 'public',
                onSelected: (_) => setState(() => _visibility = 'public'),
                selectedColor: NexColors.accent,
              ),
              ChoiceChip(
                label: Text(l.visibilityFollowers),
                selected: _visibility == 'followers',
                onSelected: (_) => setState(() => _visibility = 'followers'),
                selectedColor: NexColors.accent,
              ),
              ChoiceChip(
                label: Text(l.visibilityFriends),
                selected: _visibility == 'friends',
                onSelected: (_) => setState(() => _visibility = 'friends'),
                selectedColor: NexColors.accent,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_images.isNotEmpty)
            SizedBox(
              height: 110,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final f in _images)
                    Stack(children: [
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(f, height: 100, width: 100, fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => setState(() => _images.remove(f)),
                          child: const CircleAvatar(
                            radius: 11, backgroundColor: NexColors.surfaceHi,
                            child: Icon(Icons.close, size: 14),
                          ),
                        ),
                      ),
                    ]),
                ],
              ),
            ),
          if (_video != null)
            ListTile(
              leading: const Icon(Icons.videocam, color: NexColors.accent),
              title: Text(_video!.path.split('/').last, overflow: TextOverflow.ellipsis),
              trailing: IconButton(
                  icon: const Icon(Icons.close), onPressed: () => setState(() => _video = null)),
            ),
          if (_busy) const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }
}
