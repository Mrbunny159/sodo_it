import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/backup_helper.dart';
import '../../data/local/database_provider.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    final currentTheme = ref.watch(themeProvider);

    String getThemeName(AppThemeType type) {
      switch (type) {
        case AppThemeType.pastel: return 'Pastel (Soft)';
        case AppThemeType.premium: return 'Premium (Vibrant)';
        case AppThemeType.defaultTheme: return 'Default (Bright)';
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Appearance', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),

          ListTile(
            leading: Icon(Icons.palette_outlined, color: Theme.of(context).colorScheme.primary),
            title: const Text('Theme & Accent'),
            subtitle: Text(getThemeName(currentTheme)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Choose Theme'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: AppThemeType.values.map((themeType) {
                      return RadioListTile<AppThemeType>(
                        title: Text(getThemeName(themeType)),
                        activeColor: Theme.of(context).colorScheme.primary,
                        value: themeType,
                        groupValue: currentTheme,
                        onChanged: (value) {
                          if (value != null) {
                            ref.read(themeProvider.notifier).setTheme(value);
                            Navigator.pop(context);
                          }
                        },
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),

          const Divider(),
          const SizedBox(height: 16),
          const Text('Data & Privacy', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),

          ListTile(
            // YAHAN THEME APPLY KIYA HAI:
            leading: Icon(Icons.download_outlined, color: Theme.of(context).colorScheme.primary),
            title: const Text('Export Data'),
            subtitle: const Text('Save tasks as a JSON file'),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Export Backup'),
                  content: const Text('This will generate a JSON file of all your tasks and categories. You can save it to your phone or share it to yourself.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    ElevatedButton(
                      // YAHAN THEME APPLY KIYA HAI:
                      style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Export', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Preparing backup file...')),
                  );
                }

                final resultMessage = await BackupHelper.exportData(db);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(resultMessage)),
                  );
                }
              }
            },
          ),

          ListTile(
            leading: const Icon(Icons.upload_file_outlined, color: Color(0xFFE71D36)),
            title: const Text('Import Data'),
            subtitle: const Text('Restore tasks from a JSON file (Overwrites current data)'),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Warning'),
                  content: const Text('Importing a backup will overwrite all your current tasks and categories. Are you sure?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE71D36)),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Import', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                final success = await BackupHelper.importData(db);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Data restored successfully! 🎉' : 'Failed to restore data.'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              }
            },
          ),

          const Divider(),
          const SizedBox(height: 16),
          const Text('About', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('SoDo it'),
            subtitle: Text('Version 1.0.0 • Offline First'),
          ),
        ],
      ),
    );
  }
}