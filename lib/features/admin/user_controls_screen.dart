import 'package:flutter/material.dart';
import '../../core/error_mapper.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../l10n_gen/app_localizations.dart';
import '../../models/models.dart';
import '../../repositories/admin_repository.dart';
import '../../services/supabase_service.dart';

/// User controls available only to accounts authorized by public.is_admin().
/// The database RLS policy remains the source of truth for every mutation.
class UserControlsScreen extends StatefulWidget {
  const UserControlsScreen({super.key});

  @override
  State<UserControlsScreen> createState() => _UserControlsScreenState();
}

class _UserControlsScreenState extends State<UserControlsScreen> {
  final _repo = AdminRepository();
  final _search = TextEditingController();
  List<Map<String, dynamic>> _users = [];
  AdminStats? _stats;
  Map<String, dynamic> _cleanup = const {};
  List<Map<String, dynamic>> _cleanupLogs = [];
  bool _loading = true;
  bool _authorized = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final authorized = await _repo.isAdmin();
      if (!authorized) {
        if (mounted)
          setState(() {
            _authorized = false;
            _loading = false;
          });
        return;
      }
      final results = await Future.wait([
        _repo.searchUsers(_search.text),
        _repo.stats(),
        _repo.cleanupSettings(),
        _repo.cleanupLogs(),
      ]);
      final users = results[0] as List<Map<String, dynamic>>;
      final stats = results[1] as AdminStats?;
      final cleanup =
          results[2] as Map<String, dynamic>? ?? const <String, dynamic>{};
      final cleanupLogs = results[3] as List<Map<String, dynamic>>;
      if (mounted)
        setState(() {
          _authorized = true;
          _users = users;
          _stats = stats;
          _cleanup = cleanup;
          _cleanupLogs = cleanupLogs;
          _loading = false;
        });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _setStatus(Map<String, dynamic> user, String status) async {
    final l = AppLocalizations.of(context)!;
    final id = user['id'] as String;
    if (id == SupabaseService.currentUserId) {
      showSnack(context, 'لا يمكن تغيير حالة حساب المدير الحالي');
      return;
    }
    final name = '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'
        .trim();
    final suspended = status == 'suspended';
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(suspended ? l.suspendAccount : l.activeUsers),
        content: Text(
          suspended
              ? 'سيتم منع هذا الحساب من النشر والتفاعل.'
              : 'سيتم السماح لهذا الحساب باستخدام المنصة مجددًا.\n\n$name',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.confirm),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _repo.setAccountStatus(id, status);
      await _load();
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e, l));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.adminPanel)),
      body: !_authorized && !_loading
          ? EmptyState(icon: Icons.lock_outline, message: l.errorGeneric)
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    controller: _search,
                    textDirection: TextDirection.ltr,
                    onSubmitted: (_) => _load(),
                    decoration: InputDecoration(
                      hintText: 'ابحث بالاسم أو اسم المستخدم أو البريد',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: _load,
                      ),
                    ),
                  ),
                ),
                if (_stats != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: l.totalUsers,
                            value: _stats!.totalUsers,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _StatCard(
                            label: l.activeUsers,
                            value: _stats!.activeUsers,
                            color: NexColors.success,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _StatCard(
                            label: l.suspendedAccounts,
                            value: _stats!.suspendedAccounts,
                            color: NexColors.danger,
                          ),
                        ),
                      ],
                    ),
                  ),
                _cleanupCard(l),
                Expanded(
                  child: _loading
                      ? ListView(
                          children: const [
                            SkeletonCard(),
                            SkeletonCard(),
                            SkeletonCard(),
                          ],
                        )
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: _users.isEmpty
                              ? ListView(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(32),
                                      child: EmptyState(
                                        icon: Icons.people_outline,
                                        message: l.recentActivity,
                                      ),
                                    ),
                                  ],
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    8,
                                    12,
                                    24,
                                  ),
                                  itemCount: _users.length,
                                  separatorBuilder: (_, __) =>
                                      const Divider(height: 1),
                                  itemBuilder: (_, i) {
                                    final u = _users[i];
                                    final status =
                                        (u['account_status'] ?? 'active')
                                            as String;
                                    final isSuspended = status == 'suspended';
                                    final isSelf =
                                        u['id'] ==
                                        SupabaseService.currentUserId;
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: NexColors.surfaceHi,
                                        child: Text(
                                          '${u['first_name'] ?? '?'}'
                                              .characters
                                              .first
                                              .toUpperCase(),
                                        ),
                                      ),
                                      title: Text(
                                        '${u['first_name'] ?? ''} ${u['last_name'] ?? ''}'
                                            .trim(),
                                      ),
                                      subtitle: Text(
                                        '@${u['username'] ?? ''}\n${u['email'] ?? ''}',
                                      ),
                                      isThreeLine: true,
                                      trailing: isSelf
                                          ? const Chip(label: Text('أنت'))
                                          : TextButton.icon(
                                              onPressed: () => _setStatus(
                                                u,
                                                isSuspended
                                                    ? 'active'
                                                    : 'suspended',
                                              ),
                                              icon: Icon(
                                                isSuspended
                                                    ? Icons.lock_open_outlined
                                                    : Icons.block_outlined,
                                                size: 18,
                                              ),
                                              label: Text(
                                                isSuspended
                                                    ? l.activeUsers
                                                    : l.suspendAccount,
                                              ),
                                              style: TextButton.styleFrom(
                                                foregroundColor: isSuspended
                                                    ? NexColors.success
                                                    : NexColors.danger,
                                              ),
                                            ),
                                    );
                                  },
                                ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _cleanupCard(AppLocalizations l) {
    final enabled = _cleanup['enabled'] as bool? ?? true;
    final days = (_cleanup['retention_days'] as num?)?.toInt() ?? 7;
    const values = [0, 1, 3, 7, 14, 30, 90];
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'التنظيف التلقائي للمنشورات والوسائط',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 3),
            const Text(
              'يحذف المنشورات القديمة وصورها وفيديوهاتها نهائيًا من التخزين والقاعدة.',
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('تشغيل التنظيف الأسبوعي'),
              value: enabled,
              onChanged: (v) async {
                try {
                  await _repo.updateCleanupSettings(
                    enabled: v,
                    retentionDays: days,
                  );
                  if (mounted)
                    setState(() => _cleanup = {..._cleanup, 'enabled': v});
                } catch (e) {
                  if (mounted) showSnack(context, friendlyError(e, l));
                }
              },
            ),
            Row(
              children: [
                const Expanded(child: Text('حذف المنشورات الأقدم من')),
                DropdownButton<int>(
                  value: values.contains(days) ? days : 7,
                  items: values
                      .map(
                        (d) => DropdownMenuItem<int>(
                          value: d,
                          child: Text(d == 0 ? 'بدون حذف' : '$d يوم'),
                        ),
                      )
                      .toList(),
                  onChanged: !enabled
                      ? null
                      : (v) async {
                          if (v == null) return;
                          try {
                            await _repo.updateCleanupSettings(
                              enabled: enabled,
                              retentionDays: v,
                            );
                            if (mounted) {
                              setState(
                                () => _cleanup = {
                                  ..._cleanup,
                                  'retention_days': v,
                                },
                              );
                            }
                          } catch (e) {
                            if (mounted)
                              showSnack(context, friendlyError(e, l));
                          }
                        },
                ),
              ],
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.cleaning_services_outlined),
              label: const Text('تنفيذ التنظيف الآن'),
              onPressed: !enabled
                  ? null
                  : () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('تأكيد الحذف النهائي'),
                          content: const Text(
                            'سيتم حذف المنشورات الأقدم من المدة المحددة وصورها وفيديوهاتها نهائيًا. لا يمكن التراجع عن العملية.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(l.cancel),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(l.confirm),
                            ),
                          ],
                        ),
                      );
                      if (ok != true) return;
                      try {
                        await _repo.runCleanup();
                        await _load();
                      } catch (e) {
                        if (mounted) showSnack(context, friendlyError(e, l));
                      }
                    },
            ),
            if (_cleanupLogs.isNotEmpty) ...[
              const Divider(),
              const Text(
                'آخر عمليات التنظيف',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              ..._cleanupLogs
                  .take(3)
                  .map(
                    (log) => Text(
                      '${log['execution_status']} · منشورات: ${log['posts_deleted']} · وسائط: ${log['media_deleted']}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    this.color = NexColors.accent,
  });

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    ),
  );
}
