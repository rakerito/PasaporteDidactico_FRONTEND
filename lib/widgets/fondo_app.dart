import 'package:flutter/material.dart';

/// Fondo reutilizable para toda la app: blanco de base +
/// la imagen del pasaporte transparente encima.
/// Envuelve el contenido de cada pantalla con esto.
class FondoApp extends StatelessWidget {
  final Widget child;

  const FondoApp({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/fondo_pasaporte_transparente.png",
              fit: BoxFit.cover,
            ),
          ),
          child,
        ],
      ),
    );
  }
}
