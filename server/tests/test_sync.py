"""Tests for sync routes: /api/v1/sync (GET/POST) and /api/v1/sync/full"""
import base64
import time
import uuid
from datetime import datetime, timezone

import pytest

PUSH_URL = "/api/v1/sync"
PULL_URL = "/api/v1/sync"
FULL_URL = "/api/v1/sync/full"


def _make_record(version: int = 1, record_id: str | None = None) -> dict:
    """Build a minimal valid SyncRecordIn payload."""
    return {
        "id": record_id or str(uuid.uuid4()),
        "record_type": "connection",
        "encrypted_payload": base64.b64encode(b"fake-encrypted-data").decode(),
        "iv": base64.b64encode(b"fake-iv-12345678").decode(),
        "is_deleted": False,
        "version": version,
    }


# ---------------------------------------------------------------------------
# Push
# ---------------------------------------------------------------------------
def test_push_records(client, auth_headers):
    records = [_make_record(), _make_record()]
    resp = client.post(PUSH_URL, json={"records": records}, headers=auth_headers)
    assert resp.status_code == 200
    body = resp.json()
    assert body["synced"] == 2
    assert body["conflicts"] == 0


def test_push_empty_records(client, auth_headers):
    resp = client.post(PUSH_URL, json={"records": []}, headers=auth_headers)
    assert resp.status_code == 200
    assert resp.json()["synced"] == 0


def test_push_requires_auth(client):
    resp = client.post(PUSH_URL, json={"records": []})
    assert resp.status_code in (401, 403)


# ---------------------------------------------------------------------------
# Pull (incremental)
# ---------------------------------------------------------------------------
def test_pull_changes_since(client, auth_headers):
    # Push a record first
    record = _make_record()
    client.post(PUSH_URL, json={"records": [record]}, headers=auth_headers)

    # Pull with a timestamp from the past — should see the record
    since = "2000-01-01T00:00:00Z"
    resp = client.get(f"{PULL_URL}?since={since}", headers=auth_headers)
    assert resp.status_code == 200
    body = resp.json()
    assert "records" in body
    assert "server_timestamp" in body
    ids = [r["id"] for r in body["records"]]
    assert record["id"] in ids


def test_pull_changes_since_future_timestamp(client, auth_headers):
    """No records should be returned when 'since' is in the future."""
    record = _make_record()
    client.post(PUSH_URL, json={"records": [record]}, headers=auth_headers)

    future = "2099-01-01T00:00:00Z"
    resp = client.get(f"{PULL_URL}?since={future}", headers=auth_headers)
    assert resp.status_code == 200
    assert resp.json()["records"] == []


def test_pull_invalid_since_timestamp(client, auth_headers):
    resp = client.get(f"{PULL_URL}?since=not-a-date", headers=auth_headers)
    assert resp.status_code == 422


def test_pull_requires_auth(client):
    resp = client.get(PULL_URL)
    assert resp.status_code in (401, 403)


# ---------------------------------------------------------------------------
# Full sync
# ---------------------------------------------------------------------------
def test_pull_full(client, auth_headers):
    records = [_make_record(), _make_record()]
    client.post(PUSH_URL, json={"records": records}, headers=auth_headers)

    resp = client.get(FULL_URL, headers=auth_headers)
    assert resp.status_code == 200
    body = resp.json()
    assert "records" in body
    returned_ids = {r["id"] for r in body["records"]}
    for rec in records:
        assert rec["id"] in returned_ids


def test_pull_full_excludes_deleted(client, auth_headers):
    """Full sync must not return records marked as deleted."""
    deleted_record = {**_make_record(), "is_deleted": True}
    active_record = _make_record()
    client.post(
        PUSH_URL,
        json={"records": [deleted_record, active_record]},
        headers=auth_headers,
    )

    resp = client.get(FULL_URL, headers=auth_headers)
    assert resp.status_code == 200
    returned_ids = {r["id"] for r in resp.json()["records"]}
    assert active_record["id"] in returned_ids
    assert deleted_record["id"] not in returned_ids


def test_full_sync_requires_auth(client):
    resp = client.get(FULL_URL)
    assert resp.status_code in (401, 403)


# ---------------------------------------------------------------------------
# Conflict resolution
# ---------------------------------------------------------------------------
def test_push_conflict_server_wins(client, auth_headers):
    """
    Push a record at version 2. Then push the same record at version 1.
    The server should keep version 2 (server wins) and report a conflict.
    """
    record_id = str(uuid.uuid4())

    # First push: version 2
    newer = _make_record(version=2, record_id=record_id)
    resp1 = client.post(PUSH_URL, json={"records": [newer]}, headers=auth_headers)
    assert resp1.json()["synced"] == 1

    # Second push: version 1 (older) — server should reject
    older = _make_record(version=1, record_id=record_id)
    resp2 = client.post(PUSH_URL, json={"records": [older]}, headers=auth_headers)
    body2 = resp2.json()
    assert body2["conflicts"] == 1
    assert body2["synced"] == 0

    # Verify the stored record still has version 2
    pull_resp = client.get(f"{PULL_URL}?since=2000-01-01T00:00:00Z", headers=auth_headers)
    stored = next(r for r in pull_resp.json()["records"] if r["id"] == record_id)
    assert stored["version"] == 2


def test_push_same_version_overwrites(client, auth_headers):
    """
    Pushing the same version (>=) should be accepted (last-write-wins).
    """
    record_id = str(uuid.uuid4())
    v1 = _make_record(version=1, record_id=record_id)
    client.post(PUSH_URL, json={"records": [v1]}, headers=auth_headers)

    v1_update = {
        **v1,
        "encrypted_payload": base64.b64encode(b"updated-data").decode(),
    }
    resp = client.post(PUSH_URL, json={"records": [v1_update]}, headers=auth_headers)
    assert resp.json()["synced"] == 1
    assert resp.json()["conflicts"] == 0
