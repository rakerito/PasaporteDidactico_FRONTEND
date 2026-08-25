import 'package:flutter/material.dart';

import '../../services/auth_storage.dart';
import '../../widgets/fondo_app.dart';
import '../login_screen.dart';

class ColoresConfig {
  static const Color textoOscuro = Color(0xFF151B3D);
  static const Color verdeAcento = Color(0xFFB5CC3A);
}

class ConfiguracionDocenteScreen extends StatefulWidget {
  const ConfiguracionDocenteScreen({super.key});

  @override
  State<ConfiguracionDocenteScreen> createState() =>
      _ConfiguracionDocenteScreenState();
}

class _ConfiguracionDocenteScreenState
    extends State<ConfiguracionDocenteScreen> {
  // TODO: estos 2 valores no se guardan todavía — falta la funcionalidad real
  // del lado del admin/backend antes de que esto persista de verdad.
  bool _notificacionesPush = true;
  bool _alertasCorreo = true;

  Future<void> _cerrarSesion() async {
    await AuthStorage.cerrarSesion();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _mostrarProximamente() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Esta función estará disponible próximamente."),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FondoApp(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            children: [
              const SizedBox(height: 24),
              const Text(
                "CONFIGURACIÓN",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ColoresConfig.textoOscuro,
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _FilaConfiguracion(
                        titulo: "Notificaciones push",
                        subtitulo: "Alertas en tiempo real",
                        trailing: Switch(
                          value: _notificacionesPush,
                          activeColor: ColoresConfig.verdeAcento,
                          activeTrackColor: ColoresConfig.textoOscuro,
                          onChanged: (v) {
                            setState(() => _notificacionesPush = v);
                            _mostrarProximamente();
                          },
                        ),
                      ),
                      const Divider(height: 1, indent: 20, endIndent: 20),
                      _FilaConfiguracion(
                        titulo: "Alertas por correo",
                        subtitulo: "Resumen diario de actividad",
                        trailing: Switch(
                          value: _alertasCorreo,
                          activeColor: ColoresConfig.verdeAcento,
                          activeTrackColor: ColoresConfig.textoOscuro,
                          onChanged: (v) {
                            setState(() => _alertasCorreo = v);
                            _mostrarProximamente();
                          },
                        ),
                      ),
                      const Divider(height: 1, indent: 20, endIndent: 20),
                      _FilaConfiguracion(
                        titulo: "Cambiar contraseña",
                        subtitulo: "Última modificación: Ene 2026",
                        trailing: InkWell(
                          onTap: _mostrarProximamente,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: ColoresConfig.textoOscuro,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: _cerrarSesion,
                icon: const Icon(
                  Icons.logout,
                  size: 18,
                  color: ColoresConfig.textoOscuro,
                ),
                label: const Text(
                  "Cerrar sesión",
                  style: TextStyle(color: ColoresConfig.textoOscuro),
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                "Página 5",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ColoresConfig.textoOscuro,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilaConfiguracion extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final Widget trailing;

  const _FilaConfiguracion({
    required this.titulo,
    required this.subtitulo,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: ColoresConfig.textoOscuro,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitulo,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
