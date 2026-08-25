from fastapi import HTTPException
from app.core.supabase_client import get_supabase
from app.core.config import config

def obtener_activos():
    try:
        sb = get_supabase()
        
        # 1. Obtener cursos activos
        cursos_res = (
            sb.schema(config.supabase_schema)
            .table(config.supabase_curso)
            .select("*")
            .eq("estatus", "activo")
            .execute()
        )
        cursos = cursos_res.data
        if not cursos:
            return []

        ids_curso = [c["id_curso"] for c in cursos]

        # 2. Obtener categorías
        cat_res = (
            sb.schema(config.supabase_schema)
            .table(config.supabase_curso_categoria)
            .select("id_curso, id_categoria")
            .in_("id_curso", ids_curso)
            .execute()
        )
        
        ids_categoria = list({c["id_categoria"] for c in cat_res.data})
        nombres_cat = {}
        if ids_categoria:
            nom_res = (
                sb.schema(config.supabase_schema)
                .table("categoria")  # Asumiendo tabla "categoria"
                .select("id_categoria, nombre")
                .in_("id_categoria", ids_categoria)
                .execute()
            )
            nombres_cat = {c["id_categoria"]: c["nombre"] for c in nom_res.data}
            
        categorias_por_curso = {}
        for row in cat_res.data:
            c_id = row["id_curso"]
            cat_nombre = nombres_cat.get(row["id_categoria"], f"Cat {row['id_categoria']}")
            categorias_por_curso.setdefault(c_id, []).append(cat_nombre)

        # 3. Determinar qué otorga (Sello / Constancia)
        ids_sello = list({c["id_sello1"] for c in cursos if c.get("id_sello1")})
        constancias_por_sello = set()
        if ids_sello:
            otorga_res = (
                sb.schema(config.supabase_schema)
                .table(config.supabase_otorga)
                .select("id_sello2")
                .in_("id_sello2", ids_sello)
                .execute()
            )
            constancias_por_sello = {r["id_sello2"] for r in otorga_res.data}

        # Armar respuesta
        resultado = []
        for c in cursos:
            otorga_str = "Nada"
            id_s = c.get("id_sello1")
            if id_s:
                if id_s in constancias_por_sello:
                    otorga_str = "Sello y Constancia"
                else:
                    otorga_str = "Sello"
            
            cat_list = categorias_por_curso.get(c["id_curso"], [])
            cat_str = " • ".join(cat_list) if cat_list else "Sin categoría"
            
            resultado.append({
                "id_curso": c["id_curso"],
                "nombre": c.get("nombre", "Sin nombre"),
                "descripcion": c.get("descripcion", "Sin descripción disponible."),
                "duracion": c.get("duracion", 0),
                "estatus": c.get("estatus", "activo"),
                "fecha_lim": "2026-01-15", # Default según solicitud
                "categorias": cat_str,
                "otorga": otorga_str
            })
            
        return resultado
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al obtener cursos: {e}")

def detalle_curso(id_curso: int):
    try:
        sb = get_supabase()
        
        # 1. Obtener el curso
        curso_res = (
            sb.schema(config.supabase_schema)
            .table(config.supabase_curso)
            .select("*")
            .eq("id_curso", id_curso)
            .execute()
        )
        if not curso_res.data:
            raise HTTPException(status_code=404, detail="Curso no encontrado")
        c = curso_res.data[0]

        # 2. Categorias
        cat_res = (
            sb.schema(config.supabase_schema)
            .table(config.supabase_curso_categoria)
            .select("id_categoria")
            .eq("id_curso", id_curso)
            .execute()
        )
        ids_categoria = [row["id_categoria"] for row in cat_res.data]
        nombres_cat = []
        if ids_categoria:
            nom_res = (
                sb.schema(config.supabase_schema)
                .table("categoria")
                .select("nombre")
                .in_("id_categoria", ids_categoria)
                .execute()
            )
            nombres_cat = [row["nombre"] for row in nom_res.data]
        cat_str = " • ".join(nombres_cat) if nombres_cat else "Sin categoría"

        # 3. Otorga
        otorga_str = "Nada"
        id_s = c.get("id_sello1")
        if id_s:
            otorga_res = (
                sb.schema(config.supabase_schema)
                .table(config.supabase_otorga)
                .select("id_sello2")
                .eq("id_sello2", id_s)
                .execute()
            )
            if otorga_res.data:
                otorga_str = "Sello y Constancia"
            else:
                otorga_str = "Sello"

        # 4. Cursos requeridos (Microcursos donde id_curso_padre == id_curso)
        req_res = (
            sb.schema(config.supabase_schema)
            .table(config.supabase_curso)
            .select("id_curso, nombre")
            .eq("id_curso_padre", id_curso)
            .execute()
        )
        cursos_requeridos = req_res.data

        return {
            "id_curso": c["id_curso"],
            "nombre": c.get("nombre", "Sin nombre"),
            "descripcion": c.get("descripcion", "Sin descripción disponible."),
            "duracion": c.get("duracion", 0),
            "estatus": c.get("estatus", "activo"),
            "fecha_lim": "2026-01-15", # Default
            "categorias": cat_str,
            "otorga": otorga_str,
            "cursos_requeridos": cursos_requeridos
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al obtener detalle del curso: {e}")
