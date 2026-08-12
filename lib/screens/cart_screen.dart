import 'package:flutter/material.dart';
import 'package:flutter_application_2/utils/functions.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../models/cart_item.dart';
import '../colors.dart';
import '../widgets/animated_button.dart';
import '../widgets/animated_scale.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final items = cartProvider.items;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: null,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              pinned: true,
              toolbarHeight: 50,
              elevation: 0,
              backgroundColor: innerBoxIsScrolled
                  ? MyColors.primary
                  : MyColors.secondary,
              title: Text(
                'My Cart',
                style: TextStyle(
                  color: innerBoxIsScrolled
                      ? MyColors.secondary
                      : MyColors.primary,
                  fontFamily: 'GintoBold',
                  fontSize: 18,
                ),
              ),
              centerTitle: true, // ← Center the title
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(height: 1, color: innerBoxIsScrolled ? darkenColor(MyColors.primary, 0.08) : Colors.grey.shade200),
              ),
              actions: [
                if (items.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Clear Cart'),
                          content: const Text(
                            'Are you sure you want to clear your cart?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                cartProvider.clearCart();
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Clear',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Text(
                      'Clear All',
                      style: TextStyle(
                        color: innerBoxIsScrolled ? Colors.white : Colors.red,
                        fontFamily: 'GintoRegNorm',
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ];
        },
        body: items.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_rounded,
                      size: 80,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Your cart is empty',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Ginto',
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Start adding some delicious drinks!',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Ginto',
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  // Cart Items
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _buildCartItem(
                          item: item,
                          index: index,
                          cartProvider: cartProvider,
                        );
                      },
                    ),
                  ),

                  // Checkout Button
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 12,
                          offset: const Offset(0, -4),
                        ),
                      ],
                      border: Border(
                        top: BorderSide(
                          width: 1.0,
                          color: Colors.grey.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Summary
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Subtotal',
                                style: TextStyle(
                                  fontFamily: 'GintoRegNorm',
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '\$${cartProvider.subtotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontFamily: 'GintoRegNorm',
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Delivery Fee',
                                style: TextStyle(
                                  fontFamily: 'GintoRegNorm',
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '\$${cartProvider.deliveryFee.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontFamily: 'GintoRegNorm',
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                  fontFamily: 'GintoRegNorm',
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '\$${cartProvider.total.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontFamily: 'GintoRegNorm',
                                  fontSize: 16,
                                  color: MyColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          AnimatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CheckoutScreen(),
                                ),
                              );
                            },
                            endBorderRadius: 14,
                            startBorderRadius: 10,
                            child: const Text(
                              'Proceed to Checkout',
                              style: TextStyle(
                                fontFamily: 'GintoRegNorm',
                                fontSize: 15,
                                color: MyColors.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCartItem({
    required CartItem item,
    required int index,
    required CartProvider cartProvider,
  }) {
    return AnimatedScaleWidget(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            width: 1.0,
            color: Colors.grey.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            // Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: MyColors.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Image.asset(
                  'assets/${item.imagePath}',
                  height: 50,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontFamily: 'GintoRegNorm',
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Size: ${item.size} - Sugar: ${item.sugarLevel}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontFamily: 'GintoRegNorm',
                      fontSize: 12,
                    ),
                  ),
                  if (item.addOn != null)
                    Text(
                      'Add-on: ${item.addOn}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  if (item.specialInstructions != null)
                    Text(
                      '📝 ${item.specialInstructions}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

            // Quantity & Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        cartProvider.updateQuantity(index, item.quantity - 1);
                      },
                    ),
                    Text(
                      '${item.quantity}',
                      style: const TextStyle(
                        fontFamily: 'GintoRegNorm',
                        fontSize: 14,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        cartProvider.updateQuantity(index, item.quantity + 1);
                      },
                    ),
                  ],
                ),
                Text(
                  '\$${item.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontFamily: 'GintoRegNorm',
                    fontSize: 16,
                    color: MyColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
