class SmbConnectionEntity {
  final String id;
  final String name;
  final String host;
  final int port;
  final String shareName;
  final String? username;
  final String? password;
  final String? domain;
  final DateTime? lastConnected;
  final int sortOrder;

  const SmbConnectionEntity({
    required this.id,
    required this.name,
    required this.host,
    this.port = 445,
    required this.shareName,
    this.username,
    this.password,
    this.domain,
    this.lastConnected,
    this.sortOrder = 0,
  });

  String get displayName => name;

  SmbConnectionEntity copyWith({
    String? id,
    String? name,
    String? host,
    int? port,
    String? shareName,
    String? username,
    String? password,
    String? domain,
    DateTime? lastConnected,
    int? sortOrder,
  }) {
    return SmbConnectionEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      host: host ?? this.host,
      port: port ?? this.port,
      shareName: shareName ?? this.shareName,
      username: username ?? this.username,
      password: password ?? this.password,
      domain: domain ?? this.domain,
      lastConnected: lastConnected ?? this.lastConnected,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
