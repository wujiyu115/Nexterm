import 'package:nexterm/domain/entities/enums.dart';

class PortForwardEntity {
  final String id;
  final String name;
  final ForwardType type;
  final String hostId;
  final int localPort;
  final String? remoteHost;
  final int? remotePort;
  final String bindAddress;
  final bool autoStart;
  final ForwardStatus status;

  const PortForwardEntity({
    required this.id, required this.name, required this.type, required this.hostId,
    required this.localPort, this.remoteHost, this.remotePort,
    this.bindAddress = '127.0.0.1', this.autoStart = false, this.status = ForwardStatus.inactive,
  });

  PortForwardEntity copyWith({
    String? id, String? name, ForwardType? type, String? hostId, int? localPort,
    String? Function()? remoteHost, int? Function()? remotePort,
    String? bindAddress, bool? autoStart, ForwardStatus? status,
  }) {
    return PortForwardEntity(
      id: id ?? this.id, name: name ?? this.name, type: type ?? this.type,
      hostId: hostId ?? this.hostId, localPort: localPort ?? this.localPort,
      remoteHost: remoteHost != null ? remoteHost() : this.remoteHost,
      remotePort: remotePort != null ? remotePort() : this.remotePort,
      bindAddress: bindAddress ?? this.bindAddress, autoStart: autoStart ?? this.autoStart,
      status: status ?? this.status,
    );
  }

  String get summary => switch (type) {
    ForwardType.local => 'L $localPort → ${remoteHost ?? ""}:${remotePort ?? ""}',
    ForwardType.remote => 'R ${remotePort ?? ""} → $bindAddress:$localPort',
    ForwardType.dynamic => 'D $localPort',
  };
}
