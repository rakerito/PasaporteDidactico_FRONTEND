import 'package:flutter/material.dart';

/// Buscador reutilizable, mismo estilo en Sellos, Progreso y Cursos.
class CampoBusqueda extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final VoidCallback? onChanged;

  const CampoBusqueda({
    super.key,
    required this.controller,
    this.hint = "Buscar",
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: (_) => onChanged?.call(),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  controller.clear();
                  onChanged?.call();
                },
              ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}
