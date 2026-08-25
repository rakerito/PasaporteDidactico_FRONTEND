import 'package:flutter/material.dart';

import '../services/api_service.dart';

const _meses = [
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

String _formatearFecha(String fechaIso) {
  try {
    final fecha = DateTime.parse(fechaIso).toLocal();
    return "${fecha.day.toString().padLeft(2, '0')}.${fecha.month.toString().padLeft(2, '0')}.${fecha.year}";
  } catch (_) {
    return "";
  }
}

Future<void> mostrarDetalleSello(
  BuildContext context,
  int idDocente,
  int idSello,
) async {
  await showDialog(
    context: context,
    builder: (_) => _ModalDetalleSello(idDocente: idDocente, idSello: idSello),
  );
}

class _ModalDetalleSello extends StatefulWidget {
  final int idDocente;
  final int idSello;

  const _ModalDetalleSello({required this.idDocente, required this.idSello});

  @override
  State<_ModalDetalleSello> createState() => _ModalDetalleSelloState();
}

class _ModalDetalleSelloState extends State<_ModalDetalleSello> {
  final _apiService = ApiService();
  bool _cargando = true;
  Map<String, dynamic>? _datos;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final r = await _apiService.obtenerDetalleSello(
        widget.idDocente,
        widget.idSello,
      );
      if (!mounted) return; // el modal ya se cerró, no hay nada que actualizar
      setState(() {
        _datos = r;
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

  Widget _imagenSello(String? url, {double tamano = 90, bool obtenido = true}) {
    final imagen = ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: tamano,
        height: tamano,
        child: url == null || url.isEmpty
            ? Container(
                color: Colors.grey.shade200,
                child: const Icon(Icons.verified, color: Colors.grey),
              )
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.verified, color: Colors.grey),
                ),
              ),
      ),
    );

    if (obtenido) return imagen;

    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        0.2126,
        0.7152,
        0.0722,
        0,
        0,
        0.2126,
        0.7152,
        0.0722,
        0,
        0,
        0.2126,
        0.7152,
        0.0722,
        0,
        0,
        0,
        0,
        0,
        0.4,
        0,
      ]),
      child: imagen,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: _cargando
            ? const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              )
            : _error != null
            ? SizedBox(height: 120, child: Center(child: Text(_error!)))
            : _contenido(),
      ),
    );
  }

  Widget _contenido() {
    final sello = _datos!["sello"];
    final constancia = _datos!["constancia"];
    final requeridos = (_datos!["sellos_requeridos"] as List?) ?? [];
    final obtenido = sello["obtenido"] == true;
    final estatus = sello["estatus"]?.toString() ?? "Inactivo";
    final esActivo = estatus.toLowerCase() == "activo";

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    _imagenSello(sello["imagen"], obtenido: obtenido),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        sello["nombre"] ?? "",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF151B3D),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.volunteer_activism,
                          size: 18,
                          color: Color(0xFF151B3D),
                        ),
                        SizedBox(width: 6),
                        Text(
                          "Otorga",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      constancia != null
                          ? 'Constancia:\n"${constancia["nombre"] ?? ""}"'
                          : "Sello",
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (obtenido && sello["fecha_completado"] != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.history,
                            size: 18,
                            color: Color(0xFF151B3D),
                          ),
                          SizedBox(width: 6),
                          Text(
                            "Obtenido en",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatearFecha(sello["fecha_completado"]),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              if (!obtenido)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            esActivo
                                ? Icons.check_circle_outline
                                : Icons.cancel_outlined,
                            size: 18,
                            color: esActivo
                                ? Colors.green.shade700
                                : Colors.red.shade400,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Estatus",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        esActivo ? "Activo" : "Inactivo",
                        style: TextStyle(
                          fontSize: 13,
                          color: esActivo
                              ? Colors.green.shade700
                              : Colors.red.shade400,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 20),

          if (requeridos.isNotEmpty) ...[
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 18,
                  color: Color(0xFF151B3D),
                ),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "Cursos requeridos para obtener constancia",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: requeridos.map<Widget>((s) {
                return SizedBox(
                  width: 70,
                  child: Column(
                    children: [
                      _imagenSello(
                        s["imagen"],
                        tamano: 60,
                        obtenido: s["obtenido"] == true,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s["nombre"] ?? "",
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
