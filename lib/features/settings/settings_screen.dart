import 'package:flutter/material.dart';
import '../../core/app_update_config.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../core/error_mapper.dart';
import '../../l10n_gen/app_localizations.dart';
import '../../models/models.dart';
import '../../repositories/profile_repository.dart';
import '../../repositories/social_repository.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/admin_repository.dart';
import '../../services/app_update_service.dart';
import '../../state/app_state.dart';
import 'about_app_screen.dart';
import '../update/update_flow.dart';
import '../admin/user_controls_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  UserSettings? _settings;
  List<Profile> _blocked = [];
  bool _isAdmin = false;
  bool _checkingForUpdate = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final uid = AuthRepository().currentUserId!;
      final s = await ProfileRepository().getSettings(uid);
      final b = await SocialRepository().blockedList();
      final admin = await AdminRepository().isAdmin();
      if (!mounted) return;
      setState(() {
        _settings = s;
        _blocked = b;
        _isAdmin = admin;
      });
    } catch (_) {}
  }

  Future<void> _update(UserSettings s) async {
    final l = AppLocalizations.of(context)!;
    setState(() => _settings = s);
    try {
      await ProfileRepository().saveSettings(s);
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e, l));
    }
  }

  Future<void> _checkForAppUpdate() async {
    final l = AppLocalizations.of(context);
    if (!AppUpdateConfig.isConfigured) {
      showSnack(context, l.updateRepositoryNotConfigured);
      return;
    }
    setState(() => _checkingForUpdate = true);
    try {
      final release = await AppUpdateService().checkForUpdate(force: true);
      if (!mounted) return;
      if (release == null) {
        showSnack(context, l.updateLatest);
      } else {
        await showAppUpdatePrompt(context, release);
      }
    } catch (_) {
      if (mounted) showSnack(context, l.updateCheckFailed);
    } finally {
      if (mounted) setState(() => _checkingForUpdate = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final s = _settings;
    final levels = {
      'everyone': l.visibilityEveryone,
      'followers': l.visibilityFollowers,
      'friends': l.visibilityFriends,
      'nobody': l.visibilityNobody,
    };
    DropdownButton<String> dropdown(
      String value,
      void Function(String) onChanged,
    ) => DropdownButton<String>(
      value: value,
      dropdownColor: NexColors.surfaceHi,
      items: levels.entries
          .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
          .toList(),
      onChanged: (v) => v == null ? null : onChanged(v),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: s == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  l.privacy,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  title: Text(l.profileVisibility),
                  trailing: dropdown(
                    s.profileVisibility,
                    (v) => _update(
                      UserSettings(
                        userId: s.userId,
                        profileVisibility: v,
                        messagePrivacy: s.messagePrivacy,
                        followPrivacy: s.followPrivacy,
                        onlineStatusVisible: s.onlineStatusVisible,
                      ),
                    ),
                  ),
                ),
                ListTile(
                  title: Text(l.whoCanFollow),
                  trailing: dropdown(
                    s.followPrivacy,
                    (v) => _update(
                      UserSettings(
                        userId: s.userId,
                        profileVisibility: s.profileVisibility,
                        messagePrivacy: s.messagePrivacy,
                        followPrivacy: v,
                        onlineStatusVisible: s.onlineStatusVisible,
                      ),
                    ),
                  ),
                ),
                ListTile(
                  title: Text(l.whoCanMessage),
                  trailing: dropdown(
                    s.messagePrivacy,
                    (v) => _update(
                      UserSettings(
                        userId: s.userId,
                        profileVisibility: s.profileVisibility,
                        messagePrivacy: v,
                        followPrivacy: s.followPrivacy,
                        onlineStatusVisible: s.onlineStatusVisible,
                      ),
                    ),
                  ),
                ),
                SwitchListTile(
                  title: Text(l.showOnlineStatus),
                  value: s.onlineStatusVisible,
                  onChanged: (v) => _update(
                    UserSettings(
                      userId: s.userId,
                      profileVisibility: s.profileVisibility,
                      messagePrivacy: s.messagePrivacy,
                      followPrivacy: s.followPrivacy,
                      onlineStatusVisible: v,
                    ),
                  ),
                  activeColor: NexColors.accent,
                ),
                const Divider(height: 32),
                if (_isAdmin) ...[
                  Text(
                    l.adminPanel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.manage_accounts_outlined),
                      title: const Text('إدارة المستخدمين'),
                      subtitle: const Text(
                        'البحث عن الحسابات وإيقافها أو استعادتها',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UserControlsScreen(),
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 32),
                ],
                Text(
                  l.language,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(value: 'ar', label: Text(l.arabic)),
                    ButtonSegment(value: 'en', label: Text(l.english)),
                  ],
                  selected: {AppState().locale.languageCode},
                  onSelectionChanged: (sel) {
                    AppState().setLocale(Locale(sel.first));
                  },
                ),
                const Divider(height: 32),
                Text(
                  l.block,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                ..._blocked.map(
                  (p) => ListTile(
                    leading: ProfileAvatar(profile: p, radius: 18),
                    title: Text(p.fullName),
                    subtitle: Text('@${p.username}'),
                    trailing: TextButton(
                      onPressed: () async {
                        await SocialRepository().unblock(p.id);
                        _load();
                      },
                      child: Text(l.unblock),
                    ),
                  ),
                ),
                const Divider(height: 32),
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.info_outline,
                      color: NexColors.accent,
                    ),
                    title: Text(l.aboutApp),
                    subtitle: Text(l.aboutAppSubtitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutAppScreen()),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.system_update_alt_rounded,
                      color: NexColors.accent,
                    ),
                    title: Text(l.checkForUpdates),
                    subtitle: Text(l.checkForUpdatesSubtitle),
                    trailing: _checkingForUpdate
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.chevron_right),
                    onTap: _checkingForUpdate ? null : _checkForAppUpdate,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () async {
                    await SupabasePresence.setOnline(false);
                    await AuthRepository().logout();
                    if (context.mounted) AppState().clear();
                  },
                  child: Text(l.logout),
                ),
              ],
            ),
    );
  }
}
