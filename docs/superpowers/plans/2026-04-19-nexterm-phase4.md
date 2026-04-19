# Nexterm Phase 4: Backend API + Cloud Sync

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the FastAPI backend with JWT auth and encrypted sync API, then implement the Flutter client-side sync service with end-to-end encryption, offline-first design, and device management.

**Architecture:** Server stores only encrypted blobs — never plaintext. Client encrypts with AES-256-GCM using a key derived from the user's master password (PBKDF2 now, Argon2id when native plugin is stable). Sync protocol: incremental timestamp-based with last-write-wins conflict resolution.

**Tech Stack:**
- Backend: Python 3.12, FastAPI, SQLAlchemy 2.0, Alembic, PostgreSQL, PyJWT, bcrypt
- Client: Existing Flutter app + Dio HTTP client + CryptoService from Phase 1

**Dependencies on Phase 1-3:**
- `core/crypto/crypto_service.dart` — encrypt/decrypt payloads, key derivation
- `data/database/app_database.dart` — add sync_metadata table for tracking
- All entity types (Host, SSHKey, Snippet, PortForward) — serialized to JSON → encrypted → synced

---

## Task 1: FastAPI Project Setup

**Files:**
- Create: `server/requirements.txt`
- Create: `server/app/__init__.py`
- Create: `server/app/main.py`
- Create: `server/app/core/config.py`
- Create: `server/app/core/database.py`

- [ ] **Step 1: Create server directory and requirements**

```bash
mkdir -p server/app/core server/app/api server/app/models server/app/schemas server/app/services server/migrations
```

Create `server/requirements.txt`:

```
fastapi==0.115.6
uvicorn[standard]==0.34.0
sqlalchemy==2.0.36
alembic==1.14.1
psycopg2-binary==2.9.10
pyjwt==2.10.1
bcrypt==4.2.1
pydantic==2.10.4
pydantic-settings==2.7.1
python-multipart==0.0.20
httpx==0.28.1
pytest==8.3.4
pytest-asyncio==0.25.0
```

- [ ] **Step 2: Create config**

Create `server/app/core/config.py`:

```python
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    database_url: str = "postgresql://nexterm:nexterm@localhost:5432/nexterm"
    jwt_secret: str = "change-me-in-production"
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 30
    refresh_token_expire_days: int = 30

    class Config:
        env_file = ".env"

settings = Settings()
```

- [ ] **Step 3: Create database setup**

Create `server/app/core/database.py`:

```python
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, DeclarativeBase
from app.core.config import settings

engine = create_engine(settings.database_url)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

class Base(DeclarativeBase):
    pass

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
```

- [ ] **Step 4: Create FastAPI app**

Create `server/app/__init__.py` (empty).

Create `server/app/main.py`:

```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api import auth, sync, devices

app = FastAPI(title="Nexterm Sync Server", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router, prefix="/auth", tags=["auth"])
app.include_router(sync.router, prefix="/sync", tags=["sync"])
app.include_router(devices.router, prefix="/devices", tags=["devices"])

@app.get("/health")
def health():
    return {"status": "ok"}
```

- [ ] **Step 5: Commit**

```bash
git add server/
git commit -m "feat: scaffold FastAPI server with config and database setup"
```

---

## Task 2: Database Models

**Files:**
- Create: `server/app/models/user.py`
- Create: `server/app/models/sync_record.py`
- Create: `server/app/models/device.py`

- [ ] **Step 1: Create User model**

Create `server/app/models/user.py`:

```python
from sqlalchemy import Column, String, DateTime
from sqlalchemy.sql import func
from app.core.database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(String, primary_key=True)
    email = Column(String, unique=True, nullable=False, index=True)
    password_hash = Column(String, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
```

- [ ] **Step 2: Create SyncRecord model**

Create `server/app/models/sync_record.py`:

```python
from sqlalchemy import Column, String, DateTime, Boolean, Integer, LargeBinary
from sqlalchemy.sql import func
from app.core.database import Base

class SyncRecord(Base):
    __tablename__ = "sync_records"

    id = Column(String, primary_key=True)
    user_id = Column(String, nullable=False, index=True)
    record_type = Column(String, nullable=False)  # host, key, snippet, forward, setting
    encrypted_payload = Column(LargeBinary, nullable=False)
    iv = Column(LargeBinary, nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), index=True)
    is_deleted = Column(Boolean, default=False)
    version = Column(Integer, default=1)
```

