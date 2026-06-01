import 'package:nexterm/l10n/app_localizations.dart';

enum AuthMethod {
  password,
  key,
  keyboardInteractive;

  String localizedName(AppLocalizations l) => switch (this) {
    password => l.auth_password,
    key => l.auth_key,
    keyboardInteractive => l.auth_keyboardInteractive,
  };
}

enum KeyType {
  ed25519,
  rsa2048,
  rsa4096,
  ecdsa256,
  ecdsa384,
  ecdsa521;

  String get displayName => switch (this) {
    ed25519 => 'Ed25519',
    rsa2048 => 'RSA 2048',
    rsa4096 => 'RSA 4096',
    ecdsa256 => 'ECDSA 256',
    ecdsa384 => 'ECDSA 384',
    ecdsa521 => 'ECDSA 521',
  };
}

enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  error;
}

enum CursorStyle {
  block,
  underline,
  bar;
}

enum ForwardType {
  local,
  remote,
  dynamic;

  String localizedName(AppLocalizations l) => switch (this) {
    local => l.forwarding_local,
    remote => l.forwarding_remote,
    dynamic => l.forwarding_dynamic,
  };

  String get shortLabel => switch (this) {
    local => 'L',
    remote => 'R',
    dynamic => 'D',
  };
}

enum ForwardStatus {
  active,
  inactive,
  error;
}

enum ConnectionType {
  ssh,
  sftp,
  webdav;
}
