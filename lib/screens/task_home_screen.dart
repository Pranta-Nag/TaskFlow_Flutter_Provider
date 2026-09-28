import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/add_task_dialog.dart';
import '../widgets/task_card.dart';
import '../widgets/task_statistics.dart';

class TaskHomeScreen extends StatelessWidget {
  const TaskHomeScreen({super.key});

  void _openAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const AddTaskDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final tasks = provider.filteredTasks;
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dateString = '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Taskflow',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  dateString,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const TaskStatistics(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: Row(
                children: [
                  _FilterTab(
                    label: 'All',
                    count: provider.totalTasks,
                    isSelected: provider.currentFilter == TaskFilter.all,
                    onTap: () => context.read<TaskProvider>().setFilter(TaskFilter.all),
                  ),
                  const SizedBox(width: 8),
                  _FilterTab(
                    label: 'Pending',
                    count: provider.pendingTasks,
                    isSelected: provider.currentFilter == TaskFilter.pending,
                    onTap: () => context.read<TaskProvider>().setFilter(TaskFilter.pending),
                  ),
                  const SizedBox(width: 8),
                  _FilterTab(
                    label: 'Completed',
                    count: provider.completedTasks,
                    isSelected: provider.currentFilter == TaskFilter.completed,
                    onTap: () => context.read<TaskProvider>().setFilter(TaskFilter.completed),
                  ),
                ],
              ),
            ),
            Expanded(
              child: tasks.isEmpty
                  ? _EmptyStateView(
                      filter: provider.currentFilter,
                      onAddTaskPressed: () => _openAddTaskDialog(context),
                    )
                  : ListView.builder(
                      itemCount: tasks.length,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(top: 4.0, bottom: 90.0),
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return TaskCard(
                          key: ValueKey(task.id),
                          task: task,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddTaskDialog(context),
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text(
          'New Task',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.2),
        ),
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.2)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyStateView extends StatelessWidget {
  final TaskFilter filter;
  final VoidCallback onAddTaskPressed;

  const _EmptyStateView({
    required this.filter,
    required this.onAddTaskPressed,
  });

  @override
  Widget build(BuildContext context) {
    final title = filter == TaskFilter.completed
        ? 'No Completed Tasks'
        : filter == TaskFilter.pending
            ? 'No Pending Tasks'
            : 'No Tasks Yet';

    final subtitle = filter == TaskFilter.completed
        ? 'Check off tasks as you finish them to see your accomplishments here.'
        : filter == TaskFilter.pending
            ? 'You have completed everything on your schedule. Great work!'
            : 'Add your first task to start organizing your workflow smoothly.';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFC7D2FE), width: 1.5),
              ),
              child: const Icon(
                Icons.task_alt_rounded,
                size: 44,
                color: Color(0xFF4F46E5),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFF64748B),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 22),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF4F46E5),
                side: const BorderSide(color: Color(0xFF4F46E5), width: 1.4),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onAddTaskPressed,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text(
                'Add Task',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
