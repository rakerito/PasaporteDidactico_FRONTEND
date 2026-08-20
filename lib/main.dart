import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';

void main() {
  runApp(const PasaporteDidacticoApp());
}

class PasaporteDidacticoApp extends StatelessWidget {
  const PasaporteDidacticoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pasaporte Didáctico',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF062345)),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}
