import 'package:flutter/material.dart';
import '../../services/api_service.dart';

const _mesesProgreso = [
  "ENE", "FEB", "MAR", "ABR", "MAY", "JUN",
  "JUL", "AGO", "SEP", "OCT", "NOV", "DIC",
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

void mostrarModalDetalleCurso(BuildContext context, Map<String, dynamic> cursoInicial) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.all(20),
        child: _ModalDetalleCursoContenido(cursoInicial: cursoInicial),
      );
    },
  );
}

class _ModalDetalleCursoContenido extends StatefulWidget {
  final Map<String, dynamic> cursoInicial;
  const _ModalDetalleCursoContenido({required this.cursoInicial});

  @override
  State<_ModalDetalleCursoContenido> createState() => _ModalDetalleCursoContenidoState();
}

class _ModalDetalleCursoContenidoState extends State<_ModalDetalleCursoContenido> {
  final ApiService _apiService = ApiService();
  late Map<String, dynamic> _curso;
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _curso = Map.from(widget.cursoInicial);
    // Si no tiene descripción, asumimos que faltan detalles y los cargamos
    if (_curso["descripcion"] == null && _curso["id_curso"] != null) {
      _cargarDetalles();
    }
  }

  Future<void> _cargarDetalles() async {
    setState(() {
      _cargando = true;
    });
    try {
      final detalles = await _apiService.obtenerDetalleCurso(_curso["id_curso"]);
      if (mounted) {
        setState(() {
          // Unimos los datos nuevos con los existentes (por si había progreso, estado, etc)
          _curso.addAll(detalles);
          _cargando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String nombre = _curso["nombre"] ?? "Curso";
    final String fechaLim = _formatearFecha(_curso["fecha_lim"]?.toString());
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
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      nombre,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF151B3D),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Color(0xFFE0E0E0), size: 28),
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
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _curso["descripcion"] ?? "Descripción general del curso no disponible.",
                        style: const TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                      const SizedBox(height: 24),
                      
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.workspace_premium, color: Colors.grey.shade400, size: 22),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "Otorga",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _curso["otorga"] ?? "N/A",
                                  style: const TextStyle(
                                    color: Color(0xFF151B3D),
                                    fontSize: 14,
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
                                    Icon(Icons.format_list_bulleted, color: Colors.grey.shade400, size: 22),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "Categorías",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _curso["categorias"] ?? "N/A",
                                  style: const TextStyle(
                                    color: Color(0xFF151B3D),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.grey.shade400, size: 22),
                          const SizedBox(width: 8),
                          const Text(
                            "Fecha límite",
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fechaLim,
                        style: const TextStyle(
                          color: Color(0xFF151B3D),
                          fontSize: 14,
                        ),
                      ),
                      
                      // Cursos requeridos
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Icon(Icons.library_books, color: Colors.grey.shade400, size: 22),
                          const SizedBox(width: 8),
                          const Text(
                            "Cursos requeridos",
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (requeridos.isEmpty)
                        const Text(
                          "No cuenta con cursos requeridos registrados.",
                          style: TextStyle(
                            color: Color(0xFF151B3D),
                            fontSize: 14,
                          ),
                        )
                      else
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: requeridos.map((req) => _BadgeRequerido(nombre: req["nombre"] ?? "Microcurso")).toList(),
                        ),
                    ],
                  ),
                ),
            ],
          ),
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
              )
            ],
          ),
          child: const Center(
            child: Icon(Icons.workspace_premium, color: Color(0xFFE0E0E0), size: 32),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 70,
          child: Text(
            nombre,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF151B3D)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
