import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/providers/auth_provider.dart';

// These tests only cover validation rules that return an error
// BEFORE touching the database, so no SQLite setup is needed.
void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('AuthNotifier', () {
    test('nobody is logged in at the start', () {
      expect(container.read(authProvider), isNull);
    });

    test('signUp rejects empty username', () async {
      final error =
          await container.read(authProvider.notifier).signUp('', 'abcd');

      expect(error, 'Please fill in both fields');
      expect(container.read(authProvider), isNull);
    });

    test('signUp rejects empty password', () async {
      final error =
          await container.read(authProvider.notifier).signUp('maryam', '');

      expect(error, 'Please fill in both fields');
      expect(container.read(authProvider), isNull);
    });

    test('signUp rejects a password shorter than 4 characters', () async {
      final error =
          await container.read(authProvider.notifier).signUp('maryam', 'abc');

      expect(error, 'Password must be at least 4 characters');
      expect(container.read(authProvider), isNull);
    });

    test('login rejects empty fields', () async {
      final error =
          await container.read(authProvider.notifier).login('', '');

      expect(error, 'Please fill in both fields');
      expect(container.read(authProvider), isNull);
    });

    test('logout keeps the state empty', () {
      container.read(authProvider.notifier).logout();

      expect(container.read(authProvider), isNull);
    });
  });
}