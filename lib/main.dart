import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/app_update_config.dart';
import 'core/config.dart';
import 'core/theme.dart';
import 'l10n_gen/app_localizations.dart';
import 'services/app_update_service.dart';
import 'services/supabase_service.dart';
import 'state/app_state.dart';
import 'features/update/update_flow.dart';
import 'features/auth/login_screen.dart';
import 'features/home/home_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (AppConfig.isConfigured) {
    await SupabaseService.init();
  }
  runApp(const NexoraApp());
}

class NexoraApp extends StatelessWidget {
  const NexoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState();
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) => MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
        debugShowCheckedModeBanner: false,
        theme: NexTheme.dark(),
        locale: state.locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const RootGate(),
      ),
    );
  }
}

class RootGate extends StatefulWidget {
  const RootGate({super.key});

  @override
  State<RootGate> createState() => _RootGateState();
}

class _RootGateState extends State<RootGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkForUpdate());
  }

  Future<void> _checkForUpdate() async {
    if (!AppUpdateConfig.isConfigured) return;
    try {
      final release = await AppUpdateService().checkForUpdate();
      if (release != null && mounted) {
        await showAppUpdatePrompt(context, release);
      }
    } catch (_) {
      // An unavailable update service must never block app startup.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.isConfigured) return const _ConfigMissingScreen();
    return StreamBuilder<AuthState>(
      stream: SupabaseService.authStateChanges,
      builder: (context, snap) {
        final session =
            snap.data?.session ?? SupabaseService.client.auth.currentSession;
        if (session == null) return const LoginScreen();
        return const HomeShell();
      },
    );
  }
}

class _ConfigMissingScreen extends StatelessWidget {
  const _ConfigMissingScreen();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _NexoraLogo(size: 72),
              const SizedBox(height: 24),
              Text(
                l.configNeeded,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(l.configNeededBody, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

/// NEXORA logo mark — original branding: orange gradient "N" bolt.
class _NexoraLogo extends StatelessWidget {
  final double size;
  const _NexoraLogo({this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: NexTheme.accentGradient,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      alignment: Alignment.center,
      child: Text(
        'N',
        style: TextStyle(
          fontSize: size * 0.58,
          fontWeight: FontWeight.w900,
          color: Colors.black,
        ),
      ),
    );
  }
}
