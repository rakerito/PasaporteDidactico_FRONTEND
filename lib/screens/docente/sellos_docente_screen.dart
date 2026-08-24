import 'package:flutter/material.dart';

import '../../services/auth_storage.dart';
import '../../services/api_service.dart';
import '../../widgets/fondo_app.dart';
import '../../widgets/modal_detalle_sello.dart';

class ColoresSellos {
  static const Color textoOscuro = Color(0xFF151B3D);
  static const Color botonClaro = Color(0xFF80A0CF);
}

enum FiltroSellos { todos, obtenidos, noObtenidos }

class SellosDocenteScreen extends StatefulWidget {
  const SellosDocenteScreen({super.key});

  @override
  State<SellosDocenteScreen> createState() => _SellosDocenteScreenState();
}

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
    return "${fecha.day.toString().padLeft(2, '0')}.${_meses[fecha.month - 1]}.${fecha.year}";
  } catch (_) {
    return "";
  }
}

class _SellosDocenteScreenState extends State<SellosDocenteScreen> {
  final _apiService = ApiService();
  final _buscadorController = TextEditingController();

  bool _cargando = true;
  String? _error;

  int? _idDocente;
  List<dynamic> _obtenidos = [];
  List<dynamic> _noObtenidos = [];
  FiltroSellos _filtro = FiltroSellos.todos;

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

      final datos = await _apiService.obtenerMisSellos(docente["id_docente"]);
      setState(() {
        _idDocente = docente["id_docente"];
        _obtenidos = datos["obtenidos"] ?? [];
        _noObtenidos = datos["no_obtenidos"] ?? [];
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst("Exception: ", "");
        _cargando = false;
      });
    }
  }

  List<dynamic> _filtrarPorBusqueda(List<dynamic> lista) {
    final texto = _buscadorController.text.trim().toLowerCase();
    if (texto.isEmpty) return lista;
    return lista
        .where(
          (s) => (s["nombre"] ?? "").toString().toLowerCase().contains(texto),
        )
        .toList();
  }

  Widget _tarjetaSello(Map<String, dynamic> sello, {required bool obtenido}) {
    final tarjeta = _contenidoTarjeta(sello, obtenido: obtenido);
    return InkWell(
      onTap: () {
        if (_idDocente != null) {
          mostrarDetalleSello(context, _idDocente!, sello["id_sello"]);
        }
      },
      child: tarjeta,
    );
  }

  Widget _contenidoTarjeta(
    Map<String, dynamic> sello, {
    required bool obtenido,
  }) {
    final imagen = ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 107,
        height: 107,
        child: sello["imagen"] == null || sello["imagen"].toString().isEmpty
            ? Container(
                color: Colors.grey.shade200,
                child: const Icon(Icons.verified, size: 50, color: Colors.grey),
              )
            : Image.network(
                sello["imagen"],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade200,
                  child: const Icon(
                    Icons.verified,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
              ),
      ),
    );

    return Column(
      children: [
        obtenido
            ? imagen
            : ColorFiltered(
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
              ),
        const SizedBox(height: 8),
        Text(
          sello["nombre"] ?? "",
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: obtenido ? ColoresSellos.textoOscuro : Colors.grey,
          ),
        ),
        if (obtenido && sello["fecha_completado"] != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              _formatearFecha(sello["fecha_completado"]),
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ),
      ],
    );
  }

  Widget _grid(List<dynamic> sellos, {required bool obtenido}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 24,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: sellos.length,
      itemBuilder: (context, i) => _tarjetaSello(sellos[i], obtenido: obtenido),
    );
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

    final obtenidosFiltrados = _filtrarPorBusqueda(_obtenidos);
    final noObtenidosFiltrados = _filtrarPorBusqueda(_noObtenidos);
    final mostrarObtenidos = _filtro != FiltroSellos.noObtenidos;
    final mostrarNoObtenidos = _filtro != FiltroSellos.obtenidos;

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
                  "SELLOS",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ColoresSellos.textoOscuro,
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
                      hintText: "Buscar sello",
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
                const SizedBox(height: 12),

                // Filtros
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<FiltroSellos>(
                        value: _filtro,
                        isExpanded: true,
                        icon: const Icon(Icons.filter_list),
                        items: const [
                          DropdownMenuItem(
                            value: FiltroSellos.todos,
                            child: Text("Todos"),
                          ),
                          DropdownMenuItem(
                            value: FiltroSellos.obtenidos,
                            child: Text("Obtenidos"),
                          ),
                          DropdownMenuItem(
                            value: FiltroSellos.noObtenidos,
                            child: Text("No obtenidos"),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => _filtro = v ?? FiltroSellos.todos),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                if (mostrarObtenidos) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Colección de logros",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: ColoresSellos.textoOscuro,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  obtenidosFiltrados.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text("Aún no tienes sellos obtenidos."),
                        )
                      : _grid(obtenidosFiltrados, obtenido: true),
                  const SizedBox(height: 32),
                ],

                if (mostrarNoObtenidos) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Logros por obtener",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: ColoresSellos.textoOscuro,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  noObtenidosFiltrados.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            "¡Ya tienes todos los sellos disponibles!",
                          ),
                        )
                      : _grid(noObtenidosFiltrados, obtenido: false),
                ],

                const SizedBox(height: 24),
                const Text(
                  "Página 2",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ColoresSellos.textoOscuro,
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
