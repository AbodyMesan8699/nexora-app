import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/widgets.dart';
import '../../core/network_monitor.dart';
import '../../l10n_gen/app_localizations.dart';
import '../../models/models.dart';
import '../../repositories/search_repository.dart';
import '../profile/profile_screen.dart';
import '../posts/post_card.dart';

/// Global search with debounce + paginated results for people and posts.
class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});
  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final _query = TextEditingController();
  final _repo = SearchRepository();
  Timer? _debounce;
  String _term = '';
  int _tab = 0;
  final _people = <Profile>[];
  final _posts = <Post>[];
  bool _loading = false, _done = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _query.addListener(_onChanged);
  }

  void _onChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      setState(() {
        _term = _query.text.trim();
        _people.clear();
        _posts.clear();
        _done = false;
      });
      _load();
    });
  }

  Future<void> _load() async {
    if (_term.isEmpty || _loading || _done) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_tab == 0) {
        final r = await _repo.users(_term, offset: _people.length);
        if (!mounted) return;
        setState(() {
          _people.addAll(r);
          _done = r.length < 20;
        });
      } else {
        final r = await _repo.posts(_term, offset: _posts.length);
        if (!mounted) return;
        setState(() {
          _posts.addAll(r);
          _done = r.length < 20;
        });
      }
      if (mounted) setState(() => _loading = false);
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
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _query,
          decoration: InputDecoration(hintText: l.searchHint, isDense: true),
        ),
      ),
      body: Column(children: [
        const OfflineBanner(),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            ChoiceChip(
              label: Text(l.people),
              selected: _tab == 0,
              onSelected: (_) {
                setState(() {
                  _tab = 0;
                  _people.clear();
                  _done = false;
                });
                _load();
              },
              selectedColor: const Color(0xFFFF7A1A),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: Text(l.posts),
              selected: _tab == 1,
              onSelected: (_) {
                setState(() {
                  _tab = 1;
                  _posts.clear();
                  _done = false;
                });
                _load();
              },
              selectedColor: const Color(0xFFFF7A1A),
            ),
          ]),
        ),
        Expanded(
          child: _term.isEmpty
              ? EmptyState(icon: Icons.search, message: l.searchHint)
              : _error != null
                  ? ErrorState(message: l.errorGeneric, onRetry: _load)
                  : _tab == 0
                      ? _peopleList(l)
                      : _postsList(l),
        ),
      ]),
    );
  }

  Widget _peopleList(AppLocalizations l) {
    return ListView.builder(
      itemCount: _people.length + (_loading ? 1 : 0),
      itemBuilder: (context, i) {
        if (i >= _people.length) return const SkeletonCard(height: 70);
        final p = _people[i];
        return ListTile(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => ProfileScreen(userId: p.id))),
          leading: ProfileAvatar(profile: p, radius: 20),
          title: Row(children: [
            Flexible(child: Text(p.fullName, overflow: TextOverflow.ellipsis)),
            if (p.isVerified) ...[const SizedBox(width: 4), const VerifiedBadge(size: 14)],
          ]),
          subtitle: Text('@${p.username}'),
        );
      },
    );
  }

  Widget _postsList(AppLocalizations l) {
    if (_posts.isEmpty && !_loading) {
      return EmptyState(icon: Icons.search_off, message: l.noResults);
    }
    return ListView.builder(
      itemCount: _posts.length + (_loading ? 1 : 0),
      itemBuilder: (context, i) {
        if (i >= _posts.length) return const SkeletonCard(height: 140);
        return PostCard(post: _posts[i]);
      },
    );
  }
}
