import 'package:nexterm/domain/entities/enums.dart';

class SSHKeyEntity {
  final String id;
  final String name;
  final KeyType type;
  final String privateKey;
  final String publicKey;
  final String fingerprint;
  final String? passphrase;
  final DateTime createdAt;

  const SSHKeyEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.privateKey,
    required this.publicKey,
    required this.fingerprint,
    this.passphrase,
    required this.createdAt,
  });

  SSHKeyEntity copyWith({
    String? id,
    String? name,
    KeyType? type,
    String? privateKey,
    String? publicKey,
    String? fingerprint,
    String? Function()? passphrase,
    DateTime? createdAt,
  }) {
    return SSHKeyEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      privateKey: privateKey ?? this.privateKey,
      publicKey: publicKey ?? this.publicKey,
      fingerprint: fingerprint ?? this.fingerprint,
      passphrase: passphrase != null ? passphrase() : this.passphrase,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
