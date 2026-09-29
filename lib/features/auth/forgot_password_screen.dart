import 'package:flutter/material.dart';
import '../../../core/error_mapper.dart';
import '../../../core/widgets.dart';
import '../../../l10n_gen/app_localizations.dart';
import '../../../repositories/auth_repository.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  final _repo = AuthRepository();
  bool _busy = false;

  Future<void> _send() async {
    final l = AppLocalizations.of(context)!;
    if (!_email.text.contains('@')) return;
    setState(() => _busy = true);
    try {
      await _repo.sendPasswordReset(_email.text);
      if (!mounted) return;
      showSnack(context, l.checkEmailBody);
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e, l));
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.resetPassword)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(hintText: l.email),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _busy ? null : _send,
              child: _busy
                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(l.sendResetLink),
            ),
          ],
        ),
      ),
    );
  }
}
