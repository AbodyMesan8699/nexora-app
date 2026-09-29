import 'dart:async';
import 'package:flutter/material.dart';
import '../l10n_gen/app_localizations.dart';

/// Watches connectivity and surfaces an offline banner with retry instead of
/// crashing when the network drops.
class NetworkMonitor extends ChangeNotifier {
  bool _offline = false;
  bool get offline => _offline;

  void simulateCheck(Future<bool> Function() probe) {
    Timer.periodic(const Duration(seconds: 20), (_) async {
      try {
        final ok = await probe();
        _setOffline(!ok);
      } catch (_) {
        _setOffline(true);
      }
    });
  }

  void _setOffline(bool v) {
    if (_offline != v) {
      _offline = v;
      notifyListeners();
    }
  }
}

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: NetworkMonitor(),
      builder: (context, _) {
        final m = NetworkMonitor();
        if (!m.offline) return const SizedBox.shrink();
        return Material(
          color: const Color(0xFFE5484D),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(children: [
                const Icon(Icons.wifi_off, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.errorOffline,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ]),
            ),
          ),
        );
      },
    );
  }
}
