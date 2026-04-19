"""Tests for auth routes: /api/v1/auth/*"""
import pytest


REGISTER_URL = "/api/v1/auth/register"
LOGIN_URL = "/api/v1/auth/login"
REFRESH_URL = "/api/v1/auth/refresh"
DELETE_URL = "/api/v1/auth/account"

VALID_CREDS = {"email": "alice@example.com", "password": "s3cr3tPass!"}


# ---------------------------------------------------------------------------
# Register
# ---------------------------------------------------------------------------
def test_register_success(client):
    resp = client.post(REGISTER_URL, json=VALID_CREDS)
    assert resp.status_code == 201
    body = resp.json()
    assert "access_token" in body
    assert "refresh_token" in body
    assert body["token_type"] == "bearer"


def test_register_duplicate_email(client):
    client.post(REGISTER_URL, json=VALID_CREDS)
    resp = client.post(REGISTER_URL, json=VALID_CREDS)
    assert resp.status_code == 409
    assert "already registered" in resp.json()["detail"].lower()


# ---------------------------------------------------------------------------
# Login
# ---------------------------------------------------------------------------
def test_login_success(client):
    client.post(REGISTER_URL, json=VALID_CREDS)
    resp = client.post(LOGIN_URL, json=VALID_CREDS)
    assert resp.status_code == 200
    body = resp.json()
    assert "access_token" in body
    assert "refresh_token" in body


def test_login_wrong_password(client):
    client.post(REGISTER_URL, json=VALID_CREDS)
    resp = client.post(
        LOGIN_URL,
        json={"email": VALID_CREDS["email"], "password": "wrongpassword"},
    )
    assert resp.status_code == 401


def test_login_nonexistent_email(client):
    resp = client.post(
        LOGIN_URL,
        json={"email": "nobody@example.com", "password": "whatever"},
    )
    assert resp.status_code == 401


# ---------------------------------------------------------------------------
# Refresh
# ---------------------------------------------------------------------------
def test_refresh_token(client):
    # Register and get a refresh token
    resp = client.post(REGISTER_URL, json=VALID_CREDS)
    refresh_token = resp.json()["refresh_token"]

    resp2 = client.post(REFRESH_URL, json={"refresh_token": refresh_token})
    assert resp2.status_code == 200
    body = resp2.json()
    assert "access_token" in body
    assert "refresh_token" in body


def test_refresh_with_access_token_fails(client):
    """Using an access token on the refresh endpoint must return 401."""
    resp = client.post(REGISTER_URL, json=VALID_CREDS)
    access_token = resp.json()["access_token"]

    resp2 = client.post(REFRESH_URL, json={"refresh_token": access_token})
    assert resp2.status_code == 401


def test_refresh_with_garbage_token_fails(client):
    resp = client.post(REFRESH_URL, json={"refresh_token": "not.a.valid.token"})
    assert resp.status_code == 401


# ---------------------------------------------------------------------------
# Delete account
# ---------------------------------------------------------------------------
def test_delete_account(client):
    # Register and get auth headers
    reg_resp = client.post(REGISTER_URL, json=VALID_CREDS)
    access_token = reg_resp.json()["access_token"]
    headers = {"Authorization": f"Bearer {access_token}"}

    resp = client.delete(DELETE_URL, headers=headers)
    assert resp.status_code == 204

    # Attempting to log in after deletion should fail
    login_resp = client.post(LOGIN_URL, json=VALID_CREDS)
    assert login_resp.status_code == 401


def test_delete_account_requires_auth(client):
    resp = client.delete(DELETE_URL)
    # FastAPI HTTPBearer raises 403 when no token is provided
    assert resp.status_code in (401, 403)
