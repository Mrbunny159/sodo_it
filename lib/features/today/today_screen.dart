import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../data/local/app_database.dart';
import '../dashboard/task_providers.dart';
import 'widgets/task_tile.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  void _showTaskSheet(BuildContext context, WidgetRef ref, {Task? existingTask}) {
    final categories = ref.read(categoriesStreamProvider).value ?? [];

    Category? selectedCategory = existingTask != null
        ? categories.where((c) => c.id == existingTask.categoryId).firstOrNull
        : (categories.isNotEmpty ? categories.first : null);

    TaskPriority selectedPriority = existingTask?.priority ?? TaskPriority.low;

    final textController = TextEditingController(text: existingTask?.title ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20, right: 20, top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: textController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'e.g. Java Assignment',
                  border: InputBorder.none,
                  hintStyle: TextStyle(fontSize: 20, color: Colors.grey),
                ),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  const Icon(Icons.folder_outlined, color: Colors.grey, size: 20),
                  const SizedBox(width: 10),
                  DropdownButton<Category>(
                    value: selectedCategory,
                    underline: const SizedBox(),
                    items: categories.map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat.name));
                    }).toList(),
                    onChanged: (val) => setState(() => selectedCategory = val),
                  ),
                ],
              ),

              Row(
                children: [
                  const Icon(Icons.flag_outlined, color: Colors.grey, size: 20),
                  const SizedBox(width: 10),
                  DropdownButton<TaskPriority>(
                    value: selectedPriority,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: TaskPriority.low, child: Text('Low Priority 🟢')),
                      DropdownMenuItem(value: TaskPriority.medium, child: Text('Med Priority 🟡')),
                      DropdownMenuItem(value: TaskPriority.high, child: Text('High Priority 🔴')),
                    ],
                    onChanged: (val) => setState(() => selectedPriority = val!),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    // YAHAN THEME APPLY KIYA HAI
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (textController.text.trim().isNotEmpty) {
                      final repo = ref.read(taskRepositoryProvider);

                      if (existingTask == null) {
                        repo.insertTask(TasksCompanion(
                          title: drift.Value(textController.text.trim()),
                          categoryId: drift.Value(selectedCategory?.id),
                          priority: drift.Value(selectedPriority),
                        ));
                      } else {
                        repo.updateTask(existingTask.copyWith(
                          title: textController.text.trim(),
                          categoryId: drift.Value(selectedCategory?.id),
                          priority: selectedPriority,
                        ));
                      }
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                      existingTask == null ? 'Save Task' : 'Update Task',
                      style: const TextStyle(color: Colors.white, fontSize: 16)
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(todayTasksStreamProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Today', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Text('Good Morning, Sufiyaan ☀️', style: TextStyle(fontSize: 16, color: Colors.grey)),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: tasksAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
              data: (tasks) {
                if (tasks.isEmpty) return const Center(child: Text('All Caught Up! 🎉', style: TextStyle(color: Colors.grey, fontSize: 18)));

                final categories = categoriesAsync.value ?? [];

                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final category = categories.where((c) => c.id == task.categoryId).firstOrNull;

                    return TaskTile(
                      task: task,
                      category: category,
                      onCompletedChanged: (val) {
                        if (val != null) {
                          ref.read(taskRepositoryProvider).updateTask(task.copyWith(isCompleted: val));
                        }
                      },
                      onDelete: () => ref.read(taskRepositoryProvider).deleteTask(task.id),
                      onTap: () => _showTaskSheet(context, ref, existingTask: task),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskSheet(context, ref),
        // YAHAN THEME APPLY KIYA HAI
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}