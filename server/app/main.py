from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.auth import router as auth_router
from app.api.sync import router as sync_router
from app.api.devices import router as devices_router

app = FastAPI(
    title="Nexterm Cloud Sync API",
    description=(
        "Backend for Nexterm SSH terminal client. "
        "Stores only end-to-end encrypted user data — "
        "the server never sees plaintext."
    ),
    version="1.0.0",
)

# ---------------------------------------------------------------------------
# CORS — allow all origins in development; tighten in production via env var
# ---------------------------------------------------------------------------
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------------------------------------------------------------------
# Routers
# ---------------------------------------------------------------------------
app.include_router(auth_router, prefix="/api/v1")
app.include_router(sync_router, prefix="/api/v1")
app.include_router(devices_router, prefix="/api/v1")


# ---------------------------------------------------------------------------
# Health check
# ---------------------------------------------------------------------------
@app.get("/health", tags=["health"])
def health_check():
    """Return service liveness status."""
    return {"status": "ok", "service": "nexterm-sync"}
