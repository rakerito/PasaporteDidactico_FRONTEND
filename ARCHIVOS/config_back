from pydantic_settings import BaseSettings, SettingsConfigDict
from typing import Optional

class Settings(BaseSettings):
    PROJECT_NAME: str = "Pasaporte Didactico Backend"
    API_V1_STR: str = "/api/v1"
    ENVIRONMENT: str = "development"

    # Supabase settings
    SUPABASE_URL: str = "https://bvrzerkpmajajhdrahvn.supabase.co"
    SUPABASE_KEY: Optional[str] = None
    SUPABASE_PUBLISHABLE_KEY: Optional[str] = "sb_publishable_3G84BteJ7e6Tfa8Qx3ADyg_HgEw3nqh"
    SUPABASE_SECRET_KEY: Optional[str] = None

    # Supabase table / schema configuration
    SUPABASE_SCHEMA: str = "public"
    SUPABASE_USUARIO: str = "usuario"
    SUPABASE_CURSO: str = "curso"
    SUPABASE_CATEGORIA: str = "categoria"
    SUPABASE_CURSO_CATEGORIA: str = "curso_categoria"
    SUPABASE_TOMA: str = "toma"
    SUPABASE_OTORGA: str = "otorga"
    SUPABASE_REQUIERE: str = "requiere"
    SUPABASE_CONSTANCIA: str = "constancia"
    SUPABASE_DOCENTE: str = "docente"
    SUPABASE_SELLO: str = "sello"
    SUPABASE_BUCKET_FOTOS: str = "fotos-perfil"
    SUPABASE_NOTIFICACION_PERSONAL: str = "notificacion_personal"
    SUPABASE_NOTIFICACION_GENERAL: str = "notificacion_general"
    SUPABASE_NOTIFICACION_GENERAL_LEIDA: str = "notificacion_general_leida"
    
    @property
    def active_supabase_key(self) -> str:
        return self.SUPABASE_SECRET_KEY or self.SUPABASE_KEY or self.SUPABASE_PUBLISHABLE_KEY or ""

    @property
    def supabase_url(self) -> str:
        return self.SUPABASE_URL

    @property
    def supabase_key(self) -> str:
        return self.active_supabase_key

    @property
    def supabase_schema(self) -> str:
        return self.SUPABASE_SCHEMA

    @property
    def supabase_usuario(self) -> str:
        return self.SUPABASE_USUARIO

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore"
    )

    @property
    def supabase_curso(self) -> str:
        return self.SUPABASE_CURSO

    @property
    def supabase_categoria(self) -> str:
        return self.SUPABASE_CATEGORIA

    @property
    def supabase_curso_categoria(self) -> str:
        return self.SUPABASE_CURSO_CATEGORIA

    @property
    def supabase_toma(self) -> str:
        return self.SUPABASE_TOMA

    @property
    def supabase_otorga(self) -> str:
        return self.SUPABASE_OTORGA

    @property
    def supabase_requiere(self) -> str:
        return self.SUPABASE_REQUIERE

    @property
    def supabase_constancia(self) -> str:
        return self.SUPABASE_CONSTANCIA

    @property
    def supabase_docente(self) -> str:
        return self.SUPABASE_DOCENTE

    @property
    def supabase_sello(self) -> str:
        return self.SUPABASE_SELLO

    @property
    def supabase_notificacion_personal(self) -> str:
        return self.SUPABASE_NOTIFICACION_PERSONAL

    @property
    def supabase_notificacion_general(self) -> str:
        return self.SUPABASE_NOTIFICACION_GENERAL

    @property
    def supabase_notificacion_general_leida(self) -> str:
        return self.SUPABASE_NOTIFICACION_GENERAL_LEIDA
    
    @property
    def supabase_bucket_fotos(self) -> str:
        return self.SUPABASE_BUCKET_FOTOS
        
    # JWT settings
    JWT_SECRET_KEY: str = "kamikazequecomekktuas"
    JWT_ALGORITHM: str = "HS256"
    JWT_EXPIRATION_MINUTES: int = 60 * 24  # 1 día

    @property
    def jwt_secret_key(self) -> str:
        return self.JWT_SECRET_KEY

    @property
    def jwt_algorithm(self) -> str:
        return self.JWT_ALGORITHM

    @property
    def jwt_expiration_minutes(self) -> int:
        return self.JWT_EXPIRATION_MINUTES
settings = Settings()
config = settings
