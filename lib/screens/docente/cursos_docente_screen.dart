import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../widgets/fondo_app.dart';
import '../../widgets/modal_detalle_curso.dart';

class CursosDocenteScreen extends StatefulWidget {
  const CursosDocenteScreen({super.key});

  @override
  State<CursosDocenteScreen> createState() => _CursosDocenteScreenState();
}

class _CursosDocenteScreenState extends State<CursosDocenteScreen> {
  final ApiService _apiService = ApiService();
  bool _cargando = true;
  String? _error;
  List<dynamic> _cursos = [];
  final TextEditingController _buscadorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarCursos();
    _buscadorController.addListener(() {
      setState(() {});
    });
  }

  Future<void> _cargarCursos() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final cursos = await _apiService.obtenerCursosActivos();
      setState(() {
        _cursos = cursos;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  List<dynamic> get _cursosFiltrados {
    final texto = _buscadorController.text.trim().toLowerCase();
    if (texto.isEmpty) return _cursos;
    return _cursos
        .where(
          (c) => (c["nombre"] ?? "").toString().toLowerCase().contains(texto),
        )
        .toList();
  }

  @override
  void dispose() {
    _buscadorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const FondoApp(),
        SafeArea(
          child: Column(
            children: [
              // HEADER
              const Padding(
                padding: EdgeInsets.only(top: 20, bottom: 10),
                child: Text(
                  "CURSOS",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF151B3D), // Azul oscuro
                  ),
                ),
              ),

              // BUSCADOR Y FILTROS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  children: [
                    // Buscador
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: TextField(
                        controller: _buscadorController,
                        decoration: InputDecoration(
                          hintText: "Buscar curso",
                          hintStyle: TextStyle(color: Colors.grey.shade600),
                          prefixIcon: const Icon(Icons.search, color: Colors.black),
                          suffixIcon: _buscadorController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close, color: Colors.black),
                                  onPressed: () {
                                    _buscadorController.clear();
                                    FocusScope.of(context).unfocus();
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Dropdown Filtros
                    Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Expanded(
                            child: Text(
                              "Filtros",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // LISTA DE CURSOS
              Expanded(
                child: _cargando
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline,
                                    color: Colors.redAccent, size: 48),
                                const SizedBox(height: 16),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 32),
                                  child: Text(_error!, textAlign: TextAlign.center),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _cargarCursos,
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF151B3D)),
                                  child: const Text("Reintentar"),
                                )
                              ],
                            ),
                          )
                        : _cursosFiltrados.isEmpty
                            ? const Center(
                                child: Text("No se encontraron cursos activos.",
                                    style: TextStyle(color: Colors.grey)))
                            : ListView.builder(
                                padding: const EdgeInsets.only(bottom: 100),
                                itemCount: _cursosFiltrados.length,
                                itemBuilder: (context, index) {
                                  final curso = _cursosFiltrados[index];
                                  return _TarjetaCursoPrincipal(curso: curso);
                                },
                              ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TarjetaCursoPrincipal extends StatelessWidget {
  final Map<String, dynamic> curso;
  const _TarjetaCursoPrincipal({required this.curso});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => mostrarModalDetalleCurso(context, curso),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título con línea verde debajo
              Text(
                curso["nombre"] ?? "Curso sin nombre",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF151B3D),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 2,
                color: const Color(0xFFB5CC3A),
              ),
              const SizedBox(height: 16),

              // Descripción
              const Text(
                "Descripción",
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
              const SizedBox(height: 2),
              Text(
                curso["descripcion"] ?? "Sin descripción",
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),

              // Grid de info (Categoría, Duración, Otorga)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.list, size: 14, color: Colors.grey.shade400),
                            const SizedBox(width: 4),
                            const Text("Categoría", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          curso["categorias"] ?? "N/A",
                          style: const TextStyle(color: Color(0xFF151B3D), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 14, color: Colors.grey.shade400),
                            const SizedBox(width: 4),
                            const Text("Duración", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          curso["duracion"] != null ? "${curso["duracion"]} horas" : "N/A",
                          style: const TextStyle(color: Color(0xFF151B3D), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.workspace_premium, size: 14, color: Colors.grey.shade400),
                            const SizedBox(width: 4),
                            const Text("Otorga", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          curso["otorga"] ?? "Constancia",
                          style: const TextStyle(color: Color(0xFF151B3D), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Fecha y Botón Inscribirse
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Fecha límite: ",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        curso["fecha_lim"] ?? "15.01.2026",
                        style: const TextStyle(
                          color: Color(0xFF151B3D),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      onPressed: () {
                        // Inscribirse logic placeholder
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB5CC3A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: const Text(
                        "Inscribirse",
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
