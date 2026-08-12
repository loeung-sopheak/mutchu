// lib/screens/phone_login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_2/widgets/animated_button.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/supabase_auth_provider.dart';
import '../colors.dart';
import 'home_screen.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _otpSent = false;
  String _error = '';

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      setState(() => _error = 'Enter a valid phone number');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final authProvider = Provider.of<SupabaseAuthProvider>(context, listen: false);
      final success = await authProvider.sendPhoneOtp(phone);
      
      if (success) {
        setState(() {
          _otpSent = true;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('📱 OTP sent!'), backgroundColor: Colors.green),
        );
      } else {
        setState(() {
          _isLoading = false;
          _error = authProvider.error ?? 'Failed to send OTP';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty || otp.length < 6) {
      setState(() => _error = 'Enter the 6-digit code');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final authProvider = Provider.of<SupabaseAuthProvider>(context, listen: false);
      final success = await authProvider.verifyPhoneOtp(
        _phoneController.text.trim(),
        otp,
        type: OtpType.sms,
      );
      
      if (success) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged in!'), backgroundColor: Colors.green),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        setState(() {
          _isLoading = false;
          _error = authProvider.error ?? 'Invalid OTP';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.runtimeType.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: MyColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(child:
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Phone Login',
                style: TextStyle(
                  color: MyColors.primary_50, 
                  fontFamily: 'GintoBold',
                  fontSize: 24
                ),
              ),

              const SizedBox(height: 16),

              const Icon(Icons.phone_iphone_rounded, size: 64, color: MyColors.primary),
              
              const SizedBox(height: 16),
              
              const Text(
                'Login with Phone',
                style: TextStyle(
                  fontSize: 24, 
                  fontFamily: 'GintoRegNorm'
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your phone number to receive an OTP',
                style: TextStyle(
                  color: Colors.grey,
                  fontFamily: 'GintoRegNorm'
                ),
              ),
              const SizedBox(height: 32),

              if (_error.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    _error,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontFamily: 'GintoRegNorm'
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                enabled: !_otpSent,
                style: TextStyle(
                    fontFamily: 'GintoRegNorm'
                  ),
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: TextStyle(
                    fontFamily: 'GintoRegNorm',
                    color: Colors.black
                  ),
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              if (_otpSent)
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style: TextStyle(
                    fontFamily: 'GintoRegNorm'
                  ),
                  decoration: InputDecoration(
                    labelText: 'OTP Code',
                    labelStyle: TextStyle(
                      color: MyColors.primary,
                      fontFamily: 'GintoRegNorm'
                    ),
                    prefixIcon: const Icon(Icons.sms),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: MyColors.primary),
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              AnimatedButton(
                onPressed: _isLoading ? null : (_otpSent ? _verifyOtp : _sendOtp),
                startBorderRadius: 10,
                endBorderRadius: 14,
                child: Text(
                  _otpSent ? 'Verify OTP' : 'Send OTP',
                  style: TextStyle(
                    color: MyColors.secondary,
                    fontFamily: 'GintoRegNorm'
                  ),
                )
              ),

              if (_otpSent)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _otpSent = false;
                      _otpController.clear();
                      _error = '';
                    });
                  },
                  child: const Text(
                    'Wrong number? Go back',
                    style: TextStyle(
                      fontFamily: 'GintoRegNorm',
                      color: MyColors.primary_50
                    ),
                  ),
                ),
            ],
          ),
        ),
      )
    );
  }
}