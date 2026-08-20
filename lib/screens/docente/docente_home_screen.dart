import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/auth_storage.dart';
import '../../services/api_service.dart';
import '../../widgets/fondo_app.dart';
import '../login_screen.dart';

const double _anchoDiseno = 310.5;
const double _altoDiseno = 672;

class ColoresDocente {
  static const Color textoOscuro = Color(0xFF151B3D);
  static const Color textoAzul = Color(0xFF3D6B9E);
  static const Color verdeAcento = Color(0xFF1F9D6D);
  static const Color botonClaro = Color(0xFF80A0CF);
}

class DocenteHomeScreen extends StatefulWidget {
  const DocenteHomeScreen({super.key});

  @override
  State<DocenteHomeScreen> createState() => _DocenteHomeScreenState();
}

class _DocenteHomeScreenState extends State<DocenteHomeScreen> {
  final _apiService = ApiService();

  bool _cargando = true;
  String? _errorCarga;

  String _nombre = "";
  String _numeroUsuario = "";
  String _division = "";
  String? _fotoUrl;

  final int _sellosObtenidos = 8;
  final int _cursosCompletados = 20;
  final String _nivel = "Básico";

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final usuarioGuardado = await AuthStorage.obtenerUsuario();
      final idUsuario = usuarioGuardado?["id_usuario"];

      if (idUsuario == null) {
        throw Exception(
          "No se encontró la sesión guardada. Inicia sesión de nuevo.",
        );
      }

      final usuario = await _apiService.obtenerUsuario(idUsuario);
      final docente = await _apiService.obtenerDocentePorUsuario(idUsuario);

      setState(() {
        _nombre = "${usuario["nombre"]} ${usuario["apellidos"]}";
        _numeroUsuario = usuario["numero_usuario"] ?? "Sin número asignado";
        _division =
            docente?["division"] ??
            "Sin división asignada (no tiene perfil de docente)";
        _fotoUrl = docente?["foto_url"];
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _errorCarga = e.toString().replaceFirst("Exception: ", "");
        _cargando = false;
      });
    }
  }

  Future<void> _cerrarSesion() async {
    await AuthStorage.cerrarSesion();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorCarga != null) {
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
                Text(_errorCarga!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() => _cargando = true);
                    _cargarDatos();
                  },
                  child: const Text("Reintentar"),
                ),
                TextButton(
                  onPressed: _cerrarSesion,
                  child: const Text("Cerrar sesión"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: FondoApp(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _anchoDiseno,
            height: _altoDiseno,
            child: Stack(
              children: [
                // "No. pasaporte" (etiqueta)
                const Positioned(
                  left: 0,
                  top: 25,
                  width: _anchoDiseno,
                  child: Text(
                    "No. pasaporte",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ColoresDocente.textoOscuro,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),

                // Número de usuario, con fuente de puntos (equivalente a Dotty)
                Positioned(
                  left: 0,
                  top: 50,
                  width: _anchoDiseno,
                  child: Text(
                    _numeroUsuario,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.doto(
                      color: ColoresDocente.textoOscuro,
                      fontWeight: FontWeight.w900,
                      fontSize: 30,
                    ),
                  ),
                ),

                // Tarjeta blanca con borde
                Positioned(
                  left: 20,
                  top: 105,
                  width: 270,
                  height: 510,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                  ),
                ),

                const Positioned(
                  left: 40,
                  top: 125,
                  width: 230,
                  child: Text(
                    "PÁGINA DE IDENTIFICACIÓN",
                    style: TextStyle(
                      color: ColoresDocente.textoOscuro,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                ),

                // Foto de perfil (real si existe, si no un ícono placeholder)
                Positioned(
                  left: 40,
                  top: 195,
                  width: 90,
                  height: 100,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: (_fotoUrl == null || _fotoUrl!.isEmpty)
                        ? Container(
                            color: Colors.grey.shade300,
                            child: const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            ),
                          )
                        : Image.network(
                            _fotoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey.shade300,
                              child: const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ),
                ),

                Positioned(
                  left: 160,
                  top: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Notificaciones",
                        style: TextStyle(
                          color: ColoresDocente.textoOscuro,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: ColoresDocente.botonClaro,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.notifications,
                              size: 16,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down,
                              size: 16,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Positioned(
                  left: 40,
                  top: 310,
                  child: Text(
                    "Nombre",
                    style: TextStyle(
                      color: ColoresDocente.textoOscuro,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                Positioned(
                  left: 40,
                  top: 330,
                  width: 230,
                  child: Text(
                    _nombre,
                    style: const TextStyle(
                      color: ColoresDocente.textoAzul,
                      fontSize: 16,
                    ),
                  ),
                ),

                const Positioned(
                  left: 40,
                  top: 375,
                  child: Text(
                    "División",
                    style: TextStyle(
                      color: ColoresDocente.textoOscuro,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                Positioned(
                  left: 40,
                  top: 395,
                  width: 230,
                  child: Text(
                    _division,
                    style: const TextStyle(
                      color: ColoresDocente.textoAzul,
                      fontSize: 14,
                    ),
                  ),
                ),

                Positioned(
                  left: 40,
                  top: 465,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.emoji_events,
                            color: ColoresDocente.verdeAcento,
                            size: 22,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            "Sellos\nobtenidos",
                            style: TextStyle(
                              color: ColoresDocente.textoOscuro,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$_sellosObtenidos",
                        style: const TextStyle(
                          color: ColoresDocente.textoOscuro,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                ),

                Positioned(
                  left: 175,
                  top: 465,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.menu_book,
                            color: ColoresDocente.textoOscuro,
                            size: 22,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            "Cursos\ncompletados",
                            style: TextStyle(
                              color: ColoresDocente.textoOscuro,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$_cursosCompletados",
                        style: const TextStyle(
                          color: ColoresDocente.textoOscuro,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                ),

                Positioned(
                  left: 40,
                  top: 550,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: ColoresDocente.verdeAcento,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            "Nivel",
                            style: TextStyle(
                              color: ColoresDocente.textoOscuro,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _nivel,
                        style: const TextStyle(
                          color: ColoresDocente.textoOscuro,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                Positioned(
                  left: 185,
                  top: 530,
                  width: 90,
                  child: Image.asset(
                    "assets/sello_soy_ut.png",
                    errorBuilder: (_, __, ___) => const SizedBox(),
                  ),
                ),

                Positioned(
                  left: 20,
                  top: 630,
                  child: TextButton.icon(
                    onPressed: _cerrarSesion,
                    icon: const Icon(
                      Icons.logout,
                      size: 18,
                      color: ColoresDocente.textoOscuro,
                    ),
                    label: const Text(
                      "Cerrar sesión",
                      style: TextStyle(color: ColoresDocente.textoOscuro),
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
