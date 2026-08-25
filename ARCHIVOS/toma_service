from fastapi import HTTPException
from fastapi.encoders import jsonable_encoder

from app.core.supabase_client import get_supabase
from app.core.config import config

from datetime import datetime, timezone

def _con_fecha_completado(datos: dict) -> dict:
    """
    Si el estatus que se está guardando es 'Completado' (sin importar mayúsculas),
    registra la fecha/hora actual en fecha_completado automáticamente.
    """
    estatus = str(datos.get("estatus", "")).strip().lower()
    if estatus == "completado":
        datos["fecha_completado"] = datetime.now(timezone.utc).isoformat()
    return datos
def _table():
    sb = get_supabase()
    return sb.schema(config.supabase_schema).table(config.supabase_toma)


# =====================================
# CONSULTAS
# =====================================

def obtener_por_id(id_toma: int):
    try:
        res = (
            _table()
            .select("*")
            .eq("id_toma", id_toma)
            .execute()
        )
        return res.data[0] if res.data else None

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error al buscar toma: {e}"
        )


def listar():
    try:
        res = (
            _table()
            .select("*")
            .execute()
        )
        return res.data

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error al listar tomas: {e}"
        )


def listar_por_docente(id_docente1: int):
    try:
        res = (
            _table()
            .select("*")
            .eq("id_docente1", id_docente1)
            .execute()
        )
        return res.data

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error al listar tomas del docente: {e}"
        )


def listar_por_curso(id_curso1: int):
    try:
        res = (
            _table()
            .select("*")
            .eq("id_curso1", id_curso1)
            .execute()
        )
        return res.data

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error al listar tomas del curso: {e}"
        )


# =====================================
# CRUD
# =====================================

def crear(datos: dict):
    try:
        if not datos:
            raise HTTPException(
                status_code=400,
                detail="No se recibieron datos."
            )
        datos = _con_fecha_completado(datos)
        datos = jsonable_encoder(datos)

        res = (
            _table()
            .insert(datos)
            .execute()
        )
        return res.data[0]

    except HTTPException:
        raise

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error al crear toma: {e}"
        )


def actualizar(id_toma: int, datos: dict):
    try:
        if not datos:
            raise HTTPException(
                status_code=400,
                detail="No se recibieron datos."
            )
        datos = _con_fecha_completado(datos)
        datos = jsonable_encoder(datos)

        res = (
            _table()
            .update(datos)
            .eq("id_toma", id_toma)
            .execute()
        )
        return res.data[0] if res.data else None

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error al actualizar toma: {e}"
        )


def eliminar(id_toma: int):
    try:
        res = (
            _table()
            .delete()
            .eq("id_toma", id_toma)
            .execute()
        )
        return res.data[0] if res.data else None

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error al eliminar toma: {e}"
        )