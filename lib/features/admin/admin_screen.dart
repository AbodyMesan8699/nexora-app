import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../core/error_mapper.dart';
import '../../l10n_gen/app_localizations.dart';
import '../../models/models.dart';
import '../../repositories/admin_repository.dart';

/// Protected admin dashboard. All data comes through RLS-protected queries
/// plus the is_admin() SECURITY DEFINER RPC — the client cannot self-grant.
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _repo = AdminRepository();
  AdminStats? _stats;
  List<Report> _pending = [];
  List<Report> _reviewed = [];
  List<Map<String, dynamic>> _recent = [];
  Map<String, dynamic> _cleanup = const {};
  List<Map<String, dynamic>> _cleanupLogs = [];
  bool _loading = true;
  bool _isAdmin = false;
  bool _cleaning = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final admin = await _repo.isAdmin();
    if (!admin) {
      if (mounted) {
        setState(() {
          _isAdmin = false;
          _loading = false;
        });
      }
      return;
    }
    try {
      final stats = await _repo.stats();
      final pending = await _repo.pendingReports();
      final reviewed = await _repo.reviewedReports();
      final recent = await _repo.recentUsers();
      final cleanup =
          await _repo.cleanupSettings() ?? const <String, dynamic>{};
      final cleanupLogs = await _repo.cleanupLogs();
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _pending = pending;
        _reviewed = reviewed;
        _recent = recent;
        _cleanup = cleanup;
        _cleanupLogs = cleanupLogs;
        _isAdmin = true;
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
      appBar: AppBar(title: Text(l.adminPanel)),
      body: _loading
          ? ListView(children: const [SkeletonCard(), SkeletonCard()])
          : !_isAdmin
          ? EmptyState(icon: Icons.lock_outline, message: l.errorGeneric)
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.7,
                    children: [
                      _StatCard(
                        label: l.totalUsers,
                        value: '${_stats?.totalUsers ?? 0}',
                      ),
                      _StatCard(
                        label: l.activeUsers,
                        value: '${_stats?.activeUsers ?? 0}',
                      ),
                      _StatCard(
                        label: l.totalPosts,
                        value: '${_stats?.totalPosts ?? 0}',
                      ),
                      _StatCard(
                        label: l.totalComments,
                        value: '${_stats?.totalComments ?? 0}',
                      ),
                      _StatCard(
                        label: l.pendingReports,
                        value: '${_stats?.pendingReports ?? 0}',
                      ),
                      _StatCard(
                        label: l.suspendedAccounts,
                        value: '${_stats?.suspendedAccounts ?? 0}',
                      ),
                      _StatCard(
                        label: l.storageUsed,
                        value: '${_stats?.storageObjects ?? 0}',
                      ),
                      _StatCard(
                        label: l.recentActivity,
                        value: '${_stats?.recentUsers ?? 0}',
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  _cleanupCard(l),
                  const Divider(height: 32),
                  const Text(
                    'سجل عمليات التنظيف',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  ..._cleanupLogs.map(
                    (log) => ListTile(
                      dense: true,
                      title: Text(
                        '${log['execution_status']} · منشورات: ${log['posts_deleted']}',
                      ),
                      subtitle: Text(
                        'الوسائط: ${log['media_deleted']} · الأخطاء: ${log['errors_count']}\n${log['executed_at']}',
                      ),
                    ),
                  ),
                  const Divider(height: 32),
                  Text(
                    l.pendingReports,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  ..._pending.map(
                    (r) => ListTile(
                      title: Text('${r.targetType} · ${r.reason}'),
                      subtitle: Text(r.description ?? ''),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.check,
                              color: Color(0xFF30A46C),
                            ),
                            tooltip: l.reviewReport,
                            onPressed: () async {
                              try {
                                await _repo.reviewReport(r.id, 'reviewed');
                                _load();
                              } catch (e) {
                                if (mounted)
                                  showSnack(context, friendlyError(e, l));
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Color(0xFFE5484D),
                            ),
                            tooltip: l.dismissReport,
                            onPressed: () async {
                              try {
                                await _repo.reviewReport(r.id, 'dismissed');
                                _load();
                              } catch (e) {
                                if (mounted)
                                  showSnack(context, friendlyError(e, l));
                              }
                            },
                          ),
                          if (r.targetType == 'post')
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              tooltip: l.deletePost,
                              onPressed: () async {
                                try {
                                  await _repo.deletePost(r.targetId);
                                  await _repo.reviewReport(r.id, 'actioned');
                                  _load();
                                } catch (e) {
                                  if (mounted)
                                    showSnack(context, friendlyError(e, l));
                                }
                              },
                            ),
                          if (r.targetType == 'comment')
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              tooltip: l.delete,
                              onPressed: () async {
                                try {
                                  await _repo.deleteComment(r.targetId);
                                  await _repo.reviewReport(r.id, 'actioned');
                                  _load();
                                } catch (e) {
                                  if (mounted)
                                    showSnack(context, friendlyError(e, l));
                                }
                              },
                            ),
                          if (r.targetType == 'profile')
                            IconButton(
                              icon: const Icon(Icons.block),
                              tooltip: l.suspendAccount,
                              onPressed: () async {
                                try {
                                  await _repo.setAccountStatus(
                                    r.targetId,
                                    'suspended',
                                  );
                                  await _repo.reviewReport(r.id, 'actioned');
                                  _load();
                                } catch (e) {
                                  if (mounted)
                                    showSnack(context, friendlyError(e, l));
                                }
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 32),
                  Text(
                    l.reviewedReports,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  ..._reviewed.map(
                    (r) => ListTile(
                      dense: true,
                      title: Text('${r.targetType} · ${r.reason}'),
                      subtitle: Text(r.status),
                    ),
                  ),
                  const Divider(height: 32),
                  Text(
                    l.recentActivity,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  ..._recent.map(
                    (u) => ListTile(
                      dense: true,
                      title: Text('${u['first_name']} ${u['last_name']}'),
                      subtitle: Text('@${u['username']}'),
                      trailing: _statusChip(
                        u['account_status'] as String? ?? 'active',
                        l,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _runCleanup(AppLocalizations l, int retentionDays) async {
    if (_cleaning) return;
    setState(() => _cleaning = true);
    try {
      final result = await _repo.runCleanup();
      final postsDeleted = (result['posts_deleted'] as num?)?.toInt() ?? 0;
      final mediaDeleted = (result['media_deleted'] as num?)?.toInt() ?? 0;
      final errors = (result['errors_count'] as num?)?.toInt() ?? 0;
      final skipped = result['skipped'] == true;

      if (!mounted) return;
      final message = skipped
          ? 'لم يُنفذ التنظيف. تحقق من تفعيل التنظيف ومدة الاحتفاظ.'
          : errors > 0
          ? 'اكتمل التنظيف مع أخطاء: حُذف $postsDeleted منشورًا و$mediaDeleted ملفًا، والأخطاء: $errors.'
          : postsDeleted == 0 && mediaDeleted == 0
          ? 'تم الفحص بنجاح؛ لا توجد منشورات أقدم من $retentionDays يومًا لحذفها.'
          : 'اكتمل التنظيف: حُذف $postsDeleted منشورًا و$mediaDeleted ملفًا.';
      showSnack(context, message);
      await _load();
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e, l));
    } finally {
      if (mounted) setState(() => _cleaning = false);
    }
  }

  Widget _cleanupCard(AppLocalizations l) {
    final enabled = _cleanup['enabled'] as bool? ?? true;
    final days = (_cleanup['retention_days'] as num?)?.toInt() ?? 7;
    const values = [0, 1, 3, 7, 14, 30, 90];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'الحذف التلقائي للمنشورات',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('تشغيل الحذف التلقائي'),
              value: enabled,
              onChanged: (v) async {
                await _repo.updateCleanupSettings(
                  enabled: v,
                  retentionDays: days,
                );
                if (mounted)
                  setState(() => _cleanup = {..._cleanup, 'enabled': v});
              },
            ),
            Row(
              children: [
                const Expanded(child: Text('مدة الاحتفاظ')),
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
                          await _repo.updateCleanupSettings(
                            enabled: enabled,
                            retentionDays: v,
                          );
                          if (mounted)
                            setState(
                              () =>
                                  _cleanup = {..._cleanup, 'retention_days': v},
                            );
                        },
                ),
              ],
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: _cleaning
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cleaning_services_outlined),
              label: Text(
                _cleaning ? 'جارٍ فحص التنظيف…' : 'تنفيذ التنظيف الآن',
              ),
              onPressed: !enabled || days == 0 || _cleaning
                  ? null
                  : () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          content: const Text(
                            'سيتم حذف المنشورات القديمة وملفات الوسائط نهائيًا. هل تريد المتابعة؟',
                          ),
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
                      if (ok != true) return;
                      await _runCleanup(l, days);
                    },
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String status, AppLocalizations l) {
    final suspended = status == 'suspended';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: suspended
            ? NexColors.danger.withValues(alpha: 0.2)
            : NexColors.success.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        suspended ? l.suspendAccount : l.activeUsers,
        style: TextStyle(
          fontSize: 10,
          color: suspended ? NexColors.danger : NexColors.success,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: NexColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: NexColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: NexColors.accent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: NexColors.textDim, fontSize: 11),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
