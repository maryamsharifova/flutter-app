import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/category_provider.dart';

/// Lets the user add new categories and delete existing ones.
/// Reads/writes directly through categoryProvider - same pattern as
/// how HomePage talks to taskProvider.
class CategoryManagerDialog extends ConsumerStatefulWidget {
  const CategoryManagerDialog({super.key});

  @override
  ConsumerState<CategoryManagerDialog> createState() =>
      _CategoryManagerDialogState();
}

class _CategoryManagerDialogState
    extends ConsumerState<CategoryManagerDialog> {
  final TextEditingController newCategoryController = TextEditingController();

  static const Color backgroundPink = Color(0xFFFFF6F9);
  static const Color pastelGreen = Color(0xFFE4F1E8);
  static const Color pastelPink = Color(0xFFD98FA6);
  static const Color darkText = Color(0xFF403238);

  Future<void> addCategory() async {
    final text = newCategoryController.text.trim();

    if (text.isNotEmpty) {
      await ref.read(categoryProvider.notifier).addCategory(text);
      newCategoryController.clear();
    }
  }

  Future<void> removeCategory(String category) async {
    await ref.read(categoryProvider.notifier).deleteCategory(category);
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryProvider);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      backgroundColor: backgroundPink,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Edit Categories",
              style: TextStyle(
                color: darkText,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 16),

            // Existing categories - "All" is never in here, it's UI-only
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories
                  .map(
                    (category) => Chip(
                      label: Text(category),
                      backgroundColor: pastelGreen,
                      labelStyle: const TextStyle(
                        color: darkText,
                        fontWeight: FontWeight.w600,
                      ),
                      deleteIcon: const Icon(
                        Icons.close,
                        size: 16,
                        color: pastelPink,
                      ),
                      onDeleted: () => removeCategory(category),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide.none,
                      ),
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 16),

            // Add new category
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: newCategoryController,
                    decoration: InputDecoration(
                      hintText: "New category",
                      filled: true,
                      fillColor: pastelGreen,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => addCategory(),
                  ),
                ),

                const SizedBox(width: 8),

                IconButton(
                  onPressed: addCategory,
                  icon: const Icon(
                    Icons.add_circle,
                    color: pastelPink,
                    size: 30,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: pastelPink,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Done",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}