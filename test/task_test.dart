import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/models/task.dart';

void main() {
  group('Task', () {
    test('toMap converts all fields correctly', () {
      final deadline = DateTime(2026, 10, 20);

      final task = Task(
        id: 1,
        title: 'Buy milk',
        deadline: deadline,
        completed: true,
        category: 'Shopping',
      );

      final map = task.toMap();

      expect(map['id'], 1);
      expect(map['title'], 'Buy milk');
      expect(map['deadline'], deadline.toIso8601String());
      expect(map['completed'], 1);
      expect(map['category'], 'Shopping');
    });

    test('toMap leaves out id when it is null', () {
      final map = Task(title: 'New task').toMap();

      expect(map.containsKey('id'), isFalse);
    });

    test('fromMap rebuilds a Task from a database row', () {
      final task = Task.fromMap({
        'id': 5,
        'title': 'Study',
        'deadline': '2026-11-01T00:00:00.000',
        'completed': 0,
        'category': 'School',
      });

      expect(task.id, 5);
      expect(task.title, 'Study');
      expect(task.deadline, DateTime(2026, 11, 1));
      expect(task.completed, isFalse);
      expect(task.category, 'School');
    });

    test('fromMap handles missing deadline and category', () {
      final task = Task.fromMap({
        'id': 2,
        'title': 'Simple',
        'deadline': null,
        'completed': 1,
        'category': null,
      });

      expect(task.deadline, isNull);
      expect(task.completed, isTrue);
      expect(task.category, 'General');
    });

    test('toMap then fromMap keeps the data unchanged', () {
      final original = Task(
        id: 9,
        title: 'Round trip',
        deadline: DateTime(2027, 1, 15),
        completed: true,
        category: 'Work',
      );

      final copy = Task.fromMap(original.toMap());

      expect(copy.id, original.id);
      expect(copy.title, original.title);
      expect(copy.deadline, original.deadline);
      expect(copy.completed, original.completed);
      expect(copy.category, original.category);
    });
  });
}