"""Tests for device routes: /api/v1/devices"""
import pytest

DEVICES_URL = "/api/v1/devices"

DEVICE_PAYLOAD = {"device_name": "My Laptop", "platform": "linux"}


# ---------------------------------------------------------------------------
# Register device
# ---------------------------------------------------------------------------
def test_register_device(client, auth_headers):
    resp = client.post(DEVICES_URL, json=DEVICE_PAYLOAD, headers=auth_headers)
    assert resp.status_code == 201
    body = resp.json()
    assert body["device_name"] == DEVICE_PAYLOAD["device_name"]
    assert body["platform"] == DEVICE_PAYLOAD["platform"]
    assert "id" in body
    assert "created_at" in body


def test_register_device_requires_auth(client):
    resp = client.post(DEVICES_URL, json=DEVICE_PAYLOAD)
    assert resp.status_code in (401, 403)


# ---------------------------------------------------------------------------
# List devices
# ---------------------------------------------------------------------------
def test_list_devices_empty(client, auth_headers):
    resp = client.get(DEVICES_URL, headers=auth_headers)
    assert resp.status_code == 200
    assert resp.json() == []


def test_list_devices(client, auth_headers):
    # Register two devices
    client.post(DEVICES_URL, json={"device_name": "Phone", "platform": "android"}, headers=auth_headers)
    client.post(DEVICES_URL, json={"device_name": "Tablet", "platform": "ios"}, headers=auth_headers)

    resp = client.get(DEVICES_URL, headers=auth_headers)
    assert resp.status_code == 200
    devices = resp.json()
    assert len(devices) == 2
    names = {d["device_name"] for d in devices}
    assert "Phone" in names
    assert "Tablet" in names


def test_list_devices_requires_auth(client):
    resp = client.get(DEVICES_URL)
    assert resp.status_code in (401, 403)


def test_list_devices_isolated_per_user(client):
    """Devices registered by user A must not appear in user B's list."""
    # User A
    client.post("/api/v1/auth/register", json={"email": "a@example.com", "password": "passA123"})
    resp_a = client.post("/api/v1/auth/login", json={"email": "a@example.com", "password": "passA123"})
    headers_a = {"Authorization": f"Bearer {resp_a.json()['access_token']}"}

    # User B
    client.post("/api/v1/auth/register", json={"email": "b@example.com", "password": "passB123"})
    resp_b = client.post("/api/v1/auth/login", json={"email": "b@example.com", "password": "passB123"})
    headers_b = {"Authorization": f"Bearer {resp_b.json()['access_token']}"}

    client.post(DEVICES_URL, json={"device_name": "A's Device", "platform": "linux"}, headers=headers_a)

    resp = client.get(DEVICES_URL, headers=headers_b)
    assert resp.status_code == 200
    assert resp.json() == []


# ---------------------------------------------------------------------------
# Delete device
# ---------------------------------------------------------------------------
def test_delete_device(client, auth_headers):
    # Create a device
    create_resp = client.post(DEVICES_URL, json=DEVICE_PAYLOAD, headers=auth_headers)
    device_id = create_resp.json()["id"]

    # Delete it
    resp = client.delete(f"{DEVICES_URL}/{device_id}", headers=auth_headers)
    assert resp.status_code == 204

    # Verify it no longer appears in the list
    list_resp = client.get(DEVICES_URL, headers=auth_headers)
    ids = [d["id"] for d in list_resp.json()]
    assert device_id not in ids


def test_delete_device_not_found(client, auth_headers):
    resp = client.delete(f"{DEVICES_URL}/nonexistent-device-id", headers=auth_headers)
    assert resp.status_code == 404


def test_delete_device_requires_auth(client):
    resp = client.delete(f"{DEVICES_URL}/some-id")
    assert resp.status_code in (401, 403)


def test_delete_device_wrong_user(client):
    """User B must not be able to delete a device that belongs to user A."""
    # User A registers a device
    client.post("/api/v1/auth/register", json={"email": "a@example.com", "password": "passA123"})
    resp_a = client.post("/api/v1/auth/login", json={"email": "a@example.com", "password": "passA123"})
    headers_a = {"Authorization": f"Bearer {resp_a.json()['access_token']}"}
    create_resp = client.post(DEVICES_URL, json=DEVICE_PAYLOAD, headers=headers_a)
    device_id = create_resp.json()["id"]

    # User B tries to delete it
    client.post("/api/v1/auth/register", json={"email": "b@example.com", "password": "passB123"})
    resp_b = client.post("/api/v1/auth/login", json={"email": "b@example.com", "password": "passB123"})
    headers_b = {"Authorization": f"Bearer {resp_b.json()['access_token']}"}

    resp = client.delete(f"{DEVICES_URL}/{device_id}", headers=headers_b)
    assert resp.status_code == 404
