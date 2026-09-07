import 'package:flutter/material.dart';

import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onToggle;

  const TaskCard({
    super.key,
    required this.task,
    required this.onDelete,
    required this.onEdit,
    required this.onToggle,
  });

  static const Color pastelGreen = Color(0xFFE4F1E8);
  static const Color pastelPink = Color(0xFFD98FA6);
  static const Color darkText = Color(0xFF403238);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    bool isOverdue = false;
    bool hasDeadline = task.deadline != null;

    if (task.deadline != null) {
      final deadline = DateTime(
        task.deadline!.year,
        task.deadline!.month,
        task.deadline!.day,
      );

      final today = DateTime(
        now.year,
        now.month,
        now.day,
      );

      isOverdue = deadline.isBefore(today);
    }

    Color deadlineColor;

    if (!hasDeadline) {
      deadlineColor = Colors.grey;
    } else if (isOverdue) {
      deadlineColor = Colors.red.shade400;
    } else {
      deadlineColor = Colors.green.shade600;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: pastelGreen,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFD2E5D8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // =========================
            // CHECK BUTTON
            // =========================
            GestureDetector(
              onTap: onToggle,
              child: AnimatedContainer(
                duration:
                    const Duration(milliseconds: 200),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.completed
                      ? pastelPink
                      : Colors.transparent,
                  border: Border.all(
                    color: task.completed
                        ? pastelPink
                        : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: task.completed
                    ? const Icon(
                        Icons.check,
                        size: 17,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),

            const SizedBox(width: 14),

            // =========================
            // CONTENT
            // =========================
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // TITLE
                  Text(
                    task.title,
                    style: TextStyle(
                      color: task.completed
                          ? Colors.grey
                          : darkText,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      decoration: task.completed
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),

                  const SizedBox(height: 9),

                  // CATEGORY
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.65),
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                    child: Text(
                      task.category,
                      style: const TextStyle(
                        color: darkText,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 9),

                  // DEADLINE
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 15,
                        color: deadlineColor,
                      ),

                      const SizedBox(width: 6),

                      Text(
                        hasDeadline
                            ? "${task.deadline!.day}/${task.deadline!.month}/${task.deadline!.year}"
                            : "No Deadline",
                        style: TextStyle(
                          color: deadlineColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      if (isOverdue) ...[
                        const SizedBox(width: 7),

                        Text(
                          "Overdue",
                          style: TextStyle(
                            color: Colors.red.shade400,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 6),

            // =========================
            // ACTION BUTTONS
            // =========================
            Column(
              children: [
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: darkText,
                  ),
                  visualDensity:
                      VisualDensity.compact,
                ),

                IconButton(
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Colors.red.shade300,
                  ),
                  visualDensity:
                      VisualDensity.compact,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}