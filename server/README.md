# Nexterm Cloud Sync Server

FastAPI backend for the Nexterm SSH terminal client. Provides user authentication, encrypted data sync, and device management. The server stores **only ciphertext** — all encryption and decryption happens on the client; the server cannot access plaintext user data.

---

## Prerequisites

| Requirement | Version |
|-------------|---------|
| Python | 3.12+ |
| PostgreSQL | 14+ |

---

## Setup

```bash
# 1. Enter the server directory
cd server

# 2. Create and activate a virtual environment
python -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate

# 3. Install dependencies
pip install -r requirements.txt

# 4. Configure environment variables
cp .env.example .env
# Edit .env with your own values (see Environment Variables section below)

# 5. Create the database tables
python -c "from app.core.database import Base, engine; from app.models import user, sync_record, device; Base.metadata.create_all(engine)"

# 6. Start the development server
uvicorn app.main:app --reload --port 8000
```

### Environment Variables

Create a `.env` file in the `server/` directory:

```dotenv
DATABASE_URL=postgresql://nexterm:nexterm@localhost:5432/nexterm
JWT_SECRET=change-me-in-production-use-a-long-random-string
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
REFRESH_TOKEN_EXPIRE_DAYS=30
```

| Variable | Default | Description |
|----------|---------|-------------|
| `DATABASE_URL` | `postgresql://nexterm:nexterm@localhost:5432/nexterm` | PostgreSQL connection URL |
| `JWT_SECRET` | `change-me-in-production` | Secret key for signing JWTs — **must be changed** |
| `JWT_ALGORITHM` | `HS256` | JWT signing algorithm |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | `30` | Access token lifetime (minutes) |
| `REFRESH_TOKEN_EXPIRE_DAYS` | `30` | Refresh token lifetime (days) |

---

## API Reference

Base URL: `http://localhost:8000/api/v1`

### Authentication

| Method | Path | Description | Auth Required |
|--------|------|-------------|:---:|
| `POST` | `/auth/register` | Register a new account; returns token pair | No |
| `POST` | `/auth/login` | Authenticate with email + password; returns token pair | No |
| `POST` | `/auth/refresh` | Exchange a valid refresh token for a new token pair | No |
| `DELETE` | `/auth/account` | Permanently delete account and all associated data | Yes |

**Request body — register / login:**
```json
{ "email": "user@example.com", "password": "s3cr3t" }
```

**Response — token pair:**
```json
{ "access_token": "<jwt>", "refresh_token": "<jwt>", "token_type": "bearer" }
```

---

### Sync

All sync endpoints require `Authorization: Bearer <access_token>`.

| Method | Path | Description | Auth Required |
|--------|------|-------------|:---:|
| `GET` | `/sync` | Pull records changed since a given timestamp (incremental sync) | Yes |
| `POST` | `/sync` | Push a batch of encrypted records to the server | Yes |
| `GET` | `/sync/full` | Pull all non-deleted records (used by new devices) | Yes |

**Pull — query params:**

| Param | Type | Description |
|-------|------|-------------|
| `since` | ISO-8601 string (optional) | Only return records updated after this time. Omit for a full pull. |

**Pull response:**
```json
{
  "records": [
    {
      "id": "uuid",
      "record_type": "host",
      "encrypted_payload": "<base64>",
      "iv": "<base64>",
      "updated_at": "2024-01-01T00:00:00Z",
      "is_deleted": false,
      "version": 1
    }
  ],
  "server_timestamp": "2024-01-01T00:01:00Z"
}
```

**Push request:**
```json
{
  "records": [
    {
      "id": "uuid",
      "record_type": "host",
      "encrypted_payload": "<base64>",
      "iv": "<base64>",
      "updated_at": "2024-01-01T00:00:00Z",
      "is_deleted": false,
      "version": 1
    }
  ],
  "device_id": "uuid"
}
```

**Push response:**
```json
{ "synced": 3, "conflicts": 0 }
```

---

### Devices

All device endpoints require `Authorization: Bearer <access_token>`.

| Method | Path | Description | Auth Required |
|--------|------|-------------|:---:|
| `GET` | `/devices` | List all registered devices for the current user | Yes |
| `POST` | `/devices` | Register a new device | Yes |
| `DELETE` | `/devices/{device_id}` | Remove a registered device | Yes |

**Register device request:**
```json
{ "device_name": "iPhone 15 Pro", "platform": "ios" }
```

**Device response:**
```json
{
  "id": "uuid",
  "device_name": "iPhone 15 Pro",
  "platform": "ios",
  "last_sync_at": "2024-01-01T00:00:00Z",
  "created_at": "2024-01-01T00:00:00Z"
}
```

---

### Health Check

| Method | Path | Description | Auth Required |
|--------|------|-------------|:---:|
| `GET` | `/health` | Service liveness check | No |

---

## Database Schema

### `users`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | String (UUID) | PK | User identifier |
| `email` | String | UNIQUE, NOT NULL, indexed | Login email |
| `password_hash` | String | NOT NULL | bcrypt hash of the password |
| `created_at` | DateTime (TZ) | DEFAULT now() | Account creation timestamp |

### `sync_records`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | String (UUID) | PK | Record identifier (client-generated) |
| `user_id` | String | NOT NULL, indexed | Owning user |
| `record_type` | String | NOT NULL | Entity type: `host`, `ssh_key`, `snippet`, `port_forward` |
| `encrypted_payload` | LargeBinary | NOT NULL | AES-256-GCM ciphertext + authentication tag |
| `iv` | LargeBinary | NOT NULL | 12-byte GCM initialisation vector |
| `updated_at` | DateTime (TZ) | DEFAULT now(), `onupdate`, indexed | Used for incremental sync |
| `is_deleted` | Boolean | DEFAULT false | Soft-delete flag |
| `version` | Integer | DEFAULT 1 | Optimistic concurrency version |

### `devices`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | String (UUID) | PK | Device identifier (client-generated) |
| `user_id` | String | NOT NULL, indexed | Owning user |
| `device_name` | String | NOT NULL | Human-readable device name |
| `platform` | String | NOT NULL | `ios` or `android` |
| `last_sync_at` | DateTime (TZ) | nullable | Timestamp of last successful sync |
| `created_at` | DateTime (TZ) | DEFAULT now() | Device registration timestamp |

---

## Running

```bash
# Development (auto-reload on file changes)
uvicorn app.main:app --reload --port 8000

# Production (multiple workers)
uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4

# Interactive API docs (development only)
open http://localhost:8000/docs
```

---

## Testing

```bash
# Activate virtual environment first
source venv/bin/activate

# Run all tests
pytest

# Run with verbose output
pytest -v

# Run a specific test file
pytest tests/test_auth.py -v

# Run with coverage report
pytest --cov=app --cov-report=html
```

---

## Deployment Notes

1. **Set a strong `JWT_SECRET`** — use at least 32 random bytes (e.g. `openssl rand -hex 32`).
2. **Restrict CORS** — in production, replace `allow_origins=["*"]` in `main.py` with your app's origin or set it via an environment variable.
3. **Use TLS** — run behind a reverse proxy (nginx, Caddy) that terminates HTTPS.
4. **Database migrations** — the project uses `alembic` for schema migrations. Run `alembic upgrade head` before starting a new version.
5. **No plaintext data** — the server never processes plaintext user records; all payloads arrive and leave as AES-256-GCM ciphertext. Encryption keys never leave the client.
