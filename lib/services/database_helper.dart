import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/task.dart';

/// Wraps the SQLite database. A single shared instance is reused
/// across the whole app (via DatabaseHelper.instance).
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _db;

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
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            deadline TEXT,
            completed INTEGER NOT NULL DEFAULT 0,
            category TEXT NOT NULL DEFAULT 'General'
          )
        ''');
      },
    );
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final maps = await db.query('tasks');

    return maps.map((map) => Task.fromMap(map)).toList();
  }

  Future<int> insertTask(Task task) async {
    final db = await database;
    return db.insert('tasks', task.toMap());
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
}