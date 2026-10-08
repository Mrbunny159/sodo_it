import 'package:drift/drift.dart';
import 'app_database.dart';

class TaskRepository {
  final AppDatabase _db;

  TaskRepository(this._db);

  // 1. Fetch all categories
  Stream<List<Category>> watchCategories() {
    return _db.select(_db.categories).watch();
  }

  // 2. Insert a new category
  Future<int> insertCategory(CategoriesCompanion category) {
    return _db.into(_db.categories).insert(category);
  }

  // 3. Fetch tasks matching a specific category (or all if null)
  Stream<List<Task>> watchTasks({int? categoryId}) {
    final query = _db.select(_db.tasks);
    if (categoryId != null) {
      query.where((tbl) => tbl.categoryId.equals(categoryId));
    }
    // Order tasks by position for drag-and-drop support later
    query.orderBy([(tbl) => OrderingTerm(expression: tbl.position)]);
    return query.watch();
  }

  // 4. Fetch incomplete tasks for the "Today" view
  Stream<List<Task>> watchTodayTasks() {
    return (_db.select(_db.tasks)
          ..where((tbl) => tbl.isCompleted.equals(false))
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.position)]))
        .watch();
  }

  // 5. Insert a new task
  Future<int> insertTask(TasksCompanion task) {
    return _db.into(_db.tasks).insert(task);
  }

  // 6. Update a task (e.g., toggling completion, changing priority)
  Future<bool> updateTask(Task task) {
    return _db.update(_db.tasks).replace(task);
  }

  // 7. Delete a task permanently
  Future<int> deleteTask(int taskId) {
    return (_db.delete(_db.tasks)..where((tbl) => tbl.id.equals(taskId))).go();
  }
}