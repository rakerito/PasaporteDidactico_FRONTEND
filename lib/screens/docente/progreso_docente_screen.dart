import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../services/auth_storage.dart';
import '../../services/api_service.dart';
import '../../widgets/fondo_app.dart';
import '../../widgets/modal_detalle_curso.dart';

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

String _formatearFechaProgreso(String? fechaIso) {
  if (fechaIso == null || fechaIso.isEmpty) return "—";
  try {
    final fecha = DateTime.parse(fechaIso).toLocal();
    return "${fecha.day.toString().padLeft(2, '0')}.${_mesesProgreso[fecha.month - 1]}.${fecha.year}";
  } catch (_) {
    return fechaIso;
  }
}

class ProgresoDocenteScreen extends StatefulWidget {
  const ProgresoDocenteScreen({super.key});

  @override
  State<ProgresoDocenteScreen> createState() => _ProgresoDocenteScreenState();
}

class _ProgresoDocenteScreenState extends State<ProgresoDocenteScreen> {
  final _apiService = ApiService();
  final _buscadorController = TextEditingController();

  bool _cargando = true;
  String? _error;

  int _avanceGeneral = 0;
  int _totalCursos = 0;
  int _totalConstancias = 0;
  int _totalSellos = 0;
  List<dynamic> _cursando = [];
  List<dynamic> _completados = [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final usuarioGuardado = await AuthStorage.obtenerUsuario();
      final idUsuario = usuarioGuardado?["id_usuario"];
      final docente = await _apiService.obtenerDocentePorUsuario(idUsuario);
      if (docente == null || docente["id_docente"] == null) {
        throw Exception("Este usuario no tiene perfil de docente.");
      }
      final datos = await _apiService.obtenerProgreso(docente["id_docente"]);
      setState(() {
        _cursando = datos["cursando"] ?? [];
        _completados = datos["completados"] ?? [];

        if (_cursando.isNotEmpty) {
          int sumaProgreso = 0;
          for (var c in _cursando) {
            sumaProgreso += int.tryParse(c["progreso"]?.toString() ?? "0") ?? 0;
          }
          _avanceGeneral = (sumaProgreso / _cursando.length).round();
        } else {
          _avanceGeneral = 0;
        }

        _totalCursos = (datos["total_cursos"] ?? 0).toInt();
        _totalConstancias = (datos["total_constancias"] ?? 0).toInt();
        _totalSellos = (datos["total_sellos"] ?? 0).toInt();
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst("Exception: ", "");
        _cargando = false;
      });
    }
  }

  List<dynamic> _filtrar(List<dynamic> lista) {
    final texto = _buscadorController.text.trim().toLowerCase();
    if (texto.isEmpty) return lista;
    return lista
        .where(
          (c) => (c["nombre"] ?? "").toString().toLowerCase().contains(texto),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
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
                  onPressed: () {
                    setState(() => _cargando = true);
                    _cargar();
                  },
                  child: const Text("Reintentar"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final cursandoFiltrado = _filtrar(_cursando);
    final completadosFiltrado = _filtrar(_completados);

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
                  "PROGRESO DE\nCAPACITACIÓN",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF151B3D),
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 20),

                // Buscador
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _buscadorController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: "Buscar curso",
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _buscadorController.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () =>
                                  setState(() => _buscadorController.clear()),
                            ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Tarjeta resumen
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Text(
                              "Avance\ngeneral",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF151B3D),
                              ),
                            ),
                            const Spacer(),
                            SizedBox(
                              width: 140,
                              height: 85,
                              child: _GaugeSemicircular(
                                porcentaje: _avanceGeneral,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _StatBox(
                              valor: _totalCursos,
                              etiqueta: "Cursos",
                              color: const Color(0xFF151B3D),
                              textoColor: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            _StatBox(
                              valor: _totalConstancias,
                              etiqueta: "Constancias",
                              color: const Color(0xFF4A9B7F),
                              textoColor: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            _StatBox(
                              valor: _totalSellos,
                              etiqueta: "Sellos",
                              color: const Color(0xFFB5CC3A),
                              textoColor: const Color(0xFF151B3D),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Cursando
                if (cursandoFiltrado.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Cursando",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF151B3D),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...cursandoFiltrado.map(
                    (c) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 6,
                      ),
                      child: GestureDetector(
                        onTap: () => mostrarModalDetalleCurso(context, c),
                        child: _TarjetaCursando(curso: c),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Completados
                if (completadosFiltrado.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Cursos completados",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF151B3D),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _TablaCompletados(completados: completadosFiltrado),
                  ),
                  const SizedBox(height: 24),
                ],

                if (cursandoFiltrado.isEmpty && completadosFiltrado.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "No se encontraron cursos.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),

                const SizedBox(height: 8),
                const Text(
                  "Página 3",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF151B3D),
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

// ─────────────────────────────────────────────────────────────────────────────
// Gauge semicircular
// ─────────────────────────────────────────────────────────────────────────────

class _GaugeSemicircular extends StatelessWidget {
  final int porcentaje;
  const _GaugeSemicircular({required this.porcentaje});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double w = constraints.maxWidth;
        final double h = constraints.maxHeight;
        final Offset center = Offset(w / 2, h);
        final double radius = w / 2 - 8;

        final double sweepAngle = math.pi * (porcentaje.clamp(0, 100) / 100.0);
        final double tipAngle = math.pi + sweepAngle;

        final double tipX = center.dx + radius * math.cos(tipAngle);
        final double tipY = center.dy + radius * math.sin(tipAngle);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            CustomPaint(
              size: Size(w, h),
              painter: _GaugePainter(porcentaje: porcentaje.clamp(0, 100)),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 28),
                child: Text(
                  "$porcentaje%",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF151B3D),
                  ),
                ),
              ),
            ),
            if (porcentaje > 0)
              Positioned(
                left: tipX - 16, // Centro del icono (tamaño 32)
                top: tipY - 16,
                child: Transform.rotate(
                  angle: sweepAngle - math.pi / 20, // Girar para que el avión siga la curva tangencial
                  child: const Icon(
                    Icons.flight,
                    size: 40,
                    color: Color.fromARGB(255, 156, 174, 51),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _GaugePainter extends CustomPainter {
  final int porcentaje;
  _GaugePainter({required this.porcentaje});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 8;
    const startAngle = math.pi;
    const sweepAngle = math.pi;

    // Track (fondo verde-lima)
    final trackPaint = Paint()
      ..color = const Color(0xFFB5CC3A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 13
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      trackPaint,
    );

    // Fill (azul oscuro)
    if (porcentaje > 0) {
      final fillPaint = Paint()
        ..color = const Color(0xFF151B3D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 13
        ..strokeCap = StrokeCap.round;
      final fillSweep = sweepAngle * (porcentaje / 100);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        fillSweep,
        false,
        fillPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.porcentaje != porcentaje;
}

// ─────────────────────────────────────────────────────────────────────────────
// Stat box
// ─────────────────────────────────────────────────────────────────────────────

class _StatBox extends StatelessWidget {
  final int valor;
  final String etiqueta;
  final Color color;
  final Color textoColor;

  const _StatBox({
    required this.valor,
    required this.etiqueta,
    required this.color,
    required this.textoColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              "$valor",
              style: TextStyle(
                color: textoColor,
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              etiqueta,
              style: TextStyle(
                color: textoColor.withOpacity(0.85),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tarjeta de curso en progreso
// ─────────────────────────────────────────────────────────────────────────────

class _TarjetaCursando extends StatelessWidget {
  final Map<String, dynamic> curso;
  const _TarjetaCursando({required this.curso});

  @override
  Widget build(BuildContext context) {
    final int progreso =
        int.tryParse(curso["progreso"]?.toString() ?? "0")?.clamp(0, 100) ?? 0;
    final String fechaLim = _formatearFechaProgreso(
      curso["fecha_lim"]?.toString(),
    );
    final String estado = curso["estado"] ?? "En progreso";

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Curso",
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 2),
          Text(
            curso["nombre"] ?? "",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xFF151B3D),
            ),
          ),
          const SizedBox(height: 10),
          _BarraAvion(progreso: progreso),
          const SizedBox(height: 10),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Fecha límite",
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    fechaLim,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF151B3D),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Estado",
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    estado,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF151B3D),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BarraAvion extends StatelessWidget {
  final int progreso;
  const _BarraAvion({required this.progreso});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Reserva ~56px para el texto del porcentaje a la derecha
        final double totalWidth = constraints.maxWidth - 56;
        final double fillWidth = totalWidth * progreso / 100;
        const double avionSize = 20.0;
        final double avionLeft = (fillWidth - avionSize / 2).clamp(
          0.0,
          totalWidth - avionSize,
        );

        return Row(
          children: [
            SizedBox(
              width: totalWidth,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Fondo de barra
                  Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB5CC3A).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  // Relleno
                  Container(
                    height: 10,
                    width: fillWidth,
                    decoration: BoxDecoration(
                      color: const Color(0xFF151B3D),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  // Avión
                  Positioned(
                    left: avionLeft,
                    top: -5,
                    child: Transform.rotate(
                      angle: math.pi / 4, // 45 grados (pi/4) hace que Icons.flight apunte exactamente a la derecha
                      child: const Icon(
                        Icons.flight,
                        size: avionSize,
                        color: Color.fromARGB(255, 156, 174, 51),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "$progreso %",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF151B3D),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tabla de cursos completados
// ─────────────────────────────────────────────────────────────────────────────

class _TablaCompletados extends StatelessWidget {
  final List<dynamic> completados;
  const _TablaCompletados({required this.completados});

  String _fechaCorta(String? iso) {
    if (iso == null || iso.isEmpty) return "—";
    try {
      final dt = DateTime.parse(iso).toLocal();
      return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year.toString().substring(2)}";
    } catch (_) {
      return "—";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Encabezado verde
          Container(
            color: const Color(0xFF4A9B7F),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    "Curso",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  "Terminó",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // Filas
          ...completados.map(
            (c) => Container(
              color: const Color(0xFF4A9B7F).withOpacity(0.12),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      c["nombre"] ?? "",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF151B3D),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _fechaCorta(c["fecha_completado"]?.toString()),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF151B3D),
                    ),
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
