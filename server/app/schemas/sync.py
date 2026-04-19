import base64
from typing import List, Optional

from pydantic import BaseModel, field_validator


class SyncRecordIn(BaseModel):
    """A single sync record pushed from the client.

    encrypted_payload and iv are transmitted as base64-encoded strings and
    stored as raw bytes in the database.
    """

    id: str
    record_type: str
    encrypted_payload: str  # base64-encoded ciphertext
    iv: str  # base64-encoded initialisation vector
    updated_at: Optional[str] = None  # ISO-8601 timestamp (client hint)
    is_deleted: bool = False
    version: int = 1

    @field_validator("encrypted_payload", "iv")
    @classmethod
    def must_be_valid_base64(cls, v: str) -> str:
        try:
            base64.b64decode(v, validate=True)
        except Exception:
            raise ValueError("Field must be valid base64")
        return v


class SyncRecordOut(BaseModel):
    """A single sync record returned to the client."""

    id: str
    record_type: str
    encrypted_payload: str  # base64-encoded ciphertext
    iv: str  # base64-encoded initialisation vector
    updated_at: str  # ISO-8601 timestamp
    is_deleted: bool
    version: int

    model_config = {"from_attributes": True}


class PushRequest(BaseModel):
    records: List[SyncRecordIn]


class PushResponse(BaseModel):
    synced: int
    conflicts: int


class PullResponse(BaseModel):
    records: List[SyncRecordOut]
    server_timestamp: str
