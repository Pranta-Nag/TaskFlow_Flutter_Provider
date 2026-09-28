enum TaskPriority {
  low('Low', 0xFF0284C7, 0xFFE0F2FE),
  medium('Medium', 0xFFD97706, 0xFFFEF3C7),
  high('High', 0xFFDC2626, 0xFFFEE2E2);

  final String label;
  final int colorValue;
  final int bgValue;

  const TaskPriority(this.label, this.colorValue, this.bgValue);
}

class Task {
  final String id;
  final String title;
  final String description;
  final TaskPriority priority;
  final DateTime createdAt;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.description,
    this.priority = TaskPriority.medium,
    DateTime? createdAt,
    this.isCompleted = false,
  }) : createdAt = createdAt ?? DateTime.now();

  void toggle() {
    isCompleted = !isCompleted;
  }
}
