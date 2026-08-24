import 'package:flutter/material.dart';

import 'menu_inferior.dart';
import '../screens/docente/docente_home_screen.dart';
import '../screens/docente/sellos_docente_screen.dart';

/// Envuelve el contenido de cualquier pantalla del docente y le agrega,
/// sin repetir código: el botón circular del menú, el menú desplegable,
/// y la navegación entre pantallas.
///
/// Uso en cualquier pantalla nueva:
///   return Scaffold(
///     body: MenuScaffold(
///       pantallaActiva: "Sellos",   // el nombre exacto que usa MenuInferior
///       child: ... tu contenido normal ...,
///     ),
///   );
class MenuScaffold extends StatefulWidget {
  final String pantallaActiva;
  final Widget child;

  const MenuScaffold({
    super.key,
    required this.pantallaActiva,
    required this.child,
  });

  @override
  State<MenuScaffold> createState() => _MenuScaffoldState();
}

class _MenuScaffoldState extends State<MenuScaffold> {
  bool _menuAbierto = false;

  void _navegar(String pantalla) {
    setState(() => _menuAbierto = false);
    if (pantalla == widget.pantallaActiva)
      return; // ya estás ahí, no hacer nada

    Widget? destino;
    switch (pantalla) {
      case "Inicio":
        destino = const DocenteHomeScreen();
        break;
      case "Sellos":
        destino = const SellosDocenteScreen();
        break;
      case "Progreso":
      case "Cursos":
      case "Configuración":
        destino = null; // TODO: conectar cuando existan esas pantallas
        break;
    }

    if (destino != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => destino!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,

        Positioned(
          right: 20,
          bottom: 24,
          child: InkWell(
            onTap: () => setState(() => _menuAbierto = !_menuAbierto),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFF151B3D),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.menu, color: Colors.white, size: 20),
            ),
          ),
        ),

        if (_menuAbierto)
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: MenuInferior(
              pantallaActiva: widget.pantallaActiva,
              onCerrar: () => setState(() => _menuAbierto = false),
              onSeleccionar: _navegar,
            ),
          ),
      ],
    );
  }
}
