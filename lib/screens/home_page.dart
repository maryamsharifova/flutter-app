import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';
import '../providers/category_provider.dart';
import '../providers/auth_provider.dart';
import '../auth/login_page.dart';
import '../widgets/task_card.dart';
import '../widgets/task_dialog.dart';
import '../widgets/category_manager_dialog.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  // Search/category-filter are transient UI state - fine to keep local.
  // The category LIST itself now lives in categoryProvider (SQLite-backed).
  String searchText = "";
  String selectedCategory = "All";

  // Pastel renkler
  static const Color backgroundPink = Color(0xFFFFF6F9);
  static const Color pastelGreen = Color(0xFFE4F1E8);
  static const Color pastelPink = Color(0xFFD98FA6);
  static const Color darkText = Color(0xFF403238);
  static const Color lightText = Color(0xFF8C8085);

  Future<void> addTask() async {
    final Task? task = await showDialog(
      context: context,
      builder: (_) => const TaskDialog(),
    );

    if (task != null) {
      await ref.read(taskProvider.notifier).addTask(task);
    }
  }

  Future<void> editTask(int index) async {
    final allTasks = ref.read(taskProvider);

    final Task? updated = await showDialog(
      context: context,
      builder: (_) => TaskDialog(
        task: allTasks[index],
      ),
    );

    if (updated != null) {
      await ref.read(taskProvider.notifier).updateTask(index, updated);
    }
  }

  Future<void> toggleTask(Task task) async {
    await ref.read(taskProvider.notifier).toggleTask(task);
  }

  Future<void> manageCategories() async {
    await showDialog(
      context: context,
      builder: (_) => const CategoryManagerDialog(),
    );
  }

  void logout() {
    ref.read(taskProvider.notifier).clear();
    ref.read(authProvider.notifier).logout();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watching taskProvider/categoryProvider means this widget rebuilds
    // automatically whenever either changes - no setState needed for them.
    final allTasks = ref.watch(taskProvider);
    final userCategories = ref.watch(categoryProvider);

    // "All" is a UI-only filter option, never stored in the database.
    final displayCategories = ["All", ...userCategories];

    // If a category was deleted while it was selected, fall back to "All"
    // without needing setState (avoids mutating state during build).
    final effectiveSelectedCategory =
        displayCategories.contains(selectedCategory)
            ? selectedCategory
            : "All";

    final tasks = allTasks.where((task) {
      final matchesSearch = task.title
          .toLowerCase()
          .contains(searchText.toLowerCase());

      final matchesCategory =
          effectiveSelectedCategory == "All" ||
          task.category == effectiveSelectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();

    final completedTasks =
        allTasks.where((task) => task.completed).length;

    return Scaffold(
      backgroundColor: backgroundPink,

      body: SafeArea(
        child: Column(
          children: [
            // =========================
            // HEADER
            // =========================
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Good morning",
                          style: TextStyle(
                            color: pastelPink,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 5),

                        const Text(
                          "My Tasks",
                          style: TextStyle(
                            color: darkText,
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          "$completedTasks of ${allTasks.length} tasks completed",
                          style: const TextStyle(
                            color: lightText,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // LOGOUT BUTTON
                      IconButton(
                        onPressed: logout,
                        icon: const Icon(
                          Icons.logout,
                          color: lightText,
                          size: 22,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),

                      const SizedBox(height: 6),

                      // ADD BUTTON
                      ElevatedButton.icon(
                        onPressed: addTask,
                        icon: const Icon(
                          Icons.add,
                          size: 23,
                        ),
                        label: const Text(
                          "Add",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: pastelPink,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // =========================
            // SEARCH
            // =========================
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 12),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search your tasks...",
                  hintStyle: const TextStyle(
                    color: Color(0xFFAAA0A5),
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: pastelPink,
                    size: 28,
                  ),
                  filled: true,
                  fillColor: pastelGreen,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 18,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(
                      color: Color(0xFFD3E5D8),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(
                      color: pastelPink,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),

            // =========================
            // CATEGORY FILTERS
            // =========================
            SizedBox(
              height: 52,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 22),
                // +1 for the trailing "edit categories" chip
                itemCount: displayCategories.length + 1,
                itemBuilder: (context, index) {
                  // Last item: the pencil / edit-categories chip
                  if (index == displayCategories.length) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: manageCategories,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: pastelGreen,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFFD3E5D8),
                            ),
                          ),
                          child: const Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: darkText,
                          ),
                        ),
                      ),
                    );
                  }

                  final category = displayCategories[index];
                  final isSelected =
                      effectiveSelectedCategory == category;

                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                      child: AnimatedContainer(
                        duration:
                            const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? pastelPink
                              : pastelGreen,
                          borderRadius:
                              BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? pastelPink
                                : const Color(0xFFD3E5D8),
                          ),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : darkText,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 18),

            // =========================
            // TASK TITLE
            // =========================
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                children: [
                  const Text(
                    "Tasks",
                    style: TextStyle(
                      color: darkText,
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(width: 9),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4D9E1),
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${tasks.length}",
                      style: const TextStyle(
                        color: pastelPink,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // =========================
            // TASK LIST
            // =========================
            Expanded(
              child: tasks.isEmpty
                  ? const Center(
                      child: Text(
                        "No tasks found",
                        style: TextStyle(
                          color: darkText,
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        22,
                        4,
                        22,
                        100,
                      ),
                      itemCount: tasks.length,
                      itemBuilder: (_, index) {
                        final task = tasks[index];

                        return Padding(
                          padding:
                              const EdgeInsets.only(bottom: 12),
                          child: TaskCard(
                            task: task,
                            onToggle: () =>
                                toggleTask(task),

                            onDelete: () async {
                              final realIndex =
                                  allTasks.indexOf(task);

                              if (realIndex != -1) {
                                await ref
                                    .read(taskProvider.notifier)
                                    .deleteTask(realIndex);
                              }
                            },

                            onEdit: () {
                              final realIndex =
                                  allTasks.indexOf(task);

                              if (realIndex != -1) {
                                editTask(realIndex);
                              }
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}