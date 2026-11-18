import 'package:flutter/material.dart';

import 'pages/main_navigation_page.dart';
import 'pages/splash_screen_page.dart';

void main() {
  runApp(const SmartKasirApp());
}

class SmartKasirApp extends StatelessWidget {
  const SmartKasirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Kasir',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: Builder(
        builder: (context) => SplashScreenPage(
          onFinished: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => const MainNavigationPage(),
              ),
            );
          },
        ),
      ),
    );
  }
}
