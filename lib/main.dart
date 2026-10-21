import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/theme_provider.dart';
import 'services/notification_service.dart';
import 'ui/screens/main_navigation_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.initialize();
  runApp(
    const ProviderScope(
      child: HolyBibleApp(),
    ),
  );
}

class HolyBibleApp extends ConsumerWidget {
  const HolyBibleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeConfig = ref.watch(themeConfigProvider);

    return MaterialApp(
      title: 'መጽሐፍ ቅዱስ (Holy Bible Amharic)',
      debugShowCheckedModeBanner: false,
      theme: themeConfig.toThemeData(),
      home: const MainNavigationShell(),
    );
  }
}
