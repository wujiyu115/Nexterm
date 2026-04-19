import uuid
from datetime import timezone
from typing import List

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.deps import get_current_user_id
from app.core.database import get_db
from app.models.device import Device
from app.schemas.device import DeviceRegisterRequest, DeviceResponse

router = APIRouter(prefix="/devices", tags=["devices"])


def _device_to_response(device: Device) -> DeviceResponse:
    created_at = device.created_at
    if created_at is None:
        created_at_str = ""
    elif created_at.tzinfo is None:
        created_at_str = created_at.replace(tzinfo=timezone.utc).isoformat()
    else:
        created_at_str = created_at.isoformat()

    last_sync_at_str = None
    if device.last_sync_at is not None:
        if device.last_sync_at.tzinfo is None:
            last_sync_at_str = device.last_sync_at.replace(tzinfo=timezone.utc).isoformat()
        else:
            last_sync_at_str = device.last_sync_at.isoformat()

    return DeviceResponse(
        id=device.id,
        device_name=device.device_name,
        platform=device.platform,
        last_sync_at=last_sync_at_str,
        created_at=created_at_str,
    )


@router.get("", response_model=List[DeviceResponse])
def list_devices(
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    """List all registered devices for the authenticated user."""
    devices = db.query(Device).filter(Device.user_id == user_id).all()
    return [_device_to_response(d) for d in devices]


@router.post("", response_model=DeviceResponse, status_code=status.HTTP_201_CREATED)
def register_device(
    body: DeviceRegisterRequest,
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    """Register a new device for the authenticated user."""
    device = Device(
        id=str(uuid.uuid4()),
        user_id=user_id,
        device_name=body.device_name,
        platform=body.platform,
    )
    db.add(device)
    db.commit()
    db.refresh(device)
    return _device_to_response(device)


@router.delete("/{device_id}", status_code=status.HTTP_204_NO_CONTENT)
def remove_device(
    device_id: str,
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    """Remove a registered device. Only the owning user can remove their device."""
    device = (
        db.query(Device)
        .filter(Device.id == device_id, Device.user_id == user_id)
        .first()
    )
    if device is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Device not found",
        )
    db.delete(device)
    db.commit()
