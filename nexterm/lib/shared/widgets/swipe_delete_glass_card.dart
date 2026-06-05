import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';
import 'package:nexterm/core/theme/theme_palette.dart';
import 'package:nexterm/shared/widgets/swipe_to_delete_wrapper.dart';

class SwipeDeleteGlassCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback onDelete;
  final SwipeToDeleteController? swipeController;
  final double actionWidth;

  const SwipeDeleteGlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    required this.onDelete,
    this.swipeController,
    this.actionWidth = 72,
  });

  @override
  State<SwipeDeleteGlassCard> createState() => _SwipeDeleteGlassCardState();
}

class _SwipeDeleteGlassCardState extends State<SwipeDeleteGlassCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late double _dragExtent;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _dragExtent = 0;
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    if (_isOpen) widget.swipeController?.onClosed(this);
    _anim.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails _) {
    _dragExtent = _isOpen ? widget.actionWidth : 0;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _dragExtent -= details.primaryDelta!;
    _dragExtent = _dragExtent.clamp(0, widget.actionWidth);
    _anim.value = _dragExtent / widget.actionWidth;
  }

  void _handleDragEnd(DragEndDetails _) {
    if (_anim.value > 0.4) {
      _open();
    } else {
      _close();
    }
  }

  void _open() {
    _anim.animateTo(1.0, curve: Curves.easeOut);
    _isOpen = true;
    widget.swipeController?.onOpened(this, _close);
  }

  void _close() {
    _anim.animateTo(0.0, curve: Curves.easeOut);
    if (_isOpen) {
      _isOpen = false;
      widget.swipeController?.onClosed(this);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).extension<ThemePalette>()!;
    final radius = BorderRadius.circular(OutdoorColors.radiusLg);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: GestureDetector(
        onHorizontalDragStart: _handleDragStart,
        onHorizontalDragUpdate: _handleDragUpdate,
        onHorizontalDragEnd: _handleDragEnd,
        onTap: _isOpen ? _close : null,
        child: AnimatedBuilder(
          animation: _anim,
          builder: (context, _) {
            final progress = _anim.value;
            return ClipRRect(
              borderRadius: radius,
              child: Stack(
                children: [
                  if (progress > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      width: widget.actionWidth,
                      child: Material(
                        color: p.statusError,
                        child: InkWell(
                          onTap: () {
                            _close();
                            widget.onDelete();
                          },
                          child: const Center(
                            child: Icon(Icons.delete_outline, color: Colors.white, size: 24),
                          ),
                        ),
                      ),
                    ),
                  Transform.translate(
                    offset: Offset(-widget.actionWidth * progress, 0),
                    child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isOpen ? _close : widget.onTap,
                          onLongPress: widget.onLongPress,
                          splashColor: p.accentDim,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: p.cardBg,
                              border: Border.all(color: p.glassBorder, width: 0.5),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  p.accent.withValues(alpha: 0.08),
                                  Colors.transparent,
                                  Colors.transparent,
                                  p.accent.withValues(alpha: 0.04),
                                ],
                                stops: const [0.0, 0.4, 0.6, 1.0],
                              ),
                            ),
                            child: widget.child,
                          ),
                        ),
                      ),
                    ),
                  ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
