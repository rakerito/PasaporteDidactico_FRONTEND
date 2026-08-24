import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../theme/app_colors.dart';
import 'admin/admin_home_screen.dart';
import 'docente/docente_shell.dart';
import 'welcome_screen.dart';

/// Mismas medidas del lienzo de Canva que usamos en splash_screen.dart —
/// no las cambies, son la referencia para que las coordenadas x/y coincidan.
const double _anchoDiseno = 310.5;
const double _altoDiseno = 672;

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

      final nombre =
          "${resultado["usuario"]["nombre"]} ${resultado["usuario"]["apellidos"]}";

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => WelcomeScreen(
            nombre: nombre,
            siguiente: categoria == "admin"
                ? const AdminHomeScreen()
                : const DocenteShell(),
          ),
        ),
        (route) => false,
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

  InputDecoration _decoracionCampo(String texto) {
    return InputDecoration(
      hintText: texto,
      filled: true,
      fillColor: AppColors.campoTexto,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.fondo,
        width: double.infinity,
        height: double.infinity,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _anchoDiseno,
            height: _altoDiseno,
            child: Stack(
              children: [
                // Fondo de textura, cubre todo el lienzo
                Positioned(
                  left: 0,
                  top: 0,
                  width: _anchoDiseno,
                  height: _altoDiseno,
                  child: Image.asset(
                    "assets/fondo_textura.png",
                    fit: BoxFit.cover,
                  ),
                ),

                // ===== AJUSTA estos left/top con los valores REALES de Canva =====

                // Logo UT San Juan del Río
                Positioned(
                  left: 33,
                  top: 38,
                  child: Image.asset("assets/logo_ut.png", width: 245),
                ),

                // Título "PASAPORTE"
                const Positioned(
                  left: 0,
                  top: 130,
                  width: _anchoDiseno,
                  child: Text(
                    "PASAPORTE",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textoClaro,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),

                // Subtítulo "DIDÁCTICO"
                const Positioned(
                  left: 0,
                  top: 175,
                  width: _anchoDiseno,
                  child: Text(
                    "DIDÁCTICO",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textoClaro,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 6,
                    ),
                  ),
                ),

                // "Bienvenido (a)"
                const Positioned(
                  left: 31,
                  top: 254,
                  child: Text(
                    "Bienvenido (a)",
                    style: TextStyle(
                      color: AppColors.textoClaro,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Campo Email
                Positioned(
                  left: 31,
                  top: 293,
                  width: 247,
                  child: TextField(
                    controller: _correoController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _decoracionCampo("Email"),
                  ),
                ),

                // Campo Contraseña
                Positioned(
                  left: 31,
                  top: 355,
                  width: 247,
                  child: TextField(
                    controller: _contrasenaController,
                    obscureText: true,
                    decoration: _decoracionCampo("Contraseña"),
                  ),
                ),

                // Mensaje de error (vacío si no hay)
                if (_error != null)
                  Positioned(
                    left: 0,
                    top: 405,
                    width: _anchoDiseno,
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 11,
                      ),
                    ),
                  ),

                // Botón Iniciar sesión
                Positioned(
                  left: 31,
                  top: 430,
                  width: 247,
                  child: ElevatedButton(
                    onPressed: _cargando ? null : _iniciarSesion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.boton,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _cargando
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Iniciar sesión",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ),

                // "¿Olvidaste tu contraseña?"
                Positioned(
                  left: 0,
                  top: 535,
                  width: _anchoDiseno,
                  child: TextButton(
                    onPressed: () {
                      // TODO: pantalla de recuperar contraseña
                    },
                    child: Text(
                      "¿Olvidaste tu contraseña?",
                      style: TextStyle(
                        color: AppColors.textoClaro,
                        decoration: TextDecoration.underline,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),

                // Footer con versión
                Positioned(
                  left: 0,
                  top: 605,
                  width: _anchoDiseno,
                  child: Text(
                    "PASAPORTE DIDÁCTICO V1.0.0 | 2026 UTSJR",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textoClaro.withValues(alpha: 0.7),
                      fontSize: 10,
                    ),
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
