class CpuMetrics {
  final double usagePercent;
  final int coreCount;

  const CpuMetrics({required this.usagePercent, this.coreCount = 1});
}

class MemoryMetrics {
  final int totalBytes;
  final int usedBytes;
  final int availableBytes;

  const MemoryMetrics({
    required this.totalBytes,
    required this.usedBytes,
    required this.availableBytes,
  });

  double get usagePercent =>
      totalBytes > 0 ? (usedBytes / totalBytes) * 100 : 0;
}

class DiskPartition {
  final String filesystem;
  final String mountPoint;
  final int totalBytes;
  final int usedBytes;
  final int availableBytes;

  const DiskPartition({
    required this.filesystem,
    required this.mountPoint,
    required this.totalBytes,
    required this.usedBytes,
    required this.availableBytes,
  });

  double get usagePercent =>
      totalBytes > 0 ? (usedBytes / totalBytes) * 100 : 0;
}

class NetworkMetrics {
  final int rxBytes;
  final int txBytes;
  final int rxBytesPerSec;
  final int txBytesPerSec;

  const NetworkMetrics({
    required this.rxBytes,
    required this.txBytes,
    this.rxBytesPerSec = 0,
    this.txBytesPerSec = 0,
  });
}

class SystemSnapshot {
  final DateTime timestamp;
  final CpuMetrics cpu;
  final MemoryMetrics memory;
  final List<DiskPartition> disks;
  final NetworkMetrics network;
  final String? osInfo;
  final String? uptime;
  final String? loadAverage;

  const SystemSnapshot({
    required this.timestamp,
    required this.cpu,
    required this.memory,
    required this.disks,
    required this.network,
    this.osInfo,
    this.uptime,
    this.loadAverage,
  });
}
