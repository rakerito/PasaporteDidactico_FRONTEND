import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  static const _storage = FlutterSecureStorage();

  static Future<void> guardarToken(String token) async {
    await _storage.write(key: "token", value: token);
  }

  static Future<String?> obtenerToken() async {
    return await _storage.read(key: "token");
  }

  static Future<void> guardarUsuario(Map<String, dynamic> usuario) async {
    await _storage.write(key: "usuario", value: jsonEncode(usuario));
  }

  static Future<Map<String, dynamic>?> obtenerUsuario() async {
    final data = await _storage.read(key: "usuario");
    if (data == null) return null;
    return jsonDecode(data);
  }

  static Future<void> cerrarSesion() async {
    await _storage.deleteAll();
  }
}
