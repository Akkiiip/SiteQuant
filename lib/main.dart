import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const SiteQuantApp());
}

class SiteQuantApp extends StatelessWidget {
  const SiteQuantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SiteQuant',
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}