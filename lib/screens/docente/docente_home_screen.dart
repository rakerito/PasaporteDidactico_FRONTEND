import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/auth_storage.dart';
import '../../services/api_service.dart';
import '../../widgets/fondo_app.dart';
import '../../widgets/menu_inferior.dart';
import '../login_screen.dart';

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
  bool _menuAbierto = false;
  String? _errorCarga;

  String _nombre = "";
  String _numeroUsuario = "";
  String _division = "";
  String? _fotoUrl;

  final int _sellosObtenidos = 8;
  final int _cursosCompletados = 20;
  final String _nivel = "Básico";

  // ===== Tamaño de la tarjeta: cámbialos aquí para agrandar/achicar todo junto =====
  static const double _cardWidth = 320;
  static const double _cardHeight = 670;
  static const double _cardTop = 135;

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
        child: LayoutBuilder(
          builder: (context, constraints) {
            // La tarjeta se centra sola según el ancho real de la pantalla
            final double anchoPantalla = constraints.maxWidth;
            final double cardLeft = (anchoPantalla - _cardWidth) / 2;
            final double cardBottom = _cardTop + _cardHeight;

            return SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // "No. pasaporte" — centrado en toda la pantalla, no en la tarjeta
                  const Positioned(
                    left: 0,
                    right: 0,
                    top: 55,
                    child: Text(
                      "No. pasaporte",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ColoresDocente.textoOscuro,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),

                  Positioned(
                    left: 0,
                    right: 0,
                    top: 80,
                    child: Text(
                      _numeroUsuario,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.doto(
                        color: ColoresDocente.textoOscuro,
                        fontWeight: FontWeight.w900,
                        fontSize: 27,
                      ),
                    ),
                  ),

                  // ===== Tarjeta blanca, centrada automáticamente =====
                  Positioned(
                    left: cardLeft,
                    top: _cardTop,
                    width: _cardWidth,
                    height: _cardHeight,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                    ),
                  ),

                  Positioned(
                    left: cardLeft,
                    top: _cardTop + 34,
                    width: _cardWidth,
                    child: const Text(
                      "PÁGINA DE \nIDENTIFICACIÓN",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ColoresDocente.textoOscuro,
                        fontWeight: FontWeight.w900,
                        fontSize: 23,
                      ),
                    ),
                  ),

                  Positioned(
                    left: cardLeft + 27,
                    top: _cardTop + 135,
                    width: 90,
                    height: 136,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: (_fotoUrl == null || _fotoUrl!.isEmpty)
                          ? Container(
                              color: Colors.grey.shade300,
                              child: const Icon(
                                Icons.person,
                                size: 60,
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
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                    ),
                  ),

                  Positioned(
                    left: cardLeft + 134,
                    top: _cardTop + 135,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Notificaciones",
                          style: TextStyle(
                            color: ColoresDocente.textoOscuro,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: ColoresDocente.botonClaro,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.notifications,
                                size: 19,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.keyboard_arrow_down,
                                size: 19,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    left: cardLeft + 27,
                    top: _cardTop + 300,
                    child: const Text(
                      "Nombre",
                      style: TextStyle(
                        color: ColoresDocente.textoOscuro,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Positioned(
                    left: cardLeft + 27,
                    top: _cardTop + 326,
                    width: 282,
                    child: Text(
                      _nombre,
                      style: const TextStyle(
                        color: ColoresDocente.textoAzul,
                        fontSize: 20,
                      ),
                    ),
                  ),

                  Positioned(
                    left: cardLeft + 27,
                    top: _cardTop + 367,
                    child: const Text(
                      "División",
                      style: TextStyle(
                        color: ColoresDocente.textoOscuro,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Positioned(
                    left: cardLeft + 27,
                    top: _cardTop + 393,
                    width: 282,
                    child: Text(
                      _division,
                      style: const TextStyle(
                        color: ColoresDocente.textoAzul,
                        fontSize: 17,
                      ),
                    ),
                  ),

                  Positioned(
                    left: cardLeft + 34,
                    top: _cardTop + 444,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.emoji_events,
                              color: Color.from(
                                alpha: 1,
                                red: 0.122,
                                green: 0.616,
                                blue: 0.427,
                              ),
                              size: 28,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              "Sellos\nobtenidos",
                              style: TextStyle(
                                color: ColoresDocente.textoOscuro,
                                fontSize: 14,
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
                            fontSize: 28,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    left: cardLeft + 175,
                    top: _cardTop + 443,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.menu_book,
                              color: Color.from(
                                alpha: 1,
                                red: 0.122,
                                green: 0.616,
                                blue: 0.427,
                              ),
                              size: 28,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              "Cursos\ncompletados",
                              style: TextStyle(
                                color: ColoresDocente.textoOscuro,
                                fontSize: 14,
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
                            fontSize: 28,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    left: cardLeft + 34,
                    top: _cardTop + 556,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: ColoresDocente.verdeAcento,
                              size: 26,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              "Nivel",
                              style: TextStyle(
                                color: ColoresDocente.textoOscuro,
                                fontSize: 16,
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
                            fontSize: 21,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    left: cardLeft + 177,
                    top: _cardTop + 540,
                    width: 108,
                    child: Image.asset(
                      "assets/sello_soy_ut.png",
                      errorBuilder: (_, __, ___) => const SizedBox(),
                    ),
                  ),

                  // "Página 1" — debajo de la tarjeta, centrado en la pantalla completa
                  Positioned(
                    left: 0,
                    right: 0,
                    top: cardBottom + 35,
                    child: const Text(
                      "Página 1",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ColoresDocente.textoOscuro,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),

                  // Botón circular que abre/cierra el menú inferior
                  Positioned(
                    left: cardLeft + _cardWidth - 40,
                    top: cardBottom + 25,
                    child: InkWell(
                      onTap: () => setState(() => _menuAbierto = !_menuAbierto),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: ColoresDocente.textoOscuro,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.menu,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),

                  // Botón cerrar sesión, debajo de "Página 1"
                  Positioned(
                    left: -150,
                    right: 0,
                    top: cardBottom - 50,
                    child: Center(
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
                  ),

                  // Menú inferior (aparece solo si _menuAbierto es true)
                  if (_menuAbierto)
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 24,
                      child: MenuInferior(
                        pantallaActiva: "Inicio",
                        onCerrar: () => setState(() => _menuAbierto = false),
                        onSeleccionar: (pantalla) {
                          setState(() => _menuAbierto = false);
                          // TODO: navegar a la pantalla correspondiente cuando existan
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
