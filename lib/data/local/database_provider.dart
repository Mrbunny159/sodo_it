import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_database.dart';

// This provider creates a single, persistent instance of our local database
// that can be safely accessed from anywhere in the app.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  
  // Ensures the database connection closes automatically if the provider is ever destroyed
  ref.onDispose(() => db.close());
  
  return db;
});