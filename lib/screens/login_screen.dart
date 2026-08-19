import 'package:flutter/material.dart';

import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _apiService = ApiService();

  bool _cargando = false;
  String? _error;

  Future<void> _iniciarSesion() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final resultado = await _apiService.login(
        _correoController.text.trim(),
        _contrasenaController.text,
      );

      if (!mounted) return;

      final categoria = (resultado["usuario"]["categoria"] ?? "")
          .toString()
          .toLowerCase();

      // Aquí, más adelante, navegas a la pantalla correspondiente
      // según el rol (admin_home_screen vs docente_home_screen).
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bienvenido, sesión iniciada como $categoria")),
      );
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst("Exception: ", "");
      });
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Pasaporte Didáctico",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              TextField(
                controller: _correoController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Correo institucional",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _contrasenaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Contraseña",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),

              ElevatedButton(
                onPressed: _cargando ? null : _iniciarSesion,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: _cargando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Iniciar sesión"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
