import 'package:flutter/material.dart';

import '../../services/auth_storage.dart';
import '../login_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  Future<void> _cerrarSesion(BuildContext context) async {
    await AuthStorage.cerrarSesion();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Panel de Administrador"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _cerrarSesion(context),
          ),
        ],
      ),
      body: const Center(
        child: Text(
          "Aquí van las estadísticas y el menú de administrador",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
