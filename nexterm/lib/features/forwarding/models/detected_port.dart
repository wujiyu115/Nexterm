enum PortCategory { system, user }

class DetectedPort {
  final int port;
  final String bindAddress;
  final String? processName;
  final int? pid;
  final String? commandLine;
  final String protocolGuess;
  final PortCategory category;

  const DetectedPort({
    required this.port,
    required this.bindAddress,
    this.processName,
    this.pid,
    this.commandLine,
    required this.protocolGuess,
    required this.category,
  });

  DetectedPort copyWith({String? commandLine}) {
    return DetectedPort(
      port: port,
      bindAddress: bindAddress,
      processName: processName,
      pid: pid,
      commandLine: commandLine ?? this.commandLine,
      protocolGuess: protocolGuess,
      category: category,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DetectedPort &&
          runtimeType == other.runtimeType &&
          port == other.port &&
          bindAddress == other.bindAddress;

  @override
  int get hashCode => port.hashCode ^ bindAddress.hashCode;
}
