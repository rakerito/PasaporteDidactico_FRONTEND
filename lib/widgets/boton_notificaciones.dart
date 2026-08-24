import 'package:flutter/material.dart';

import '../../services/api_service.dart';

const Map<String, Color> _colorPorTipo = {
  "sello": Color(0xFFDCF3E8), // verde suave
  "curso": Color(0xFFDCE6F5), // azul suave
  "constancia": Color(0xFFF6F3D5), // amarillo suave
};

const Map<String, Color> _puntoPorTipo = {
  "sello": Color(0xFF1F9D6D),
  "curso": Color(0xFF3D6B9E),
  "constancia": Color(0xFFC9B400),
};

class BotonNotificaciones extends StatefulWidget {
  const BotonNotificaciones({super.key});

  @override
  State<BotonNotificaciones> createState() => _BotonNotificacionesState();
}

class _BotonNotificacionesState extends State<BotonNotificaciones> {
  final _apiService = ApiService();
  bool _panelAbierto = false;
  Map<String, dynamic>? _resumen;

  @override
  void initState() {
    super.initState();
    _cargarResumen();
  }

  Future<void> _cargarResumen() async {
    try {
      final r = await _apiService.obtenerResumenNotificaciones();
      if (mounted) setState(() => _resumen = r);
    } catch (e) {
      debugPrint(
        "ERROR al cargar resumen de notificaciones: $e",
      ); // TEMPORAL, para depurar
    }
  }

  void _abrirModalCompleto() async {
    setState(() => _panelAbierto = false);
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ModalNotificaciones(onVaciar: _cargarResumen),
    );
    _cargarResumen(); // refresca el resumen al cerrar el modal
  }

  @override
  Widget build(BuildContext context) {
    final total = _resumen?["total"] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _panelAbierto = !_panelAbierto),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFF80A0CF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.notifications,
                      size: 19,
                      color: Colors.white,
                    ),
                    if (total > 0)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 19,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
        if (_panelAbierto)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: InkWell(
              onTap: _abrirModalCompleto,
              child: Container(
                width: 170,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFBFCFE6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: total == 0
                    ? const Text(
                        "Sin notificaciones",
                        style: TextStyle(fontSize: 12),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if ((_resumen?["sello"] ?? 0) > 0)
                            Text(
                              "${_resumen!["sello"]} notificación(es) de sellos",
                              style: const TextStyle(fontSize: 11),
                            ),
                          if ((_resumen?["curso"] ?? 0) > 0)
                            Text(
                              "${_resumen!["curso"]} notificación(es) de cursos",
                              style: const TextStyle(fontSize: 11),
                            ),
                          if ((_resumen?["constancia"] ?? 0) > 0)
                            Text(
                              "${_resumen!["constancia"]} notificación(es) de constancias",
                              style: const TextStyle(fontSize: 11),
                            ),
                        ],
                      ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ModalNotificaciones extends StatefulWidget {
  final VoidCallback onVaciar;
  const _ModalNotificaciones({required this.onVaciar});

  @override
  State<_ModalNotificaciones> createState() => _ModalNotificacionesState();
}

class _ModalNotificacionesState extends State<_ModalNotificaciones> {
  final _apiService = ApiService();
  bool _cargando = true;
  List<dynamic> _notificaciones = [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final lista = await _apiService.obtenerNotificaciones();
      setState(() {
        _notificaciones = lista;
        _cargando = false;
      });
    } catch (_) {
      setState(() => _cargando = false);
    }
  }

  Future<void> _vaciar() async {
    await _apiService.vaciarNotificaciones();
    widget.onVaciar();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _abrirDetalle(Map<String, dynamic> n) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(n["titulo"] ?? ""),
        content: Text(n["mensaje"] ?? ""),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          ),
        ],
      ),
    );

    if (n["leida"] == true) return;

    try {
      await _apiService.marcarNotificacionLeida(
        n["origen"],
        n["id_notificacion"],
      );
      setState(() => n["leida"] = true);
      widget.onVaciar();
    } catch (_) {
      // si falla, no rompemos la UI; el usuario puede reintentar abriendo de nuevo
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
            child: Row(
              children: [
                const Icon(Icons.notifications, color: Color(0xFF151B3D)),
                const SizedBox(width: 8),
                const Text(
                  "Notificaciones",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF1F9D6D)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : _notificaciones.isEmpty
                ? const Center(child: Text("No tienes notificaciones"))
                : Scrollbar(
                    thumbVisibility: true,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _notificaciones.length,
                      itemBuilder: (context, i) {
                        final n = _notificaciones[i];
                        final tipo = n["tipo"] ?? "curso";
                        final leida = n["leida"] == true;
                        return InkWell(
                          onTap: () => _abrirDetalle(n),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color:
                                  (_colorPorTipo[tipo] ?? Colors.grey.shade100)
                                      .withValues(alpha: leida ? 0.5 : 1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color:
                                            _puntoPorTipo[tipo] ?? Colors.grey,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        n["titulo"] ?? "",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  n["mensaje"] ?? "",
                                  style: const TextStyle(fontSize: 13),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  n["creada_en"]?.toString().substring(0, 10) ??
                                      "",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
          if (_notificaciones.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: _vaciar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade100,
                  foregroundColor: Colors.red.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                icon: const Icon(Icons.close),
                label: const Text("Vaciar notificaciones"),
              ),
            ),
        ],
      ),
    );
  }
}
