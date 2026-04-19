"""Tests for app/core/security.py: hashing, JWT creation, and decoding."""
import time
from datetime import datetime, timedelta, timezone

import jwt
import pytest

from app.core.config import settings
from app.core.security import (
    create_access_token,
    create_refresh_token,
    decode_token,
    hash_password,
    verify_password,
)

TEST_USER_ID = "test-user-uuid-1234"


# ---------------------------------------------------------------------------
# Password hashing
# ---------------------------------------------------------------------------
def test_hash_password_returns_string():
    hashed = hash_password("mypassword")
    assert isinstance(hashed, str)
    assert len(hashed) > 0


def test_hash_password_is_not_plaintext():
    plaintext = "mypassword"
    hashed = hash_password(plaintext)
    assert hashed != plaintext


def test_hash_password_different_salts():
    """Two calls for the same password must produce different hashes (salted)."""
    h1 = hash_password("same-password")
    h2 = hash_password("same-password")
    assert h1 != h2


def test_verify_password_correct():
    hashed = hash_password("correct-horse-battery-staple")
    assert verify_password("correct-horse-battery-staple", hashed) is True


def test_verify_password_wrong():
    hashed = hash_password("correct-password")
    assert verify_password("wrong-password", hashed) is False


def test_verify_password_empty_string_wrong():
    hashed = hash_password("nonempty")
    assert verify_password("", hashed) is False


# ---------------------------------------------------------------------------
# Access token
# ---------------------------------------------------------------------------
def test_create_access_token_returns_string():
    token = create_access_token(TEST_USER_ID)
    assert isinstance(token, str)
    assert len(token) > 0


def test_decode_access_token_claims():
    token = create_access_token(TEST_USER_ID)
    payload = decode_token(token)
    assert payload is not None
    assert payload["sub"] == TEST_USER_ID
    assert payload["type"] == "access"
    assert "exp" in payload
    assert "iat" in payload


def test_access_token_not_usable_as_refresh():
    """An access token must fail when decoded and checked for type == refresh."""
    token = create_access_token(TEST_USER_ID)
    payload = decode_token(token)
    assert payload is not None
    assert payload.get("type") != "refresh"


# ---------------------------------------------------------------------------
# Refresh token
# ---------------------------------------------------------------------------
def test_create_refresh_token_returns_string():
    token = create_refresh_token(TEST_USER_ID)
    assert isinstance(token, str)


def test_decode_refresh_token_claims():
    token = create_refresh_token(TEST_USER_ID)
    payload = decode_token(token)
    assert payload is not None
    assert payload["sub"] == TEST_USER_ID
    assert payload["type"] == "refresh"


def test_refresh_token_not_usable_as_access():
    """A refresh token must fail when decoded and checked for type == access."""
    token = create_refresh_token(TEST_USER_ID)
    payload = decode_token(token)
    assert payload is not None
    assert payload.get("type") != "access"


# ---------------------------------------------------------------------------
# Invalid / expired tokens
# ---------------------------------------------------------------------------
def test_decode_garbage_token_returns_none():
    assert decode_token("this.is.garbage") is None


def test_decode_empty_string_returns_none():
    assert decode_token("") is None


def test_decode_tampered_token_returns_none():
    token = create_access_token(TEST_USER_ID)
    # Flip the last character to break the signature
    tampered = token[:-1] + ("A" if token[-1] != "A" else "B")
    assert decode_token(tampered) is None


def test_expired_token_returns_none():
    """Manually craft an already-expired JWT and verify decode_token returns None."""
    expired_payload = {
        "sub": TEST_USER_ID,
        "type": "access",
        "exp": datetime.now(timezone.utc) - timedelta(seconds=1),
        "iat": datetime.now(timezone.utc) - timedelta(minutes=1),
    }
    expired_token = jwt.encode(
        expired_payload,
        settings.jwt_secret,
        algorithm=settings.jwt_algorithm,
    )
    assert decode_token(expired_token) is None


def test_token_signed_with_wrong_secret_returns_none():
    wrong_secret_token = jwt.encode(
        {
            "sub": TEST_USER_ID,
            "type": "access",
            "exp": datetime.now(timezone.utc) + timedelta(minutes=30),
        },
        "wrong-secret",
        algorithm=settings.jwt_algorithm,
    )
    assert decode_token(wrong_secret_token) is None