- [ ] **Step 3: Create Device model**

Create `server/app/models/device.py`:

```python
from sqlalchemy import Column, String, DateTime
from sqlalchemy.sql import func
from app.core.database import Base

class Device(Base):
    __tablename__ = "devices"

    id = Column(String, primary_key=True)
    user_id = Column(String, nullable=False, index=True)
    device_name = Column(String, nullable=False)
    platform = Column(String, nullable=False)  # ios, android
    last_sync_at = Column(DateTime(timezone=True))
    created_at = Column(DateTime(timezone=True), server_default=func.now())
```

- [ ] **Step 4: Commit**

```bash
git add server/app/models/
git commit -m "feat: add SQLAlchemy models for users, sync_records, and devices"
```

---

## Task 3: Auth API (Register, Login, JWT)

**Files:**
- Create: `server/app/schemas/auth.py`
- Create: `server/app/services/auth_service.py`
- Create: `server/app/api/auth.py`
- Create: `server/app/core/security.py`

- [ ] **Step 1: Create security utilities**

Create `server/app/core/security.py`:

```python
from datetime import datetime, timedelta, timezone
import jwt
import bcrypt
from app.core.config import settings

def hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()

def verify_password(password: str, hashed: str) -> bool:
    return bcrypt.checkpw(password.encode(), hashed.encode())

def create_access_token(user_id: str) -> str:
    expire = datetime.now(timezone.utc) + timedelta(minutes=settings.access_token_expire_minutes)
    return jwt.encode({"sub": user_id, "exp": expire, "type": "access"}, settings.jwt_secret, algorithm=settings.jwt_algorithm)

def create_refresh_token(user_id: str) -> str:
    expire = datetime.now(timezone.utc) + timedelta(days=settings.refresh_token_expire_days)
    return jwt.encode({"sub": user_id, "exp": expire, "type": "refresh"}, settings.jwt_secret, algorithm=settings.jwt_algorithm)

def decode_token(token: str) -> dict:
    return jwt.decode(token, settings.jwt_secret, algorithms=[settings.jwt_algorithm])
```

- [ ] **Step 2: Create auth schemas**

Create `server/app/schemas/auth.py`:

```python
from pydantic import BaseModel, EmailStr

class RegisterRequest(BaseModel):
    email: EmailStr
    password: str

class LoginRequest(BaseModel):
    email: EmailStr
    password: str

class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"

class RefreshRequest(BaseModel):
    refresh_token: str
```

- [ ] **Step 3: Create auth service**

Create `server/app/services/auth_service.py`:

```python
import uuid
from sqlalchemy.orm import Session
from app.models.user import User
from app.core.security import hash_password, verify_password

def create_user(db: Session, email: str, password: str) -> User:
    user = User(id=str(uuid.uuid4()), email=email, password_hash=hash_password(password))
    db.add(user)
    db.commit()
    db.refresh(user)
    return user

def get_user_by_email(db: Session, email: str) -> User | None:
    return db.query(User).filter(User.email == email).first()

def authenticate_user(db: Session, email: str, password: str) -> User | None:
    user = get_user_by_email(db, email)
    if user and verify_password(password, user.password_hash):
        return user
    return None

def delete_user(db: Session, user_id: str):
    db.query(User).filter(User.id == user_id).delete()
    db.commit()
```

- [ ] **Step 4: Create auth API routes**

Create `server/app/api/auth.py`:

