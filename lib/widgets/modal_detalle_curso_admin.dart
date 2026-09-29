import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'formulario_curso.dart';

const _mesesProgreso = [
  "ENE",
  "FEB",
  "MAR",
  "ABR",
  "MAY",
  "JUN",
  "JUL",
  "AGO",
  "SEP",
  "OCT",
  "NOV",
  "DIC",
];

String _formatearFecha(String? fechaIso) {
  if (fechaIso == null || fechaIso.isEmpty) return "—";
  try {
    final fecha = DateTime.parse(fechaIso).toLocal();
    return "${fecha.day.toString().padLeft(2, '0')}.${_mesesProgreso[fecha.month - 1]}.${fecha.year}";
  } catch (_) {
    return fechaIso;
  }
}

void mostrarModalDetalleCursoAdmin(
  BuildContext context,
  Map<String, dynamic> cursoInicial, {
  VoidCallback? onActualizado,
}) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.all(20),
        child: _ModalDetalleCursoAdminContenido(
          cursoInicial: cursoInicial,
          onActualizado: onActualizado,
        ),
      );
    },
  );
}

class _ModalDetalleCursoAdminContenido extends StatefulWidget {
  final Map<String, dynamic> cursoInicial;
  final VoidCallback? onActualizado;
  const _ModalDetalleCursoAdminContenido({
    required this.cursoInicial,
    this.onActualizado,
  });

  @override
  State<_ModalDetalleCursoAdminContenido> createState() =>
      _ModalDetalleCursoAdminContenidoState();
}

class _ModalDetalleCursoAdminContenidoState
    extends State<_ModalDetalleCursoAdminContenido> {
  final ApiService _apiService = ApiService();
  late Map<String, dynamic> _curso;
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _curso = Map.from(widget.cursoInicial);
    if (_curso["descripcion"] == null && _curso["id_curso"] != null) {
      _cargarDetalles();
    }
  }

  Future<void> _cargarDetalles() async {
    setState(() => _cargando = true);
    try {
      final detalles = await _apiService.obtenerDetalleCurso(
        _curso["id_curso"],
      );
      if (mounted) {
        setState(() {
          _curso.addAll(detalles);
          _cargando = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Widget _itemDetalle(IconData icono, String etiqueta, String valor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icono, color: Colors.grey.shade400, size: 20),
            const SizedBox(width: 6),
            Text(
              etiqueta,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          valor,
          style: const TextStyle(color: Color(0xFF151B3D), fontSize: 13),
        ),
      ],
    );
  }

  Widget _itemDetalleCategorias(IconData icono, String etiqueta, String valor) {
    final items = valor
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icono, color: Colors.grey.shade400, size: 20),
            const SizedBox(width: 6),
            Text(
              etiqueta,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (items.isEmpty)
          const Text(
            "—",
            style: TextStyle(color: Color(0xFF151B3D), fontSize: 13),
          )
        else
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "• ",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: Color(0xFF151B3D),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final String nombre = _curso["nombre"] ?? "Curso";
    final String fechaLim = _curso["fecha_lim"]?.toString() ?? "—";
    final bool activo =
        (_curso["estatus"] ?? "").toString().toLowerCase() == "activo";
    final List<dynamic> requeridos = _curso["cursos_requeridos"] ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      nombre,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF151B3D),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: activo
                            ? const Color(0xFFB5CC3A)
                            : const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        activo ? "Activo" : "Inactivo",
                        style: TextStyle(
                          color: activo ? Colors.black : Colors.grey.shade700,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(
                  Icons.edit_square,
                  color: Color(0xFF151B3D),
                  size: 22,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  abrirFormularioCurso(
                    context,
                    () => widget.onActualizado?.call(),
                    cursoExistente: _curso,
                  );
                },
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.close,
                  color: Color(0xFFE0E0E0),
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: Color(0xFFB5CC3A), thickness: 2, height: 1),
          const SizedBox(height: 16),

          if (_cargando)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Descripción",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _curso["descripcion"] ?? "Sin descripción.",
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _itemDetalle(
                                Icons.workspace_premium,
                                "Otorga",
                                _curso["otorga"] ?? "—",
                              ),
                              const SizedBox(height: 16),
                              _itemDetalle(
                                Icons.calendar_month,
                                "Fecha límite",
                                fechaLim,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _itemDetalleCategorias(
                                Icons.format_list_bulleted,
                                "Categorías",
                                _curso["categorias"] ?? "",
                              ),
                              const SizedBox(height: 16),
                              _itemDetalle(
                                Icons.people,
                                "Inscritos",
                                (_curso["inscritos"] ?? 0).toString(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Icon(
                          Icons.library_books,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Cursos requeridos",
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    requeridos.isEmpty
                        ? const Text(
                            "No cuenta con cursos requeridos registrados.",
                            style: TextStyle(
                              color: Color(0xFF151B3D),
                              fontSize: 14,
                            ),
                          )
                        : Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: requeridos
                                .map(
                                  (req) => _BadgeRequerido(
                                    nombre: req["nombre"] ?? "Microcurso",
                                  ),
                                )
                                .toList(),
                          ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BadgeRequerido extends StatelessWidget {
  final String nombre;
  const _BadgeRequerido({required this.nombre});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.workspace_premium,
              color: Color(0xFFE0E0E0),
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 70,
          child: Text(
            nombre,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF151B3D),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
