from datetime import datetime, timezone
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.api.deps import get_current_user_id
from app.core.database import get_db
from app.schemas.sync import PullResponse, PushRequest, PushResponse
from app.services.sync_service import get_all_records, get_changes_since, push_records

router = APIRouter(prefix="/sync", tags=["sync"])


@router.get("", response_model=PullResponse)
def pull_changes(
    since: Optional[str] = Query(
        default=None,
        description="ISO-8601 timestamp; return only records updated after this time",
    ),
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    """Return records changed since the given timestamp (incremental sync)."""
    server_ts = datetime.now(timezone.utc).isoformat()

    if since is None:
        # No timestamp provided — treat as epoch (return everything)
        since_dt = datetime.fromtimestamp(0, tz=timezone.utc)
    else:
        try:
            since_dt = datetime.fromisoformat(since)
            if since_dt.tzinfo is None:
                since_dt = since_dt.replace(tzinfo=timezone.utc)
        except ValueError:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail="Invalid 'since' timestamp; expected ISO-8601 format",
            )

    records = get_changes_since(db, user_id, since_dt)
    return PullResponse(records=records, server_timestamp=server_ts)


@router.post("", response_model=PushResponse)
def push_changes(
    body: PushRequest,
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    """Push a batch of encrypted records to the server."""
    synced, conflicts = push_records(db, user_id, body.records)
    return PushResponse(synced=synced, conflicts=conflicts)


@router.get("/full", response_model=PullResponse)
def full_sync(
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    """Return all non-deleted records for the user (full sync)."""
    server_ts = datetime.now(timezone.utc).isoformat()
    records = get_all_records(db, user_id)
    return PullResponse(records=records, server_timestamp=server_ts)
