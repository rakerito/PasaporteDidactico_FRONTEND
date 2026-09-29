import 'package:flutter/material.dart';

class MenuAdmin extends StatelessWidget {
  final String pantallaActiva; // "Inicio", "Usuarios", "Cursos", "Sellos", "Constancias", "Configuración"
  final VoidCallback onCerrar;
  final Function(String) onSeleccionar;

  const MenuAdmin({
    super.key,
    required this.pantallaActiva,
    required this.onCerrar,
    required this.onSeleccionar,
  });

  static const Color _fondoOscuro = Color(0xFF0B1E3D);
  static const Color _verde = Color(0xFF1F9D6D);

  Widget _item(IconData icono, String etiqueta) {
    final activo = etiqueta == pantallaActiva;
    return Expanded(
      child: InkWell(
        onTap: () => onSeleccionar(etiqueta),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, color: activo ? _verde : Colors.white, size: 22),
            const SizedBox(height: 4),
            Text(
              etiqueta,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: activo ? _verde : Colors.white,
                fontSize: 10,
                fontWeight: activo ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: _fondoOscuro,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            children: [
              _item(Icons.home, "Inicio"),
              _item(Icons.people, "Usuarios"),
              _item(Icons.menu_book, "Cursos"),
              _item(Icons.verified, "Sellos"),
              _item(Icons.workspace_premium, "Constancias"),
              _item(Icons.settings, "Configuración"),
            ],
          ),
          Positioned(
            right: -4,
            top: -10,
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
