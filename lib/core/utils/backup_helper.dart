import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:drift/drift.dart' as drift;
import '../../data/local/app_database.dart';

class BackupHelper {

  /// EXPORT: Reads database, converts to JSON, and opens the native Share menu
  /// EXPORT: Reads database, converts to JSON, and opens the native Share menu
  static Future<String> exportData(AppDatabase db) async {
    try {
      final categories = await db.select(db.categories).get();
      final tasks = await db.select(db.tasks).get();

      final backupData = {
        'categories': categories.map((c) => c.toJson()).toList(),
        'tasks': tasks.map((t) => t.toJson()).toList(),
      };

      final jsonString = jsonEncode(backupData);

      final directory = await getTemporaryDirectory();
      // Using a simpler file name without timestamps so it's easier to find
      final file = File('${directory.path}/sodo_it_backup.json');
      await file.writeAsString(jsonString);

      // Open Share Dialog
      await Share.shareXFiles([XFile(file.path)], text: 'SoDo it Backup');
      return 'Export menu opened!';
    } catch (e) {
      return 'Export failed: No apps found to handle the file share.';
    }
  }

  /// IMPORT: Opens file picker, reads JSON, and restores to database
  static Future<bool> importData(AppDatabase db) async {
    try {
      // 1. Pick the JSON file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) return false;

      // 2. Read the file
      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final Map<String, dynamic> backupData = jsonDecode(jsonString);

      // 3. Parse data
      final List<dynamic> rawCategories = backupData['categories'] ?? [];
      final List<dynamic> rawTasks = backupData['tasks'] ?? [];

      // 4. Wipe current database and insert backup (Batch operation)
      await db.transaction(() async {
        // Clear existing data
        await db.delete(db.tasks).go();
        await db.delete(db.categories).go();

        // Insert restored categories
        for (var c in rawCategories) {
          await db.into(db.categories).insert(
            Category.fromJson(c as Map<String, dynamic>).toCompanion(true),
          );
        }

        // Insert restored tasks
        for (var t in rawTasks) {
          await db.into(db.tasks).insert(
            Task.fromJson(t as Map<String, dynamic>).toCompanion(true),
          );
        }
      });

      return true; // Success
    } catch (e) {
      print('Import error: $e');
      return false; // Failed
    }
  }
}