```python
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.security import create_access_token, create_refresh_token, decode_token
from app.schemas.auth import RegisterRequest, LoginRequest, TokenResponse, RefreshRequest
from app.services.auth_service import create_user, authenticate_user, get_user_by_email, delete_user
from app.api.deps import get_current_user_id

router = APIRouter()

@router.post("/register", response_model=TokenResponse)
def register(req: RegisterRequest, db: Session = Depends(get_db)):
    if get_user_by_email(db, req.email):
        raise HTTPException(status_code=400, detail="Email already registered")
    user = create_user(db, req.email, req.password)
    return TokenResponse(
        access_token=create_access_token(user.id),
        refresh_token=create_refresh_token(user.id),
    )

@router.post("/login", response_model=TokenResponse)
def login(req: LoginRequest, db: Session = Depends(get_db)):
    user = authenticate_user(db, req.email, req.password)
    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    return TokenResponse(
        access_token=create_access_token(user.id),
        refresh_token=create_refresh_token(user.id),
    )

@router.post("/refresh", response_model=TokenResponse)
def refresh(req: RefreshRequest):
    try:
        payload = decode_token(req.refresh_token)
        if payload.get("type") != "refresh":
            raise HTTPException(status_code=401, detail="Invalid token type")
        user_id = payload["sub"]
        return TokenResponse(
            access_token=create_access_token(user_id),
            refresh_token=create_refresh_token(user_id),
        )
    except Exception:
        raise HTTPException(status_code=401, detail="Invalid refresh token")

@router.delete("/account")
def delete_account(user_id: str = Depends(get_current_user_id), db: Session = Depends(get_db)):
    delete_user(db, user_id)
    return {"status": "deleted"}
```

Create `server/app/api/deps.py`:

```python
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from app.core.security import decode_token

security = HTTPBearer()

def get_current_user_id(credentials: HTTPAuthorizationCredentials = Depends(security)) -> str:
    try:
        payload = decode_token(credentials.credentials)
        if payload.get("type") != "access":
            raise HTTPException(status_code=401, detail="Invalid token type")
        return payload["sub"]
    except Exception:
        raise HTTPException(status_code=401, detail="Invalid token")
```

- [ ] **Step 5: Commit**

```bash
git add server/
git commit -m "feat: add auth API with register, login, JWT tokens, and account deletion"
```

---

## Task 4: Sync API

**Files:**
- Create: `server/app/schemas/sync.py`
- Create: `server/app/services/sync_service.py`
- Create: `server/app/api/sync.py`

- [ ] **Step 1: Create sync schemas**

Create `server/app/schemas/sync.py`:

```python
from pydantic import BaseModel
from datetime import datetime
import base64

class SyncRecordIn(BaseModel):
    id: str
    record_type: str
    encrypted_payload: str  # base64
    iv: str  # base64
    updated_at: datetime
    is_deleted: bool = False
    version: int = 1

class SyncRecordOut(BaseModel):
    id: str
    record_type: str
    encrypted_payload: str  # base64
    iv: str  # base64
    updated_at: datetime
    is_deleted: bool
    version: int

class SyncPushRequest(BaseModel):
    records: list[SyncRecordIn]
    device_id: str

class SyncPullResponse(BaseModel):
    records: list[SyncRecordOut]
    server_time: datetime
```

- [ ] **Step 2: Create sync service**

Create `server/app/services/sync_service.py`:

