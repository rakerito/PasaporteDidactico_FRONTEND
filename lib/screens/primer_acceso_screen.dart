import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../theme/app_colors.dart';

class PrimerAccesoScreen extends StatefulWidget {
  final String? correoInicial;
  const PrimerAccesoScreen({super.key, this.correoInicial});

  @override
  State<PrimerAccesoScreen> createState() => _PrimerAccesoScreenState();
}

class _PrimerAccesoScreenState extends State<PrimerAccesoScreen> {
  final _apiService = ApiService();
  late final TextEditingController _correoCtrl;
  final _noEmpleadoCtrl = TextEditingController();
  final _contrasenaCtrl = TextEditingController();
  final _confirmarCtrl = TextEditingController();

  bool _cargando = false;
  String? _error;
  bool _exito = false;

  @override
  void initState() {
    super.initState();
    _correoCtrl = TextEditingController(text: widget.correoInicial ?? "");
  }

  Future<void> _crearContrasena() async {
    if (_contrasenaCtrl.text != _confirmarCtrl.text) {
      setState(() => _error = "Las contraseñas no coinciden.");
      return;
    }
    if (_contrasenaCtrl.text.length < 6) {
      setState(
        () => _error = "La contraseña debe tener al menos 6 caracteres.",
      );
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      await _apiService.primerAcceso(
        _correoCtrl.text.trim(),
        _noEmpleadoCtrl.text.trim(),
        _contrasenaCtrl.text,
      );
      if (!mounted) return;
      setState(() => _exito = true);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst("Exception: ", ""));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: _exito
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.greenAccent,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "¡Contraseña creada!\nYa puedes iniciar sesión.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Ir a iniciar sesión"),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Primer acceso",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Ingresa tu correo y número de empleado para crear tu contraseña.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _correoCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Correo",
                      labelStyle: TextStyle(color: Colors.white70),
                    ),
                  ),
                  TextField(
                    controller: _noEmpleadoCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Número de empleado",
                      labelStyle: TextStyle(color: Colors.white70),
                    ),
                  ),
                  TextField(
                    controller: _contrasenaCtrl,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Nueva contraseña",
                      labelStyle: TextStyle(color: Colors.white70),
                    ),
                  ),
                  TextField(
                    controller: _confirmarCtrl,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Confirmar contraseña",
                      labelStyle: TextStyle(color: Colors.white70),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _cargando ? null : _crearContrasena,
                      child: _cargando
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text("Crear contraseña"),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
