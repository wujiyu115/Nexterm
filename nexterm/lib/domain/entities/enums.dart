enum AuthMethod {
  password,
  key,
  keyboardInteractive;

  String get displayName => switch (this) {
    password => '密码认证',
    key => '密钥认证',
    keyboardInteractive => '键盘交互',
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
