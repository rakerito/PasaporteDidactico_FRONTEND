import 'package:flutter/material.dart';

import '../../widgets/menu_inferior.dart';
import 'docente_home_screen.dart';
import 'sellos_docente_screen.dart';
import 'progreso_docente_screen.dart';
import 'cursos_docente_screen.dart';
import 'configuracion_docente_screen.dart';

/// Contenedor único que mantiene las pantallas del docente en memoria
/// UNA VEZ QUE LAS VISITAS (no se cargan las 5 de golpe al entrar,
/// solo la de Inicio; las demás se crean la primera vez que las abres).
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

  final Set<int> _visitadas = {0};
  final List<Widget?> _cache = List<Widget?>.filled(5, null);

  Widget _obtenerPantalla(int indice) {
    if (_cache[indice] != null) return _cache[indice]!;

    final Widget pantalla;
    switch (indice) {
      case 0:
        pantalla = const DocenteHomeScreen();
        break;
      case 1:
        pantalla = const SellosDocenteScreen();
        break;
      case 2:
        pantalla = const ProgresoDocenteScreen();
        break;
      case 3:
        pantalla = const CursosDocenteScreen();
        break;
      default:
        pantalla = const ConfiguracionDocenteScreen();
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
              5,
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
