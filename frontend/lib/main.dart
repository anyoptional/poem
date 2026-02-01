import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:poem/config/app_config.dart';
import 'package:poem/providers/poem_provider.dart';
import 'package:poem/routes/app_router.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  setUrlStrategy(PathUrlStrategy());
  GoRouter.optionURLReflectsImperativeAPIs = true;

  await AppConfig.initialize();

  runApp(const PoemApp());
}

class PoemApp extends StatelessWidget {
  const PoemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => PoemProvider())],
      child: MaterialApp.router(
        title: 'Poem',
        debugShowCheckedModeBanner: false,
        theme: _buildDarkTheme(),
        darkTheme: _buildDarkTheme(),
        themeMode: ThemeMode.dark,
        routerConfig: goRouter,
      ),
    );
  }
}

ThemeData _buildDarkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFc9d1d9),
      secondary: Color(0xFF58a6ff),
      surface: Color(0xFF0d1117),
      onSurface: Color(0xFFc9d1d9),
      surfaceContainerHighest: Color(0xFF161b22),
    ),
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      surfaceTintColor: Color(0xFF0d1117),
      backgroundColor: Color(0xFF0d1117),
      foregroundColor: Color(0xFFc9d1d9),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFF30363d), width: 1),
      ),
      color: const Color(0xFF161b22),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF0d1117),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFF30363d)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFF30363d)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFF58a6ff), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      hintStyle: const TextStyle(color: Color(0xFF8b949e)),
      labelStyle: const TextStyle(color: Color(0xFF8b949e)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF238636),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFFc9d1d9),
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFFc9d1d9),
      ),
      bodyMedium: TextStyle(fontSize: 14, color: Color(0xFFc9d1d9)),
      bodySmall: TextStyle(fontSize: 12, color: Color(0xFF8b949e)),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF30363d),
      thickness: 1,
      space: 1,
    ),
  );
}
