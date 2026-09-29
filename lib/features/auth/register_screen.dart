import 'package:flutter/material.dart';
import '../../../core/error_mapper.dart';
import '../../../core/widgets.dart';
import '../../../l10n_gen/app_localizations.dart';
import '../../../repositories/auth_repository.dart';
import 'check_email_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _user = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _repo = AuthRepository();
  bool _busy = false;
  bool? _usernameOk;
  bool _obscure = true;

  Future<void> _checkUsername(String v) async {
    final u = v.trim().toLowerCase();
    if (u.length < 3) {
      setState(() => _usernameOk = null);
      return;
    }
    try {
      final ok = await _repo.isUsernameAvailable(u);
      if (mounted) setState(() => _usernameOk = ok);
    } catch (_) {}
  }

  Future<void> _register() async {
    final l = AppLocalizations.of(context)!;
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await _repo.register(
        email: _email.text,
        password: _pass.text,
        firstName: _first.text,
        lastName: _last.text,
        username: _user.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CheckEmailScreen()));
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e, l));
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.createAccount)),
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              TextFormField(
                controller: _first,
                decoration: InputDecoration(hintText: l.firstName),
                validator: (v) => (v == null || v.trim().isEmpty) ? l.errorGeneric : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _last,
                decoration: InputDecoration(hintText: l.lastName),
                validator: (v) => (v == null || v.trim().isEmpty) ? l.errorGeneric : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _user,
                decoration: InputDecoration(
                  hintText: l.username,
                  prefixText: '@ ',
                  suffixIcon: _usernameOk == null
                      ? null
                      : Icon(_usernameOk! ? Icons.check_circle : Icons.cancel,
                          color: _usernameOk! ? const Color(0xFF30A46C) : const Color(0xFFE5484D),
                          size: 20),
                ),
                onChanged: _checkUsername,
                validator: (v) =>
                    (v == null || !RegExp(r'^[a-z0-9_.]{3,24}$').hasMatch(v.trim().toLowerCase()))
                        ? l.errorGeneric
                        : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(hintText: l.email),
                validator: (v) => (v == null || !v.contains('@')) ? l.errorGeneric : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pass,
                obscureText: _obscure,
                decoration: InputDecoration(
                  hintText: l.password,
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, size: 20),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (v) => (v == null || v.length < 8) ? l.errorGeneric : null,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _busy ? null : _register,
                child: _busy
                    ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l.register),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l.haveAccount, style: const TextStyle(color: Color(0xFF9AA0AB))),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l.login),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
