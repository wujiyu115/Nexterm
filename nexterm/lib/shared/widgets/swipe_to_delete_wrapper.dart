import 'package:flutter/material.dart';
import 'package:nexterm/core/theme/theme_palette.dart';

class SwipeToDeleteController extends ChangeNotifier {
  VoidCallback? _closeCurrently;
  Object? _currentId;

  void onOpened(Object id, VoidCallback close) {
    if (_currentId != null && _currentId != id) {
      _closeCurrently?.call();
    }
    _currentId = id;
    _closeCurrently = close;
  }

  void onClosed(Object id) {
    if (_currentId == id) {
      _currentId = null;
      _closeCurrently = null;
    }
  }

  void closeAny() {
    _closeCurrently?.call();
    _currentId = null;
    _closeCurrently = null;
  }
}

class SwipeToDeleteWrapper extends StatefulWidget {
  final Widget? child;
  final Widget Function(BuildContext context, double progress)? childBuilder;
  final VoidCallback onDelete;
  final double actionWidth;
  final double borderRadius;
  final SwipeToDeleteController? controller;

  const SwipeToDeleteWrapper({
    super.key,
    this.child,
    this.childBuilder,
    required this.onDelete,
    this.actionWidth = 72,
    this.borderRadius = 0,
    this.controller,
  }) : assert(child != null || childBuilder != null);

  @override
  State<SwipeToDeleteWrapper> createState() => _SwipeToDeleteWrapperState();
}

class _SwipeToDeleteWrapperState extends State<SwipeToDeleteWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late double _dragExtent;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _dragExtent = 0;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    if (_isOpen) {
      widget.controller?.onClosed(this);
    }
    _controller.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    _dragExtent = _isOpen ? widget.actionWidth : 0;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _dragExtent -= details.primaryDelta!;
    _dragExtent = _dragExtent.clamp(0, widget.actionWidth);
    _controller.value = _dragExtent / widget.actionWidth;
  }

  void _handleDragEnd(DragEndDetails details) {
    final shouldOpen = _controller.value > 0.4;
    if (shouldOpen) {
      _open();
    } else {
      _close();
    }
  }

  void _open() {
    _controller.animateTo(1.0, curve: Curves.easeOut);
    _isOpen = true;
    widget.controller?.onOpened(this, _close);
  }

  void _close() {
    _controller.animateTo(0.0, curve: Curves.easeOut);
    if (_isOpen) {
      _isOpen = false;
      widget.controller?.onClosed(this);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).extension<ThemePalette>()!;
    return GestureDetector(
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      onTap: _isOpen ? _close : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Stack(
          children: [
            Positioned.fill(
              child: Row(
                children: [
                  const Spacer(),
                  SizedBox(
                    width: widget.actionWidth,
                    child: Material(
                      color: p.statusError,
                      child: InkWell(
                        onTap: () {
                          _close();
                          widget.onDelete();
                        },
                        child: const Center(
                          child: Icon(
                            Icons.delete_outline,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final progress = _controller.value;
                final content = widget.childBuilder != null
                    ? widget.childBuilder!(context, progress)
                    : widget.child!;
                return Transform.translate(
                  offset: Offset(-widget.actionWidth * progress, 0),
                  child: content,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
