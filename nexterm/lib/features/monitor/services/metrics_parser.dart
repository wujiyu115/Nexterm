import '../models/system_metrics.dart';

class MetricsParser {
  int? _prevCpuIdle;
  int? _prevCpuTotal;
  int? _prevRxBytes;
  int? _prevTxBytes;
  DateTime? _prevTimestamp;

  SystemSnapshot? parse(String raw) {
    final sections = _splitSections(raw);
    if (sections.isEmpty) return null;

    final cpu = _parseCpu(sections['CPU'] ?? '');
    final memory = _parseMemory(sections['MEM'] ?? '');
    final disks = _parseDisk(sections['DISK'] ?? '');
    final network = _parseNetwork(sections['NET'] ?? '');
    final osInfo = _parseOsInfo(sections['OS'] ?? '');

    if (cpu == null || memory == null) return null;

    return SystemSnapshot(
      timestamp: DateTime.now(),
      cpu: cpu,
      memory: memory,
      disks: disks,
      network: network ?? const NetworkMetrics(rxBytes: 0, txBytes: 0),
      osInfo: osInfo['os'],
      uptime: osInfo['uptime'],
      loadAverage: osInfo['loadavg'],
    );
  }

  Map<String, String> _splitSections(String raw) {
    final result = <String, String>{};
    final markers = ['CPU', 'MEM', 'DISK', 'NET', 'OS'];

    for (int i = 0; i < markers.length; i++) {
      final start = raw.indexOf('::${markers[i]}::');
      if (start == -1) continue;

      final contentStart = start + markers[i].length + 4;
      int contentEnd = raw.length;

      for (int j = i + 1; j < markers.length; j++) {
        final nextStart = raw.indexOf('::${markers[j]}::', contentStart);
        if (nextStart != -1) {
          contentEnd = nextStart;
          break;
        }
      }

      result[markers[i]] = raw.substring(contentStart, contentEnd).trim();
    }

    return result;
  }

  CpuMetrics? _parseCpu(String section) {
    if (section.isEmpty) return null;

    final line = section.split('\n').first.trim();

    // Linux: cpu  user nice system idle iowait irq softirq steal
    if (line.startsWith('cpu')) {
      final parts = line.split(RegExp(r'\s+')).skip(1).toList();
      if (parts.length < 4) return null;

      final values = parts.map((s) => int.tryParse(s) ?? 0).toList();
      final idle = values[3] + (values.length > 4 ? values[4] : 0);
      final total = values.fold(0, (a, b) => a + b);

      double usage = 0;
      if (_prevCpuIdle != null && _prevCpuTotal != null) {
        final deltaIdle = idle - _prevCpuIdle!;
        final deltaTotal = total - _prevCpuTotal!;
        if (deltaTotal > 0) {
          usage = ((deltaTotal - deltaIdle) / deltaTotal) * 100;
        }
      }

      _prevCpuIdle = idle;
      _prevCpuTotal = total;

      return CpuMetrics(usagePercent: usage.clamp(0, 100));
    }

    // macOS: CPU usage: X% user, Y% sys, Z% idle
    final macMatch = RegExp(r'(\d+\.?\d*)% idle').firstMatch(section);
    if (macMatch != null) {
      final idle = double.tryParse(macMatch.group(1)!) ?? 0;
      return CpuMetrics(usagePercent: (100 - idle).clamp(0, 100));
    }

    return null;
  }

  MemoryMetrics? _parseMemory(String section) {
    if (section.isEmpty) return null;

    // Linux /proc/meminfo
    final lines = section.split('\n');
    int? total, free, available, buffers, cached;

    for (final line in lines) {
      if (line.startsWith('MemTotal:')) {
        total = _parseKbValue(line);
      } else if (line.startsWith('MemFree:')) {
        free = _parseKbValue(line);
      } else if (line.startsWith('MemAvailable:')) {
        available = _parseKbValue(line);
      } else if (line.startsWith('Buffers:')) {
        buffers = _parseKbValue(line);
      } else if (line.startsWith('Cached:')) {
        cached = _parseKbValue(line);
      }
    }

    if (total != null) {
      final totalBytes = total * 1024;
      final availBytes = (available ?? (free! + (buffers ?? 0) + (cached ?? 0))) * 1024;
      final usedBytes = totalBytes - availBytes;
      return MemoryMetrics(
        totalBytes: totalBytes,
        usedBytes: usedBytes,
        availableBytes: availBytes,
      );
    }

    // macOS vm_stat
    final pageSizeMatch = RegExp(r'page size of (\d+)').firstMatch(section);
    final pageSize = pageSizeMatch != null
        ? int.tryParse(pageSizeMatch.group(1)!) ?? 4096
        : 4096;

    int freePages = 0, activePages = 0, inactivePages = 0, wiredPages = 0, compressedPages = 0;
    for (final line in lines) {
      if (line.contains('Pages free:')) {
        freePages = _parseVmStatValue(line);
      } else if (line.contains('Pages active:')) {
        activePages = _parseVmStatValue(line);
      } else if (line.contains('Pages inactive:')) {
        inactivePages = _parseVmStatValue(line);
      } else if (line.contains('Pages wired')) {
        wiredPages = _parseVmStatValue(line);
      } else if (line.contains('Pages occupied by compressor:')) {
        compressedPages = _parseVmStatValue(line);
      }
    }

    if (activePages > 0 || wiredPages > 0) {
      final totalPages = freePages + activePages + inactivePages + wiredPages + compressedPages;
      final usedPages = activePages + wiredPages + compressedPages;
      return MemoryMetrics(
        totalBytes: totalPages * pageSize,
        usedBytes: usedPages * pageSize,
        availableBytes: (freePages + inactivePages) * pageSize,
      );
    }

    return null;
  }