```python
import base64
from datetime import datetime, timezone
from sqlalchemy.orm import Session
from app.models.sync_record import SyncRecord
from app.models.device import Device
from app.schemas.sync import SyncRecordIn, SyncRecordOut

def get_changes_since(db: Session, user_id: str, since: datetime) -> list[SyncRecordOut]:
    records = db.query(SyncRecord).filter(
        SyncRecord.user_id == user_id,
        SyncRecord.updated_at > since,
    ).all()
    return [
        SyncRecordOut(
            id=r.id,
            record_type=r.record_type,
            encrypted_payload=base64.b64encode(r.encrypted_payload).decode(),
            iv=base64.b64encode(r.iv).decode(),
            updated_at=r.updated_at,
            is_deleted=r.is_deleted,
            version=r.version,
        )
        for r in records
    ]

def get_all_records(db: Session, user_id: str) -> list[SyncRecordOut]:
    records = db.query(SyncRecord).filter(
        SyncRecord.user_id == user_id,
        SyncRecord.is_deleted == False,
    ).all()
    return [
        SyncRecordOut(
            id=r.id,
            record_type=r.record_type,
            encrypted_payload=base64.b64encode(r.encrypted_payload).decode(),
            iv=base64.b64encode(r.iv).decode(),
            updated_at=r.updated_at,
            is_deleted=r.is_deleted,
            version=r.version,
        )
        for r in records
    ]

def push_records(db: Session, user_id: str, records: list[SyncRecordIn], device_id: str):
    for rec in records:
        existing = db.query(SyncRecord).filter(
            SyncRecord.id == rec.id,
            SyncRecord.user_id == user_id,
        ).first()

        if existing:
            if rec.version > existing.version or rec.updated_at > existing.updated_at:
                existing.encrypted_payload = base64.b64decode(rec.encrypted_payload)
                existing.iv = base64.b64decode(rec.iv)
                existing.updated_at = rec.updated_at
                existing.is_deleted = rec.is_deleted
                existing.version = rec.version
        else:
            db.add(SyncRecord(
                id=rec.id,
                user_id=user_id,
                record_type=rec.record_type,
                encrypted_payload=base64.b64decode(rec.encrypted_payload),
                iv=base64.b64decode(rec.iv),
                updated_at=rec.updated_at,
                is_deleted=rec.is_deleted,
                version=rec.version,
            ))

    device = db.query(Device).filter(Device.id == device_id, Device.user_id == user_id).first()
    if device:
        device.last_sync_at = datetime.now(timezone.utc)

    db.commit()
```

- [ ] **Step 3: Create sync API routes**

Create `server/app/api/sync.py`:

```python
from datetime import datetime, timezone
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.api.deps import get_current_user_id
from app.schemas.sync import SyncPushRequest, SyncPullResponse
from app.services.sync_service import get_changes_since, get_all_records, push_records

router = APIRouter()

@router.get("", response_model=SyncPullResponse)
def pull_changes(
    since: datetime = Query(...),
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    records = get_changes_since(db, user_id, since)
    return SyncPullResponse(records=records, server_time=datetime.now(timezone.utc))

@router.post("")
def push_changes(
    req: SyncPushRequest,
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    push_records(db, user_id, req.records, req.device_id)
    return {"status": "ok", "synced": len(req.records)}

@router.get("/full", response_model=SyncPullResponse)
def pull_full(
    user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    records = get_all_records(db, user_id)
    return SyncPullResponse(records=records, server_time=datetime.now(timezone.utc))
```

- [ ] **Step 4: Commit**

```bash
git add server/
git commit -m "feat: add sync API with incremental pull, full pull, and push endpoints"
```

---

## Task 5: Devices API

**Files:**
- Create: `server/app/api/devices.py`
- Create: `server/app/schemas/device.py`

- [ ] **Step 1: Create device schemas and API**

Create `server/app/schemas/device.py`:

```python
from pydantic import BaseModel
from datetime import datetime

class DeviceRegister(BaseModel):
    device_name: str
    platform: str

class DeviceOut(BaseModel):
    id: str
    device_name: str
    platform: str
    last_sync_at: datetime | None
    created_at: datetime
```

Create `server/app/api/devices.py`:

```python
import uuid
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.api.deps import get_current_user_id
from app.models.device import Device
from app.schemas.device import DeviceRegister, DeviceOut

router = APIRouter()

@router.get("", response_model=list[DeviceOut])
def list_devices(user_id: str = Depends(get_current_user_id), db: Session = Depends(get_db)):
    devices = db.query(Device).filter(Device.user_id == user_id).all()
    return devices

@router.post("", response_model=DeviceOut)
def register_device(req: DeviceRegister, user_id: str = Depends(get_current_user_id), db: Session = Depends(get_db)):
    device = Device(id=str(uuid.uuid4()), user_id=user_id, device_name=req.device_name, platform=req.platform)
    db.add(device)
    db.commit()
    db.refresh(device)
    return device

@router.delete("/{device_id}")
def remove_device(device_id: str, user_id: str = Depends(get_current_user_id), db: Session = Depends(get_db)):
    device = db.query(Device).filter(Device.id == device_id, Device.user_id == user_id).first()
    if not device:
        raise HTTPException(status_code=404, detail="Device not found")
    db.delete(device)
    db.commit()
    return {"status": "removed"}
```

- [ ] **Step 2: Create Alembic migration**

