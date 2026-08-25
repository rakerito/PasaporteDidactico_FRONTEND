/// Guarda en memoria los datos ya cargados de cada pantalla del docente,
/// para que no se vuelvan a pedir al backend cada vez que regresas a ellas
/// (independiente de cómo el paquete de animación maneje sus páginas por dentro).
/// Se vacía al cerrar sesión.
class CacheApp {
  static Map<String, dynamic>? docenteHome;
  static Map<String, dynamic>? sellos;
  static Map<String, dynamic>? progreso;
  static List<dynamic>? cursos;

  static void limpiar() {
    docenteHome = null;
    sellos = null;
    progreso = null;
    cursos = null;
  }
}
