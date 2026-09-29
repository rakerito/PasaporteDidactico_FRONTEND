import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../widgets/fondo_app.dart';

class ColoresAdmin {
  static const Color textoOscuro = Color(0xFF151B3D);
  static const Color verdeAcento = Color(0xFF1F9D6D);
}

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen>
    with AutomaticKeepAliveClientMixin {
  final _apiService = ApiService();

  bool _cargando = true;
  String? _error;

  int _docentes = 0;
  int _sellosOtorgados = 0;
  int _cursosActivos = 0;
  int _constanciasOtorgadas = 0;
  List<dynamic> _cursosDestacados = [];
  List<dynamic> _cursosProximos = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final datos = await _apiService.obtenerReporteMensual();
      if (!mounted) return;
      setState(() {
        _docentes = datos["docentes"] ?? 0;
        _sellosOtorgados = datos["sellos_otorgados"] ?? 0;
        _cursosActivos = datos["cursos_activos"] ?? 0;
        _constanciasOtorgadas = datos["constancias_otorgadas"] ?? 0;
        _cursosDestacados = datos["cursos_destacados"] ?? [];
        _cursosProximos = datos["cursos_proximos_vencer"] ?? [];
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

  String _fechaCorta(String? iso) {
    if (iso == null || iso.isEmpty) return "—";
    try {
      final dt = DateTime.parse(iso).toLocal();
      return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year.toString().substring(2)}";
    } catch (_) {
      return "—";
    }
  }

  // Colores rotativos para las burbujas de "Cursos destacados"
  static const List<Color> _coloresBurbujas = [
    Color(0xFFB5CC3A),
    Color(0xFF8FBF7F),
    Color(0xFF4A9B7F),
    Color(0xFF9CAECC),
    Color(0xFF3D5A99),
  ];

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

    return FondoApp(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text(
                "PANEL DE\nADMINISTRADOR",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ColoresAdmin.textoOscuro,
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 24),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Reporte mensual",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: ColoresAdmin.textoOscuro,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _StatBox(
                      valor: _docentes,
                      etiqueta: "Docentes",
                      color: const Color(0xFF151B3D),
                    ),
                    _StatBox(
                      valor: _sellosOtorgados,
                      etiqueta: "Sellos otorgados",
                      color: const Color(0xFFB5CC3A),
                      textoOscuro: true,
                    ),
                    _StatBox(
                      valor: _cursosActivos,
                      etiqueta: "Cursos activos",
                      color: const Color(0xFF4A9B7F),
                    ),
                    _StatBox(
                      valor: _constanciasOtorgadas,
                      etiqueta: "Constancias",
                      color: const Color(0xFF9CAECC),
                      textoOscuro: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Cursos destacados",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: ColoresAdmin.textoOscuro,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: _cursosDestacados.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              "Aún no hay suficientes datos.",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      : Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 12,
                          runSpacing: 12,
                          children: List.generate(_cursosDestacados.length, (
                            i,
                          ) {
                            final curso = _cursosDestacados[i];
                            return Container(
                              width: 90,
                              height: 90,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color:
                                    _coloresBurbujas[i %
                                        _coloresBurbujas.length],
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                curso["nombre"] ?? "",
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }),
                        ),
                ),
              ),
              const SizedBox(height: 28),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Cursos próximos a vencer",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: ColoresAdmin.textoOscuro,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _cursosProximos.isEmpty
                    ? const Text(
                        "No hay cursos con fecha de vencimiento próxima.",
                        style: TextStyle(color: Colors.grey),
                      )
                    : Column(
                        children: _cursosProximos.map((c) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4A9B7F).withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    c["nombre"] ?? "",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: ColoresAdmin.textoOscuro,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    _fechaCorta(c["fecha_lim_default"]),
                                    style: const TextStyle(
                                      color: ColoresAdmin.textoOscuro,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),

              const SizedBox(height: 24),
              const Text(
                "Página 1",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ColoresAdmin.textoOscuro,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final int valor;
  final String etiqueta;
  final Color color;
  final bool textoOscuro;

  const _StatBox({
    required this.valor,
    required this.etiqueta,
    required this.color,
    this.textoOscuro = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorTexto = textoOscuro ? ColoresAdmin.textoOscuro : Colors.white;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              "$valor",
              style: TextStyle(
                color: colorTexto,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              etiqueta,
              textAlign: TextAlign.center,
              style: TextStyle(color: colorTexto.withOpacity(0.9), fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}
