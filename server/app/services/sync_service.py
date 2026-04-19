import base64
import uuid
from datetime import datetime, timezone
from typing import List, Optional, Tuple

from sqlalchemy.orm import Session

from app.models.sync_record import SyncRecord
from app.schemas.sync import SyncRecordIn, SyncRecordOut


def _record_to_out(record: SyncRecord) -> SyncRecordOut:
    """Convert a SyncRecord ORM object to the API response schema."""
    updated_at = record.updated_at
    if updated_at is None:
        updated_at_str = datetime.now(timezone.utc).isoformat()
    elif updated_at.tzinfo is None:
        # Treat naive datetimes as UTC
        updated_at_str = updated_at.replace(tzinfo=timezone.utc).isoformat()
    else:
        updated_at_str = updated_at.isoformat()

    return SyncRecordOut(
        id=record.id,
        record_type=record.record_type,
        encrypted_payload=base64.b64encode(record.encrypted_payload).decode(),
        iv=base64.b64encode(record.iv).decode(),
        updated_at=updated_at_str,
        is_deleted=record.is_deleted,
        version=record.version,
    )


def get_changes_since(
    db: Session, user_id: str, since: datetime
) -> List[SyncRecordOut]:
    """Return all records for the user updated after `since`."""
    records = (
        db.query(SyncRecord)
        .filter(SyncRecord.user_id == user_id, SyncRecord.updated_at > since)
        .order_by(SyncRecord.updated_at.asc())
        .all()
    )
    return [_record_to_out(r) for r in records]


def get_all_records(db: Session, user_id: str) -> List[SyncRecordOut]:
    """Return all non-deleted records for the user (full sync)."""
    records = (
        db.query(SyncRecord)
        .filter(SyncRecord.user_id == user_id, SyncRecord.is_deleted == False)
        .order_by(SyncRecord.updated_at.asc())
        .all()
    )
    return [_record_to_out(r) for r in records]


def push_records(
    db: Session, user_id: str, incoming: List[SyncRecordIn]
) -> Tuple[int, int]:
    """
    Persist incoming records using last-write-wins conflict resolution.

    Resolution strategy:
    - If the record does not exist: insert it.
    - If the record exists and the incoming version >= stored version: update it.
    - If the stored version is newer (conflict): skip (server wins).

    Returns (synced_count, conflict_count).
    """
    synced = 0
    conflicts = 0
    now = datetime.now(timezone.utc)

    for item in incoming:
        encrypted_bytes = base64.b64decode(item.encrypted_payload)
        iv_bytes = base64.b64decode(item.iv)

        existing: Optional[SyncRecord] = (
            db.query(SyncRecord)
            .filter(SyncRecord.id == item.id, SyncRecord.user_id == user_id)
            .first()
        )

        if existing is None:
            # New record — insert
            record = SyncRecord(
                id=item.id,
                user_id=user_id,
                record_type=item.record_type,
                encrypted_payload=encrypted_bytes,
                iv=iv_bytes,
                updated_at=now,
                is_deleted=item.is_deleted,
                version=item.version,
            )
            db.add(record)
            synced += 1
        elif item.version >= existing.version:
            # Client version is same or newer — accept (last-write-wins)
            existing.record_type = item.record_type
            existing.encrypted_payload = encrypted_bytes
            existing.iv = iv_bytes
            existing.updated_at = now
            existing.is_deleted = item.is_deleted
            existing.version = item.version
            synced += 1
        else:
            # Server has a newer version — conflict, server wins
            conflicts += 1

    db.commit()
    return synced, conflicts
