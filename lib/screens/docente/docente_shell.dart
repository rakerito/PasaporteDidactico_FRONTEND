import 'package:flutter/material.dart';
import 'package:page_flip/page_flip.dart';

import '../../widgets/menu_inferior.dart';
import 'docente_home_screen.dart';
import 'sellos_docente_screen.dart';
import 'progreso_docente_screen.dart';
import 'cursos_docente_screen.dart';
import 'configuracion_docente_screen.dart';

class DocenteShell extends StatefulWidget {
  const DocenteShell({super.key});

  @override
  State<DocenteShell> createState() => _DocenteShellState();
}

class _DocenteShellState extends State<DocenteShell> {
  final GlobalKey<PageFlipWidgetState> _pageFlipKey =
      GlobalKey<PageFlipWidgetState>();

  int _indiceActual = 0;
  bool _menuAbierto = false;

  static const _nombresPantallas = [
    "Inicio",
    "Sellos",
    "Progreso",
    "Cursos",
    "Configuración",
  ];

  // Con este paquete no tenemos garantía de un aviso al deslizar,
  // así que precargamos TODAS las pantallas de una vez (no hay carga perezosa aquí).
  // Si sientes que tarda al entrar, dímelo y retomamos la optimización de precarga
  // que dejamos pendiente en la lista de pendientes del proyecto.
  final List<Widget> _pantallas = const [
    DocenteHomeScreen(),
    SellosDocenteScreen(),
    ProgresoDocenteScreen(),
    CursosDocenteScreen(),
    ConfiguracionDocenteScreen(),
  ];

  void _irAPantalla(String nombre) {
    setState(() => _menuAbierto = false);
    final nuevoIndice = _nombresPantallas.indexOf(nombre);
    if (nuevoIndice == -1) return;

    setState(() => _indiceActual = nuevoIndice);
    _pageFlipKey.currentState?.goToPage(nuevoIndice);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageFlipWidget(
            key: _pageFlipKey,
            backgroundColor: Colors.white,
            children: _pantallas,
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
