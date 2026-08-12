import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/colors.dart';
import 'package:flutter_application_2/widgets/animated_button.dart';
import 'package:provider/provider.dart';
import '../providers/supabase_auth_provider.dart';
import '../screens/home_screen.dart';
import '../screens/otp_verification_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String _signupMethod = 'email'; // 'email' or 'phone'
  
  final List<Map<String, String>> _countries = [
    {"name": "Cambodia", "code": "+855", "flag": "🇰🇭", "iso": "KH"},
    {"name": "United States", "code": "+1", "flag": "🇺🇸", "iso": "US"},
    {"name": "United Kingdom", "code": "+44", "flag": "🇬🇧", "iso": "GB"},
    {"name": "Australia", "code": "+61", "flag": "🇦🇺", "iso": "AU"},
  ];

  String _selectedCountryIso = "KH";

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<SupabaseAuthProvider>(context, listen: false);
      
      if (_signupMethod == 'email') {
        final email = _emailController.text.trim().toLowerCase();
        final password = _passwordController.text.trim();
        final name = _nameController.text.trim();
        
        final success = await authProvider.signUp(
          email: email,
          password: password,
          name: name,
        );

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else if (!success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.error ?? 'Sign up failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // Phone sign up
        final selectedCountry = _countries
            .firstWhere((c) => c["iso"] == _selectedCountryIso);
        final fullPhoneNumber = "${selectedCountry["code"]}${_phoneController.text.trim()}";
        
        // Navigate to OTP screen
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpVerificationScreen(
                phoneNumber: fullPhoneNumber,
                name: _nameController.text.trim(),
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Sign up error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign up failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 16),
                  
                  Text(
                    'Create Account',
                    style: TextStyle(
                      color: MyColors.primary_50,
                      fontFamily: 'GintoBold',
                      fontSize: 26
                    )
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign up to order your favorite matcha drinks!',
                    style: TextStyle(
                      fontFamily: 'GintoRegNorm',
                      fontSize: 14
                    )
                  ),
                  const SizedBox(height: 32),

                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      labelStyle: TextStyle(
                        fontFamily: 'GintoRegNorm',
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Signup Method Toggle
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _signupMethod = 'email');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _signupMethod == 'email' 
                                    ? Colors.white 
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: _signupMethod == 'email'
                                    ? [
                                        BoxShadow(
                                          color: Colors.grey.shade200,
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  'Email',
                                  style: TextStyle(
                                    color: _signupMethod == 'email'
                                        ? Colors.green[800]
                                        : Colors.grey[600],
                                    fontWeight: _signupMethod == 'email'
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _signupMethod = 'phone');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _signupMethod == 'phone' 
                                    ? Colors.white 
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: _signupMethod == 'phone'
                                    ? [
                                        BoxShadow(
                                          color: Colors.grey.shade200,
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  'Phone',
                                  style: TextStyle(
                                    color: _signupMethod == 'phone'
                                        ? Colors.green[800]
                                        : Colors.grey[600],
                                    fontWeight: _signupMethod == 'phone'
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Email or Phone Field
                  if (_signupMethod == 'email') ...[
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(
                          fontFamily: 'GintoRegNorm',
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                  ] else ...[
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        labelStyle: TextStyle(
                          fontFamily: 'GintoRegNorm',
                          fontSize: 14,
                        ),
                        prefixIcon: Container(
                          padding: const EdgeInsets.only(left: 12, right: 4),
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCountryIso,
                              isDense: true,
                              alignment: Alignment.centerLeft,
                              icon: const Icon(Icons.arrow_drop_down, size: 20),
                              dropdownColor: MyColors.secondary,
                              style: TextStyle(
                                  fontFamily: 'GintoRegNorm',
                                  fontSize: 14,
                                  color: Colors.black
                                ),
                              items: _countries.map((country) {
                                return DropdownMenuItem<String>(
                                  value: country["iso"],
                                  child: Text(
                                    "${country["flag"]} ${country["code"]}",
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedCountryIso = newValue;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        if (value.length < 7) {
                          return 'Enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(
                        fontFamily: 'GintoRegNorm',
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword 
                              ? Icons.visibility_outlined 
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Sign Up Button
                  AnimatedButton(
                    onPressed: _signUp,
                    endBorderRadius: 14,
                    startBorderRadius: 10,
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        color: MyColors.secondary,
                        fontFamily: 'GintoRegNorm'
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(
                          fontFamily: 'GintoRegNorm',
                          fontSize: 12,
                          color: Colors.grey[600]
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Log In',
                          style: TextStyle(
                            color: MyColors.primary,
                            fontFamily: 'GintoBold',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}