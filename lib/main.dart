import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'data/local/database_provider.dart';
import 'data/local/app_database.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'core/theme/theme_provider.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();
  final db = container.read(databaseProvider);

  // Check if categories are empty, if so, seed the defaults
  final existingCategories = await db.select(db.categories).get();
  if (existingCategories.isEmpty) {
    await db.into(db.categories).insert(const CategoriesCompanion(
      name: drift.Value('Inbox'),
      accentColor: drift.Value('#3772FF'),
    ));
    await db.into(db.categories).insert(const CategoriesCompanion(
      name: drift.Value('College'),
      accentColor: drift.Value('#FF9F1C'),
    ));
    await db.into(db.categories).insert(const CategoriesCompanion(
      name: drift.Value('Class'),
      accentColor: drift.Value('#2EC4B6'),
    ));
    await db.into(db.categories).insert(const CategoriesCompanion(
      name: drift.Value('Personal'),
      accentColor: drift.Value('#E71D36'),
    ));
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const SoDoItApp(),
    ),
  );
}

// Yahan ConsumerWidget hona zaroori hai taaki yeh theme changes ko sun sake
class SoDoItApp extends ConsumerWidget {
  const SoDoItApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Yeh line app ko batati hai ki jab bhi themeProvider change ho, app ko dobara paint karo
    final currentThemeType = ref.watch(themeProvider);

    return MaterialApp(
      title: 'SoDo it',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(currentThemeType),
      home: const DashboardScreen(),
    );
  }
}