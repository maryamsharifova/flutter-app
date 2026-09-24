import 'package:flutter_riverpod/legacy.dart';

import '../services/database_helper.dart';

/// Holds the list of user-defined categories ("All" is NOT stored here -
/// it's a UI-only filter concept added separately in HomePage).
class CategoryNotifier extends StateNotifier<List<String>> {
  CategoryNotifier() : super([]) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    state = await DatabaseHelper.instance.getCategories();
  }

  Future<void> addCategory(String name) async {
    if (state.contains(name)) return;

    await DatabaseHelper.instance.insertCategory(name);
    state = [...state, name];
  }

  Future<void> deleteCategory(String name) async {
    await DatabaseHelper.instance.deleteCategory(name);
    state = state.where((c) => c != name).toList();
  }
}

final categoryProvider =
    StateNotifierProvider<CategoryNotifier, List<String>>((ref) {
  return CategoryNotifier();
});
