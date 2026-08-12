// lib/utils/functions.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/home_screen.dart';
import '../screens/login_signup_screen.dart';

// Global key used by MaterialApp to navigate without a local BuildContext
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Checks if the user is logged in and replaces the splash screen with a smooth fade.
Future<void> checkLoggedInAndRoute() async {
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('logged_in') ?? false;

  // Decide which screen to show
  final Widget targetPage = isLoggedIn ? const HomeScreen() : const LoginSignUpScreen();

  // Route with a custom fade transition
  navigatorKey.currentState?.pushReplacement(
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 800),
      reverseTransitionDuration: const Duration(milliseconds: 800),
      pageBuilder: (context, animation, secondaryAnimation) => targetPage,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  );
}

/// Updates the login state in local storage.
Future<void> setLoggedInStatus(bool status) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('logged_in', status);
}

Color darkenColor(Color color, [double amount = 0.2]) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
}