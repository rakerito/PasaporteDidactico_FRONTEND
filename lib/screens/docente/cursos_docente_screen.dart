import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/cache_app.dart';
import '../../widgets/fondo_app.dart';
import '../../widgets/modal_detalle_curso.dart';
import '../../widgets/campo_busqueda.dart';
import '../../widgets/boton_filtros.dart';

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

  final Set<String> _categoriasSeleccionadas = {};
  String? _tipoSeleccionado; // null = todos, "normal", "microcurso"

  @override
  void initState() {
    super.initState();
    if (CacheApp.cursos != null) {
      _cursos = CacheApp.cursos!;
      _cargando = false;
    } else {
      _cargarCursos();
    }
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
      CacheApp.cursos = cursos;

      if (!mounted) return;
      setState(() {
        _cursos = cursos;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  List<String> get _categoriasDisponibles {
    final set = <String>{};
    for (var c in _cursos) {
      final raw = (c["categorias"] ?? "").toString();
      if (raw.isEmpty) continue;
      for (var cat in raw.split(",")) {
        set.add(cat.trim());
      }
    }
    final lista = set.toList()..sort();
    return lista;
  }

  List<dynamic> get _cursosFiltrados {
    final texto = _buscadorController.text.trim().toLowerCase();

    return _cursos.where((c) {
      final coincideTexto =
          texto.isEmpty ||
          (c["nombre"] ?? "").toString().toLowerCase().contains(texto);

      final coincideTipo =
          _tipoSeleccionado == null || c["tipo"] == _tipoSeleccionado;

      final categoriasCurso = (c["categorias"] ?? "")
          .toString()
          .split(",")
          .map((e) => e.trim())
          .toSet();
      final coincideCategoria =
          _categoriasSeleccionadas.isEmpty ||
          categoriasCurso.intersection(_categoriasSeleccionadas).isNotEmpty;

      return coincideTexto && coincideTipo && coincideCategoria;
    }).toList();
  }

  int get _filtrosActivos =>
      _categoriasSeleccionadas.length + (_tipoSeleccionado != null ? 1 : 0);

  Future<void> _abrirFiltros() async {
    Set<String> categoriasTemp = Set.from(_categoriasSeleccionadas);
    String? tipoTemp = _tipoSeleccionado;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Filtros",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF151B3D),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            categoriasTemp.clear();
                            tipoTemp = null;
                          });
                        },
                        child: const Text("Limpiar"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  const Text(
                    "Tipo de curso",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text("Todos"),
                        selected: tipoTemp == null,
                        onSelected: (_) => setModalState(() => tipoTemp = null),
                      ),
                      ChoiceChip(
                        label: const Text("Normal"),
                        selected: tipoTemp == "normal",
                        onSelected: (_) =>
                            setModalState(() => tipoTemp = "normal"),
                      ),
                      ChoiceChip(
                        label: const Text("Microcurso"),
                        selected: tipoTemp == "microcurso",
                        onSelected: (_) =>
                            setModalState(() => tipoTemp = "microcurso"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    "Categorías",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  if (_categoriasDisponibles.isEmpty)
                    const Text(
                      "No hay categorías disponibles todavía.",
                      style: TextStyle(color: Colors.grey),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categoriasDisponibles.map((cat) {
                        final seleccionada = categoriasTemp.contains(cat);
                        return FilterChip(
                          label: Text(cat),
                          selected: seleccionada,
                          onSelected: (v) {
                            setModalState(() {
                              if (v) {
                                categoriasTemp.add(cat);
                              } else {
                                categoriasTemp.remove(cat);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF151B3D),
                      ),
                      onPressed: () {
                        setState(() {
                          _categoriasSeleccionadas
                            ..clear()
                            ..addAll(categoriasTemp);
                          _tipoSeleccionado = tipoTemp;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text("Aplicar filtros"),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _buscadorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FondoApp(
      child: SafeArea(
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
                  CampoBusqueda(
                    controller: _buscadorController,
                    hint: "Buscar curso",
                    onChanged: () => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  // Filtros
                  BotonFiltros(activos: _filtrosActivos, onTap: _abrirFiltros),
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
                          const Icon(
                            Icons.error_outline,
                            color: Colors.redAccent,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(_error!, textAlign: TextAlign.center),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _cargarCursos,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF151B3D),
                            ),
                            child: const Text("Reintentar"),
                          ),
                        ],
                      ),
                    )
                  : _cursosFiltrados.isEmpty
                  ? const Center(
                      child: Text(
                        "No se encontraron cursos activos.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
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
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                curso["nombre"] ?? "Curso sin nombre",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF151B3D),
                ),
              ),
              const SizedBox(height: 4),
              Container(height: 2, color: const Color(0xFFB5CC3A)),
              const SizedBox(height: 16),
              const Text(
                "Descripción",
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
              const SizedBox(height: 2),
              Text(
                curso["descripcion"] ?? "Sin descripción",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.list,
                              size: 14,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              "Categoría",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          curso["categorias"] ?? "N/A",
                          style: const TextStyle(
                            color: Color(0xFF151B3D),
                            fontSize: 11,
                          ),
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
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              "Duración",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          curso["duracion"] != null
                              ? "${curso["duracion"]} horas"
                              : "N/A",
                          style: const TextStyle(
                            color: Color(0xFF151B3D),
                            fontSize: 11,
                          ),
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
                            Icon(
                              Icons.workspace_premium,
                              size: 14,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              "Otorga",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          curso["otorga"] ?? "Constancia",
                          style: const TextStyle(
                            color: Color(0xFF151B3D),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
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
                        curso["fecha_lim"] ?? "Sin fecha",
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
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
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