```bash
cd server
alembic init migrations
```

Update `alembic.ini` sqlalchemy.url and `migrations/env.py` to import models and Base.

```bash
alembic revision --autogenerate -m "initial schema"
alembic upgrade head
```

- [ ] **Step 3: Commit**

```bash
git add server/
git commit -m "feat: add devices API and Alembic migrations"
```

---

## Task 6: Flutter Sync Client

**Files:**
- Create: `lib/features/sync/services/sync_service.dart`
- Create: `lib/features/sync/services/auth_api_client.dart`
- Create: `lib/features/sync/services/sync_api_client.dart`
- Create: `lib/features/sync/providers/sync_provider.dart`
- Create: `lib/features/sync/providers/auth_provider.dart`
- Modify: `lib/data/database/app_database.dart` — add sync_metadata table

- [ ] **Step 1: Create auth API client**

Create `lib/features/sync/services/auth_api_client.dart`:

```dart
import 'package:dio/dio.dart';

class AuthApiClient {
  final Dio _dio;

  AuthApiClient(this._dio);

  Future<Map<String, dynamic>> register(String email, String password) async {
    final response = await _dio.post('/auth/register', data: {'email': email, 'password': password});
    return response.data;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post('/auth/login', data: {'email': email, 'password': password});
    return response.data;
  }

  Future<Map<String, dynamic>> refresh(String refreshToken) async {
    final response = await _dio.post('/auth/refresh', data: {'refresh_token': refreshToken});
    return response.data;
  }

  Future<void> deleteAccount(String accessToken) async {
    await _dio.delete('/auth/account', options: Options(headers: {'Authorization': 'Bearer $accessToken'}));
  }
}
```

- [ ] **Step 2: Create sync API client**

Create `lib/features/sync/services/sync_api_client.dart`:

```dart
import 'package:dio/dio.dart';

class SyncApiClient {
  final Dio _dio;

  SyncApiClient(this._dio);

  Future<Map<String, dynamic>> pullChanges(String since, String accessToken) async {
    final response = await _dio.get('/sync', queryParameters: {'since': since},
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}));
    return response.data;
  }

  Future<Map<String, dynamic>> pullFull(String accessToken) async {
    final response = await _dio.get('/sync/full',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}));
    return response.data;
  }

  Future<void> pushChanges(List<Map<String, dynamic>> records, String deviceId, String accessToken) async {
    await _dio.post('/sync', data: {'records': records, 'device_id': deviceId},
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}));
  }
}
```

- [ ] **Step 3: Create sync service (E2E encryption layer)**

Create `lib/features/sync/services/sync_service.dart`:

```dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:nexterm/core/crypto/crypto_service.dart';
import 'package:nexterm/features/sync/services/sync_api_client.dart';

class SyncService {
  final SyncApiClient _api;
  final CryptoService _crypto;
  Uint8List? _encryptionKey;

  SyncService(this._api, this._crypto);

  void setEncryptionKey(Uint8List key) {
    _encryptionKey = key;
  }

  Map<String, dynamic> encryptRecord(Map<String, dynamic> plainRecord) {
    if (_encryptionKey == null) throw StateError('Encryption key not set');
    final jsonBytes = utf8.encode(jsonEncode(plainRecord));
    final encrypted = _crypto.encrypt(jsonBytes, _encryptionKey!);
    // encrypted = IV (12) + ciphertext + tag (16)
    final iv = encrypted.sublist(0, 12);
    final payload = encrypted.sublist(12);
    return {
      'encrypted_payload': base64Encode(payload),
      'iv': base64Encode(iv),
    };
  }

  Map<String, dynamic> decryptRecord(String encryptedPayloadB64, String ivB64) {
    if (_encryptionKey == null) throw StateError('Encryption key not set');
    final iv = base64Decode(ivB64);
    final payload = base64Decode(encryptedPayloadB64);
    final combined = Uint8List.fromList([...iv, ...payload]);
    final decrypted = _crypto.decrypt(combined, _encryptionKey!);
    return jsonDecode(utf8.decode(decrypted));
  }

  Future<List<Map<String, dynamic>>> pullAndDecrypt(String since, String accessToken) async {
    final response = await _api.pullChanges(since, accessToken);
    final records = (response['records'] as List).cast<Map<String, dynamic>>();
    return records.map((r) {
      final decrypted = decryptRecord(r['encrypted_payload'], r['iv']);
      return {
        ...decrypted,
        'id': r['id'],
        'record_type': r['record_type'],
        'updated_at': r['updated_at'],
        'is_deleted': r['is_deleted'],
        'version': r['version'],
      };
    }).toList();
  }

  Future<void> encryptAndPush(List<Map<String, dynamic>> records, String deviceId, String accessToken) async {
    final encrypted = records.map((r) {
      final encData = encryptRecord(r['data']);
      return {
        'id': r['id'],
        'record_type': r['record_type'],
        ...encData,
        'updated_at': r['updated_at'],
        'is_deleted': r['is_deleted'] ?? false,
        'version': r['version'] ?? 1,
      };
    }).toList();
    await _api.pushChanges(encrypted, deviceId, accessToken);
  }
}
```

