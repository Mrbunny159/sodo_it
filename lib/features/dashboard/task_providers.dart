import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/app_database.dart';
import '../../data/local/database_provider.dart';
import '../../data/local/task_repository.dart';

// Provides the TaskRepository instance
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return TaskRepository(db);
});

// Stream provider for tracking categories reactively
final categoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(taskRepositoryProvider).watchCategories();
});

// Stream provider for tracking incomplete tasks for the "Today" dashboard view
final todayTasksStreamProvider = StreamProvider<List<Task>>((ref) {
  return ref.watch(taskRepositoryProvider).watchTodayTasks();
});

// Fetches tasks filtered by a specific Category ID
final categoryTasksProvider = StreamProvider.family<List<Task>, int>((ref, categoryId) {
  return ref.watch(taskRepositoryProvider).watchTasks(categoryId: categoryId);
});

// Fetches tasks specifically assigned to the Inbox (usually ID 1)
final inboxTasksProvider = StreamProvider<List<Task>>((ref) async* {
  final db = ref.watch(databaseProvider);

  // Find the Inbox category
  final inboxCategory = await (db.select(db.categories)
    ..where((tbl) => tbl.name.equals('Inbox')))
      .getSingleOrNull();

  if (inboxCategory != null) {
    // Yield the stream of tasks for this category
    yield* ref.watch(taskRepositoryProvider).watchTasks(categoryId: inboxCategory.id);
  } else {
    yield [];
  }
});