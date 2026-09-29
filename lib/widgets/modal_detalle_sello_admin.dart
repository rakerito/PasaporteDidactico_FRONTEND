import 'package:flutter/material.dart';

void mostrarModalDetalleSelloAdmin(
  BuildContext context,
  Map<String, dynamic> sello,
) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.all(20),
        child: _ModalDetalleSelloAdminContenido(sello: sello),
      );
    },
  );
}

class _ModalDetalleSelloAdminContenido extends StatelessWidget {
  final Map<String, dynamic> sello;
  const _ModalDetalleSelloAdminContenido({required this.sello});

  Widget _itemDetalle(IconData icono, String etiqueta, String valor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icono, color: Colors.grey.shade400, size: 20),
            const SizedBox(width: 6),
            Text(
              etiqueta,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          valor,
          style: const TextStyle(color: Color(0xFF151B3D), fontSize: 13),
        ),
      ],
    );
  }

  Widget _itemDetalleCategorias(IconData icono, String etiqueta, String valor) {
    final items = valor
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icono, color: Colors.grey.shade400, size: 20),
            const SizedBox(width: 6),
            Text(
              etiqueta,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (items.isEmpty)
          const Text(
            "—",
            style: TextStyle(color: Color(0xFF151B3D), fontSize: 13),
          )
        else
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "• ",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: Color(0xFF151B3D),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final String nombre = sello["nombre"] ?? "Sello";
    final String descripcion = sello["descripcion"] ?? "Sin descripción.";
    final String fechaLim = sello["fecha_lim"] ?? "15.01.2026";
    final bool activo = (sello["estatus"] ?? "").toString().toLowerCase() == "activo";
    final String otorga = sello["otorga"] ?? "Constancia: \"Fundamentos de redes\"";
    final String categorias = sello["categorias"] ?? "Metodología, Comunicación";
    final String inscritos = (sello["inscritos"] ?? 189).toString();
    
    final List<dynamic> requeridos = [
      {"nombre": "Tecnólogo Educativo"},
      {"nombre": "Tecnólogo Educativo"},
      {"nombre": "Tecnólogo Educativo"},
      {"nombre": "Tecnólogo Educativo"},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      nombre,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF151B3D),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: activo ? const Color(0xFFB5CC3A) : const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        activo ? "Activo" : "Inactivo",
                        style: TextStyle(
                          color: activo ? Colors.black : Colors.grey.shade700,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(
                  Icons.edit_square,
                  color: Color(0xFF151B3D),
                  size: 22,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Editar sello próximamente")),
                  );
                },
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.close,
                  color: Color(0xFFE0E0E0),
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: Color(0xFFB5CC3A), thickness: 2, height: 1),
          const SizedBox(height: 16),

          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Descripción",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    descripcion,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _itemDetalle(
                              Icons.volunteer_activism,
                              "Otorga",
                              otorga,
                            ),
                            const SizedBox(height: 16),
                            _itemDetalle(
                              Icons.calendar_month,
                              "Fecha límite",
                              fechaLim,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _itemDetalleCategorias(
                              Icons.format_list_bulleted,
                              "Categorías",
                              categorias,
                            ),
                            const SizedBox(height: 16),
                            _itemDetalle(
                              Icons.people,
                              "Inscritos",
                              inscritos,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(
                        Icons.library_books,
                        color: Colors.grey.shade400,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Cursos requeridos para obtener constancia",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: requeridos
                        .map(
                          (req) => _BadgeRequerido(
                            nombre: req["nombre"] ?? "Microcurso",
                          ),
                        )
                        .toList(),
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

class _BadgeRequerido extends StatelessWidget {
  final String nombre;
  const _BadgeRequerido({required this.nombre});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.workspace_premium,
              color: Color(0xFFE0E0E0),
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 70,
          child: Text(
            nombre,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF151B3D),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
