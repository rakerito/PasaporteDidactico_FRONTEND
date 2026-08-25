import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:io';

import '../../services/auth_storage.dart';
import '../../services/api_service.dart';
import '../../services/cache_app.dart';
import '../../widgets/fondo_app.dart';
import '../../widgets/boton_notificaciones.dart';
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
  String? _errorCarga;

  String _nombre = "";
  String _numeroUsuario = "";
  String _division = "";
  String? _fotoUrl;
  int? _idDocente;

  int _logrosObtenidos = 0;
  int _cursosCompletados = 0;
  String _nivel = "Básico";

  static const double _cardWidth = 320;
  static const double _cardHeight = 670;
  static const double _cardTop = 135;

  @override
  void initState() {
    super.initState();
    if (CacheApp.docenteHome != null) {
      _aplicarDatos(CacheApp.docenteHome!);
      _cargando = false;
    } else {
      _cargarDatos();
    }
  }

  void _aplicarDatos(Map<String, dynamic> d) {
    _nombre = d["nombre"];
    _numeroUsuario = d["numeroUsuario"];
    _division = d["division"];
    _fotoUrl = d["fotoUrl"];
    _idDocente = d["idDocente"];
    _logrosObtenidos = d["logrosObtenidos"];
    _cursosCompletados = d["cursosCompletados"];
    _nivel = d["nivel"];
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

      // Pedimos usuario y docente AL MISMO TIEMPO, no uno tras otro
      final resultados = await Future.wait([
        _apiService.obtenerUsuario(idUsuario),
        _apiService.obtenerDocentePorUsuario(idUsuario),
      ]);
      final usuario = resultados[0] as Map<String, dynamic>;
      final docente = resultados[1] as Map<String, dynamic>?;

      Map<String, dynamic>? estadisticas;
      if (docente != null && docente["id_docente"] != null) {
        // Esta sí depende del resultado anterior (necesita el id_docente), no se puede paralelizar
        estadisticas = await _apiService.obtenerEstadisticasDocente(
          docente["id_docente"],
        );
      }

      final datosNuevos = {
        "nombre": "${usuario["nombre"]} ${usuario["apellidos"]}",
        "numeroUsuario": usuario["numero_usuario"] ?? "Sin número asignado",
        "division":
            docente?["division"] ??
            "Sin división asignada (no tiene perfil de docente)",
        "fotoUrl": docente?["foto_url"],
        "idDocente": docente?["id_docente"],
        "logrosObtenidos": estadisticas?["logros_obtenidos"] ?? 0,
        "cursosCompletados": estadisticas?["cursos_completados"] ?? 0,
        "nivel": estadisticas?["nivel"] ?? "Básico",
      };
      CacheApp.docenteHome = datosNuevos;

      if (!mounted) return;
      setState(() {
        _aplicarDatos(datosNuevos);
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorCarga = e.toString().replaceFirst("Exception: ", "");
        _cargando = false;
      });
    }
  }

  Future<void> _cambiarFoto() async {
    if (_idDocente == null) return;

    final picker = ImagePicker();
    final imagenSeleccionada = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (imagenSeleccionada == null) return;

    try {
      final nuevaUrl = await _apiService.subirFotoPerfil(
        _idDocente!,
        File(imagenSeleccionada.path),
      );
      if (CacheApp.docenteHome != null) {
        CacheApp.docenteHome!["fotoUrl"] = nuevaUrl;
      }
      setState(() => _fotoUrl = nuevaUrl);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("No se pudo subir la foto: $e")));
      }
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

    return FondoApp(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double anchoPantalla = constraints.maxWidth;
          final double cardLeft = (anchoPantalla - _cardWidth) / 2;
          final double cardBottom = _cardTop + _cardHeight;
          // Alto real necesario para que TODO quepa (tarjeta + "Página 1" + margen).
          // Si la pantalla es más chica que esto, se podrá hacer scroll
          // en vez de que "Página 1" quede cortado sin que lo veas.
          final double altoNecesario = cardBottom + 80;
          final double altoFinal = altoNecesario > constraints.maxHeight
              ? altoNecesario
              : constraints.maxHeight;

          return SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              height: altoFinal,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
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
                    child: GestureDetector(
                      onTap: _cambiarFoto,
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 90,
                              height: 136,
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
                            right: 4,
                            bottom: 4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: ColoresDocente.textoOscuro,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
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
                        const BotonNotificaciones(),
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
                              color: ColoresDocente.verdeAcento,
                              size: 28,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              "Logros\nobtenidos",
                              style: TextStyle(
                                color: ColoresDocente.textoOscuro,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "$_logrosObtenidos",
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
                              color: ColoresDocente.verdeAcento,
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
