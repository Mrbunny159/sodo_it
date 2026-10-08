import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// Drift requires this part statement to target the generated file
part 'app_database.g.dart';

// Priority levels matching your color-coded flag design
enum TaskPriority { low, medium, high }

/// Categories Table (Default: Inbox, College, Class, Personal)
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get accentColor => text().withLength(min: 7, max: 7)(); // Hex code e.g., #3772FF
  IntColumn get iconCode => integer().nullable()(); // Icon identifier
}

/// Tasks Table (The core daily execution schema)
class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer().nullable().references(Categories, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text().withLength(min: 1, max: 255)();
  TextColumn get notes => text().nullable()();
  IntColumn get priority => intEnum<TaskPriority>().withDefault(Constant(TaskPriority.low.index))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get dueDate => dateTime().nullable()();
  IntColumn get position => integer().withDefault(const Constant(0))(); // For drag-and-drop ordering
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Database configuration annotation
@DriftDatabase(tables: [Categories, Tasks])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

/// Establishes the physical connection to the phone's storage
QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'sodo_it.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}