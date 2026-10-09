import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'ui/screens/home_reader_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

    final themeData = ThemeData(
      useMaterial3: true,
      brightness: themeConfig.mode == ReaderThemeMode.dark
          ? Brightness.dark
          : Brightness.light,
      scaffoldBackgroundColor: themeConfig.backgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: themeConfig.accentColor,
        brightness: themeConfig.mode == ReaderThemeMode.dark
            ? Brightness.dark
            : Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: themeConfig.surfaceColor,
        foregroundColor: themeConfig.textColor,
        elevation: 0.5,
      ),
    );

    return MaterialApp(
      title: 'መጽሐፍ ቅዱስ - Holy Bible',
      debugShowCheckedModeBanner: false,
      theme: themeData,
      home: const HomeReaderScreen(),
    );
  }
}