- [ ] **Step 4: Create auth provider**

Create `lib/features/sync/providers/auth_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:nexterm/features/sync/services/auth_api_client.dart';

class AuthState {
  final String? accessToken;
  final String? refreshToken;
  final String? email;
  final bool isLoggedIn;

  const AuthState({this.accessToken, this.refreshToken, this.email, this.isLoggedIn = false});

  AuthState copyWith({String? accessToken, String? refreshToken, String? email, bool? isLoggedIn}) {
    return AuthState(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      email: email ?? this.email,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthApiClient _api;
  final FlutterSecureStorage _storage;

  AuthNotifier(this._api, this._storage) : super(const AuthState());

  Future<void> loadSavedAuth() async {
    final accessToken = await _storage.read(key: 'access_token');
    final refreshToken = await _storage.read(key: 'refresh_token');
    final email = await _storage.read(key: 'email');
    if (accessToken != null && refreshToken != null) {
      state = AuthState(accessToken: accessToken, refreshToken: refreshToken, email: email, isLoggedIn: true);
    }
  }

  Future<void> register(String email, String password) async {
    final tokens = await _api.register(email, password);
    await _saveTokens(tokens, email);
  }

  Future<void> login(String email, String password) async {
    final tokens = await _api.login(email, password);
    await _saveTokens(tokens, email);
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    state = const AuthState();
  }

  Future<void> refreshTokens() async {
    if (state.refreshToken == null) return;
    final tokens = await _api.refresh(state.refreshToken!);
    await _saveTokens(tokens, state.email);
  }

  Future<void> _saveTokens(Map<String, dynamic> tokens, String? email) async {
    final access = tokens['access_token'] as String;
    final refresh = tokens['refresh_token'] as String;
    await _storage.write(key: 'access_token', value: access);
    await _storage.write(key: 'refresh_token', value: refresh);
    if (email != null) await _storage.write(key: 'email', value: email);
    state = AuthState(accessToken: access, refreshToken: refresh, email: email, isLoggedIn: true);
  }
}

final authApiClientProvider = Provider<AuthApiClient>((ref) {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.nexterm.app'));
  return AuthApiClient(dio);
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final api = ref.watch(authApiClientProvider);
  const storage = FlutterSecureStorage();
  return AuthNotifier(api, storage);
});
```

- [ ] **Step 5: Commit**

```bash
git add lib/features/sync/
git commit -m "feat: add Flutter sync client with E2E encryption and auth provider"
```

---

## Summary

Phase 4 delivers:

- **6 tasks** covering full backend + client sync
- **FastAPI Server**: Auth (register/login/JWT), Sync (incremental pull/push/full), Devices (list/register/remove)
- **Database**: PostgreSQL with users, sync_records (encrypted blobs), devices tables
- **E2E Encryption**: Client encrypts all data with AES-256-GCM before upload; server only stores ciphertext
- **Sync Protocol**: Timestamp-based incremental sync, last-write-wins conflict resolution
- **Auth**: JWT access + refresh tokens, secure storage on device
- **Offline-first**: Local operations never block on network; sync runs in background

After Phase 4, proceed to **Phase 5: Settings + Polish**.
