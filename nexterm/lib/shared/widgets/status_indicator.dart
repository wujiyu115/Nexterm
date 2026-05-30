import 'package:flutter/material.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';

class StatusIndicator extends StatefulWidget {
  final ConnectionStatus status;
  final double size;
  const StatusIndicator({super.key, required this.status, this.size = 10});

  @override
  State<StatusIndicator> createState() => _StatusIndicatorState();
}

class _StatusIndicatorState extends State<StatusIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.8).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.7, curve: Curves.easeOut)),
    );
    _opacityAnimation = Tween<double>(begin: 0.3, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.7, curve: Curves.easeOut)),
    );
    if (_isOnline) _controller.repeat();
  }

  @override
  void didUpdateWidget(StatusIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isOnline && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!_isOnline && _controller.isAnimating) {
      _controller.stop();
    }
  }

  bool get _isOnline => widget.status == ConnectionStatus.connected;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = switch (widget.status) {
      ConnectionStatus.connected => isDark ? OutdoorColors.darkStatusOnline : OutdoorColors.lightStatusOnline,
      ConnectionStatus.connecting => isDark ? OutdoorColors.darkStatusConnecting : OutdoorColors.lightStatusConnecting,
      ConnectionStatus.error => isDark ? OutdoorColors.darkStatusError : OutdoorColors.lightStatusError,
      ConnectionStatus.disconnected => isDark ? OutdoorColors.darkStatusOffline : OutdoorColors.lightStatusOffline,
    };

    return SizedBox(
      width: widget.size * 2,
      height: widget.size * 2,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_isOnline)
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Opacity(
                      opacity: _opacityAnimation.value,
                      child: Container(
                        width: widget.size,
                        height: widget.size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: OutdoorColors.accent, width: 1),
                        ),
                      ),
                    ),
                  );
                },
              ),
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: _isOnline
                    ? const [BoxShadow(color: OutdoorColors.accentGlow, blurRadius: 8, spreadRadius: 0)]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
