from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    database_url: str = "postgresql://nexterm:nexterm@localhost:5432/nexterm"
    jwt_secret: str = "change-me-in-production"
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 30
    refresh_token_expire_days: int = 30

    class Config:
        env_file = ".env"


settings = Settings()
