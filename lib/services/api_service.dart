import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'auth_storage.dart';

class ApiService {
  // AJUSTA ESTO según dónde estés probando:
  // - Emulador Android: http://10.0.2.2:8000
  // - Celular físico en la misma WiFi: http://<IP-de-tu-PC>:8000
  // - iOS Simulator: http://localhost:8000
  //static const String baseUrl = "http://192.168.1.71:8000";
  static const String baseUrl = "http://127.0.0.1:8000";

  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthStorage.obtenerToken();
    return {"Authorization": "Bearer $token"};
  }

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

  Future<Map<String, dynamic>> obtenerProgreso(int idDocente) async {
    final token = await AuthStorage.obtenerToken();
    final respuesta = await http.get(
      Uri.parse("$baseUrl/docentes/$idDocente/progreso"),
      headers: {"Authorization": "Bearer $token"},
    );
    final datos = jsonDecode(utf8.decode(respuesta.bodyBytes));
    if (respuesta.statusCode == 200) {
      return datos;
    } else {
      throw Exception(datos["detail"] ?? "Error al obtener el progreso");
    }
  }

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

  // ---------------------------------------------------------
  // ENDPOINTS DE CURSOS
  // ---------------------------------------------------------

  /// Obtiene la lista de cursos con estatus activo
  Future<List<dynamic>> obtenerCursosActivos() async {
    final response = await http.get(
      Uri.parse('$baseUrl/cursos/activos'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      return List<dynamic>.from(decoded);
    } else {
      throw Exception('Error al cargar cursos activos: ${response.body}');
    }
  }

  /// Obtiene los detalles de un curso en específico (incluyendo requeridos)
  Future<Map<String, dynamic>> obtenerDetalleCurso(int idCurso) async {
    final response = await http.get(
      Uri.parse('$baseUrl/cursos/$idCurso/detalle'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Error al cargar detalle del curso: ${response.body}');
    }
  }

  // --------------------------------------------------------------------
  // ENDPOINTS ADMIN
  // --------------------------------------------------------------------

  Future<void> primerAcceso(
    String correo,
    String noEmpleado,
    String nuevaContrasena,
  ) async {
    final respuesta = await http.post(
      Uri.parse("$baseUrl/auth/primer-acceso"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "correo": correo,
        "no_empleado": noEmpleado,
        "nueva_contrasena": nuevaContrasena,
      }),
    );
    if (respuesta.statusCode != 200) {
      final error = jsonDecode(utf8.decode(respuesta.bodyBytes));
      throw Exception(error["detail"] ?? "Error al crear tu contraseña");
    }
  }

  Future<Map<String, dynamic>> obtenerReporteMensual() async {
    final token = await AuthStorage.obtenerToken();
    final respuesta = await http.get(
      Uri.parse("$baseUrl/admin/reporte-mensual"),
      headers: {"Authorization": "Bearer $token"},
    );
    final datos = jsonDecode(utf8.decode(respuesta.bodyBytes));
    if (respuesta.statusCode == 200) {
      return datos;
    } else {
      throw Exception(datos["detail"] ?? "Error al obtener el reporte mensual");
    }
  }

  Future<List<dynamic>> obtenerUsuariosAdmin() async {
    final token = await AuthStorage.obtenerToken();
    final respuesta = await http.get(
      Uri.parse("$baseUrl/admin/usuarios"),
      headers: {"Authorization": "Bearer $token"},
    );
    final datos = jsonDecode(utf8.decode(respuesta.bodyBytes));
    if (respuesta.statusCode == 200) {
      return datos["items"];
    } else {
      throw Exception(datos["detail"] ?? "Error al obtener usuarios");
    }
  }

  Future<void> crearUsuario(Map<String, dynamic> datos) async {
    final token = await AuthStorage.obtenerToken();
    final respuesta = await http.post(
      Uri.parse("$baseUrl/admin/usuarios"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(datos),
    );
    if (respuesta.statusCode != 200) {
      final error = jsonDecode(utf8.decode(respuesta.bodyBytes));
      throw Exception(error["detail"] ?? "Error al crear el usuario");
    }
  }

  Future<void> actualizarUsuarioAdmin(
    int idUsuario,
    Map<String, dynamic> datos,
  ) async {
    final token = await AuthStorage.obtenerToken();
    final respuesta = await http.put(
      Uri.parse("$baseUrl/usuarios/$idUsuario"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(datos),
    );
    if (respuesta.statusCode != 200) {
      final error = jsonDecode(utf8.decode(respuesta.bodyBytes));
      throw Exception(error["detail"] ?? "Error al actualizar el usuario");
    }
  }

  Future<void> actualizarDocenteAdmin(
    int idDocente,
    Map<String, dynamic> datos,
  ) async {
    final token = await AuthStorage.obtenerToken();
    final respuesta = await http.put(
      Uri.parse("$baseUrl/docentes/$idDocente"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(datos),
    );
    if (respuesta.statusCode != 200) {
      final error = jsonDecode(utf8.decode(respuesta.bodyBytes));
      throw Exception(error["detail"] ?? "Error al actualizar la división");
    }
  }

  Future<void> eliminarUsuarioAdmin(int idUsuario) async {
    final token = await AuthStorage.obtenerToken();
    final respuesta = await http.delete(
      Uri.parse("$baseUrl/admin/usuarios/$idUsuario"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (respuesta.statusCode != 200) {
      final error = jsonDecode(utf8.decode(respuesta.bodyBytes));
      throw Exception(error["detail"] ?? "Error al eliminar el usuario");
    }
  }

  Future<void> actualizarUsuarioCompleto(
    int idUsuario,
    Map<String, dynamic> datos,
  ) async {
    final token = await AuthStorage.obtenerToken();
    final respuesta = await http.put(
      Uri.parse("$baseUrl/admin/usuarios/$idUsuario"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(datos),
    );
    if (respuesta.statusCode != 200) {
      final error = jsonDecode(utf8.decode(respuesta.bodyBytes));
      throw Exception(error["detail"] ?? "Error al actualizar el usuario");
    }
  }

  Future<List<dynamic>> obtenerCursosAdmin() async {
    final token = await AuthStorage.obtenerToken();
    final respuesta = await http.get(
      Uri.parse("$baseUrl/admin/cursos"),
      headers: {"Authorization": "Bearer $token"},
    );
    final datos = jsonDecode(utf8.decode(respuesta.bodyBytes));
    if (respuesta.statusCode == 200) {
      return List<dynamic>.from(datos);
    } else {
      throw Exception(datos["detail"] ?? "Error al obtener cursos");
    }
  }

  Future<void> crearCursoAdmin(Map<String, dynamic> datos) async {
    final token = await AuthStorage.obtenerToken();
    final respuesta = await http.post(
      Uri.parse("$baseUrl/admin/cursos"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(datos),
    );
    if (respuesta.statusCode != 200) {
      final error = jsonDecode(utf8.decode(respuesta.bodyBytes));
      throw Exception(error["detail"] ?? "Error al crear el curso");
    }
  }

  Future<void> actualizarCursoAdmin(
    int idCurso,
    Map<String, dynamic> datos,
  ) async {
    final token = await AuthStorage.obtenerToken();
    final respuesta = await http.put(
      Uri.parse("$baseUrl/admin/cursos/$idCurso"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(datos),
    );
    if (respuesta.statusCode != 200) {
      final error = jsonDecode(utf8.decode(respuesta.bodyBytes));
      throw Exception(error["detail"] ?? "Error al actualizar el curso");
    }
  }

  Future<void> eliminarCursoAdmin(int idCurso) async {
    final token = await AuthStorage.obtenerToken();
    final respuesta = await http.delete(
      Uri.parse("$baseUrl/admin/cursos/$idCurso"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (respuesta.statusCode != 200) {
      final error = jsonDecode(utf8.decode(respuesta.bodyBytes));
      throw Exception(error["detail"] ?? "Error al eliminar el curso");
    }
  }

  // Catálogos usados en el formulario de curso
  Future<List<dynamic>> obtenerCatalogoSellos() async {
    final token = await AuthStorage.obtenerToken();
    final respuesta = await http.get(
      Uri.parse("$baseUrl/sellos"),
      headers: {"Authorization": "Bearer $token"},
    );
    final datos = jsonDecode(utf8.decode(respuesta.bodyBytes));
    if (respuesta.statusCode == 200) {
      return datos["items"];
    } else {
      throw Exception(datos["detail"] ?? "Error al obtener sellos");
    }
  }

  Future<List<dynamic>> obtenerCatalogoCategorias() async {
    final token = await AuthStorage.obtenerToken();
    final respuesta = await http.get(
      Uri.parse("$baseUrl/categorias"),
      headers: {"Authorization": "Bearer $token"},
    );
    final datos = jsonDecode(utf8.decode(respuesta.bodyBytes));
    if (respuesta.statusCode == 200) {
      return datos["items"];
    } else {
      throw Exception(datos["detail"] ?? "Error al obtener categorías");
    }
  }

  Future<Map<String, dynamic>> crearCategoria(String nombre) async {
    final token = await AuthStorage.obtenerToken();
    final respuesta = await http.post(
      Uri.parse("$baseUrl/categorias"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"nombre": nombre}),
    );
    final datos = jsonDecode(utf8.decode(respuesta.bodyBytes));
    if (respuesta.statusCode == 200) {
      return datos;
    } else {
      throw Exception(datos["detail"] ?? "Error al crear la categoría");
    }
  }
}
