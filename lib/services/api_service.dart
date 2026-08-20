import 'dart:convert';

import 'package:http/http.dart' as http;

import 'auth_storage.dart';

class ApiService {
  // AJUSTA ESTO según dónde estés probando:
  // - Emulador Android: http://10.0.2.2:8000
  // - Celular físico en la misma WiFi: http://<IP-de-tu-PC>:8000
  // - iOS Simulator: http://localhost:8000
  static const String baseUrl = "http://192.168.100.73:8000";

  Future<Map<String, dynamic>> login(String correo, String contrasena) async {
    final respuesta = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"correo": correo, "contraseña": contrasena}),
    );

    final datos = jsonDecode(utf8.decode(respuesta.bodyBytes));

    if (respuesta.statusCode == 200) {
      await AuthStorage.guardarToken(datos["access_token"]);
      await AuthStorage.guardarUsuario(datos["usuario"]);
      return datos;
    } else {
      throw Exception(datos["detail"] ?? "Error al iniciar sesión");
    }
  }

  Future<Map<String, dynamic>> obtenerUsuario(int idUsuario) async {
    final token = await AuthStorage.obtenerToken();
    final respuesta = await http.get(
      Uri.parse("$baseUrl/usuarios/$idUsuario"),
      headers: {"Authorization": "Bearer $token"},
    );
    final datos = jsonDecode(utf8.decode(respuesta.bodyBytes));
    if (respuesta.statusCode == 200) {
      return datos["item"];
    } else {
      throw Exception(datos["detail"] ?? "Error al obtener usuario");
    }
  }

  Future<Map<String, dynamic>?> obtenerDocentePorUsuario(int idUsuario) async {
    final token = await AuthStorage.obtenerToken();
    final respuesta = await http.get(
      Uri.parse("$baseUrl/docentes/usuario/$idUsuario"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (respuesta.statusCode == 404) return null;
    final datos = jsonDecode(utf8.decode(respuesta.bodyBytes));
    if (respuesta.statusCode == 200) {
      return datos["item"];
    } else {
      throw Exception(datos["detail"] ?? "Error al obtener docente");
    }
  }

  // Ejemplo de cómo se verán las demás llamadas, ya con el token incluido
  Future<List<dynamic>> obtenerCursos() async {
    final token = await AuthStorage.obtenerToken();

    final respuesta = await http.get(
      Uri.parse("$baseUrl/cursos"),
      headers: {"Authorization": "Bearer $token"},
    );

    final datos = jsonDecode(utf8.decode(respuesta.bodyBytes));

    if (respuesta.statusCode == 200) {
      return datos["items"];
    } else {
      throw Exception(datos["detail"] ?? "Error al obtener cursos");
    }
  }
}
