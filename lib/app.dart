import 'package:flutter/material.dart';

import 'routes.dart';

class TriviaTrailApp extends StatelessWidget {
  const TriviaTrailApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TriviaTrail',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4BC0FF),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF3F7FF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
          elevation: 0,
          foregroundColor: Color(0xFF0B0B1F),
        ),
        textTheme: ThemeData(brightness: Brightness.light).textTheme.apply(
              bodyColor: const Color(0xFF141233),
              displayColor: const Color(0xFF141233),
            ),
        chipTheme: ChipThemeData.fromDefaults(
          secondaryColor: const Color(0xFF8559F0),
          brightness: Brightness.light,
          labelStyle: const TextStyle(color: Color(0xFF141233)),
        ).copyWith(
          backgroundColor: const Color(0xFFE5ECFF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
      ),
      initialRoute: AppRoutes.login,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
