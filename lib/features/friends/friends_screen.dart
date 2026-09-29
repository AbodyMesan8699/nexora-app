import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../core/error_mapper.dart';
import '../../l10n_gen/app_localizations.dart';
import '../../models/models.dart';
import '../../repositories/social_repository.dart';
import '../profile/profile_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});
  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final _repo = SocialRepository();
  List<FriendRequest> _requests = [];
  List<Profile> _friends = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await _repo.pendingRequests();
      final f = await _repo.friends();
      if (!mounted) return;
      setState(() {
        _requests = r;
        _friends = f;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.friends)),
      body: _loading
          ? ListView(children: const [SkeletonCard(), SkeletonCard()])
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                Text(l.requests,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 8),
                if (_requests.isEmpty) Text(l.noRequests, style: const TextStyle(color: NexColors.textDim)),
                ..._requests.map((r) => ListTile(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => ProfileScreen(userId: r.sender.id))),
                      leading: ProfileAvatar(profile: r.sender, radius: 20),
                      title: Text(r.sender.fullName),
                      subtitle: Text('@${r.sender.username}'),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(
                          icon: const Icon(Icons.check_circle, color: Color(0xFF30A46C)),
                          tooltip: l.accept,
                          onPressed: () async {
                            try {
                              await _repo.acceptFriendRequest(r.id);
                              _load();
                            } catch (e) {
                              if (mounted) showSnack(context, friendlyError(e, l));
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Color(0xFFE5484D)),
                          tooltip: l.reject,
                          onPressed: () async {
                            try {
                              await _repo.declineFriendRequest(r.id);
                              _load();
                            } catch (e) {
                              if (mounted) showSnack(context, friendlyError(e, l));
                            }
                          },
                        ),
                      ]),
                    )),
                const Divider(height: 32),
                ..._friends.map((p) => ListTile(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => ProfileScreen(userId: p.id))),
                      leading: ProfileAvatar(profile: p, radius: 20),
                      title: Text(p.fullName),
                      subtitle: Text('@${p.username}'),
                      trailing: TextButton(
                        onPressed: () async {
                          try {
                            await _repo.removeFriend(p.id);
                            _load();
                          } catch (e) {
                            if (mounted) showSnack(context, friendlyError(e, l));
                          }
                        },
                        child: Text(l.removeFriend),
                      ),
                    )),
              ],
            ),
    );
  }
}
