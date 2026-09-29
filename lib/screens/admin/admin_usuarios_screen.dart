import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../widgets/fondo_app.dart';
import '../../widgets/campo_busqueda.dart';
import '../../widgets/boton_filtros.dart';
import '../../widgets/modal_detalle_usuario.dart';

class ColoresUsuarios {
  static const Color textoOscuro = Color(0xFF151B3D);
  static const Color verde = Color(0xFFB5CC3A);
  static const Color azulClaro = Color(0xFF9CAECC);
}

class AdminUsuariosScreen extends StatefulWidget {
  const AdminUsuariosScreen({super.key});

  @override
  State<AdminUsuariosScreen> createState() => _AdminUsuariosScreenState();
}

class _AdminUsuariosScreenState extends State<AdminUsuariosScreen>
    with AutomaticKeepAliveClientMixin {
  final _apiService = ApiService();
  final _buscadorController = TextEditingController();

  bool _cargando = true;
  String? _error;
  List<dynamic> _usuarios = [];

  // null = todos, "docente", "admin"
  String? _filtroCategoria;
  // null = todos los años; si no es null, es el prefijo de año del numero_usuario, ej. "2026"
  String? _filtroAnio;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final usuarios = await _apiService.obtenerUsuariosAdmin();
      if (!mounted) return;
      setState(() {
        _usuarios = usuarios;
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

  List<dynamic> get _usuariosFiltrados {
    final texto = _buscadorController.text.trim().toLowerCase();
    return _usuarios.where((u) {
      final coincideTexto =
          texto.isEmpty ||
          "${u["nombre"]} ${u["apellidos"]}".toLowerCase().contains(texto) ||
          (u["correo"] ?? "").toString().toLowerCase().contains(texto) ||
          (u["no_empleado"] ?? "").toString().toLowerCase().contains(texto) ||
          (u["numero_usuario"] ?? "").toString().toLowerCase().contains(texto);
      final coincideCategoria =
          _filtroCategoria == null ||
          (u["categoria"] ?? "").toString().toLowerCase() == _filtroCategoria;
      final coincideAnio =
          _filtroAnio == null ||
          (u["numero_usuario"] ?? "").toString().startsWith(_filtroAnio!);
      return coincideTexto && coincideCategoria && coincideAnio;
    }).toList();
  }

  // Años disponibles, calculados de los usuarios ya cargados (primeros 4 dígitos del numero_usuario)
 List<String> get _aniosDisponibles {
  final set = <String>{};
  final regexAnioValido = RegExp(r'^20\d{2}$'); // solo años tipo "20XX"
  for (var u in _usuarios) {
    final num = (u["numero_usuario"] ?? "").toString();
    if (num.length >= 4) {
      final posibleAnio = num.substring(0, 4);
      if (regexAnioValido.hasMatch(posibleAnio)) {
        set.add(posibleAnio);
      }
    }
  }
  final lista = set.toList()..sort((a, b) => b.compareTo(a));
  return lista;
}

  int get _filtrosActivos =>
      (_filtroCategoria != null ? 1 : 0) + (_filtroAnio != null ? 1 : 0);

  Future<void> _abrirFiltros() async {
    String? filtroTemp = _filtroCategoria;
    String? filtroAnioTemp = _filtroAnio;
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
                          color: ColoresUsuarios.textoOscuro,
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
                    "Categoría",
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
                        label: const Text("Docente"),
                        selected: filtroTemp == "docente",
                        onSelected: (_) =>
                            setModalState(() => filtroTemp = "docente"),
                      ),
                      ChoiceChip(
                        label: const Text("Admin"),
                        selected: filtroTemp == "admin",
                        onSelected: (_) =>
                            setModalState(() => filtroTemp = "admin"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Año de pasaporte",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text("Todos"),
                        selected: filtroAnioTemp == null,
                        onSelected: (_) =>
                            setModalState(() => filtroAnioTemp = null),
                      ),
                      ..._aniosDisponibles.map(
                        (anio) => ChoiceChip(
                          label: Text(anio),
                          selected: filtroAnioTemp == anio,
                          onSelected: (_) =>
                              setModalState(() => filtroAnioTemp = anio),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColoresUsuarios.textoOscuro,
                      ),
                      onPressed: () {
                        setState(() {
                          _filtroCategoria = filtroTemp;
                          _filtroAnio = filtroAnioTemp;
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

  Future<void> _abrirFormularioMaestro({
    Map<String, dynamic>? usuarioExistente,
  }) async {
    final esEdicion = usuarioExistente != null;
    final nombreCtrl = TextEditingController(
      text: usuarioExistente?["nombre"] ?? "",
    );
    final apellidosCtrl = TextEditingController(
      text: usuarioExistente?["apellidos"] ?? "",
    );
    final correoCtrl = TextEditingController(
      text: usuarioExistente?["correo"] ?? "",
    );
    final contrasenaCtrl = TextEditingController();
    final noEmpleadoCtrl = TextEditingController();
    final divisionCtrl = TextEditingController(
      text: usuarioExistente?["division"] ?? "",
    );
    String categoriaSeleccionada = usuarioExistente?["categoria"] ?? "docente";
    String? errorLocal;
    bool guardando = false;

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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      esEdicion ? "Editar usuario" : "Agregar usuario",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ColoresUsuarios.textoOscuro,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nombreCtrl,
                      decoration: const InputDecoration(labelText: "Nombre"),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: apellidosCtrl,
                      decoration: const InputDecoration(labelText: "Apellidos"),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: correoCtrl,
                      decoration: const InputDecoration(labelText: "Correo"),
                      enabled: !esEdicion,
                    ),
                    const SizedBox(height: 12),
                    if (!esEdicion) ...[
                      TextField(
                        controller: noEmpleadoCtrl,
                        decoration: const InputDecoration(
                          labelText: "No. de empleado (6 dígitos)",
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Categoría",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text("Docente"),
                            selected: categoriaSeleccionada == "docente",
                            onSelected: (_) => setModalState(
                              () => categoriaSeleccionada = "docente",
                            ),
                          ),
                          ChoiceChip(
                            label: const Text("Admin"),
                            selected: categoriaSeleccionada == "admin",
                            onSelected: (_) => setModalState(
                              () => categoriaSeleccionada = "admin",
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                    // La división solo aplica a docentes (al crear, según lo elegido;
                    // al editar, solo si el usuario ya era docente desde antes)
                    if ((!esEdicion && categoriaSeleccionada == "docente") ||
                        (esEdicion && usuarioExistente["id_docente"] != null))
                      TextField(
                        controller: divisionCtrl,
                        decoration: const InputDecoration(
                          labelText: "División",
                        ),
                      ),
                    if (errorLocal != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        errorLocal!,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColoresUsuarios.textoOscuro,
                        ),
                        onPressed: guardando
                            ? null
                            : () async {
                                setModalState(() => guardando = true);
                                try {
                                  if (esEdicion) {
                                    await _apiService.actualizarUsuarioAdmin(
                                      usuarioExistente["id_usuario"],
                                      {
                                        "nombre": nombreCtrl.text.trim(),
                                        "apellidos": apellidosCtrl.text.trim(),
                                      },
                                    );
                                    if (usuarioExistente["id_docente"] !=
                                        null) {
                                      await _apiService.actualizarDocenteAdmin(
                                        usuarioExistente["id_docente"],
                                        {"division": divisionCtrl.text.trim()},
                                      );
                                    }
                                  } else {
                                    await _apiService.crearUsuario({
                                      "nombre": nombreCtrl.text.trim(),
                                      "apellidos": apellidosCtrl.text.trim(),
                                      "correo": correoCtrl.text.trim(),
                                      "no_empleado": noEmpleadoCtrl.text.trim(),
                                      "categoria": categoriaSeleccionada,
                                      if (categoriaSeleccionada == "docente")
                                        "division": divisionCtrl.text.trim(),
                                    });
                                  }
                                  if (context.mounted) Navigator.pop(context);
                                  _cargar();
                                } catch (e) {
                                  setModalState(() {
                                    errorLocal = e.toString().replaceFirst(
                                      "Exception: ",
                                      "",
                                    );
                                    guardando = false;
                                  });
                                }
                              },
                        child: guardando
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                esEdicion ? "Guardar cambios" : "Crear maestro",
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmarEliminar(Map<String, dynamic> usuario) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Eliminar usuario?"),
        content: Text(
          "Se eliminará a ${usuario["nombre"]} ${usuario["apellidos"]} de forma permanente.",
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
        await _apiService.eliminarUsuarioAdmin(usuario["id_usuario"]);
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

    final lista = _usuariosFiltrados;

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
                  "USUARIOS",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ColoresUsuarios.textoOscuro,
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: OutlinedButton.icon(
                    onPressed: () => _abrirFormularioMaestro(),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A9B7F),
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.person_add, color: Colors.white),
                    label: const Text(
                      "Agregar usuario",
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
                    hint: "Buscar usuario",
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
                      "No se encontraron usuarios.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  ...lista.map(
                    (u) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 6,
                      ),
                      child: GestureDetector(
                        onTap: () => mostrarDetalleUsuario(context, u, _cargar),
                        child: _TarjetaUsuario(
                          usuario: u,
                          onEditar: () => mostrarDetalleUsuario(
                            context,
                            u,
                            _cargar,
                            editarDeInicio: true,
                          ),
                          onEliminar: () => _confirmarEliminar(u),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 24),
                const Text(
                  "Página 2",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ColoresUsuarios.textoOscuro,
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

class _TarjetaUsuario extends StatelessWidget {
  final Map<String, dynamic> usuario;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const _TarjetaUsuario({
    required this.usuario,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final esDocente =
        (usuario["categoria"] ?? "").toString().toLowerCase() == "docente";
    final colorAvatar = esDocente
        ? ColoresUsuarios.verde
        : ColoresUsuarios.azulClaro;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Stack(
        children: [
          // Botones flotando en la esquina — NUNCA se mueven, sin importar
          // cuánto texto haya en el resto de la tarjeta.
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

          // Contenido normal, con espacio reservado a la derecha (60px)
          // para que el texto nunca quede debajo de los botones flotantes.
          Padding(
            padding: const EdgeInsets.only(right: 60),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: colorAvatar,
                      backgroundImage:
                          (usuario["foto_url"] != null &&
                              usuario["foto_url"].toString().isNotEmpty)
                          ? NetworkImage(usuario["foto_url"])
                          : null,
                      child:
                          (usuario["foto_url"] == null ||
                              usuario["foto_url"].toString().isEmpty)
                          ? const Icon(
                              Icons.person,
                              size: 24,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorAvatar,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        esDocente ? "Docente" : "Admin",
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre: puede crecer a 2 líneas sin empujar nada más,
                      // porque ya no comparte fila con los botones.
                      Text(
                        "${usuario["nombre"]} ${usuario["apellidos"]}",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: ColoresUsuarios.textoOscuro,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        usuario["correo"] ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      if (esDocente) ...[
                        const SizedBox(height: 4),
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: "División: ",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              TextSpan(
                                text: usuario["division"] ?? "Sin asignar",
                                style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
