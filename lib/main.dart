import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/providers/app_providers.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await StorageService.initialize();

  runApp(const ProviderScope(child: RecognizingApp()));
}

class RecognizingApp extends ConsumerWidget {
  const RecognizingApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(settingsProvider.select((s) => s.darkMode));

    return MaterialApp(
      title: 'Recogniz.ing',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const AppShell(),
    );
  }
}
