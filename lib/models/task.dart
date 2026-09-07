class Task {
  int? id;
  String title;
  DateTime? deadline;
  bool completed;
  String category;

  Task({
    this.id,
    required this.title,
    this.deadline,
    this.completed = false,
    this.category = "General",
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'deadline': deadline?.toIso8601String(),
      'completed': completed ? 1 : 0,
      'category': category,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      deadline: map['deadline'] != null
          ? DateTime.parse(map['deadline'] as String)
          : null,
      completed: (map['completed'] as int) == 1,
      category: map['category'] as String? ?? "General",
    );
  }
}