import 'package:flutter/material.dart';

import '../../widgets/menu_inferior.dart';
import 'docente_home_screen.dart';
import 'sellos_docente_screen.dart';

/// Contenedor único que mantiene todas las pantallas del docente
/// creadas una sola vez (no se recargan al cambiar entre ellas),
/// con una transición de volteo al cambiar de pestaña.
class DocenteShell extends StatefulWidget {
  const DocenteShell({super.key});

  @override
  State<DocenteShell> createState() => _DocenteShellState();
}

class _DocenteShellState extends State<DocenteShell> {
  int _indiceActual = 0;
  bool _menuAbierto = false;

  static const _nombresPantallas = [
    "Inicio",
    "Sellos",
    "Progreso",
    "Cursos",
    "Configuración",
  ];

  // Las 5 pantallas, creadas UNA sola vez aquí.
  final List<Widget> _pantallas = const [
    DocenteHomeScreen(),
    SellosDocenteScreen(),
    _PantallaProximamente(nombre: "Progreso"),
    _PantallaProximamente(nombre: "Cursos"),
    _PantallaProximamente(nombre: "Configuración"),
  ];

  void _irAPantalla(String nombre) {
    setState(() => _menuAbierto = false);
    final nuevoIndice = _nombresPantallas.indexOf(nombre);
    if (nuevoIndice == -1 || nuevoIndice == _indiceActual) return;
    setState(() => _indiceActual = nuevoIndice);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // TODO: aquí va la animación de "hojas de libro" cuando la retomemos.
          // Por ahora, cambio directo sin efecto, para que la app funcione bien.
          IndexedStack(index: _indiceActual, children: _pantallas),

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
                pantallaActiva: _nombresPantallas[_indiceActual],
                onCerrar: () => setState(() => _menuAbierto = false),
                onSeleccionar: _irAPantalla,
              ),
            ),
        ],
      ),
    );
  }
}

class _PantallaProximamente extends StatelessWidget {
  final String nombre;
  const _PantallaProximamente({required this.nombre});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "$nombre — próximamente",
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
