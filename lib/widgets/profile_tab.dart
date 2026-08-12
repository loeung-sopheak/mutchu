import 'package:flutter/material.dart';
import 'package:flutter_application_2/widgets/custom_dialog.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../colors.dart';
import '../providers/supabase_auth_provider.dart';
import '../screens/login_screen.dart';
// import '../screens/order_history_screen.dart';
import '../screens/order_tracking_screen.dart';
import '../screens/payment_screen.dart';
import '../services/supabase_service.dart';
import 'animated_button.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = false;

  String _originalName = '';
  String _originalPhone = '';
  bool _hasChanges = false;

  bool _isPhoneVerified = false;
  bool _isPhoneVerifying = false;
  String _enteredOtp = '';
  bool _hasPhoneChanged = false;

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isChangingPassword = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  final _deletePasswordController = TextEditingController();
  final _deleteOtpController = TextEditingController();
  bool _obscureDeletePassword = true;
  bool _otpSentForDelete = false;
  String _deleteError = '';

  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Passwords do not match!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<SupabaseAuthProvider>(
        context,
        listen: false,
      );

      final success = await authProvider.changePassword(
        _newPasswordController.text.trim(),
      );

      if (success && mounted) {
        setState(() {
          _isChangingPassword = false;
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Failed to change password'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'ready':
        return Colors.teal;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _viewOrderHistory() async {
    final authProvider = Provider.of<SupabaseAuthProvider>(
      context,
      listen: false,
    );
    final orders = await SupabaseService().getOrders(authProvider.userId);

    if (orders.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No orders yet')));
      return;
    }

    showModalBottomSheet(
      backgroundColor: MyColors.primary_50,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Order History',
                  style: TextStyle(
                    fontFamily: 'GintoBold',
                    fontSize: 18,
                    color: MyColors.secondary,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        elevation: 0,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            'Order #${order.orderNumber}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${order.items.length} items • \$${order.total.toStringAsFixed(2)}',
                              ),
                              Text(
                                order.deliveryAddress.fullAddress,
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                order.status,
                              ).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              order.status.toUpperCase(),
                              style: TextStyle(
                                color: _getStatusColor(order.status),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context); // Close bottom sheet
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    OrderTrackingScreen(orderId: order.id),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_checkChanges);
    _phoneController.addListener(_checkChanges);
    _loadUser();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _checkChanges() {
    final currentName = _nameController.text.trim();
    final currentPhone = _phoneController.text.trim();
    setState(() {
      _hasChanges =
          currentName != _originalName || currentPhone != _originalPhone;
      _hasPhoneChanged = currentPhone != _originalPhone;
      if (_hasPhoneChanged) {
        _isPhoneVerified = false; // Reset verification if phone changed
      }
    });
  }

  Future<void> _loadUser() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<SupabaseAuthProvider>(
        context,
        listen: false,
      );
      final user = authProvider.currentUser;

      if (user != null) {
        // print('User ID: ${user.id}');
        // print('Email: ${user.email}');
        // print('Phone: ${user.phone}');
        // print('Phone confirmed: ${user.phoneConfirmedAt}');

        setState(() {
          _originalName = user.userMetadata?['name'] ?? '';
          _originalPhone = user.phone ?? '';
          _nameController.text = _originalName;
          _emailController.text = user.email ?? ''; // empty if phone-only
          _phoneController.text = _originalPhone;
          _isPhoneVerified = user.phoneConfirmedAt != null;
        });
      }
    } catch (e) {
      // print('Error loading user: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ===== UPDATE PROFILE =====
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<SupabaseAuthProvider>(
      context,
      listen: false,
    );
    final user = authProvider.currentUser;

    // Check if we are on email account
    if (user?.email == null || user!.email!.isEmpty) {
      _showSwitchAccountDialog();
      return;
    }

    // If phone changed, we need to verify it
    if (_hasPhoneChanged) {
      await _updateProfileWithPhone();
    } else {
      // Only name changed
      await _updateProfileNameOnly();
    }
  }

  Future<void> _updateProfileNameOnly() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<SupabaseAuthProvider>(
        context,
        listen: false,
      );
      final success = await authProvider.updateProfile(
        name: _nameController.text.trim(),
        phone: null, // don't change phone
      );
      if (success && mounted) {
        _resetAfterSave();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Profile updated!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfileWithPhone() async {
    final newPhone = _phoneController.text.trim();
    if (newPhone.isEmpty || newPhone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid phone number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<SupabaseAuthProvider>(
        context,
        listen: false,
      );

      // Check if phone is already linked to another account
      final exists = await authProvider.checkPhoneExists(newPhone);
      if (exists) {
        setState(() => _isLoading = false);
        _showPhoneAlreadyLinkedDialog();
        return;
      }

      // Update profile with phone
      final success = await authProvider.updateProfile(
        name: _nameController.text.trim(),
        phone: newPhone,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📱 Verification code sent!'),
            backgroundColor: Colors.green,
          ),
        );
        _showOtpDialog();
        setState(() => _isLoading = false);
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Failed to update'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showPhoneAlreadyLinkedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Phone Already Linked'),
        content: const Text(
          'This phone number is already linked to a different account. '
          'You cannot link it to this account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _resetAfterSave() {
    setState(() {
      _isEditing = false;
      _hasChanges = false;
      _hasPhoneChanged = false;
      _originalName = _nameController.text.trim();
      _originalPhone = _phoneController.text.trim();
      _isPhoneVerified = true;
    });
  }

  // ===== OTP FLOW =====
  void _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid phone number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isPhoneVerifying = true);
    try {
      final authProvider = Provider.of<SupabaseAuthProvider>(
        context,
        listen: false,
      );
      final success = await authProvider.updateProfile(
        name: _nameController.text.trim(),
        phone: phone,
      );
      if (success) {
        _showOtpDialog();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📱 OTP sent!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Failed to send OTP'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isPhoneVerifying = false);
    }
  }

  void _showOtpDialog() {
    _enteredOtp = '';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Verify Phone'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the 6-digit code sent to:',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              _phoneController.text.trim(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              maxLength: 6,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 8),
              onChanged: (value) => _enteredOtp = value,
              decoration: InputDecoration(
                hintText: '123456',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '📱 Test OTP: 123456',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isPhoneVerifying = false);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _verifyOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  void _verifyOtp() async {
    if (_enteredOtp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter OTP'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<SupabaseAuthProvider>(
        context,
        listen: false,
      );
      final success = await authProvider.verifyPhoneOtp(
        _phoneController.text.trim(),
        _enteredOtp,
        type: OtpType.phoneChange,
      );
      if (success) {
        // Phone is now linked to the email account!
        setState(() {
          _isPhoneVerified = true;
          _isEditing = false;
          _hasChanges = false;
          _hasPhoneChanged = false;
          _originalName = _nameController.text.trim();
          _originalPhone = _phoneController.text.trim();
        });
        Navigator.pop(context); // close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Phone linked to your account!'),
            backgroundColor: Colors.green,
          ),
        );
        // Reload user to refresh the state
        await _loadUser();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Invalid OTP'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSwitchAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Switch Account'),
        content: const Text(
          'You are currently logged in with phone only. To add a phone to your email account, please sign out and sign in with your email address.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final authProvider = Provider.of<SupabaseAuthProvider>(
                context,
                listen: false,
              );
              await authProvider.signOut();
              if (mounted) {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: 'Logout',
        content: 'Are you sure you want to logout?',
        confirmColor: MyColors.primary,
        onConfirm: () async {
          final authProvider = Provider.of<SupabaseAuthProvider>(
            context,
            listen: false,
          );
          await authProvider.signOut();
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          }
        },
      ),
    );
  }

  Future<void> _sendDeleteOtp(
    void Function(void Function()) setDialogState,
  ) async {
    if (mounted) {
      setDialogState(() => _isLoading = true);
    }
    _deleteError = '';

    try {
      final authProvider = Provider.of<SupabaseAuthProvider>(
        context,
        listen: false,
      );
      final success = await authProvider.sendDeleteAccountOtp();

      if (success) {
        if (mounted) {
          setDialogState(() {
            _otpSentForDelete = true;
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('📱 OTP sent!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          setDialogState(() {
            _isLoading = false;
            _deleteError = authProvider.error ?? 'Failed to send OTP';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setDialogState(() {
          _isLoading = false;
          _deleteError = e.toString();
        });
      }
    }
  }

  Future<void> _deleteAccount(
    void Function(void Function()) setDialogState,
  ) async {
    final authProvider = Provider.of<SupabaseAuthProvider>(
      context,
      listen: false,
    );
    final user = authProvider.currentUser;
    final bool isEmailUser = user?.email != null && user!.email!.isNotEmpty;
    final bool isPhoneUser = user?.phone != null && user!.phone!.isNotEmpty;

    // Validate
    if (isEmailUser) {
      final password = _deletePasswordController.text.trim();
      if (password.isEmpty) {
        if (mounted) {
          setDialogState(() => _deleteError = 'Please enter your password');
        }
        return;
      }
    }

    if (isPhoneUser) {
      if (!_otpSentForDelete) {
        if (mounted) {
          setDialogState(() => _deleteError = 'Please send OTP first');
        }
        return;
      }
      final otp = _deleteOtpController.text.trim();
      if (otp.isEmpty || otp.length < 6) {
        if (mounted) {
          setDialogState(() => _deleteError = 'Please enter the 6-digit OTP');
        }
        return;
      }
    }

    if (mounted) {
      setDialogState(() => _isLoading = true);
    }
    _deleteError = '';

    try {
      final success = await authProvider.deleteAccount(
        password: isEmailUser ? _deletePasswordController.text.trim() : null,
        otp: isPhoneUser ? _deleteOtpController.text.trim() : null,
      );

      if (success) {
        if (mounted) {
          Navigator.pop(context);
          _deletePasswordController.clear();
          _deleteOtpController.clear();
          _otpSentForDelete = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account deleted'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      } else {
        if (mounted) {
          setDialogState(() {
            _isLoading = false;
            _deleteError = authProvider.error ?? 'Failed to delete account';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setDialogState(() {
          _isLoading = false;
          _deleteError = e.toString();
        });
      }
    }
  }

  void _showDeleteAccountDialog() {
    final authProvider = Provider.of<SupabaseAuthProvider>(
      context,
      listen: false,
    );
    final user = authProvider.currentUser;
    final bool isEmailUser = user?.email != null && user!.email!.isNotEmpty;
    final bool isPhoneUser = user?.phone != null && user!.phone!.isNotEmpty;

    // Reset states
    _deletePasswordController.clear();
    _deleteOtpController.clear();
    _otpSentForDelete = false;
    _deleteError = '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Delete Account'),
            content: SizedBox(
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '⚠️ This action cannot be undone!',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'All your data, orders, and preferences will be permanently deleted.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),

                  // Email user: password field
                  if (isEmailUser) ...[
                    const Text(
                      'Enter your password to confirm:',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _deletePasswordController,
                      obscureText: _obscureDeletePassword,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureDeletePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(() {
                            _obscureDeletePassword = !_obscureDeletePassword;
                          }),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],

                  // Phone user: OTP flow
                  if (isPhoneUser) ...[
                    const Text(
                      'Verify your phone to delete:',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    if (!_otpSentForDelete) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () => _sendDeleteOtp(setDialogState),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MyColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Send OTP'),
                        ),
                      ),
                    ],
                    if (_otpSentForDelete) ...[
                      const Text(
                        'Enter 6-digit OTP:',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _deleteOtpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: InputDecoration(
                          hintText: '123456',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '📱 Test OTP: 123456',
                        style: TextStyle(color: Colors.grey[500], fontSize: 11),
                      ),
                    ],
                  ],

                  if (_deleteError.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _deleteError,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deletePasswordController.clear();
                  _deleteOtpController.clear();
                  _deleteError = '';
                  _otpSentForDelete = false;
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => _deleteAccount(setDialogState),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delete Forever'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<SupabaseAuthProvider>(context);
    final user = authProvider.currentUser;
    final bool hasEmail = user?.email != null && user!.email!.isNotEmpty;
    
    return Scaffold(
      backgroundColor: MyColors.primary,
      appBar: AppBar(
        backgroundColor: MyColors.secondary,
        elevation: 0,
        title: Text(
          'My Profile',
          style: TextStyle(
            color: MyColors.primary,
            fontFamily: 'GintoBold',
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: MyColors.primary),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                  _originalName = _nameController.text.trim();
                  _originalPhone = _phoneController.text.trim();
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileAvatar(),
            const SizedBox(height: 16),

            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        icon: Icons.person_outline,
                        enabled: _isEditing,
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Enter name' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email_outlined,
                        enabled: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'No email set';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        icon: Icons.phone_outlined,
                        enabled: _isEditing,
                        keyboardType: TextInputType.phone,
                        suffixWidget: _isEditing
                            ? (_isPhoneVerified
                                  ? const Icon(
                                      Icons.verified,
                                      color: Colors.green,
                                      size: 20,
                                    )
                                  : IconButton(
                                      icon: _isPhoneVerifying
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.verified_outlined,
                                              color: Colors.grey,
                                            ),
                                      onPressed: _isPhoneVerifying
                                          ? null
                                          : _sendOtp,
                                    ))
                            : null,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter phone number';
                          }
                          if (value.length < 10) {
                            return 'Enter a valid phone number';
                          }
                          return null;
                        },
                      ),
                      if (_hasChanges && _isEditing) ...[
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: AnimatedButton(
                                onPressed: _updateProfile,
                                backgroundColor: MyColors.primary,
                                endBorderRadius: 12,
                                startBorderRadius: 8,
                                child: const Text(
                                  'Save Changes',
                                  style: TextStyle(
                                    fontFamily: 'GintoRegNorm',
                                    fontSize: 12,
                                    color: MyColors.secondary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AnimatedButton(
                                onPressed: () {
                                  setState(() {
                                    _isEditing = false;
                                    _hasChanges = false;
                                    _nameController.text = _originalName;
                                    _phoneController.text = _originalPhone;
                                  });
                                },
                                backgroundColor: Colors.grey.withValues(
                                  alpha: 0.5,
                                ),
                                foregroundColor: Colors.grey,
                                startBorderRadius: 8,
                                endBorderRadius: 12,
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontFamily: 'GintoRegNorm',
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ===== Change Password (only for email accounts) =====
            if (hasEmail) ...[
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () => setState(
                          () => _isChangingPassword = !_isChangingPassword,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.lock_outline,
                              color: MyColors.primary,
                              size: 18,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Change Password',
                              style: TextStyle(
                                fontFamily: 'GintoRegNorm',
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              _isChangingPassword
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                      if (_isChangingPassword) ...[
                        const Divider(height: 24),
                        _buildPasswordField(
                          controller: _currentPasswordController,
                          label: 'Current Password',
                          obscureText: _obscureCurrentPassword,
                          onToggle: () => setState(
                            () => _obscureCurrentPassword =
                                !_obscureCurrentPassword,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildPasswordField(
                          controller: _newPasswordController,
                          label: 'New Password',
                          obscureText: _obscureNewPassword,
                          onToggle: () => setState(
                            () => _obscureNewPassword = !_obscureNewPassword,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildPasswordField(
                          controller: _confirmPasswordController,
                          label: 'Confirm New Password',
                          obscureText: _obscureConfirmPassword,
                          onToggle: () => setState(
                            () => _obscureConfirmPassword =
                                !_obscureConfirmPassword,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _changePassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: MyColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Update Password',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
            ],

            // ===== Order History =====
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: _viewOrderHistory,
                borderRadius: BorderRadius.circular(16),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.history, color: MyColors.primary, size: 18),
                      SizedBox(width: 12),
                      Text(
                        'Order History',
                        style: TextStyle(
                          fontFamily: 'GintoRegNorm',
                          fontSize: 14,
                        ),
                      ),
                      Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),

            // ===== Payment Methods =====
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PaymentScreen()),
                ),
                borderRadius: BorderRadius.circular(16),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.payment, color: MyColors.primary, size: 18),
                      SizedBox(width: 12),
                      Text(
                        'Payment Methods',
                        style: TextStyle(
                          fontFamily: 'GintoRegNorm',
                          fontSize: 14,
                        ),
                      ),
                      Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Add this after Logout button
            const SizedBox(height: 6),

            // ===== Delete Account =====
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: _showDeleteAccountDialog,
                borderRadius: BorderRadius.circular(16),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.delete_forever, color: Colors.red, size: 18),
                      SizedBox(width: 12),
                      Text(
                        'Delete Account',
                        style: TextStyle(
                          color: Colors.red,
                          fontFamily: 'GintoRegNorm',
                          fontSize: 14,
                        ),
                      ),
                      Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildProfileAvatar() {
  return Stack(
    children: [
      Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          shape: BoxShape.circle,
          border: Border.all(color: MyColors.primary, width: 3),
        ),
        child: const Icon(Icons.person, size: 50, color: Colors.grey),
      ),
      Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: MyColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
        ),
      ),
    ],
  );
}

Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  double iconSize = 18,
  bool enabled = true,
  TextInputType? keyboardType,
  String? Function(String?)? validator,
  Widget? suffixWidget,
}) {
  return TextFormField(
    style: TextStyle(fontFamily: 'GintoRegNorm', fontSize: 12),
    controller: controller,
    enabled: enabled,
    keyboardType: keyboardType,
    validator: validator,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        fontFamily: 'GintoRegNorm',
        fontSize: 12,
        color: MyColors.primary,
      ),
      prefixIcon: Icon(icon, color: Colors.grey[400], size: iconSize),
      suffixIcon: suffixWidget,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: MyColors.primary),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}

Widget _buildPasswordField({
  required TextEditingController controller,
  required String label,
  required bool obscureText,
  required VoidCallback onToggle,
}) {
  return TextFormField(
    style: TextStyle(fontFamily: 'GintoRegNorm', fontSize: 12),
    controller: controller,
    obscureText: obscureText,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        fontFamily: 'Ginto',
        fontSize: 12,
        color: MyColors.primary,
      ),
      prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
      suffixIcon: IconButton(
        icon: Icon(
          obscureText ? Icons.visibility_off : Icons.visibility,
          color: Colors.grey,
        ),
        onPressed: onToggle,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: MyColors.primary),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}
