import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/providers/auth_provider.dart';
import 'package:todo_app/providers/task_provider.dart';
import 'package:todo_app/services/database_helper.dart';

// These tests use a REAL SQLite database (through sqflite_common_ffi),
// stored in a temporary folder that is created fresh for every run.
//
// All tests in this file share that one database, so every test creates
// its own users with unique names and never assumes the database is empty.

int _counter = 0;

String uniqueName(String base) => '${base}_${_counter++}';

ProviderContainer makeContainer() {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  return container;
}

List<String> titlesOf(ProviderContainer container) {
  return container.read(taskProvider).map((task) => task.title).toList();
}

void main() {
  late Directory tempDir;
  final db = DatabaseHelper.instance;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    tempDir = await Directory.systemTemp.createTemp('todo_app_test_');
    await databaseFactory.setDatabasesPath(tempDir.path);
  });

  tearDownAll(() async {
    try {
      await tempDir.delete(recursive: true);
    } catch (_) {
      // The database file can still be locked on Windows. The OS cleans
      // the temp folder later, so it is safe to ignore this.
    }
  });

  group('users table', () {
    test('stores a hashed password, never the plain one', () async {
      final name = uniqueName('hash');
      await db.insertUser(name, 'secret123');

      final row = (await db.getUserByUsername(name))!;

      expect(row['username'], name);
      expect(row['password'], isNot('secret123'));
      expect((row['password'] as String).length, 64); // SHA-256 in hex
    });

    test('getUserByUsername returns null for an unknown user', () async {
      expect(await db.getUserByUsername(uniqueName('ghost')), isNull);
    });

    test('validateUser accepts the correct password', () async {
      final name = uniqueName('valid');
      await db.insertUser(name, 'pass1234');

      final row = await db.validateUser(name, 'pass1234');

      expect(row, isNotNull);
      expect(row!['username'], name);
    });

    test('validateUser rejects a wrong password', () async {
      final name = uniqueName('wrongpass');
      await db.insertUser(name, 'pass1234');

      expect(await db.validateUser(name, 'nope9999'), isNull);
    });

    test('validateUser rejects an unknown user', () async {
      expect(await db.validateUser(uniqueName('nobody'), 'pass1234'), isNull);
    });

    test('the same username cannot be inserted twice', () async {
      final name = uniqueName('dup');
      await db.insertUser(name, 'pass1234');

      await expectLater(
        db.insertUser(name, 'other999'),
        throwsA(isA<DatabaseException>()),
      );
    });
  });

  group('tasks table', () {
    test('each user only sees their own tasks', () async {
      final alice = await db.insertUser(uniqueName('alice'), 'pass1234');
      final bob = await db.insertUser(uniqueName('bob'), 'pass1234');

      await db.insertTask(Task(title: 'Alice task'), alice);
      await db.insertTask(Task(title: 'Bob task 1'), bob);
      await db.insertTask(Task(title: 'Bob task 2'), bob);

      final aliceTitles =
          (await db.getTasks(alice)).map((t) => t.title).toList();
      final bobTitles = (await db.getTasks(bob)).map((t) => t.title).toList();

      expect(aliceTitles, ['Alice task']);
      expect(bobTitles, unorderedEquals(['Bob task 1', 'Bob task 2']));
    });

    test('a new user starts with no tasks', () async {
      final user = await db.insertUser(uniqueName('fresh'), 'pass1234');

      expect(await db.getTasks(user), isEmpty);
    });

    test('updateTask saves the changes', () async {
      final user = await db.insertUser(uniqueName('updater'), 'pass1234');
      final id = await db.insertTask(Task(title: 'Old title'), user);

      await db.updateTask(
        Task(id: id, title: 'New title', completed: true, category: 'Work'),
      );

      final saved = (await db.getTasks(user)).single;

      expect(saved.title, 'New title');
      expect(saved.completed, isTrue);
      expect(saved.category, 'Work');
    });

    test('deleteTask removes only that task', () async {
      final user = await db.insertUser(uniqueName('deleter'), 'pass1234');
      final keepId = await db.insertTask(Task(title: 'Keep me'), user);
      final removeId = await db.insertTask(Task(title: 'Remove me'), user);

      await db.deleteTask(removeId);

      final remaining = await db.getTasks(user);

      expect(remaining.map((t) => t.id), [keepId]);
    });
  });

  group('categories table', () {
    test('the default categories are created', () async {
      final categories = await db.getCategories();

      expect(
        categories,
        containsAll(['General', 'School', 'Work', 'Personal', 'Shopping']),
      );
    });

    test('insertCategory adds and deleteCategory removes', () async {
      final name = uniqueName('Gym');

      await db.insertCategory(name);
      expect(await db.getCategories(), contains(name));

      await db.deleteCategory(name);
      expect(await db.getCategories(), isNot(contains(name)));
    });

    test('adding the same category twice does not duplicate it', () async {
      final name = uniqueName('Music');

      await db.insertCategory(name);
      await db.insertCategory(name);

      final matches = (await db.getCategories()).where((c) => c == name);

      expect(matches.length, 1);
    });
  });

  group('auth and tasks working together', () {
    test('signUp, logout and login work end to end', () async {
      final container = makeContainer();
      final auth = container.read(authProvider.notifier);
      final name = uniqueName('maryam');

      expect(await auth.signUp(name, 'pass1234'), isNull);
      expect(container.read(authProvider)?.username, name);

      auth.logout();
      expect(container.read(authProvider), isNull);

      expect(await auth.login(name, 'pass1234'), isNull);
      expect(container.read(authProvider)?.username, name);
    });

    test('signUp rejects a username that is already taken', () async {
      final container = makeContainer();
      final auth = container.read(authProvider.notifier);
      final name = uniqueName('taken');

      expect(await auth.signUp(name, 'pass1234'), isNull);
      auth.logout();

      expect(
        await auth.signUp(name, 'other999'),
        'This username is already taken',
      );
      expect(container.read(authProvider), isNull);
    });

    test('login fails with a wrong password', () async {
      final container = makeContainer();
      final auth = container.read(authProvider.notifier);
      final name = uniqueName('lockedout');

      await auth.signUp(name, 'pass1234');
      auth.logout();

      expect(
        await auth.login(name, 'wrong999'),
        'Incorrect username or password',
      );
      expect(container.read(authProvider), isNull);
    });

    test('login fails for a user that does not exist', () async {
      final container = makeContainer();
      final auth = container.read(authProvider.notifier);

      expect(
        await auth.login(uniqueName('missing'), 'pass1234'),
        'Incorrect username or password',
      );
    });

    test('tasks stay separate between two users', () async {
      final container = makeContainer();
      final auth = container.read(authProvider.notifier);
      final tasks = container.read(taskProvider.notifier);

      // User A signs up and adds a task.
      await auth.signUp(uniqueName('userA'), 'pass1234');
      final idA = container.read(authProvider)!.id;
      await tasks.loadTasksForUser(idA);
      await tasks.addTask(Task(title: 'A secret'));
      expect(titlesOf(container), ['A secret']);

      // User A logs out, user B signs up and sees an empty list.
      auth.logout();
      tasks.clear();
      await auth.signUp(uniqueName('userB'), 'pass1234');
      final idB = container.read(authProvider)!.id;
      await tasks.loadTasksForUser(idB);
      expect(titlesOf(container), isEmpty);

      await tasks.addTask(Task(title: 'B note'));
      expect(titlesOf(container), ['B note']);

      // User A comes back and only sees their own task.
      await tasks.loadTasksForUser(idA);
      expect(titlesOf(container), ['A secret']);
    });

    test('a completed task is still completed after reloading', () async {
      final container = makeContainer();
      final auth = container.read(authProvider.notifier);
      final tasks = container.read(taskProvider.notifier);

      await auth.signUp(uniqueName('toggler'), 'pass1234');
      final id = container.read(authProvider)!.id;
      await tasks.loadTasksForUser(id);
      await tasks.addTask(Task(title: 'Toggle me'));

      await tasks.toggleTask(container.read(taskProvider).first);

      tasks.clear();
      await tasks.loadTasksForUser(id);

      expect(container.read(taskProvider).first.completed, isTrue);
    });

    test('a deleted task stays deleted after reloading', () async {
      final container = makeContainer();
      final auth = container.read(authProvider.notifier);
      final tasks = container.read(taskProvider.notifier);

      await auth.signUp(uniqueName('remover'), 'pass1234');
      final id = container.read(authProvider)!.id;
      await tasks.loadTasksForUser(id);
      await tasks.addTask(Task(title: 'Delete me'));

      await tasks.deleteTask(0);

      tasks.clear();
      await tasks.loadTasksForUser(id);

      expect(container.read(taskProvider), isEmpty);
    });

    test('adding a task without a logged-in user does nothing', () async {
      final container = makeContainer();
      final tasks = container.read(taskProvider.notifier);

      await tasks.addTask(Task(title: 'Nobody owns me'));

      expect(container.read(taskProvider), isEmpty);
    });
  });
}