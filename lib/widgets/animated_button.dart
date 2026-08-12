// lib/widgets/animated_button.dart
import 'package:flutter/material.dart';
import '../utils/functions.dart';
import '../colors.dart';

class AnimatedButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color backgroundColor;
  final Color foregroundColor;
  final EdgeInsets padding;
  final double? width;
  final double? height;
  final double endBorderRadius;
  final double startBorderRadius;
  final double endScale;
  final double startScale;
  final Duration duration;
  final Curve curve;
  final bool isLoading;
  final Border? border;

  const AnimatedButton({
    super.key,
    this.onPressed,
    required this.child,
    this.backgroundColor = MyColors.primary,
    this.foregroundColor = Colors.white,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
    this.width,
    this.height,
    this.endBorderRadius = 24,
    this.startBorderRadius = 12,
    this.endScale = 0.95,
    this.startScale = 1.0,
    this.duration = const Duration(milliseconds: 350),
    this.curve = Curves.easeOutBack,
    this.isLoading = false,
    this.border,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: AnimatedContainer(
          duration: widget.duration,
          curve: widget.curve,
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..scale(_isPressed ? widget.endScale : widget.startScale),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.isLoading
                ? darkenColor(widget.backgroundColor, 0.1)
                : (_isPressed
                      ? darkenColor(widget.backgroundColor, 0.1)
                      : widget.backgroundColor),
            borderRadius: BorderRadius.circular(
              _isPressed ? widget.endBorderRadius : widget.startBorderRadius,
            ),
            border: widget.border
          ),
          padding: widget.padding,
          child: widget.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : widget.child,
        ),
      ),
    );
  }
}
