import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskDialog extends StatefulWidget {
  final Task? task;

  const TaskDialog({super.key, this.task});

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  late TextEditingController controller;
  DateTime? deadline;

  String category = "General";

  final List<String> categories = [
    "General",
    "School",
    "Work",
    "Personal",
    "Shopping",
  ];

  @override
  void initState() {
    super.initState();

    controller = TextEditingController(
      text: widget.task?.title ?? '',
    );

    deadline = widget.task?.deadline;

    category = widget.task?.category ?? "General";
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: deadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        deadline = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.task == null ? "Add Task" : "Update Task",
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: "Task",
              hintText: "Enter your task",
            ),
          ),

          const SizedBox(height: 15),

          DropdownButtonFormField<String>(
            initialValue: category,
            decoration: const InputDecoration(
              labelText: "Category",
              border: OutlineInputBorder(),
            ),
            items: categories.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  category = value;
                });
              }
            },
          ),

          const SizedBox(height: 15),

          ElevatedButton(
            onPressed: pickDate,
            child: Text(
              deadline == null
                  ? "Select Deadline"
                  : "${deadline!.day}/${deadline!.month}/${deadline!.year}",
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),

        ElevatedButton(
          onPressed: () {
            if (controller.text.trim().isEmpty) {
              return;
            }

            Navigator.pop(
              context,
              Task(
                title: controller.text.trim(),
                deadline: deadline,
                category: category,
              ),
            );
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}