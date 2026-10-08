import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../data/local/app_database.dart';
import '../dashboard/task_providers.dart';
import '../today/widgets/task_tile.dart';

class InboxScreen extends ConsumerStatefulWidget {
  const InboxScreen({super.key});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  Future<void> _quickAddTask() async {
    final title = _textController.text.trim();
    if (title.isEmpty) return;

    final categories = ref.read(categoriesStreamProvider).value ?? [];
    final inboxCategory = categories.firstWhere(
          (c) => c.name == 'Inbox',
      orElse: () => categories.first,
    );

    await ref.read(taskRepositoryProvider).insertTask(TasksCompanion(
      title: drift.Value(title),
      categoryId: drift.Value(inboxCategory.id),
      priority: const drift.Value(TaskPriority.low),
    ));

    _textController.clear();
    _focusNode.unfocus();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(inboxTasksProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Inbox', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _quickAddTask(),
                decoration: InputDecoration(
                  hintText: 'Quick add a task...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  suffixIcon: IconButton(
                    // YAHAN THEME APPLY KIYA HAI:
                    icon: Icon(Icons.add_circle, color: Theme.of(context).colorScheme.primary),
                    onPressed: _quickAddTask,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: tasksAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
              data: (tasks) {
                if (tasks.isEmpty) {
                  return const Center(
                    child: Text('Inbox is empty. Brain dump here!',
                        style: TextStyle(color: Colors.grey, fontSize: 16)),
                  );
                }

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
                      onTap: () {},
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_textController.text.trim().isNotEmpty) {
            _quickAddTask();
          } else {
            _focusNode.requestFocus();
          }
        },
        // YAHAN THEME APPLY KIYA HAI:
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}