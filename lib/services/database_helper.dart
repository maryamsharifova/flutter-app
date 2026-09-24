import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/task.dart';

/// Wraps the SQLite database. A single shared instance is reused
/// across the whole app (via DatabaseHelper.instance).
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _db;

  static const List<String> _defaultCategories = [
    "General",
    "School",
    "Work",
    "Personal",
    "Shopping",
  ];

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tasks.db');

    return openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            title TEXT NOT NULL,
            deadline TEXT,
            completed INTEGER NOT NULL DEFAULT 0,
            category TEXT NOT NULL DEFAULT 'General'
          )
        ''');

        await db.execute('''
          CREATE TABLE categories(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL UNIQUE
          )
        ''');

        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL
          )
        ''');

        for (final name in _defaultCategories) {
          await db.insert('categories', {'name': name});
        }
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Coming from version 1 (tasks table only): add categories table.
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS categories(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL UNIQUE
            )
          ''');

          for (final name in _defaultCategories) {
            await db.insert(
              'categories',
              {'name': name},
              conflictAlgorithm: ConflictAlgorithm.ignore,
            );
          }
        }

        // Coming from version < 3: add users table + user_id on tasks.
        // NOTE: any tasks that existed before this upgrade will have
        // user_id = NULL and won't belong to any account anymore.
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS users(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              username TEXT NOT NULL UNIQUE,
              password TEXT NOT NULL
            )
          ''');

          try {
            await db.execute('ALTER TABLE tasks ADD COLUMN user_id INTEGER');
          } catch (_) {
            // Column already exists - safe to ignore.
          }
        }
      },
    );
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  // ============= USERS =============

  /// Returns the user row if that username exists, otherwise null.
  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    return result.isEmpty ? null : result.first;
  }

  /// Creates a new user with a hashed password. Assumes the caller has
  /// already checked the username isn't taken.
  Future<int> insertUser(String username, String password) async {
    final db = await database;
    return db.insert('users', {
      'username': username,
      'password': _hashPassword(password),
    });
  }

  /// Returns the user row if username+password match, otherwise null.
  Future<Map<String, dynamic>?> validateUser(
    String username,
    String password,
  ) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, _hashPassword(password)],
    );

    return result.isEmpty ? null : result.first;
  }

  // ============= TASKS (scoped per user) =============

  Future<List<Task>> getTasks(int userId) async {
    final db = await database;
    final maps = await db.query(
      'tasks',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    return maps.map((map) => Task.fromMap(map)).toList();
  }

  Future<int> insertTask(Task task, int userId) async {
    final db = await database;
    final map = task.toMap();
    map['user_id'] = userId;

    return db.insert('tasks', map);
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    return db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // ============= CATEGORIES (shared across all users) =============

  Future<List<String>> getCategories() async {
    final db = await database;
    final maps = await db.query('categories', orderBy: 'id ASC');

    return maps.map((map) => map['name'] as String).toList();
  }

  Future<void> insertCategory(String name) async {
    final db = await database;
    await db.insert(
      'categories',
      {'name': name},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> deleteCategory(String name) async {
    final db = await database;
    await db.delete('categories', where: 'name = ?', whereArgs: [name]);
  }
}