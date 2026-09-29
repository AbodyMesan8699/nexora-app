import 'package:flutter/material.dart';

import '../../core/widgets.dart';
import '../../core/network_monitor.dart';
import '../../l10n_gen/app_localizations.dart';
import '../../models/models.dart';
import '../../repositories/post_repository.dart';
import '../posts/post_card.dart';

/// Infinite-scroll home feed with pull-to-refresh and cursor pagination.
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final _repo = PostRepository();
  final _scroll = ScrollController();
  final _posts = <Post>[];
  bool _loading = false;
  bool _done = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 400) _load();
    });
  }

  Future<void> _load() async {
    if (_loading || _done) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final before = _posts.isEmpty ? null : _posts.last.createdAt;
      final batch = await _repo.feed(limit: 10, before: before);
      if (!mounted) return;
      setState(() {
        _posts.addAll(batch);
        _done = batch.length < 10;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _posts.clear();
      _done = false;
    });
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          const NexoraLogo(size: 34),
          const SizedBox(width: 10),
          Text('NEXORA'),
        ]),
      ),
      body: Column(children: [
        const OfflineBanner(),
        Expanded(
          child: _error != null && _posts.isEmpty
              ? ErrorState(message: friendlyGeneric(_error!, l), onRetry: _refresh)
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: _posts.isEmpty && !_loading
                      ? ListView(children: [const SizedBox(height: 120), EmptyState(icon: Icons.waving_hand_outlined, message: l.feedEmpty)])
                      : ListView.builder(
                          controller: _scroll,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: _posts.length + (_done ? 0 : 1),
                          itemBuilder: (context, i) {
                            if (i >= _posts.length) return const SkeletonCard(height: 160);
                            return PostCard(post: _posts[i], onChanged: _refresh);
                          },
                        ),
                ),
        ),
      ]),
    );
  }
}

String friendlyGeneric(String raw, AppLocalizations l) =>
    raw.contains('network') || raw.contains('connection') ? l.errorNetwork : l.errorGeneric;
