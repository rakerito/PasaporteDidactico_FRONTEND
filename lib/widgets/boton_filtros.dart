import 'package:flutter/material.dart';

/// Botón de "Filtros" reutilizable, mismo estilo en Sellos, Progreso y Cursos.
/// Muestra un contador cuando hay filtros activos.
class BotonFiltros extends StatelessWidget {
  final int activos;
  final VoidCallback onTap;

  const BotonFiltros({super.key, required this.activos, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hayActivos = activos > 0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hayActivos ? const Color(0xFF151B3D) : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                hayActivos ? "Filtros ($activos)" : "Filtros",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: hayActivos ? const Color(0xFF151B3D) : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }
}