  int _parseKbValue(String line) {
    final match = RegExp(r'(\d+)').firstMatch(line.split(':').last);
    return match != null ? int.tryParse(match.group(1)!) ?? 0 : 0;
  }

  int _parseVmStatValue(String line) {
    final match = RegExp(r'(\d+)').firstMatch(line.split(':').last);
    return match != null ? int.tryParse(match.group(1)!) ?? 0 : 0;
  }

  List<DiskPartition> _parseDisk(String section) {
    if (section.isEmpty) return [];

    final lines = section.split('\n');
    final partitions = <DiskPartition>[];

    for (final line in lines) {
      if (line.startsWith('Filesystem') || line.trim().isEmpty) continue;

      final parts = line.split(RegExp(r'\s+'));
      if (parts.length < 6) continue;

      final fs = parts[0];
      // Skip pseudo filesystems
      if (fs == 'tmpfs' || fs == 'devtmpfs' || fs == 'none' || fs.startsWith('overlay')) continue;

      final totalStr = parts[1];
      final usedStr = parts[2];
      final availStr = parts[3];
      final mountPoint = parts.last;

      // Skip system mounts
      if (mountPoint.startsWith('/snap') ||
          mountPoint.startsWith('/boot/efi') ||
          mountPoint == '/dev' ||
          mountPoint == '/dev/shm') {
        continue;
      }

      final total = int.tryParse(totalStr) ?? 0;
      final used = int.tryParse(usedStr) ?? 0;
      final avail = int.tryParse(availStr) ?? 0;

      if (total <= 0) continue;

      partitions.add(DiskPartition(
        filesystem: fs,
        mountPoint: mountPoint,
        totalBytes: total,
        usedBytes: used,
        availableBytes: avail,
      ));
    }

    return partitions;
  }

  NetworkMetrics? _parseNetwork(String section) {
    if (section.isEmpty) return null;

    final lines = section.split('\n');
    int totalRx = 0, totalTx = 0;

    for (final line in lines) {
      if (line.contains('Inter-') || line.contains('face') || line.trim().isEmpty) continue;
      if (line.contains(' lo:') || line.contains(' lo0:')) continue;

      // Linux: iface: rx_bytes rx_packets ... tx_bytes tx_packets ...
      final colonIdx = line.indexOf(':');
      if (colonIdx == -1) continue;

      final data = line.substring(colonIdx + 1).trim();
      final parts = data.split(RegExp(r'\s+'));
      if (parts.length >= 9) {
        totalRx += int.tryParse(parts[0]) ?? 0;
        totalTx += int.tryParse(parts[8]) ?? 0;
      }
    }

    // macOS netstat -ibn
    if (totalRx == 0 && totalTx == 0) {
      for (final line in lines) {
        if (line.startsWith('Name') || line.trim().isEmpty) continue;
        if (line.startsWith('lo')) continue;

        final parts = line.split(RegExp(r'\s+'));
        if (parts.length >= 7) {
          // Name Mtu Network Address Ipkts Ibytes Opkts Obytes
          totalRx += int.tryParse(parts[5]) ?? 0;
          totalTx += int.tryParse(parts.length > 8 ? parts[8] : parts[6]) ?? 0;
        }
      }
    }

    int rxPerSec = 0, txPerSec = 0;
    final now = DateTime.now();
    if (_prevRxBytes != null && _prevTimestamp != null) {
      final elapsed = now.difference(_prevTimestamp!).inMilliseconds / 1000.0;
      if (elapsed > 0) {
        rxPerSec = ((totalRx - _prevRxBytes!) / elapsed).round().clamp(0, 1 << 30);
        txPerSec = ((totalTx - _prevTxBytes!) / elapsed).round().clamp(0, 1 << 30);
      }
    }
    _prevRxBytes = totalRx;
    _prevTxBytes = totalTx;
    _prevTimestamp = now;

    return NetworkMetrics(
      rxBytes: totalRx,
      txBytes: totalTx,
      rxBytesPerSec: rxPerSec,
      txBytesPerSec: txPerSec,
    );
  }

  Map<String, String?> _parseOsInfo(String section) {
    if (section.isEmpty) return {};

    final lines = section.split('\n').where((l) => l.trim().isNotEmpty).toList();
    String? os, uptime, loadavg;

    if (lines.isNotEmpty) os = lines.first.trim();

    for (final line in lines) {
      if (line.contains('up') && line.contains('load average')) {
        final uptimeMatch = RegExp(r'up\s+(.+?),\s+\d+\s+user').firstMatch(line);
        uptime = uptimeMatch?.group(1)?.trim();
        final loadMatch = RegExp(r'load averages?:\s*(.+)').firstMatch(line);
        loadavg = loadMatch?.group(1)?.trim();
      }
    }

    return {'os': os, 'uptime': uptime, 'loadavg': loadavg};
  }

  void reset() {
    _prevCpuIdle = null;
    _prevCpuTotal = null;
    _prevRxBytes = null;
    _prevTxBytes = null;
    _prevTimestamp = null;
  }
}
