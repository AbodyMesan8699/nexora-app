import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/config.dart';
import '../../core/theme.dart';
import '../../core/error_mapper.dart';
import '../../core/widgets.dart';
import '../../l10n_gen/app_localizations.dart';
import '../../repositories/auth_repository.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'check_email_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _repo = AuthRepository();
  bool _busy = false;
  bool _obscure = true;

  Future<void> _login() async {
    final l = AppLocalizations.of(context)!;
    if (_email.text.trim().isEmpty || _pass.text.isEmpty) return;
    setState(() => _busy = true);
    try {
      await _repo.login(email: _email.text, password: _pass.text);
      await SupabasePresence.setOnline(true);
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e, l));
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const NexoraLogo(size: 84),
                const SizedBox(height: 12),
                const Text('NEXORA',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: 4)),
                const SizedBox(height: 4),
                Text(l.tagline,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: NexColors.textDim)),
                const SizedBox(height: 36),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(hintText: l.email, prefixIcon: const Icon(Icons.alternate_email, size: 20)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _pass,
                  obscureText: _obscure,
                  onSubmitted: (_) => _login(),
                  decoration: InputDecoration(
                    hintText: l.password,
                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, size: 20),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Directionality.of(context) == TextDirection.rtl
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                    child: Text(l.forgotPassword),
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: _busy ? null : _login,
                  child: _busy
                      ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(l.login),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l.noAccount, style: const TextStyle(color: NexColors.textDim)),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const RegisterScreen())),
                      child: Text(l.register),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
