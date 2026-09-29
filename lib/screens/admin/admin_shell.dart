import 'package:flutter/material.dart';

import '../../widgets/menu_admin.dart';
import 'admin_home_screen.dart';
import 'admin_usuarios_screen.dart';
import 'admin_cursos_screen.dart';
import 'admin_sellos_screen.dart';

/// Igual que DocenteShell: cada pantalla se crea una sola vez, la primera
/// vez que se visita, y se queda en memoria de ahí en adelante.
class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _indiceActual = 0;
  bool _menuAbierto = false;

  static const _nombresPantallas = [
    "Inicio",
    "Usuarios",
    "Cursos",
    "Sellos",
    "Constancias",
    "Configuración",
  ];

  final Set<int> _visitadas = {0};
  final List<Widget?> _cache = List<Widget?>.filled(6, null);

  Widget _obtenerPantalla(int indice) {
    if (_cache[indice] != null) return _cache[indice]!;

    final Widget pantalla;
    switch (indice) {
      case 0:
        pantalla = const AdminHomeScreen();
        break;
      case 1:
        pantalla = const AdminUsuariosScreen();
        break;
      case 2:
        pantalla = const AdminCursosScreen();
        break;
      case 3:
        pantalla = const AdminSellosScreen();
        break;
      default:
        pantalla = _PantallaProximamente(nombre: _nombresPantallas[indice]);
    }

    _cache[indice] = pantalla;
    return pantalla;
  }

  void _irAPantalla(String nombre) {
    setState(() => _menuAbierto = false);
    final nuevoIndice = _nombresPantallas.indexOf(nombre);
    if (nuevoIndice == -1 || nuevoIndice == _indiceActual) return;
    setState(() {
      _visitadas.add(nuevoIndice);
      _indiceActual = nuevoIndice;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _indiceActual,
            children: List.generate(
              6,
              (i) => _visitadas.contains(i)
                  ? _obtenerPantalla(i)
                  : const SizedBox.shrink(),
            ),
          ),

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
              child: MenuAdmin(
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
