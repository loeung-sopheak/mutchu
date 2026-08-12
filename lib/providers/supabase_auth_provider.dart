import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_service.dart';

class SupabaseAuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  // getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  String get userId => _currentUser?.id ?? '';
  String get userName => _currentUser?.userMetadata?['name'] ?? 'Guest';
  String get userEmail => _currentUser?.email ?? '';
  String? get userPhone => _currentUser?.phone;

  SupabaseAuthProvider() {
    _initAuth();
  }

  void _initAuth() {
    // Get current session if exists
    final session = supabase.auth.currentSession;
    if (session != null) {
      _currentUser = session.user;
    }

    // Listen to auth state changes
    supabase.auth.onAuthStateChange.listen((data) {
      _currentUser = data.session?.user;
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null) {
        _currentUser = response.session!.user;
        notifyListeners();
        return true;
      }
      return false;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'phone': phone},
      );

      if (response.session != null) {
        _currentUser = response.session!.user;
        notifyListeners();
        return true;
      }

      // Email confirmation required
      if (response.user != null && response.session == null) {
        _error = 'Please confirm your email before logging in.';
        return false;
      }

      return false;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await supabase.auth.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile({required String name, String? phone}) async {
    _setLoading(true);
    _error = null;

    try {
      // Build attributes
      final Map<String, dynamic> data = {'name': name};

      // Only add phone if it's provided and not empty
      if (phone != null && phone.isNotEmpty) {
        data['phone'] = phone;
      }

      await supabase.auth.updateUser(
        UserAttributes(
          data: data,
          phone: phone, // This updates auth.users phone column
        ),
      );

      // Refresh current user
      _currentUser = supabase.auth.currentUser;
      print('✅ Updated user: ${_currentUser?.phone}');
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      print('❌ Update error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> changePassword(String newPassword) async {
    _setLoading(true);
    _error = null;

    try {
      await supabase.auth.updateUser(UserAttributes(password: newPassword));
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshUser() async {
    _currentUser = supabase.auth.currentUser;
    notifyListeners();
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _error = null;

    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.matcha://login-callback/',
      );
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithApple() async {
    _setLoading(true);
    _error = null;

    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.supabase.matcha://login-callback/',
      );
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _error = null;

    try {
      await supabase.auth.resetPasswordForEmail(email);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> sendPhoneOtp(String phone) async {
    _setLoading(true);
    _error = null;

    try {
      // print('Sending OTP to: $phone');

      // Make sure phone has country code
      if (!phone.startsWith('+')) {
        _error = 'Phone must include country code (e.g., +855...)';
        return false;
      }

      await supabase.auth.signInWithOtp(phone: phone);

      // print('OTP sent successfully');
      return true;
    } on AuthException catch (e) {
      // print('Auth error: ${e.message}');
      _error = e.message;
      return false;
    } catch (e) {
      // print('Error: $e');
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> verifyPhoneOtp(
    String phone,
    String token, {
    OtpType type = OtpType.phoneChange,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await supabase.auth.verifyOTP(
        phone: phone,
        token: token,
        type: type,
      );

      // Force refresh user
      _currentUser = supabase.auth.currentUser;
      // print('Phone verified: ${_currentUser?.phone}');
      // print('Phone confirmed at: ${_currentUser?.phoneConfirmedAt}');
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> checkPhoneExists(String phone) async {
    try {
      final response = await supabase
          .from('auth.users')
          .select('id')
          .eq('phone', phone)
          .maybeSingle();
      return response != null;
    } catch (e) {
      print('Error checking phone: $e');
      return false;
    }
  }

  Future<bool> sendDeleteAccountOtp() async {
    _setLoading(true);
    _error = null;

    try {
      final user = _currentUser;
      if (user?.phone == null) {
        _error = 'No phone number found';
        return false;
      }

      // Send OTP to the phone
      await supabase.auth.signInWithOtp(phone: user!.phone!);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteAccount({String? password, String? otp}) async {
    _setLoading(true);
    _error = null;

    try {
      final user = _currentUser;
      if (user == null) {
        _error = 'No user logged in';
        return false;
      }

      // For email users: verify password
      if (user.email != null && user.email!.isNotEmpty) {
        if (password == null || password.isEmpty) {
          _error = 'Password required';
          return false;
        }
        try {
          await supabase.auth.signInWithPassword(
            email: user.email!,
            password: password,
          );
        } catch (e) {
          _error = 'Incorrect password';
          return false;
        }
      }

      // For phone users: verify OTP
      if (user.phone != null && user.phone!.isNotEmpty) {
        if (otp == null || otp.isEmpty) {
          _error = 'OTP required';
          return false;
        }
        try {
          await supabase.auth.verifyOTP(
            phone: user.phone!,
            token: otp,
            type: OtpType.sms,
          );
        } catch (e) {
          _error = 'Invalid OTP';
          return false;
        }
      }

      // Get function URL from .env
      final functionUrl = dotenv.env['SUPABASE_FUNCTION_URL'];
      if (functionUrl == null || functionUrl.isEmpty) {
        _error = 'Function URL not configured';
        return false;
      }

      final session = supabase.auth.currentSession;
      if (session == null) {
        _error = 'No session found';
        return false;
      }

      // Call the Edge Function
      final response = await http.post(
        Uri.parse(functionUrl),
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        _error = data['error'] ?? 'Failed to delete account';
        return false;
      }

      // Sign out after successful deletion
      await supabase.auth.signOut();
      _currentUser = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  bool get isPhoneVerified {
    return _currentUser?.phoneConfirmedAt != null;
  }
}
