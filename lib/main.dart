import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MultipIAIApp());
}

class MultipIAIApp extends StatelessWidget {
  const MultipIAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MultipIAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00C271)),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: const SplashScreen(),
    );
  }
}
