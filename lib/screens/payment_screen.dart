// lib/screens/payment_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../providers/cart_provider.dart';
import '../providers/supabase_auth_provider.dart';
import '../services/supabase_service.dart';
import '../models/payment_model.dart';
import '../colors.dart';
import 'order_tracking_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'credit_card';
  bool _isProcessing = false;
  
  final _cardNumberController = TextEditingController();
  final _cardholderNameController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  
  final _cashAmountController = TextEditingController();
  
  List<PaymentMethod> _savedCards = [];
  bool _showNewCardForm = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCards();
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardholderNameController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _cashAmountController.dispose();
    super.dispose();
  }

  void _loadSavedCards() {
    // In a real app, load from database
    _savedCards = [
      PaymentMethod(
        id: '1',
        type: 'credit_card',
        last4: '4242',
        cardholderName: 'John Doe',
        expiryDate: '12/25',
        isDefault: true,
        brand: 'Visa',
      ),
      PaymentMethod(
        id: '2',
        type: 'credit_card',
        last4: '8888',
        cardholderName: 'Jane Smith',
        expiryDate: '06/26',
        isDefault: false,
        brand: 'Mastercard',
      ),
    ];
  }

  Future<void> _processPayment() async {
  final cartProvider = Provider.of<CartProvider>(context, listen: false);
  final authProvider = Provider.of<SupabaseAuthProvider>(context, listen: false);
  final service = SupabaseService();
  
  if (cartProvider.items.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('❌ Your cart is empty!'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  setState(() => _isProcessing = true);

  try {
    // Create a default address (or let user input)
    final address = Address(
      street: '123 Main St',
      city: 'Phnom Penh',
      state: 'Phnom Penh',
      zipCode: '12000',
      country: 'Cambodia',
      apartment: null,
      phone: authProvider.userPhone,
    );
    
    // Generate order number
    final orderNumber = 'ORD-${DateTime.now().millisecondsSinceEpoch}';
    
    // Place order and get order ID
    final orderId = await service.createOrder(
      userId: authProvider.userId,
      orderNumber: orderNumber,
      items: cartProvider.items,
      subtotal: cartProvider.subtotal,
      deliveryFee: cartProvider.deliveryFee,
      total: cartProvider.total,
      paymentMethod: _selectedMethod,
      address: address,
      notes: null,
    );
    
    // Clear local cart
    cartProvider.clearCart();
    
    if (mounted) {
      // Show success dialog with Track Order button
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Payment Successful! 🎉'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Order #$orderNumber',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Total: \$${cartProvider.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: MyColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Paid with: ${_selectedMethod.replaceAll('_', ' ').toUpperCase()}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderTrackingScreen(
                      orderId: orderId, // ← Pass the order ID here
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Track Order'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to cart
              },
              child: const Text('Continue Shopping'),
            ),
          ],
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment failed: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    if (mounted) setState(() => _isProcessing = false);
  }
}


  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final total = cartProvider.total;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Payment',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ===== Order Summary =====
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order Summary',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Consumer<CartProvider>(
                          builder: (context, cartProvider, child) {
                            return Text(
                              '${cartProvider.items.length} items',
                              style: TextStyle(color: Colors.grey),
                            );
                          },
                        )
                      ],
                    ),
                    const Divider(height: 16),
                    _buildSummaryRow('Subtotal', '\$${cartProvider.subtotal.toStringAsFixed(2)}'),
                    _buildSummaryRow('Delivery Fee', '\$${cartProvider.deliveryFee.toStringAsFixed(2)}'),
                    const Divider(height: 16),
                    _buildSummaryRow(
                      'Total',
                      '\$${total.toStringAsFixed(2)}',
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ===== Payment Methods =====
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Method',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Credit Card
                    _buildPaymentOption(
                      icon: Icons.credit_card,
                      title: 'Credit Card',
                      subtitle: 'Visa, Mastercard, Amex',
                      isSelected: _selectedMethod == 'credit_card',
                      onTap: () {
                        setState(() {
                          _selectedMethod = 'credit_card';
                          _showNewCardForm = true;
                        });
                      },
                    ),
                    
                    // PayPal
                    _buildPaymentOption(
                      icon: Icons.payments,
                      title: 'PayPal',
                      subtitle: 'Pay with your PayPal account',
                      isSelected: _selectedMethod == 'paypal',
                      onTap: () {
                        setState(() {
                          _selectedMethod = 'paypal';
                          _showNewCardForm = false;
                        });
                      },
                    ),
                    
                    // Apple Pay
                    if (Theme.of(context).platform == TargetPlatform.iOS)
                      _buildPaymentOption(
                        icon: Icons.apple,
                        title: 'Apple Pay',
                        subtitle: 'Pay with Apple Pay',
                        isSelected: _selectedMethod == 'apple_pay',
                        onTap: () {
                          setState(() {
                            _selectedMethod = 'apple_pay';
                            _showNewCardForm = false;
                          });
                        },
                      ),
                    
                    // Cash
                    _buildPaymentOption(
                      icon: Icons.money,
                      title: 'Cash on Delivery',
                      subtitle: 'Pay when you receive your order',
                      isSelected: _selectedMethod == 'cash',
                      onTap: () {
                        setState(() {
                          _selectedMethod = 'cash';
                          _showNewCardForm = false;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ===== Card Details Form =====
            if (_selectedMethod == 'credit_card' && _showNewCardForm) ...[
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Saved Cards
                      if (_savedCards.isNotEmpty) ...[
                        const Text(
                          'Saved Cards',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._savedCards.map((card) => _buildSavedCard(card)),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                      ],
                      
                      const Text(
                        'New Card',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      _buildCardField(
                        controller: _cardNumberController,
                        label: 'Card Number',
                        hint: '1234 5678 9012 3456',
                        icon: Icons.credit_card,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      
                      _buildCardField(
                        controller: _cardholderNameController,
                        label: 'Cardholder Name',
                        hint: 'John Doe',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _buildCardField(
                              controller: _expiryDateController,
                              label: 'Expiry Date',
                              hint: 'MM/YY',
                              icon: Icons.calendar_today,
                              keyboardType: TextInputType.datetime,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildCardField(
                              controller: _cvvController,
                              label: 'CVV',
                              hint: '123',
                              icon: Icons.security,
                              keyboardType: TextInputType.number,
                              obscureText: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // ===== Pay Button =====
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Pay \$${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 14,
              color: isTotal ? MyColors.primary : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? MyColors.primary.withValues(alpha: 0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? MyColors.primary : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? MyColors.primary : Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? MyColors.primary : Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: MyColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedCard(PaymentMethod card) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: card.isDefault ? MyColors.primary.withValues(alpha: 0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: card.isDefault ? MyColors.primary : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            card.brand == 'Visa' ? Icons.credit_card : Icons.payment,
            color: MyColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${card.brand} •••• ${card.last4}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Expires ${card.expiryDate}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          if (card.isDefault)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: MyColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Default',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCardField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey[400]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MyColors.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}