import 'package:nexterm/domain/entities/enums.dart';

class HostEntity {
  final String id;
  final String name;
  final String hostname;
  final int port;
  final String username;
  final AuthMethod authMethod;
  final String? password;
  final String? keyId;
  final String? group;
  final List<String> tags;
  final bool isFavorite;
  final List<String> jumpHosts;
  final String? startupSnippetId;
  final String? startupCommand;
  final DateTime? lastConnected;
  final ConnectionType? lastConnectionType;
  final int sortOrder;

  const HostEntity({
    required this.id,
    required this.name,
    required this.hostname,
    this.port = 22,
    required this.username,
    required this.authMethod,
    this.password,
    this.keyId,
    this.group,
    this.tags = const [],
    this.isFavorite = false,
    this.jumpHosts = const [],
    this.startupSnippetId,
    this.startupCommand,
    this.lastConnected,
    this.lastConnectionType,
    this.sortOrder = 0,
  });

  HostEntity copyWith({
    String? id,
    String? name,
    String? hostname,
    int? port,
    String? username,
    AuthMethod? authMethod,
    String? Function()? password,
    String? Function()? keyId,
    String? Function()? group,
    List<String>? tags,
    bool? isFavorite,
    List<String>? jumpHosts,
    String? Function()? startupSnippetId,
    String? Function()? startupCommand,
    DateTime? Function()? lastConnected,
    ConnectionType? Function()? lastConnectionType,
    int? sortOrder,
  }) {
    return HostEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      hostname: hostname ?? this.hostname,
      port: port ?? this.port,
      username: username ?? this.username,
      authMethod: authMethod ?? this.authMethod,
      password: password != null ? password() : this.password,
      keyId: keyId != null ? keyId() : this.keyId,
      group: group != null ? group() : this.group,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      jumpHosts: jumpHosts ?? this.jumpHosts,
      startupSnippetId: startupSnippetId != null ? startupSnippetId() : this.startupSnippetId,
      startupCommand: startupCommand != null ? startupCommand() : this.startupCommand,
      lastConnected: lastConnected != null ? lastConnected() : this.lastConnected,
      lastConnectionType: lastConnectionType != null ? lastConnectionType() : this.lastConnectionType,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
