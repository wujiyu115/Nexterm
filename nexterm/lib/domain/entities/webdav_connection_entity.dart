class WebdavConnectionEntity {
  final String id;
  final String name;
  final String url;
  final String? username;
  final String? password;
  final DateTime? lastConnected;
  final int sortOrder;

  const WebdavConnectionEntity({
    required this.id,
    required this.name,
    required this.url,
    this.username,
    this.password,
    this.lastConnected,
    this.sortOrder = 0,
  });

  String get displayName => name;

  WebdavConnectionEntity copyWith({
    String? id,
    String? name,
    String? url,
    String? username,
    String? password,
    DateTime? lastConnected,
    int? sortOrder,
  }) {
    return WebdavConnectionEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      username: username ?? this.username,
      password: password ?? this.password,
      lastConnected: lastConnected ?? this.lastConnected,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
