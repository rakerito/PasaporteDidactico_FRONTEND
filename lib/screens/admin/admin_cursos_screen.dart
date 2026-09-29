import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../widgets/fondo_app.dart';
import '../../widgets/campo_busqueda.dart';
import '../../widgets/boton_filtros.dart';
import '../../widgets/modal_detalle_curso_admin.dart';
import '../../widgets/formulario_curso.dart';

class ColoresCursos {
  static const Color textoOscuro = Color(0xFF151B3D);
  static const Color verde = Color(0xFFB5CC3A);
}

class AdminCursosScreen extends StatefulWidget {
  const AdminCursosScreen({super.key});

  @override
  State<AdminCursosScreen> createState() => _AdminCursosScreenState();
}

class _AdminCursosScreenState extends State<AdminCursosScreen>
    with AutomaticKeepAliveClientMixin {
  final _apiService = ApiService();
  final _buscadorController = TextEditingController();

  bool _cargando = true;
  String? _error;
  List<dynamic> _cursos = [];

  // null = todos, "activo", "inactivo"
  String? _filtroEstado;
  // null = todos, "normal", "microcurso"
  String? _filtroTipo;
  final Set<String> _filtroCategorias = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final cursos = await _apiService.obtenerCursosAdmin();
      if (!mounted) return;
      setState(() {
        _cursos = cursos;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst("Exception: ", "");
        _cargando = false;
      });
    }
  }

  bool _esActivo(Map curso) {
    return (curso["estatus"] ?? "").toString().toLowerCase() == "activo";
  }

  List<String> get _categoriasDisponibles {
    final set = <String>{};
    for (var c in _cursos) {
      final raw = (c["categorias"] ?? "").toString();
      if (raw.isEmpty) continue;
      for (var cat in raw.split(",")) {
        final limpio = cat.trim();
        if (limpio.isNotEmpty) set.add(limpio);
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
          (c["nombre"] ?? "").toString().toLowerCase().contains(texto) ||
          (c["descripcion"] ?? "").toString().toLowerCase().contains(texto) ||
          (c["categorias"] ?? "").toString().toLowerCase().contains(texto);

      final esActivo = _esActivo(c);
      final coincideEstado =
          _filtroEstado == null ||
          (_filtroEstado == "activo" && esActivo) ||
          (_filtroEstado == "inactivo" && !esActivo);

      final coincideTipo =
          _filtroTipo == null ||
          (c["tipo"] ?? "").toString().toLowerCase() == _filtroTipo;

      final categoriasCurso = (c["categorias"] ?? "")
          .toString()
          .split(",")
          .map((e) => e.trim())
          .toSet();
      final coincideCategoria =
          _filtroCategorias.isEmpty ||
          categoriasCurso.intersection(_filtroCategorias).isNotEmpty;

      return coincideTexto &&
          coincideEstado &&
          coincideTipo &&
          coincideCategoria;
    }).toList();
  }

  int get _filtrosActivos =>
      (_filtroEstado != null ? 1 : 0) +
      (_filtroTipo != null ? 1 : 0) +
      _filtroCategorias.length;

  Future<void> _abrirFiltros() async {
    String? filtroTemp = _filtroEstado;
    String? filtroTipoTemp = _filtroTipo;
    Set<String> filtroCategoriasTemp = Set.from(_filtroCategorias);
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Filtros de Cursos",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: ColoresCursos.textoOscuro,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => setModalState(() {
                          filtroTemp = null;
                          filtroTipoTemp = null;
                          filtroCategoriasTemp.clear();
                        }),
                        child: const Text("Limpiar"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Estado del curso",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text("Todos"),
                        selected: filtroTemp == null,
                        onSelected: (_) =>
                            setModalState(() => filtroTemp = null),
                      ),
                      ChoiceChip(
                        label: const Text("Activo"),
                        selected: filtroTemp == "activo",
                        onSelected: (_) =>
                            setModalState(() => filtroTemp = "activo"),
                      ),
                      ChoiceChip(
                        label: const Text("Inactivo"),
                        selected: filtroTemp == "inactivo",
                        onSelected: (_) =>
                            setModalState(() => filtroTemp = "inactivo"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
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
                        selected: filtroTipoTemp == null,
                        onSelected: (_) =>
                            setModalState(() => filtroTipoTemp = null),
                      ),
                      ChoiceChip(
                        label: const Text("Normal"),
                        selected: filtroTipoTemp == "normal",
                        onSelected: (_) =>
                            setModalState(() => filtroTipoTemp = "normal"),
                      ),
                      ChoiceChip(
                        label: const Text("Microcurso"),
                        selected: filtroTipoTemp == "microcurso",
                        onSelected: (_) =>
                            setModalState(() => filtroTipoTemp = "microcurso"),
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
                        final seleccionada = filtroCategoriasTemp.contains(cat);
                        return FilterChip(
                          label: Text(cat),
                          selected: seleccionada,
                          onSelected: (v) => setModalState(() {
                            if (v) {
                              filtroCategoriasTemp.add(cat);
                            } else {
                              filtroCategoriasTemp.remove(cat);
                            }
                          }),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColoresCursos.textoOscuro,
                      ),
                      onPressed: () {
                        setState(() {
                          _filtroEstado = filtroTemp;
                          _filtroTipo = filtroTipoTemp;
                          _filtroCategorias
                            ..clear()
                            ..addAll(filtroCategoriasTemp);
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

  Future<void> _confirmarEliminar(Map<String, dynamic> curso) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Eliminar curso?"),
        content: Text(
          "Se eliminará \"${curso["nombre"]}\" de forma permanente.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      try {
        await _apiService.eliminarCursoAdmin(curso["id_curso"]);
        _cargar();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceFirst("Exception: ", "")),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.redAccent,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _cargar,
                  child: const Text("Reintentar"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final lista = _cursosFiltrados;

    return FondoApp(
      child: SafeArea(
        child: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                const Text(
                  "CURSOS",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ColoresCursos.textoOscuro,
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: OutlinedButton.icon(
                    onPressed: () => abrirFormularioCurso(
                      context,
                      _cargar,
                      cursosDisponibles: _cursos,
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A9B7F),
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.add_circle, color: Colors.white),
                    label: const Text(
                      "Agregar curso",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CampoBusqueda(
                    controller: _buscadorController,
                    hint: "Buscar curso",
                    onChanged: () => setState(() {}),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: BotonFiltros(
                    activos: _filtrosActivos,
                    onTap: _abrirFiltros,
                  ),
                ),
                const SizedBox(height: 20),

                if (lista.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "No se encontraron cursos.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  ...lista.map(
                    (c) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 6,
                      ),
                      child: GestureDetector(
                        onTap: () => mostrarModalDetalleCursoAdmin(context, c),
                        child: _TarjetaCurso(
                          curso: c,
                          onEditar: () => abrirFormularioCurso(
                            context,
                            _cargar,
                            cursoExistente: c,
                            cursosDisponibles: _cursos,
                          ),
                          onEliminar: () => _confirmarEliminar(c),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 24),
                const Text(
                  "Página 3",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ColoresCursos.textoOscuro,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TarjetaCurso extends StatelessWidget {
  final Map<String, dynamic> curso;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const _TarjetaCurso({
    required this.curso,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final String nombre = curso["nombre"] ?? "Curso";
    final String descripcion = curso["descripcion"] ?? "";
    final String categoria = curso["categorias"] ?? "Sin categoría";
    final String duracion = "${curso["duracion"] ?? "—"} horas";
    final String inscritos = (curso["inscritos"] ?? 0).toString();
    final String otorga = curso["otorga"] ?? "—";
    final bool activo =
        (curso["estatus"] ?? "").toString().toLowerCase() == "activo";

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_square),
                  color: const Color.fromARGB(221, 65, 65, 65),
                  iconSize: 20,
                  onPressed: onEditar,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onEliminar,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF5350),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 72),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: ColoresCursos.textoOscuro,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                const Divider(
                  color: ColoresCursos.verde,
                  thickness: 1.5,
                  height: 1,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Descripción",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  descripcion,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.format_list_bulleted,
                                color: Colors.grey.shade400,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                "Categoría",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            categoria,
                            style: const TextStyle(
                              color: ColoresCursos.textoOscuro,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                color: Colors.grey.shade400,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                "Duración",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            duracion,
                            style: const TextStyle(
                              color: ColoresCursos.textoOscuro,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.people,
                                color: Colors.grey.shade400,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                "Inscritos",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            inscritos,
                            style: const TextStyle(
                              color: ColoresCursos.textoOscuro,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.workspace_premium,
                          color: Colors.grey.shade400,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          "Otorga",
                          style: TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      otorga,
                      style: const TextStyle(
                        color: ColoresCursos.textoOscuro,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // El badge de Activo/Inactivo NO respeta el padding de 72 —
          // se estira hasta casi el borde, alineado con el botón de eliminar.
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: activo
                    ? const Color(0xFFB5CC3A)
                    : const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                activo ? "Activo" : "Inactivo",
                style: TextStyle(
                  color: activo ? Colors.black87 : Colors.grey.shade700,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
