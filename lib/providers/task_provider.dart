import 'package:flutter/foundation.dart';
import '../models/task.dart';

enum TaskFilter { all, pending, completed }

class TaskProvider extends ChangeNotifier {
  final List<Task> _tasks = [
    Task(
      id: 'demo-1',
      title: 'Review System Architecture',
      description: 'Audit clean separation between Model, Provider, and UI presentation components.',
      priority: TaskPriority.high,
      isCompleted: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    Task(
      id: 'demo-2',
      title: 'Design Classy & Smart UI Layout',
      description: 'Implement modern card micro-interactions, smooth status pills, and progress rings.',
      priority: TaskPriority.medium,
      isCompleted: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
    Task(
      id: 'demo-3',
      title: 'Prepare Viva Defense Answers',
      description: 'Explain difference between context.read for mutations and context.watch for subscriptions.',
      priority: TaskPriority.low,
      isCompleted: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
  ];

  TaskFilter _currentFilter = TaskFilter.all;

  List<Task> get tasks => List.unmodifiable(_tasks);

  TaskFilter get currentFilter => _currentFilter;

  List<Task> get filteredTasks {
    switch (_currentFilter) {
      case TaskFilter.pending:
        return _tasks.where((t) => !t.isCompleted).toList();
      case TaskFilter.completed:
        return _tasks.where((t) => t.isCompleted).toList();
      case TaskFilter.all:
        return List.unmodifiable(_tasks);
    }
  }

  int get totalTasks => _tasks.length;
  int get completedTasks => _tasks.where((task) => task.isCompleted).length;
  int get pendingTasks => _tasks.where((task) => !task.isCompleted).length;

  double get completionRate =>
      _tasks.isEmpty ? 0.0 : (completedTasks / totalTasks).clamp(0.0, 1.0);

  String get motivationalMessage {
    if (_tasks.isEmpty) return 'No tasks on your radar';
    if (completionRate == 1.0) return 'All caught up! Outstanding work 🎯';
    if (completionRate >= 0.5) return 'Great momentum, halfway there ⚡';
    return 'Focus on top priorities today 🚀';
  }

  void setFilter(TaskFilter filter) {
    if (_currentFilter != filter) {
      _currentFilter = filter;
      notifyListeners();
    }
  }

  void addTask(
    String title,
    String description, {
    TaskPriority priority = TaskPriority.medium,
  }) {
    final newTask = Task(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title.trim(),
      description: description.trim(),
      priority: priority,
      isCompleted: false,
    );

    _tasks.insert(0, newTask);
    notifyListeners();
  }

  void toggleTask(String taskId) {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      _tasks[taskIndex].toggle();
      notifyListeners();
    }
  }

  void deleteTask(String taskId) {
    _tasks.removeWhere((task) => task.id == taskId);
    notifyListeners();
  }

  void restoreTask(int index, Task task) {
    final insertIndex = index.clamp(0, _tasks.length);
    _tasks.insert(insertIndex, task);
    notifyListeners();
  }
}
