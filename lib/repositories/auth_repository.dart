import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

/// All authentication flows. Plaintext passwords never touch PostgreSQL —
/// Supabase Auth stores only bcrypt hashes.
class AuthRepository {
  SupabaseClient get _c => SupabaseService.client;

  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String username,
  }) async {
    username = username.trim().toLowerCase();
    final res = await _c.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'first_name': firstName.trim(),
        'last_name': lastName.trim(),
        'username': username,
      },
    );
    if (res.user == null) throw const AuthException('signup-failed');
  }

  Future<void> login({required String email, required String password}) async {
    await _c.auth.signInWithPassword(email: email.trim(), password: password);
  }

  Future<void> logout() => _c.auth.signOut();

  Future<void> sendPasswordReset(String email) =>
      _c.auth.resetPasswordForEmail(email.trim());

  String? get currentUserId => _c.auth.currentUser?.id;

  bool get isEmailVerified => _c.auth.currentUser?.emailConfirmedAt != null;

  Future<bool> isUsernameAvailable(String username) async {
    final rows = await _c
        .from('profiles')
        .select('id')
        .eq('username', username.toLowerCase())
        .limit(1);
    return rows.isEmpty;
  }
}
