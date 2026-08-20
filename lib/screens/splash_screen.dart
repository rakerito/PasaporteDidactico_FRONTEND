import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'login_screen.dart';

/// son la referencia para que las coordenadas x/y coincidan
const double _anchoDiseno = 310.5;
const double _altoDiseno = 672;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.fondo,
        width: double.infinity,
        height: double.infinity,
        child: FittedBox(
          fit: BoxFit.cover, // llena la pantalla completa, recorta si sobra
          child: SizedBox(
            width: _anchoDiseno,
            height: _altoDiseno,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  width: _anchoDiseno,
                  height: _altoDiseno,
                  child: Image.asset(
                    "assets/fondo_textura.png",
                    fit: BoxFit.cover,
                  ),
                ),

                // ===== AJUSTA estos left/top con los valores REALES de Canva =====

                // Logo UT San Juan del Río
                Positioned(
                  left: 33,
                  top: 38,
                  child: Image.asset("assets/logo_ut.png", width: 245),
                ),

                // Título "PASAPORTE"
                const Positioned(
                  left: 0,
                  top: 150,
                  width: _anchoDiseno,
                  child: Text(
                    "PASAPORTE",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textoClaro,
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),

                // Subtítulo "DIDÁCTICO"
                const Positioned(
                  left: 0,
                  top: 200,
                  width: _anchoDiseno,
                  child: Text(
                    "DIDÁCTICO",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textoClaro,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 6,
                    ),
                  ),
                ),

                // Escudo circular del Pasaporte
                Positioned(
                  left: 55,
                  top: 300,
                  child: Image.asset("assets/escudo_pasaporte.png", width: 200),
                ),

                // Footer con versión
                Positioned(
                  left: 0,
                  top: 605,
                  width: _anchoDiseno,
                  child: Text(
                    "PASAPORTE DIDÁCTICO V1.0.0 | 2026 UTSJR",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textoClaro.withValues(alpha: 0.7),
                      fontSize: 10,
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
