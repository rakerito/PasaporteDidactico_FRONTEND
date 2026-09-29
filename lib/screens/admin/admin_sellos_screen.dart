import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../widgets/fondo_app.dart';
import '../../widgets/campo_busqueda.dart';
import '../../widgets/boton_filtros.dart';
import '../../widgets/modal_detalle_sello_admin.dart';

class ColoresSellos {
  static const Color textoOscuro = Color(0xFF151B3D);
  static const Color verde = Color(0xFFB5CC3A);
}

class AdminSellosScreen extends StatefulWidget {
  const AdminSellosScreen({super.key});

  @override
  State<AdminSellosScreen> createState() => _AdminSellosScreenState();
}

class _AdminSellosScreenState extends State<AdminSellosScreen>
    with AutomaticKeepAliveClientMixin {
  final _apiService = ApiService();
  final _buscadorController = TextEditingController();

  bool _cargando = true;
  String? _error;
  List<dynamic> _sellos = [];

  // null = todos, "activo", "inactivo"
  String? _filtroEstado;

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
      final sellos = await _apiService.obtenerCatalogoSellos();
      if (!mounted) return;
      setState(() {
        _sellos = sellos;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        // Fallback to mock data for visual-only demo
        _sellos = _sellosMock;
        _cargando = false;
      });
    }
  }

  final List<Map<String, dynamic>> _sellosMock = [
    {
      "id_sello": 1,
      "nombre": "Innovador Digital",
      "descripcion": "Sello que pertenece a microcurso",
      "cursos_requeridos_count": 3,
      "estatus": "Activo",
      "otorga": "Constancia: \"Fundamentos de redes\"",
      "fecha_lim": "15.01.2026",
      "categorias": "Metodología, Comunicación",
      "inscritos": 189,
    },
    {
      "id_sello": 2,
      "nombre": "Mentor Certificado",
      "descripcion": "Dominio en tecnologías digitales",
      "cursos_requeridos_count": 3,
      "estatus": "Inactivo",
      "otorga": "Constancia: \"Mentoría Avanzada\"",
      "fecha_lim": "20.02.2026",
      "categorias": "Liderazgo, Mentoría",
      "inscritos": 45,
    }
  ];

  List<dynamic> get _sellosFiltrados {
    final texto = _buscadorController.text.trim().toLowerCase();
    final listaBase = _sellos.isEmpty ? _sellosMock : _sellos;
    return listaBase.where((s) {
      final coincideTexto =
          texto.isEmpty ||
          (s["nombre"] ?? "").toString().toLowerCase().contains(texto) ||
          (s["descripcion"] ?? "").toString().toLowerCase().contains(texto);
      
      final bool esActivo = (s["estatus"] ?? "").toString().toLowerCase() == "activo";
      final coincideEstado = _filtroEstado == null ||
          (_filtroEstado == "activo" && esActivo) ||
          (_filtroEstado == "inactivo" && !esActivo);
          
      return coincideTexto && coincideEstado;
    }).toList();
  }

  int get _filtrosActivos => _filtroEstado != null ? 1 : 0;

  Future<void> _abrirFiltros() async {
    String? filtroTemp = _filtroEstado;
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
                        "Filtros de Sellos",
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
                    "Estado del sello",
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
                            setModalState(() => filtroTemp == "inactivo"),
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
                        setState(() {
                          _filtroEstado = filtroTemp;
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
  Widget build(BuildContext context) {
    super.build(context);

    if (_cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final lista = _sellosFiltrados;

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
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Agregar sello próximamente")),
                      );
                    },
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
                      "Agregar sello",
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
                const SizedBox(height: 20),

                if (lista.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "No se encontraron sellos.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  ...lista.map(
                    (s) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 6,
                      ),
                      child: GestureDetector(
                        onTap: () => mostrarModalDetalleSelloAdmin(context, s),
                        child: _TarjetaSello(
                          sello: s,
                          onEditar: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Editar sello próximamente")),
                            );
                          },
                          onEliminar: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Eliminar sello próximamente")),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 24),
                const Text(
                  "Página 4",
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

class _TarjetaSello extends StatelessWidget {
  final Map<String, dynamic> sello;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const _TarjetaSello({
    required this.sello,
    required this.onEditar,
    required this.onEliminar,
  });

  Widget _buildSelloVisual() {
    final String nombre = (sello["nombre"] ?? "").toString().toLowerCase();
    
    // Si es Innovador Digital, dibujamos el sello redondo rojo texturizado
    if (nombre.contains("innovador")) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF8B2626), // Dark red
          border: Border.all(color: const Color(0xFF6B1D1D), width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
                style: BorderStyle.solid,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.verified,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ),
      );
    }
    
    // Si es Mentor Certificado u otro, dibujamos el sello estilo sketch del Panteón de Roma
    return Container(
      width: 90,
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF333333), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const RotatedBox(
              quarterTurns: 3,
              child: Text(
                "ROME",
                style: TextStyle(fontSize: 6, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
            ),
            const Icon(
              Icons.account_balance, // Pantheon sketch alternative
              color: Color(0xFF151B3D),
              size: 36,
            ),
            const RotatedBox(
              quarterTurns: 1,
              child: Text(
                "ITALY",
                style: TextStyle(fontSize: 6, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String nombre = sello["nombre"] ?? "Sello";
    final String descripcion = sello["descripcion"] ?? "";
    final int cursosRequeridos = sello["cursos_requeridos_count"] ?? 3;
    final bool activo = (sello["estatus"] ?? "").toString().toLowerCase() == "activo";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Stack(
        children: [
          // Edit/Delete Action Buttons
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

          // Main Card Content Layout
          Padding(
            padding: const EdgeInsets.only(right: 72),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left element: Sello Visual
                SizedBox(
                  width: 90,
                  child: Center(child: _buildSelloVisual()),
                ),
                const SizedBox(width: 14),
                
                // Right element: Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Nombre del sello",
                        style: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        nombre,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: ColoresSellos.textoOscuro,
                        ),
                      ),
                      const SizedBox(height: 6),
                      
                      // Horizontal divider line
                      const Divider(
                        color: Colors.grey,
                        thickness: 0.8,
                        height: 1,
                      ),
                      const SizedBox(height: 8),

                      const Text(
                        "Descripción",
                        style: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        descripcion,
                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      const Text(
                        "Cursos requeridos",
                        style: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        cursosRequeridos.toString(),
                        style: const TextStyle(
                          color: ColoresSellos.textoOscuro,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Active/Inactive badge at the bottom right corner
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
