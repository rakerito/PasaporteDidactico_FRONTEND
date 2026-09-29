import 'package:flutter/material.dart';

import '../../services/api_service.dart';

Future<void> abrirFormularioCurso(
  BuildContext context,
  VoidCallback onGuardado, {
  Map<String, dynamic>? cursoExistente,
  List<dynamic> cursosDisponibles = const [],
}) async {
  final apiService = ApiService();
  final esEdicion = cursoExistente != null;

  final nombreCtrl = TextEditingController(
    text: cursoExistente?["nombre"] ?? "",
  );
  final descripcionCtrl = TextEditingController(
    text: cursoExistente?["descripcion"] ?? "",
  );
  final duracionCtrl = TextEditingController(
    text: cursoExistente?["duracion"]?.toString() ?? "",
  );
  final diasCtrl = TextEditingController(
    text: cursoExistente?["dias_para_completar"]?.toString() ?? "",
  );

  String estatusSeleccionado = (cursoExistente?["estatus"] ?? "Activo")
      .toString();
  int? idSelloSeleccionado = cursoExistente?["id_sello1"];
  Set<int> categoriasSeleccionadas = Set<int>.from(
    cursoExistente?["categorias_ids"] ?? [],
  );
  String tipoSeleccionado = (cursoExistente?["tipo"] ?? "normal").toString();
  int? idCursoPadreSeleccionado = cursoExistente?["id_curso_padre"];

  // Cursos "normal" disponibles para ser elegidos como padre (nunca el propio curso, si se edita)
  final cursosNormales = cursosDisponibles
      .where(
        (c) =>
            (c["tipo"] ?? "normal") == "normal" &&
            c["id_curso"] != cursoExistente?["id_curso"],
      )
      .toList();

  List<dynamic> sellos = [];
  List<dynamic> categorias = [];
  bool cargandoCatalogos = true;
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
          if (cargandoCatalogos) {
            Future.wait([
                  apiService.obtenerCatalogoSellos(),
                  apiService.obtenerCatalogoCategorias(),
                ])
                .then((resultados) {
                  setModalState(() {
                    sellos = resultados[0];
                    categorias = resultados[1];
                    cargandoCatalogos = false;
                  });
                })
                .catchError((e) {
                  setModalState(() {
                    errorLocal = "No se pudieron cargar los catálogos.";
                    cargandoCatalogos = false;
                  });
                });
          }

          Future<void> crearCategoriaNueva() async {
            final nombreCtrlCategoria = TextEditingController();
            final resultado = await showDialog<String>(
              context: context,
              builder: (ctxDialog) => AlertDialog(
                title: const Text("Nueva categoría"),
                content: TextField(
                  controller: nombreCtrlCategoria,
                  decoration: const InputDecoration(
                    labelText: "Nombre de la categoría",
                  ),
                  autofocus: true,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctxDialog),
                    child: const Text("Cancelar"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(
                      ctxDialog,
                      nombreCtrlCategoria.text.trim(),
                    ),
                    child: const Text("Crear"),
                  ),
                ],
              ),
            );

            if (resultado != null && resultado.isNotEmpty) {
              try {
                final nueva = await apiService.crearCategoria(resultado);
                setModalState(() {
                  categorias.add(nueva);
                  categoriasSeleccionadas.add(nueva["id_categoria"]);
                });
              } catch (e) {
                setModalState(
                  () =>
                      errorLocal = e.toString().replaceFirst("Exception: ", ""),
                );
              }
            }
          }

          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: cargandoCatalogos
                  ? const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          esEdicion ? "Editar curso" : "Agregar curso",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF151B3D),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: nombreCtrl,
                          decoration: const InputDecoration(
                            labelText: "Nombre",
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: descripcionCtrl,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: "Descripción",
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: duracionCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Duración (horas)",
                          ),
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          "Estatus",
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
                              label: const Text("Activo"),
                              selected: estatusSeleccionado == "Activo",
                              onSelected: (_) => setModalState(
                                () => estatusSeleccionado = "Activo",
                              ),
                            ),
                            ChoiceChip(
                              label: const Text("Inactivo"),
                              selected: estatusSeleccionado == "Inactivo",
                              onSelected: (_) => setModalState(
                                () => estatusSeleccionado = "Inactivo",
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // === Tipo de curso: solo editable al CREAR, no al editar ===
                        const Text(
                          "Tipo de curso",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (esEdicion)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.lock_outline,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  tipoSeleccionado == "microcurso"
                                      ? "Microcurso"
                                      : "Normal",
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  "No editable",
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            children: [
                              ChoiceChip(
                                label: const Text("Normal"),
                                selected: tipoSeleccionado == "normal",
                                onSelected: (_) => setModalState(
                                  () => tipoSeleccionado = "normal",
                                ),
                              ),
                              ChoiceChip(
                                label: const Text("Microcurso"),
                                selected: tipoSeleccionado == "microcurso",
                                onSelected: (_) => setModalState(
                                  () => tipoSeleccionado = "microcurso",
                                ),
                              ),
                            ],
                          ),

                        // === Curso padre: solo si es microcurso ===
                        if (tipoSeleccionado == "microcurso") ...[
                          const SizedBox(height: 12),
                          const Text(
                            "Curso padre",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (cursosNormales.isEmpty)
                            const Text(
                              "No hay cursos de tipo 'Normal' disponibles todavía para asignar como padre.",
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 12,
                              ),
                            )
                          else
                            DropdownButtonFormField<int>(
                              initialValue: idCursoPadreSeleccionado,
                              items: cursosNormales
                                  .map<DropdownMenuItem<int>>(
                                    (c) => DropdownMenuItem(
                                      value: c["id_curso"],
                                      child: Text(c["nombre"] ?? ""),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) => setModalState(
                                () => idCursoPadreSeleccionado = v,
                              ),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                            ),
                        ],
                        const SizedBox(height: 16),

                        const Text(
                          "Sello que otorga",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          initialValue: idSelloSeleccionado,
                          items: sellos
                              .map<DropdownMenuItem<int>>(
                                (s) => DropdownMenuItem(
                                  value: s["id_sello"],
                                  child: Text(s["nombre"] ?? ""),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setModalState(() => idSelloSeleccionado = v),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            const Text(
                              "Categorías",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: crearCategoriaNueva,
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text(
                                "Nueva",
                                style: TextStyle(fontSize: 12),
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: categorias.map<Widget>((c) {
                            final seleccionada = categoriasSeleccionadas
                                .contains(c["id_categoria"]);
                            return FilterChip(
                              label: Text(c["nombre"] ?? ""),
                              selected: seleccionada,
                              onSelected: (v) => setModalState(() {
                                if (v) {
                                  categoriasSeleccionadas.add(
                                    c["id_categoria"],
                                  );
                                } else {
                                  categoriasSeleccionadas.remove(
                                    c["id_categoria"],
                                  );
                                }
                              }),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),

                        TextField(
                          controller: diasCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Días para completar (opcional)",
                            helperText: "Días desde que el docente se inscribe hasta su fecha límite. Déjalo vacío si no aplica.",
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
                              backgroundColor: const Color(0xFF151B3D),
                            ),
                            onPressed: guardando
                                ? null
                                : () async {
                                    if (nombreCtrl.text.trim().isEmpty ||
                                        idSelloSeleccionado == null) {
                                      setModalState(
                                        () => errorLocal =
                                            "Nombre y sello son obligatorios.",
                                      );
                                      return;
                                    }
                                    if (tipoSeleccionado == "microcurso" &&
                                        idCursoPadreSeleccionado == null) {
                                      setModalState(
                                        () => errorLocal = "Selecciona el curso padre para este microcurso.",
                                      );
                                      return;
                                    }
                                    setModalState(() => guardando = true);
                                    try {
                                      final datos = {
                                        "nombre": nombreCtrl.text.trim(),
                                        "descripcion": descripcionCtrl.text
                                            .trim(),
                                        "duracion":
                                            int.tryParse(
                                              duracionCtrl.text.trim(),
                                            ) ??
                                            0,
                                        "estatus": estatusSeleccionado,
                                        "id_sello1": idSelloSeleccionado,
                                        "categorias_ids":
                                            categoriasSeleccionadas.toList(),
                                        if (diasCtrl.text.trim().isNotEmpty)
                                          "dias_para_completar": int.tryParse(
                                            diasCtrl.text.trim(),
                                          ),
                                        if (!esEdicion)
                                          "tipo": tipoSeleccionado,
                                        if (!esEdicion &&
                                            tipoSeleccionado == "microcurso")
                                          "id_curso_padre":
                                              idCursoPadreSeleccionado,
                                      };

                                      if (esEdicion) {
                                        await apiService.actualizarCursoAdmin(
                                          cursoExistente["id_curso"],
                                          datos,
                                        );
                                      } else {
                                        await apiService.crearCursoAdmin(datos);
                                      }
                                      if (context.mounted)
                                        Navigator.pop(context);
                                      onGuardado();
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
                                    esEdicion
                                        ? "Guardar cambios"
                                        : "Crear curso",
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
