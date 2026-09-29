import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../core/error_mapper.dart';
import '../../l10n_gen/app_localizations.dart';
import '../../models/models.dart';
import '../../repositories/profile_repository.dart';
import '../../repositories/post_repository.dart';
import '../../repositories/social_repository.dart';
import '../../repositories/message_repository.dart';
import '../../repositories/admin_repository.dart';
import '../../services/supabase_service.dart';
import '../../services/storage_service.dart';
import '../../state/app_state.dart';
import '../posts/post_card.dart';
import '../posts/report_helper.dart';
import '../messages/chat_screen.dart';
import '../friends/friends_screen.dart';
import '../settings/settings_screen.dart';
import '../admin/admin_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;
  const ProfileScreen({super.key, this.userId});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profileRepo = ProfileRepository();
  final _postRepo = PostRepository();
  final _socialRepo = SocialRepository();
  Profile? _profile;
  List<Post> _posts = [];
  String? _error;
  bool _loading = true;
  bool _isFollowing = false;
  bool _isFriend = false;
  FriendRequestState? _requestState;
  bool _relationshipBusy = false;
  int _tab = 0;

  String get _targetId => widget.userId ?? SupabaseService.currentUserId!;
  bool get _isMe => _targetId == SupabaseService.currentUserId;

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
      final p = await _profileRepo.get(_targetId);
      final posts = await _postRepo.userPosts(_targetId);
      bool following = false, friend = false;
      FriendRequestState? reqState;
      if (!_isMe) {
        // Relationship data must never prevent the profile and its action
        // buttons from rendering. A missing/old RLS policy should leave the
        // buttons visible and usable rather than replacing the whole screen
        // with an error state.
        try {
          following = await _socialRepo.isFollowing(_targetId);
          friend = await _socialRepo.isFriend(_targetId);
          reqState = await _socialRepo.requestStatus(_targetId);
        } catch (e) {
          debugPrint('[Nexora relationship load] $e');
        }
      }
      if (!mounted) return;
      setState(() {
        _profile = p;
        _posts = posts;
        _isFollowing = following;
        _isFriend = friend;
        _requestState = reqState;
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

  Future<void> _reloadRelationship() async {
    if (_isMe) return;
    final following = await _socialRepo.isFollowing(_targetId);
    final friend = await _socialRepo.isFriend(_targetId);
    final request = await _socialRepo.requestStatus(_targetId);
    if (!mounted) return;
    setState(() {
      _isFollowing = following;
      _isFriend = friend;
      _requestState = request;
    });
  }

  Future<void> _refreshRelationshipQuietly() async {
    try {
      await _reloadRelationship();
    } catch (e) {
      debugPrint('[Nexora relationship refresh] $e');
    }
  }

  Future<void> _toggleFollow() async {
    final l = AppLocalizations.of(context)!;
    if (_relationshipBusy || _isMe) return;
    setState(() => _relationshipBusy = true);
    try {
      if (_isFollowing) {
        await _socialRepo.unfollow(_targetId);
      } else {
        await _socialRepo.follow(_targetId);
      }
      if (mounted) setState(() => _isFollowing = !_isFollowing);
      await _refreshRelationshipQuietly();
      if (mounted) setState(() => _relationshipBusy = false);
    } catch (e) {
      if (mounted) setState(() => _relationshipBusy = false);
      if (mounted) showSnack(context, friendlyError(e, l));
    }
  }

  Future<void> _friendAction() async {
    final l = AppLocalizations.of(context)!;
    if (_relationshipBusy || _isMe) return;
    setState(() => _relationshipBusy = true);
    try {
      if (_isFriend) {
        final ok = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            content: Text(l.removeFriendConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l.confirm),
              ),
            ],
          ),
        );
        if (ok == true) {
          await _socialRepo.removeFriend(_targetId);
          if (mounted) setState(() => _isFriend = false);
        }
        await _refreshRelationshipQuietly();
        if (mounted) setState(() => _relationshipBusy = false);
        return;
      }
      final request = _requestState;
      if (request?.isPending == true) {
        if (request!.sentByMe) {
          await _socialRepo.cancelFriendRequest(request.id);
          if (mounted) setState(() => _requestState = null);
        } else {
          await _socialRepo.acceptFriendRequest(request.id);
          if (mounted) setState(() => _isFriend = true);
        }
      } else {
        final sent = await _socialRepo.sendFriendRequest(_targetId);
        if (mounted) setState(() => _requestState = sent);
      }
      await _refreshRelationshipQuietly();
      if (mounted) setState(() => _relationshipBusy = false);
    } catch (e) {
      if (mounted) setState(() => _relationshipBusy = false);
      if (mounted) showSnack(context, friendlyError(e, l));
    }
  }

  Future<void> _message() async {
    final l = AppLocalizations.of(context)!;
    try {
      final convId = await MessageRepository().startConversation(_targetId);
      if (convId == null) {
        if (mounted) showSnack(context, l.errorGeneric);
        return;
      }
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ChatScreen(conversationId: convId)),
      );
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e, l));
    }
  }

  Future<void> _block() async {
    final l = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(l.blockConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.block),
          ),
        ],
      ),
    );
    if (ok == true) {
      try {
        await _socialRepo.block(_targetId);
        if (mounted) {
          showSnack(context, l.blocked);
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) showSnack(context, friendlyError(e, l));
      }
    }
  }

  void _report() {
    final l = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (_) => ReportSheetHolder(
        targetType: 'profile',
        targetId: _targetId,
        title: l.reportAccount,
      ),
    );
  }

  Future<void> _editProfile() async {
    final l = AppLocalizations.of(context)!;
    final p = _profile!;
    final first = TextEditingController(text: p.firstName);
    final last = TextEditingController(text: p.lastName);
    final username = TextEditingController(text: p.username);
    final bio = TextEditingController(text: p.bio ?? '');
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.editProfile),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: first,
              decoration: InputDecoration(hintText: l.firstName),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: last,
              decoration: InputDecoration(hintText: l.lastName),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: username,
              decoration: InputDecoration(hintText: l.username),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: bio,
              maxLines: 3,
              decoration: InputDecoration(hintText: l.bio),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.save),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      final newUsername = username.text.trim().toLowerCase();
      if (newUsername.isEmpty) {
        if (mounted) showSnack(context, l.errorGeneric);
        return;
      }
      if (newUsername != p.username &&
          !await _profileRepo.isUsernameAvailable(newUsername)) {
        if (mounted) showSnack(context, l.errorGeneric);
        return;
      }
      await _profileRepo.update(p.id, {
        'first_name': first.text.trim(),
        'last_name': last.text.trim(),
        'username': newUsername,
        'bio': bio.text.trim(),
      });
      await AppState().loadMe();
      _load();
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e, l));
    }
  }

  Future<void> _changePhoto(bool cover) async {
    final l = AppLocalizations.of(context)!;
    final res = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (res == null) return;
    try {
      final url = await StorageService.upload(
        file: File(res.path),
        bucket: cover ? 'cover-images' : 'profile-images',
      );
      await _profileRepo.update(_targetId, {
        cover ? 'cover_url' : 'avatar_url': url,
      });
      await AppState().loadMe();
      _load();
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e, l));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (_loading) {
      return Scaffold(
        appBar: AppBar(),
        body: ListView(
          children: const [
            SkeletonCard(height: 200),
            SkeletonCard(height: 300),
          ],
        ),
      );
    }
    if (_error != null || _profile == null) {
      return Scaffold(
        appBar: AppBar(),
        body: ErrorState(message: l.errorGeneric, onRetry: _load),
      );
    }
    final p = _profile!;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 210,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: _isMe
                ? [
                    IconButton(
                      tooltip: l.editProfile,
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: _editProfile,
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      ),
                    ),
                  ]
                : [
                    PopupMenuButton<String>(
                      onSelected: (v) {
                        if (v == 'block') _block();
                        if (v == 'report') _report();
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(value: 'block', child: Text(l.block)),
                        PopupMenuItem(
                          value: 'report',
                          child: Text(l.reportAccount),
                        ),
                      ],
                    ),
                  ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  (p.coverUrl ?? '').isNotEmpty
                      ? Image.network(p.coverUrl!, fit: BoxFit.cover)
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                NexColors.accent.withValues(alpha: 0.25),
                                NexColors.accentSoft.withValues(alpha: 0.25),
                              ],
                            ),
                          ),
                        ),
                  Positioned(
                    bottom: 8,
                    left: 16,
                    child: GestureDetector(
                      onTap: _isMe ? () => _changePhoto(false) : null,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: NexColors.bg,
                        ),
                        child: ProfileAvatar(profile: p, radius: 36),
                      ),
                    ),
                  ),
                  if (_isMe)
                    Positioned(
                      bottom: 34,
                      right: 16,
                      child: IconButton(
                        onPressed: () => _changePhoto(true),
                        icon: const Icon(
                          Icons.photo_camera_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          p.fullName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (p.isVerified) ...[
                        const SizedBox(width: 6),
                        const VerifiedBadge(size: 18),
                      ],
                    ],
                  ),
                  Text(
                    '@${p.username}',
                    style: const TextStyle(color: NexColors.textDim),
                  ),
                  if ((p.bio ?? '').isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(p.bio!),
                  ],
                  const SizedBox(height: 16),
                  FutureBuilder<List<int>>(
                    future: _counts(),
                    builder: (context, snap) {
                      final c = snap.data ?? const [0, 0, 0];
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _Stat(label: l.posts, value: '${_posts.length}'),
                          _Stat(label: l.followers, value: '${c[0]}'),
                          _Stat(label: l.following, value: '${c[1]}'),
                          _Stat(label: l.friends, value: '${c[2]}'),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_isMe)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: _editProfile,
                            icon: const Icon(Icons.edit_outlined),
                            label: Text(l.editProfile, softWrap: false),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const FriendsScreen(),
                              ),
                            ),
                            child: Text(l.friends, softWrap: false),
                          ),
                          const SizedBox(width: 8),
                          FutureBuilder<bool>(
                            future: AdminRepository().isAdmin(),
                            builder: (context, snap) {
                              if (snap.data != true)
                                return const SizedBox.shrink();
                              return OutlinedButton.icon(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AdminScreen(),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.admin_panel_settings_outlined,
                                  size: 20,
                                ),
                                label: Text(l.adminPanel, softWrap: false),
                              );
                            },
                          ),
                        ],
                      ),
                    )
                  else
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            FilledButton.icon(
                              onPressed: _relationshipBusy
                                  ? null
                                  : _toggleFollow,
                              icon: Icon(
                                _isFollowing
                                    ? Icons.person_remove_alt_1_outlined
                                    : Icons.person_add_alt_1_outlined,
                              ),
                              label: _relationshipBusy
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(_isFollowing ? l.unfollow : l.follow),
                            ),
                            OutlinedButton.icon(
                              onPressed: _relationshipBusy
                                  ? null
                                  : _friendAction,
                              icon: Icon(
                                _isFriend
                                    ? Icons.person_remove_outlined
                                    : Icons.group_add_outlined,
                              ),
                              label: Text(
                                _isFriend
                                    ? l.removeFriend
                                    : (_requestState?.isPending == true
                                          ? (_requestState!.sentByMe
                                                ? l.cancel
                                                : l.accept)
                                          : l.friendRequest),
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: _message,
                              icon: const Icon(Icons.chat_bubble_outline),
                              label: Text(l.messages),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  if (_isMe)
                    Row(
                      children: [
                        ChoiceChip(
                          label: Text(l.myPosts),
                          selected: _tab == 0,
                          onSelected: (_) => setState(() => _tab = 0),
                          selectedColor: NexColors.accent,
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: Text(l.savedPostsTab),
                          selected: _tab == 1,
                          onSelected: (_) async {
                            setState(() => _tab = 1);
                            try {
                              final saved = await _postRepo.savedPosts();
                              if (mounted) setState(() => _posts = saved);
                            } catch (e) {
                              if (mounted)
                                showSnack(context, friendlyError(e, l));
                            }
                          },
                          selectedColor: NexColors.accent,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => PostCard(post: _posts[i], onChanged: _load),
              childCount: _posts.length,
            ),
          ),
        ],
      ),
    );
  }

  Future<List<int>> _counts() => _socialRepo.counts(_targetId);
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        Text(
          label,
          style: const TextStyle(color: NexColors.textDim, fontSize: 12),
        ),
      ],
    );
  }
}
