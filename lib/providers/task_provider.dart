import 'package:flutter_riverpod/legacy.dart';

import '../models/task.dart';
import '../services/database_helper.dart';

/// Holds the list of tasks and persists them to a local SQLite database.
class TaskNotifier extends StateNotifier<List<Task>> {
  TaskNotifier() : super([]) {
    loadTasks();
  }

  Future<void> loadTasks() async {
    state = await DatabaseHelper.instance.getTasks();
  }

  Future<void> addTask(Task task) async {
    final id = await DatabaseHelper.instance.insertTask(task);
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