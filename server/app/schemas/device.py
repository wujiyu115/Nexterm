from typing import Optional
from pydantic import BaseModel


class DeviceRegisterRequest(BaseModel):
    device_name: str
    platform: str


class DeviceResponse(BaseModel):
    id: str
    device_name: str
    platform: str
    last_sync_at: Optional[str] = None
    created_at: str

    model_config = {"from_attributes": True}
