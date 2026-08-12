import 'package:flutter/material.dart';
import 'dart:ui';

class PrivacyScreen extends StatefulWidget {
  final Widget child;
  const PrivacyScreen({super.key, required this.child});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> with WidgetsBindingObserver {
  bool _isHidden = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _isHidden = state == AppLifecycleState.paused ||
          state == AppLifecycleState.inactive ||
          state == AppLifecycleState.detached;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        IgnorePointer(
          ignoring: !_isHidden,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeInOut,
            opacity: _isHidden ? 1.0 : 0.0,
            child: Container(
              color: Colors.transparent,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(
                  color: Colors.white.withValues(alpha: _isHidden ? 0.5 : 0.0),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}