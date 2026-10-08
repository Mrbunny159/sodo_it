import 'package:flutter/material.dart';
import '../../../data/local/app_database.dart';
import '../../../core/utils/color_extension.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final Category? category;
  final ValueChanged<bool?> onCompletedChanged;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const TaskTile({
    super.key,
    required this.task,
    this.category,
    required this.onCompletedChanged,
    required this.onDelete,
    required this.onTap,
  });

  Color _getPriorityColor() {
    switch (task.priority) {
      case TaskPriority.high: return const Color(0xFFE71D36); // Red
      case TaskPriority.medium: return const Color(0xFFFF9F1C); // Yellow
      case TaskPriority.low: return const Color(0xFF2EC4B6); // Green
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('task_${task.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFE71D36),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (direction) => onDelete(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          leading: Checkbox(
            value: task.isCompleted,
            // YAHAN THEME APPLY KIYA HAI:
            activeColor: Theme.of(context).colorScheme.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onChanged: onCompletedChanged,
          ),
          title: Text(
            task.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              color: task.isCompleted ? Colors.grey : Colors.black87,
            ),
          ),
          subtitle: category != null
              ? Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: HexColor.fromHex(category!.accentColor).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    category!.name,
                    style: TextStyle(
                      fontSize: 12,
                      color: HexColor.fromHex(category!.accentColor),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          )
              : null,
          trailing: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getPriorityColor(),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}