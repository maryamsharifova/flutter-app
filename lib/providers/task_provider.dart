import 'package:flutter_riverpod/legacy.dart';

import '../models/task.dart';
import '../services/database_helper.dart';

/// Holds the list of tasks BELONGING TO THE CURRENTLY LOGGED-IN USER,
/// persisted to a local SQLite database.
///
/// Unlike before, this no longer loads automatically on creation -
/// there's no user to load tasks FOR until someone logs in. Call
/// loadTasksForUser(userId) right after a successful login/signup.
class TaskNotifier extends StateNotifier<List<Task>> {
  TaskNotifier() : super([]);

  int? _currentUserId;

  Future<void> loadTasksForUser(int userId) async {
    _currentUserId = userId;
    state = await DatabaseHelper.instance.getTasks(userId);
  }

  /// Clears in-memory tasks (call this on logout so the next person
  /// who logs in doesn't briefly see the previous user's tasks).
  void clear() {
    _currentUserId = null;
    state = [];
  }

  Future<void> addTask(Task task) async {
    final userId = _currentUserId;
    if (userId == null) return;

    final id = await DatabaseHelper.instance.insertTask(task, userId);
    task.id = id;
    state = [...state, task];
  }

  Future<void> updateTask(int index, Task task) async {
    task.id = state[index].id;
    await DatabaseHelper.instance.updateTask(task);

    final newList = [...state];
    newList[index] = task;
    state = newList;
  }

  Future<void> deleteTask(int index) async {
    final id = state[index].id;

    if (id != null) {
      await DatabaseHelper.instance.deleteTask(id);
    }

    final newList = [...state]..removeAt(index);
    state = newList;
  }

  Future<void> toggleTask(Task task) async {
    final index = state.indexOf(task);

    if (index != -1) {
      task.completed = !task.completed;
      await DatabaseHelper.instance.updateTask(task);
      state = [...state];
    }
  }
}

/// Global provider - watch this anywhere with `ref.watch(taskProvider)`.
final taskProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier();
});