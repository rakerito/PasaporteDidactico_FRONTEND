import 'package:flutter/material.dart';

import 'screens/login_screen.dart';

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
        // TODO: ajustar colores según la paleta de tu diseño final
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
