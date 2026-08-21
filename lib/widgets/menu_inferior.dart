import 'package:flutter/material.dart';

class MenuInferior extends StatelessWidget {
  final String
  pantallaActiva; // "Inicio", "Sellos", "Progreso", "Cursos", "Configuración"
  final VoidCallback onCerrar;
  final Function(String) onSeleccionar;

  const MenuInferior({
    super.key,
    required this.pantallaActiva,
    required this.onCerrar,
    required this.onSeleccionar,
  });

  static const Color _fondoOscuro = Color(0xFF0B1E3D);
  static const Color _verde = Color(0xFF1F9D6D);

  Widget _item(IconData icono, String etiqueta) {
    final activo = etiqueta == pantallaActiva;
    return InkWell(
      onTap: () => onSeleccionar(etiqueta),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, color: activo ? _verde : Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(
            etiqueta,
            style: TextStyle(
              color: activo ? _verde : Colors.white,
              fontSize: 11,
              fontWeight: activo ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _fondoOscuro,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _item(Icons.home, "Inicio"),
              _item(Icons.verified, "Sellos"),
              _item(Icons.bar_chart, "Progreso"),
              _item(Icons.menu_book, "Cursos"),
              _item(Icons.settings, "Configuración"),
            ],
          ),
          Positioned(
            right: -8,
            top: -8,
            child: InkWell(
              onTap: onCerrar,
              child: const Icon(Icons.close, color: Colors.white70, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
