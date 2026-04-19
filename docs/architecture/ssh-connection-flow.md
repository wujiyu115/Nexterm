# SSH Connection Flow

This document describes the full lifecycle of an SSH connection in Nexterm, from the moment the user taps "Connect" to terminal teardown and reconnection.

---

## Direct Connection Flow

```
User taps "Connect" on a host
         │
         ▼
TerminalActions.connectHost(hostId)
         │
         ├─► Look up HostEntity from HostRepository
         ├─► Create tab in TabManager (status: connecting)
         ├─► Create xterm Terminal instance
         │
         ▼
_buildConfig(host)
         │
         ├─► For each jump host ID in host.jumpHosts:
         │     └─► Resolve HostEntity → SSHConnectionConfig
         │
         └─► Resolve SSH key (if authMethod == key)
               └─► SSHConnectionConfig { host, port, username,
                                         authMethod, password?,
                                         privateKeyPem?, passphrase?,
                                         jumpChain: [] }
         │
         ▼
SSHService.connect(sessionId, config)
         │
         ├─► SSHSocket.connect(host, port, timeout: 30s)   ← TCP
         ├─► SSHClient(socket, username, identities, ...)   ← SSH handshake
         └─► client.shell(pty: xterm-256color, 80×24)       ← PTY open
                   │
                   ▼
         SSHActiveSession { sessionId, client, session, jumpClients: [] }
                   │
                   ▼
         tab status → connected
         lastConnected timestamp updated
                   │
         ┌─────────┴──────────┐
         │                    │
         ▼                    ▼
stdout stream             terminal.onOutput
wire to xterm             wire to SSH stdin
Terminal.write()          SSHService.write()
         │
         ▼
Execute startup snippet (if host.startupSnippetId != null)
         │
         ▼
Start auto-start port forwards
```

---

## Jump Host Chain Flow

When a host has one or more jump hosts configured:

```
jumpChain = [jumpHost1Config, jumpHost2Config]   target = finalHostConfig

Step 1 — Connect to outermost jump host:
  SSHSocket.connect(jumpHost1.host, jumpHost1.port)
  jumpClient1 = SSHClient(socket1, username1, ...)     ← stored in jumpClients[]

Step 2 — Tunnel through jumpHost1 to jumpHost2:
  channel = jumpClient1.forwardLocal(jumpHost2.host, jumpHost2.port)
  jumpClient2 = SSHClient(channel, username2, ...)     ← stored in jumpClients[]

Step 3 — Tunnel through jumpHost2 to the final target:
  channel = jumpClient2.forwardLocal(target.host, target.port)
  targetClient = SSHClient(channel, targetUsername, ...)

Step 4 — Open shell on targetClient (same as direct flow)

Teardown order (reversed):
  targetClient.close()
  jumpClient2.close()   ← innermost first
  jumpClient1.close()   ← outermost last
```

---

## Authentication Methods

Nexterm supports three SSH authentication methods, configured per host:

### Password Authentication

```
SSHClient(
  socket,
  username: config.username,
  onPasswordRequest: () => config.password,   // called by dartssh2
)
```

### Public Key Authentication

```
identities = SSHKeyPair.fromPem(privateKeyPem, passphrase?)

SSHClient(
  socket,
  username: config.username,
  identities: identities,
)
```

Private keys are stored AES-256-GCM encrypted in the local SQLite database and decrypted in memory only when a connection is being established.

### Keyboard-Interactive Authentication

```
SSHClient(
  socket,
  username: config.username,
  onUserInfoRequest: (request) =>
      List.filled(request.prompts.length, ''),   // empty responses
)
```

Keyboard-interactive is a placeholder; empty strings are returned for all prompts. Full UI-driven challenge-response is a future enhancement.

---

## Keep-Alive

All SSH clients are created with:

```dart
keepAliveInterval: const Duration(seconds: 30)
```

dartssh2 sends SSH keep-alive packets every 30 seconds to prevent idle connection drops from network equipment and SSH servers with short `ClientAliveInterval` settings.

---

## Reconnection with Exponential Backoff

When the SSH session stream closes (`onDone`), the reconnect service schedules automatic reconnection attempts:

```
Session disconnects (stdout stream onDone)
         │
         ▼
tab status → disconnected
         │
         ▼
ReconnectService.scheduleReconnect(
  maxRetries: 10,
  baseDelay: 1s,
  maxDelay: 30s,
)
         │
         ▼
Attempt loop:
  attempt 0 → wait  1s  (2^0 * 1s)
  attempt 1 → wait  2s  (2^1 * 1s)
  attempt 2 → wait  4s
  attempt 3 → wait  8s
  attempt 4 → wait 16s
  attempt 5+ → wait 30s (capped)
         │
For each attempt:
  ├─► terminal.write("[reconnecting, attempt N in Xs…]")
  ├─► Re-fetch HostEntity (picks up credential changes)
  ├─► SSHService.connect(newSessionId, freshConfig)
  │     ├─► success → tab status → connected
  │     │             Re-wire stdout and stdin
  │     │             terminal.write("[reconnected]")
  │     └─► failure → increment attempt, retry
         │
After 10 failed attempts:
  tab status → error
  terminal.write("[connection lost — gave up reconnecting]")
```

Reconnection can be cancelled at any time by calling `ReconnectService.cancelReconnect(sessionId)`.

---

## Startup Snippet Execution

After a successful connection, if the host has a `startupSnippetId` configured:

```
1. Fetch SnippetEntity by ID from SnippetRepository
2. Build variable defaults map from snippet.variables[].defaultValue
3. VariableParser.substitute(snippet.command, defaults)
     → replace {{varName}} placeholders with default values
4. VariableParser.splitLines(substituted)
     → split on newlines
5. For each line:
     SSHService.write(sessionId, '$line\n')
```

Variable prompting (asking the user for values at connect time) is a planned feature; currently only default values are used.

---

## Auto-Start Port Forwards

After the shell opens, port forwards marked `autoStart = true` for the connected host are started automatically:

```
portForwardRepo.getAutoStartByHostId(hostId)
  └─► For each forward in result:
        client = SSHService.getClient(sessionId)
        switch forward.type:
          case local   → PortForwardService.startLocalForward(client, entity)
          case remote  → PortForwardService.startRemoteForward(client, entity)
          case dynamic → PortForwardService.startDynamicForward(client, entity)
```

Failures on individual forwards are logged but do not abort the connection.

---

## Session Teardown

```
User closes tab / navigates away
         │
         ▼
TerminalActions.disconnectTab(tabId)
         │
         ├─► SSHService.disconnect(sessionId)
         │     ├─► session.close()
         │     ├─► targetClient.close()
         │     └─► jumpClients (reversed): close each
         │
         ├─► TabManager.removeTab(tabId)
         └─► Remove Terminal instance from terminalControllersProvider
```
