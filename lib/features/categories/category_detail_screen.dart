import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/app_database.dart';
import '../../core/utils/color_extension.dart';
import '../dashboard/task_providers.dart';
import '../today/widgets/task_tile.dart';

class CategoryDetailScreen extends ConsumerWidget {
  final Category category;

  const CategoryDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch tasks specific to this category
    final tasksAsync = ref.watch(categoryTasksProvider(category.id));
    final categoryColor = HexColor.fromHex(category.accentColor);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: categoryColor),
        title: Text(
          category.name,
          style: TextStyle(fontWeight: FontWeight.bold, color: categoryColor),
        ),
      ),
      body: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (tasks) {
          if (tasks.isEmpty) {
            return Center(
              child: Text(
                'No tasks in ${category.name} yet!',
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return TaskTile(
                task: task,
                category: category,
                onCompletedChanged: (val) {
                  if (val != null) {
                    ref.read(taskRepositoryProvider).updateTask(task.copyWith(isCompleted: val));
                  }
                },
                onDelete: () => ref.read(taskRepositoryProvider).deleteTask(task.id),
                // ADD THIS LINE TO CLEAR THE ERROR:
                onTap: () {},
              );
            },
          );
        },
      ),
    );
  }
}