import 'package:flutter/material.dart';

/// Wraps the currently displayed screen and gives every navigation change —
/// whether triggered by tapping a back button/row, or by an iOS-style
/// edge-swipe — a smooth sliding transition instead of an instant cut.
///
/// [child] must carry a [Key] that's unique per screen "instance" (the
/// existing `ValueKey('vehicle-$id')` style keys already used around the
/// app work well) so this widget can tell a genuine navigation change apart
/// from an in-place rebuild of the same screen.
///
/// [behind] is what the edge-swipe should reveal while dragging — the
/// screen [onBack] would land on. Both are optional; when either is null,
/// the edge-swipe gesture is simply not attached.
class ScreenTransition extends StatefulWidget {
  final Widget child;
  final Widget? behind;
  final VoidCallback? onBack;

  /// True when this build's [child] is a "back" navigation relative to the
  /// previous build (e.g. the user tapped a back chevron) — flips the slide
  /// direction for the automatic transition. Ignored while a drag is live.
  final bool isBack;

  const ScreenTransition({super.key, required this.child, this.behind, this.onBack, this.isBack = false});

  @override
  State<ScreenTransition> createState() => _ScreenTransitionState();
}

class _ScreenTransitionState extends State<ScreenTransition> with SingleTickerProviderStateMixin {
  static const _edgeWidth = 36.0;
  static const _commitFraction = 0.35;
  static const _flingVelocity = 600.0;

  late final AnimationController _controller;
  Widget? _from;
  Widget? _to;
  bool _forward = false;
  bool _dragTracking = false;
  bool _swipeCommitting = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, value: 0);
  }

  @override
  void didUpdateWidget(ScreenTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child.key == widget.child.key) return;

    if (_swipeCommitting) {
      // The edge-swipe already animated this exact transition to completion;
      // this rebuild is just the route catching up. Settle instantly.
      _swipeCommitting = false;
      _controller.value = 0;
      _from = null;
      _to = null;
      return;
    }

    _from = oldWidget.child;
    _to = widget.child;
    _forward = !widget.isBack;
    _controller.value = 0;
    _controller.animateTo(1, duration: const Duration(milliseconds: 340), curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canSwipe => widget.onBack != null && widget.behind != null;

  void _onDragStart(DragStartDetails details) {
    _dragTracking = _canSwipe && details.globalPosition.dx <= _edgeWidth;
    if (_dragTracking) {
      _controller.stop();
      _from = widget.child;
      _to = widget.behind;
      _forward = false;
      _controller.value = 0;
    }
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_dragTracking) return;
    final width = MediaQuery.of(context).size.width;
    if (width <= 0) return;
    _controller.value = (_controller.value + details.delta.dx / width).clamp(0.0, 1.0);
  }

  void _onDragEnd(DragEndDetails details) {
    if (!_dragTracking) return;
    _dragTracking = false;
    final velocity = details.primaryVelocity ?? 0;
    final shouldCommit = _controller.value > _commitFraction || velocity > _flingVelocity;
    if (shouldCommit) {
      _swipeCommitting = true;
      _controller
          .animateTo(1, duration: const Duration(milliseconds: 220), curve: Curves.easeOut)
          .then((_) => widget.onBack?.call());
    } else {
      _controller.animateTo(0, duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_from == null || _to == null || (_controller.value == 0 && !_dragTracking)) {
          return widget.child;
        }
        final width = MediaQuery.of(context).size.width;
        final t = _controller.value;
        final slideDx = _forward ? (1 - t) * width : t * width;
        final sliding = _forward ? _to! : _from!;
        final static_ = _forward ? _from! : _to!;
        return Stack(
          children: [
            static_,
            Transform.translate(offset: Offset(slideDx, 0), child: sliding),
          ],
        );
      },
    );

    if (!_canSwipe) return content;

    return GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: content,
    );
  }
}
