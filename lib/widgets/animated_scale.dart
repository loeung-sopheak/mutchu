import 'package:flutter/material.dart';

class AnimatedScaleWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final FocusNode? focusNode;
  final double endScale;
  final Duration duration;
  final Curve curve;
  final BorderRadius? endBorderRadius;
  final BorderRadius? startBorderRadius;

  const AnimatedScaleWidget({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.focusNode,
    this.endScale = 0.95,
    this.duration = const Duration(milliseconds: 350),
    this.curve = Curves.easeOutBack,
    this.endBorderRadius,
    this.startBorderRadius,
  });

  @override
  State<AnimatedScaleWidget> createState() => _AnimatedScaleWidgetState();
}

class _AnimatedScaleWidgetState extends State<AnimatedScaleWidget> {
  bool _isHolding = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        if (mounted) setState(() => _isHolding = true);
      },
      onTapUp: (_) {
        if (mounted) setState(() => _isHolding = false);
        if (widget.focusNode != null) widget.focusNode!.requestFocus();
        widget.onTap?.call();
      },
      onTapCancel: () {
        if (mounted) setState(() => _isHolding = false);
      },
      onLongPress: widget.onLongPress,
      child: AnimatedContainer(
        duration: widget.duration,
        curve: widget.curve,
        transform: Matrix4.identity()..scale(_isHolding ? widget.endScale : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: _isHolding
              ? (widget.endBorderRadius ?? BorderRadius.zero)
              : (widget.startBorderRadius ?? BorderRadius.zero),
        ),
        child: widget.child,
      ),
    );
  }
}