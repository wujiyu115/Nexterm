# Nexterm — System Architecture Overview

This document describes the high-level architecture of the Nexterm system, covering the major components and how they interact.

---

## System Diagram

```
┌────────────────────────────────────────────────────────────────┐
│                      Mobile Client (Flutter)                   │
│                                                                │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────┐  │
│  │ terminal │  │  hosts   │  │  keys    │  │   settings   │  │
│  │ feature  │  │  feature │  │  feature │  │   feature    │  │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └──────┬───────┘  │
│       │              │              │                │          │
│  ┌────▼──────────────▼──────────────▼────────────────▼──────┐  │
│  │              Riverpod Provider Layer                      │  │
│  └────────────────────────┬──────────────────────────────────┘  │
│                           │                                    │
│  ┌────────────────────────▼──────────────────────────────────┐  │
│  │                   Domain Layer                             │  │
│  │         (Entities + Repository Interfaces)                 │  │
│  └────────────────────────┬──────────────────────────────────┘  │
│                           │                                    │
│  ┌────────────────────────▼──────────────────────────────────┐  │
│  │                    Data Layer                              │  │
│  │              Drift / SQLite (local DB)                     │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                   Core Layer                               │  │
│  │         CryptoService · AppRouter · AppTheme               │  │
│  └───────────────────────────────────────────────────────────┘  │
└──────────────────────────┬──┬──────────────────────────────────┘
                           │  │
              SSH (port 22)│  │HTTPS (REST API)
                           │  │
           ┌───────────────┘  └────────────────────┐
           │                                        │
           ▼                                        ▼
   ┌───────────────┐                    ┌───────────────────────┐
   │  SSH Server   │                    │   FastAPI Sync Server  │
   │  (any host)   │                    │                        │
   └───────────────┘                    │  /api/v1/auth          │
                                        │  /api/v1/sync          │
                                        │  /api/v1/devices       │
                                        └───────────┬───────────┘
                                                    │
                                                    ▼
                                        ┌───────────────────────┐
                                        │      PostgreSQL        │
                                        │                        │
                                        │  users                 │
                                        │  sync_records          │
                                        │  devices               │
                                        └───────────────────────┘
```

---

## Module Dependency Graph

```
features/terminal  ──► SSHService, ReconnectService, PortForwardService
features/hosts     ──► HostRepository (domain)
features/keys      ──► SSHKeyRepository (domain)
features/snippets  ──► SnippetRepository (domain)
features/forwarding──► PortForwardRepository (domain), PortForwardService
features/sftp      ──► SftpService (wraps dartssh2 SftpClient)
features/sync      ──► SyncApiClient, SyncService, CryptoService
features/settings  ──► BiometricService, RecoveryService, DataExportService

data/repositories  ──► domain/repositories (implements interfaces)
                   ──► data/database (Drift DAOs)

core/crypto        ──► pointycastle (AES-256-GCM, PBKDF2)
core/router        ──► go_router
core/theme         ──► Flutter Material

Legend: A ──► B  means A depends on B
```

---

## Data Flow Overview

### Local Read Path

```
UI Widget
  └─► Riverpod Provider (watches stream)
        └─► Repository Interface (domain)
              └─► Repository Impl (data)
                    └─► Drift DAO
                          └─► SQLite (on-device)
```

### Local Write Path

```
UI Widget (user action)
  └─► Riverpod Provider (calls method)
        └─► Repository Impl
              └─► Drift DAO (INSERT / UPDATE / DELETE)
                    └─► SQLite
                          └─► Riverpod stream emits new state
                                └─► UI rebuilds
```

### SSH Connection Path

```
User taps "Connect"
  └─► TerminalActions.connectHost()
        ├─► Resolve HostEntity from HostRepository
        ├─► Resolve SSHKeyEntity (if key auth)
        ├─► Build SSHConnectionConfig (+ jump chain)
        ├─► SSHService.connect()  ──► dartssh2 ──► SSH Server
        ├─► Wire stdout stream ──► xterm Terminal widget
        ├─► Execute startup snippet (if configured)
        └─► Start auto-start port forwards
```

### Sync Path

```
User initiates sync
  └─► SyncService.pullAndDecrypt(since, token)
        ├─► SyncApiClient.pullChanges()  ──► GET /api/v1/sync?since=...
        │     └─► FastAPI  ──► PostgreSQL (query sync_records)
        └─► Decrypt each record with AES-256-GCM key (client-side)
              └─► Merge into local SQLite

User data changes
  └─► SyncService.encryptAndPush(records, deviceId, token)
        ├─► Encrypt each record with AES-256-GCM key (client-side)
        └─► SyncApiClient.pushChanges()  ──► POST /api/v1/sync
              └─► FastAPI  ──► PostgreSQL (upsert sync_records)
```

---

## Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| **Clean Architecture layers** | Isolates UI from data details; enables in-memory DB for tests |
| **Riverpod 2 + code generation** | Compile-time safe providers; auto-dispose prevents memory leaks |
| **Drift (SQLite)** | Type-safe SQL; reactive streams; supports in-memory mode for tests |
| **dartssh2** | Pure Dart SSH2 implementation; works on iOS and Android without native plugins |
| **End-to-end encryption** | Server stores only ciphertext; even a compromised server leaks nothing |
| **Offline-first sync** | App fully functional without network; sync is additive, not blocking |
| **Exponential backoff reconnect** | Avoids thundering-herd against transient network failures |
