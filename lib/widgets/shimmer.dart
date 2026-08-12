// lib/widgets/shimmer.dart
import 'package:flutter/material.dart';
import 'dart:ui';

class Shimmer extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const Shimmer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);  // ← Smooth reverse
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,  // ← Smooth fade transition
      child: ShaderMask(
        shaderCallback: (bounds) {
          return LinearGradient(
            colors: const [
              Color(0xFFE0E0E0),
              Color.fromARGB(255, 151, 174, 153),
              Color(0xFFE0E0E0),
            ],
            stops: const [0.0, 0.5, 1.0],
            begin: Alignment(-1.0 + _controller.value * 2, -1.0),
            end: Alignment(1.0 + _controller.value * 2, 1.0),
          ).createShader(bounds);
        },
        blendMode: BlendMode.srcATop,
        child: widget.child,
      ),
    );
  }
}