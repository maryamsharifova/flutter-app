import 'package:flutter_riverpod/legacy.dart';

import '../services/database_helper.dart';

class AppUser {
  final int id;
  final String username;

  AppUser({required this.id, required this.username});
}

/// Holds the currently logged-in user (null = nobody logged in).
/// This is session-only - it's never persisted, so the app always
/// starts at the login screen, by design.
class AuthNotifier extends StateNotifier<AppUser?> {
  AuthNotifier() : super(null);

  /// Returns null on success, or an error message to show the user.
  Future<String?> signUp(String username, String password) async {
    final trimmed = username.trim();

    if (trimmed.isEmpty || password.isEmpty) {
      return "Please fill in both fields";
    }

    if (password.length < 4) {
      return "Password must be at least 4 characters";
    }

    final existing = await DatabaseHelper.instance.getUserByUsername(trimmed);

    if (existing != null) {
      return "This username is already taken";
    }

    final id = await DatabaseHelper.instance.insertUser(trimmed, password);
    state = AppUser(id: id, username: trimmed);
    return null;
  }

  /// Returns null on success, or an error message to show the user.
  Future<String?> login(String username, String password) async {
    final trimmed = username.trim();

    if (trimmed.isEmpty || password.isEmpty) {
      return "Please fill in both fields";
    }

    final user = await DatabaseHelper.instance.validateUser(trimmed, password);

    if (user == null) {
      return "Incorrect username or password";
    }

    state = AppUser(
      id: user['id'] as int,
      username: user['username'] as String,
    );

    return null;
  }

  void logout() {
    state = null;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AppUser?>((ref) {
  return AuthNotifier();
});