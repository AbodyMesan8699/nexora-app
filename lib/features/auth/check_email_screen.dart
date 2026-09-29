import 'package:flutter/material.dart';
import '../../../core/widgets.dart';
import '../../../l10n_gen/app_localizations.dart';
import '../../../repositories/auth_repository.dart';

/// Shown right after sign-up while the confirmation email is pending.
class CheckEmailScreen extends StatelessWidget {
  const CheckEmailScreen({super.key});

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
              const NexoraLogo(size: 72),
              const SizedBox(height: 24),
              Text(l.checkEmailTitle,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Text(l.checkEmailBody, textAlign: TextAlign.center),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).popUntil((r) => r.isFirst);
                },
                child: Text(l.backToLogin),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
