import 'dart:async';

import 'package:flutter/material.dart';

import '../widgets/fondo_app.dart';

const double _anchoDiseno = 310.5;
const double _altoDiseno = 672;

/// Pantalla 7: bienvenida con el nombre del usuario, después del login.
/// Pasa sola a la pantalla que le pases en 'siguiente'.
class WelcomeScreen extends StatefulWidget {
  final String nombre;
  final Widget siguiente;

  const WelcomeScreen({
    super.key,
    required this.nombre,
    required this.siguiente,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => widget.siguiente),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FondoApp(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _anchoDiseno,
            height: _altoDiseno,
            child: Stack(
              children: [
                // ===== AJUSTA left/top con los valores reales de Canva =====
                const Positioned(
                  left: 30,
                  top: 280,
                  child: Text(
                    "Bienvenido (a)",
                    style: TextStyle(
                      color: Color(0xFF151B3D),
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Positioned(
                  left: 30,
                  top: 320,
                  width: 250,
                  child: Text(
                    widget.nombre,
                    style: const TextStyle(
                      color: Color(0xFF1F9D6D),
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
