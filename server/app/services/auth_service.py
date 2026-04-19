import uuid
from typing import Optional

from sqlalchemy.orm import Session

from app.core.security import hash_password, verify_password
from app.models.user import User


def create_user(db: Session, email: str, password: str) -> User:
    """Create a new user with a hashed password."""
    user = User(
        id=str(uuid.uuid4()),
        email=email,
        password_hash=hash_password(password),
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


def get_user_by_email(db: Session, email: str) -> Optional[User]:
    """Retrieve a user by email address."""
    return db.query(User).filter(User.email == email).first()


def get_user_by_id(db: Session, user_id: str) -> Optional[User]:
    """Retrieve a user by their ID."""
    return db.query(User).filter(User.id == user_id).first()


def authenticate_user(db: Session, email: str, password: str) -> Optional[User]:
    """Verify email/password credentials and return the User if valid."""
    user = get_user_by_email(db, email)
    if user is None:
        return None
    if not verify_password(password, user.password_hash):
        return None
    return user


def delete_user(db: Session, user_id: str) -> bool:
    """Delete a user and all their associated data. Returns True if deleted."""
    user = db.query(User).filter(User.id == user_id).first()
    if user is None:
        return False

    # Cascade-delete sync records and devices for this user
    from app.models.sync_record import SyncRecord
    from app.models.device import Device

    db.query(SyncRecord).filter(SyncRecord.user_id == user_id).delete()
    db.query(Device).filter(Device.user_id == user_id).delete()
    db.delete(user)
    db.commit()
    return True
