import 'dart:async';

import 'package:flutter/material.dart';
import '../utils/functions.dart';

import 'package:flutter_svg/svg.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    checkUser();
  }

  Future<void> checkUser() async {
    // Let the splash screen show for 3 seconds
    await Future.delayed(const Duration(seconds: 3));

    // Safety check to make sure screen is still active
    if (!mounted) return;

    // Trigger the global routing function we built in function.dart
    checkLoggedInAndRoute();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF617B60),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: SvgPicture.asset(
                'assets/icons/Mutchu_Logo.svg',
                width: 100,
                height: 100,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
