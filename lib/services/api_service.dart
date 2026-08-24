import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'auth_storage.dart';

class ApiService {
  // AJUSTA ESTO según dónde estés probando:
  // - Emulador Android: http://10.0.2.2:8000
  // - Celular físico en la misma WiFi: http://<IP-de-tu-PC>:8000
  // - iOS Simulator: http://localhost:8000
  static const String baseUrl = "http://10.0.2.2:8000";

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

  Future<Map<String, dynamic>> obtenerEstadisticasDocente(int idDocente) async {
    final token = await AuthStorage.obtenerToken();
    final respuesta = await http.get(
      Uri.parse("$baseUrl/docentes/$idDocente/estadisticas"),
      headers: {"Authorization": "Bearer $token"},
    );
    final datos = jsonDecode(utf8.decode(respuesta.bodyBytes));
    if (respuesta.statusCode == 200) {
      return datos;
    } else {
      throw Exception(datos["detail"] ?? "Error al obtener estadísticas");
    }
  }

  Future<Map<String, dynamic>> obtenerResumenNotificaciones() async {
    final token = await AuthStorage.obtenerToken();
    final respuesta = await http.get(
      Uri.parse("$baseUrl/notificaciones/resumen"),
      headers: {"Authorization": "Bearer $token"},
    );
    return jsonDecode(utf8.decode(respuesta.bodyBytes));
  }

  Future<List<dynamic>> obtenerNotificaciones() async {
    final token = await AuthStorage.obtenerToken();
    final respuesta = await http.get(
      Uri.parse("$baseUrl/notificaciones"),
      headers: {"Authorization": "Bearer $token"},
    );
    final datos = jsonDecode(utf8.decode(respuesta.bodyBytes));
    return datos["items"];
  }

  Future<String> subirFotoPerfil(int idDocente, File imagen) async {
    final token = await AuthStorage.obtenerToken();
    final uri = Uri.parse("$baseUrl/docentes/$idDocente/foto");

    final request = http.MultipartRequest("POST", uri)
      ..headers["Authorization"] = "Bearer $token"
      ..files.add(await http.MultipartFile.fromPath("archivo", imagen.path));

    final streamedResponse = await request.send();
    final respuesta = await http.Response.fromStream(streamedResponse);
    final datos = jsonDecode(utf8.decode(respuesta.bodyBytes));

    if (respuesta.statusCode == 200) {
      return datos["foto_url"];
    } else {
      throw Exception(datos["detail"] ?? "Error al subir la foto");
    }
  }

  Future<void> marcarNotificacionLeida(
    String origen,
    int idNotificacion,
  ) async {
    final token = await AuthStorage.obtenerToken();
    await http.post(
      Uri.parse("$baseUrl/notificaciones/marcar-leida"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"origen": origen, "id_notificacion": idNotificacion}),
    );
  }

  Future<void> vaciarNotificaciones() async {
    final token = await AuthStorage.obtenerToken();
    await http.delete(
      Uri.parse("$baseUrl/notificaciones"),
      headers: {"Authorization": "Bearer $token"},
    );
  }

  Future<Map<String, dynamic>> obtenerMisSellos(int idDocente) async {
    final token = await AuthStorage.obtenerToken();
    final respuesta = await http.get(
      Uri.parse("$baseUrl/docentes/$idDocente/sellos"),
      headers: {"Authorization": "Bearer $token"},
    );
    final datos = jsonDecode(utf8.decode(respuesta.bodyBytes));
    if (respuesta.statusCode == 200) {
      return datos;
    } else {
      throw Exception(datos["detail"] ?? "Error al obtener sellos");
    }
  }

  Future<Map<String, dynamic>> obtenerDetalleSello(
    int idDocente,
    int idSello,
  ) async {
    final token = await AuthStorage.obtenerToken();
    final respuesta = await http.get(
      Uri.parse("$baseUrl/docentes/$idDocente/sellos/$idSello/detalle"),
      headers: {"Authorization": "Bearer $token"},
    );
    final datos = jsonDecode(utf8.decode(respuesta.bodyBytes));
    if (respuesta.statusCode == 200) {
      return datos;
    } else {
      throw Exception(
        datos["detail"] ?? "Error al obtener el detalle del sello",
      );
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
