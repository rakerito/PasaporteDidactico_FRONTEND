import 'package:flutter/material.dart';

import '../services/api_service.dart';

Future<void> mostrarDetalleUsuario(
  BuildContext context,
  Map<String, dynamic> usuario,
  VoidCallback onActualizado, {
  bool editarDeInicio = false,
}) async {
  await showDialog(
    context: context,
    builder: (_) => _ModalDetalleUsuario(
      usuario: usuario,
      onActualizado: onActualizado,
      editarDeInicio: editarDeInicio,
    ),
  );
}

class _ModalDetalleUsuario extends StatefulWidget {
  final Map<String, dynamic> usuario;
  final VoidCallback onActualizado;
  final bool editarDeInicio;

  const _ModalDetalleUsuario({
    required this.usuario,
    required this.onActualizado,
    this.editarDeInicio = false,
  });

  @override
  State<_ModalDetalleUsuario> createState() => _ModalDetalleUsuarioState();
}

class _ModalDetalleUsuarioState extends State<_ModalDetalleUsuario> {
  final _apiService = ApiService();

  late bool _editando;
  bool _guardando = false;
  String? _error;

  late TextEditingController _nombreCtrl;
  late TextEditingController _apellidosCtrl;
  late TextEditingController _noEmpleadoCtrl;
  late TextEditingController _divisionCtrl;
  late String _categoria;

  @override
  void initState() {
    super.initState();
    _editando = widget.editarDeInicio;
    _nombreCtrl = TextEditingController(text: widget.usuario["nombre"]);
    _apellidosCtrl = TextEditingController(text: widget.usuario["apellidos"]);
    _noEmpleadoCtrl = TextEditingController(
      text: widget.usuario["no_empleado"]?.toString() ?? "",
    );
    _divisionCtrl = TextEditingController(
      text: widget.usuario["division"] ?? "",
    );
    _categoria = (widget.usuario["categoria"] ?? "docente")
        .toString()
        .toLowerCase();
  }

  Future<void> _guardar() async {
    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      await _apiService.actualizarUsuarioCompleto(
        widget.usuario["id_usuario"],
        {
          "nombre": _nombreCtrl.text.trim(),
          "apellidos": _apellidosCtrl.text.trim(),
          "no_empleado": _noEmpleadoCtrl.text.trim(),
          "categoria": _categoria,
          if (_categoria == "docente") "division": _divisionCtrl.text.trim(),
        },
      );
      widget.onActualizado();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst("Exception: ", "");
        _guardando = false;
      });
    }
  }

  Widget _fila(IconData icono, String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 18, color: const Color(0xFF151B3D)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  etiqueta,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  valor.isEmpty ? "—" : valor,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filaEditable(
    IconData icono,
    String etiqueta,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 18, color: const Color(0xFF151B3D)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(labelText: etiqueta, isDense: true),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final esDocente = _categoria == "docente";

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: esDocente
                        ? const Color(0xFFB5CC3A)
                        : const Color(0xFF9CAECC),
                    backgroundImage:
                        (widget.usuario["foto_url"] != null &&
                            widget.usuario["foto_url"].toString().isNotEmpty)
                        ? NetworkImage(widget.usuario["foto_url"])
                        : null,
                    child:
                        (widget.usuario["foto_url"] == null ||
                            widget.usuario["foto_url"].toString().isEmpty)
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "${widget.usuario["nombre"]} ${widget.usuario["apellidos"]}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF151B3D),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 28),

              // Correo: SIEMPRE de solo lectura, sin importar si se está editando
              _fila(Icons.email, "Correo", widget.usuario["correo"] ?? ""),

              if (!_editando) ...[
                _fila(
                  Icons.badge,
                  "Categoría",
                  esDocente ? "Docente" : "Admin",
                ),
                _fila(
                  Icons.numbers,
                  "Número de empleado",
                  widget.usuario["no_empleado"]?.toString() ?? "",
                ),
                _fila(
                  Icons.confirmation_number,
                  "Número de pasaporte",
                  widget.usuario["numero_usuario"]?.toString() ?? "",
                ),
                if (esDocente)
                  _fila(
                    Icons.apartment,
                    "División",
                    widget.usuario["division"] ?? "",
                  ),
              ] else ...[
                _filaEditable(Icons.badge, "Nombre", _nombreCtrl),
                _filaEditable(Icons.badge, "Apellidos", _apellidosCtrl),
                _filaEditable(
                  Icons.numbers,
                  "Número de empleado",
                  _noEmpleadoCtrl,
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    "Categoría",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text("Docente"),
                      selected: _categoria == "docente",
                      onSelected: (_) => setState(() => _categoria = "docente"),
                    ),
                    ChoiceChip(
                      label: const Text("Admin"),
                      selected: _categoria == "admin",
                      onSelected: (_) => setState(() => _categoria = "admin"),
                    ),
                  ],
                ),
                if (_categoria == "docente") ...[
                  const SizedBox(height: 12),
                  _filaEditable(Icons.apartment, "División", _divisionCtrl),
                ],
              ],

              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
              ],

              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF151B3D),
                  ),
                  onPressed: _guardando
                      ? null
                      : () {
                          if (_editando) {
                            _guardar();
                          } else {
                            setState(() => _editando = true);
                          }
                        },
                  child: _guardando
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(_editando ? "Guardar cambios" : "Editar"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
