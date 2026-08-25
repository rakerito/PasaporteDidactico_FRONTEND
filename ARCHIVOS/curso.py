from fastapi import APIRouter, Depends
from app.service import curso_service
from app.core.security import usuario_actual

router = APIRouter()

@router.get("/cursos/activos", tags=["Cursos"])
def obtener_cursos_activos(usuario: dict = Depends(usuario_actual)):
    """
    Devuelve la lista de cursos con estatus 'activo', 
    incluyendo sus categorías calculadas y lo que otorgan.
    """
    return curso_service.obtener_activos()

@router.get("/cursos/{id_curso}/detalle", tags=["Cursos"])
def obtener_detalle_curso(id_curso: int, usuario: dict = Depends(usuario_actual)):
    """
    Devuelve el detalle de un curso en específico, 
    incluyendo los microcursos requeridos.
    """
    return curso_service.detalle_curso(id_curso)
