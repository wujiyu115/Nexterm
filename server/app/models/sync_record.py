from sqlalchemy import Column, String, DateTime, Boolean, Integer, LargeBinary
from sqlalchemy.sql import func
from app.core.database import Base


class SyncRecord(Base):
    __tablename__ = "sync_records"

    id = Column(String, primary_key=True)
    user_id = Column(String, nullable=False, index=True)
    record_type = Column(String, nullable=False)
    encrypted_payload = Column(LargeBinary, nullable=False)
    iv = Column(LargeBinary, nullable=False)
    updated_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        index=True,
    )
    is_deleted = Column(Boolean, default=False)
    version = Column(Integer, default=1)
