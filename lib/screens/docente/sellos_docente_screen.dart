import 'package:flutter/material.dart';

import '../../services/auth_storage.dart';
import '../../services/api_service.dart';
import '../../widgets/fondo_app.dart';
import '../../widgets/modal_detalle_sello.dart';
import '../../widgets/campo_busqueda.dart';
import '../../widgets/boton_filtros.dart';

class ColoresSellos {
  static const Color textoOscuro = Color(0xFF151B3D);
  static const Color botonClaro = Color(0xFF80A0CF);
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

class SellosDocenteScreen extends StatefulWidget {
  const SellosDocenteScreen({super.key});

  @override
  State<SellosDocenteScreen> createState() => _SellosDocenteScreenState();
}

class _SellosDocenteScreenState extends State<SellosDocenteScreen> {
  final _apiService = ApiService();
  final _buscadorController = TextEditingController();

  bool _cargando = true;
  String? _error;

  int? _idDocente;
  List<dynamic> _obtenidos = [];
  List<dynamic> _noObtenidos = [];

  // null = todos, "obtenidos", "no_obtenidos"
  String? _filtroEstado;

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

  int get _filtrosActivos => _filtroEstado != null ? 1 : 0;

  Future<void> _abrirFiltros() async {
    String? filtroTemp = _filtroEstado;

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
                          color: ColoresSellos.textoOscuro,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => setModalState(() => filtroTemp = null),
                        child: const Text("Limpiar"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Estado",
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
                        label: const Text("Obtenidos"),
                        selected: filtroTemp == "obtenidos",
                        onSelected: (_) =>
                            setModalState(() => filtroTemp = "obtenidos"),
                      ),
                      ChoiceChip(
                        label: const Text("No obtenidos"),
                        selected: filtroTemp == "no_obtenidos",
                        onSelected: (_) =>
                            setModalState(() => filtroTemp = "no_obtenidos"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColoresSellos.textoOscuro,
                      ),
                      onPressed: () {
                        setState(() => _filtroEstado = filtroTemp);
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
    final mostrarObtenidos = _filtroEstado != "no_obtenidos";
    final mostrarNoObtenidos = _filtroEstado != "obtenidos";

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

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CampoBusqueda(
                    controller: _buscadorController,
                    hint: "Buscar sello",
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
