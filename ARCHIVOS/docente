from pydantic import BaseModel, Field

class crearDocente(BaseModel):
    division: str = Field(max_length=100)
    id_usuario1: int = Field(ge=0)
    foto_url: str | None = Field(default=None, max_length=300)

class actualizarDocente(BaseModel):
    division: str | None = Field(default=None, max_length=100)
    id_usuario1: int | None = Field(default=None, ge=0)
    foto_url: str | None = Field(default=None, max_length=300)

class recuperarDocente(BaseModel):
    id_docente: int
    division: str
    id_usuario1: int
    foto_url: str | None

class soloDocente(BaseModel):
    item: recuperarDocente

class listaDocente(BaseModel):
    items: list[recuperarDocente]