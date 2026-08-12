// lib/screens/product_detail_screen.dart (Updated with all features)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/drink_model.dart';
import '../providers/cart_provider.dart';
import '../colors.dart';

class ProductDetailScreen extends StatefulWidget {
  final Drink drink;
  
  const ProductDetailScreen({
    super.key,
    required this.drink,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  String _selectedSize = 'M';
  String _selectedSugar = '100%';
  String _selectedIce = 'Regular';
  String? _selectedAddOn;
  String _specialInstructions = '';
  double _totalPrice = 0;
  
  final TextEditingController _instructionsController = TextEditingController();
  
  final List<String> _sizes = ['S', 'M', 'L'];
  final List<String> _sugarOptions = ['0%', '30%', '50%', '70%', '100%'];
  final List<String> _iceOptions = ['Less', 'Regular', 'Extra'];
  final List<String> _addOns = ['Boba', 'Lychee Jelly', 'Aloe Vera', 'None'];

  @override
  void initState() {
    super.initState();
    _updatePrice();
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  void _updatePrice() {
    setState(() {
      double basePrice = widget.drink.price;
      
      if (_selectedSize == 'L') {
        basePrice += 1.50;
      } else if (_selectedSize == 'S') {
        basePrice -= 0.50;
      }
      
      if (_selectedAddOn != null && _selectedAddOn != 'None') {
        basePrice += 0.75;
      }
      
      _totalPrice = basePrice * _quantity;
    });
  }

  void _addToCart() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    
    cartProvider.addItem(
      drink: widget.drink,
      quantity: _quantity,
      size: _selectedSize,
      sugarLevel: _selectedSugar,
      iceLevel: _selectedIce,
      addOn: _selectedAddOn != 'None' ? _selectedAddOn : null,
      specialInstructions: _specialInstructions.isNotEmpty ? _specialInstructions : null,
      totalPrice: _totalPrice,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Added ${_quantity}× ${widget.drink.name}!'),
            Text(
              '\$${_totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontFamily: 'GintoRegNorm',
                fontSize: 12,
              ),
            ),
          ],
        ),
        backgroundColor: MyColors.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      backgroundColor: MyColors.primary,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
          SliverAppBar(
            pinned: true,
            expandedHeight: 0,
            toolbarHeight: 100,
            elevation: 0,
            backgroundColor: !innerBoxIsScrolled ? MyColors.primary : MyColors.secondary,
            
            leading: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 8, top: 46),
                child: CircleAvatar(
                  backgroundColor: innerBoxIsScrolled 
                      ? Colors.transparent
                      : Colors.white.withValues(alpha: 0.9),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: MyColors.primary_50, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
            
            title: innerBoxIsScrolled 
                ? Padding(
                  padding: const EdgeInsets.only(bottom: 8, top: 46), child: 
                    Text(
                      widget.drink.name, 
                      style: TextStyle(
                        color: MyColors.primary,
                        fontFamily: 'Ginto',
                        fontSize: 14
                        )
                      )
                  )
                : null,
          ),
        ];
      },

      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: 
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== PRODUCT IMAGE =====
                Container(
                  margin: const EdgeInsets.all(16),
                  height: 200,
                  decoration: BoxDecoration(
                    color: MyColors.secondary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/${widget.drink.imagePath}',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & Rating
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.drink.name,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontFamily: 'GintoBold',
                                    color: MyColors.secondary
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.drink.rating.toString(),
                                      style: const TextStyle(
                                        fontFamily: 'Ginto',
                                        color: MyColors.secondary,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '(120 reviews)',
                                      style: TextStyle(
                                        color: Colors.grey[300],
                                        fontSize: 12,
                                        fontFamily: 'Ginto',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (widget.drink.discount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                '${widget.drink.discount.round()}% OFF',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'GintoBold',
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Price
                      Row(
                        children: [
                          Text(
                            '\$${(_totalPrice / _quantity).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontFamily: 'GintoBold',
                              color: MyColors.secondary,
                            ),
                          ),
                          if (widget.drink.originalPrice > 0) ...[
                            const SizedBox(width: 8),
                            Text(
                              '\$${widget.drink.originalPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Ginto',
                                color: Colors.grey[300],
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // ===== DESCRIPTION =====
                      Text(
                        widget.drink.description,
                        style: TextStyle(
                          color: MyColors.secondary,
                          fontFamily: 'Ginto',
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // ===== NUTRITION INFO =====
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F8F8),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.food_bank, color: MyColors.primary, size: 18),
                                const SizedBox(width: 8),
                                const Text(
                                  'Nutrition Facts',
                                  style: TextStyle(
                                    fontFamily: 'GintoBold',
                                    color: MyColors.primary_50,
                                    fontSize: 16,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  widget.drink.nutrition.servingSize,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                    fontFamily: 'GintoRegNorm',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildNutritionItem(
                                  '🔥',
                                  '${widget.drink.nutrition.calories}',
                                  'Calories',
                                ),
                                _buildNutritionItem(
                                  '🍬',
                                  '${widget.drink.nutrition.sugar}g',
                                  'Sugar',
                                ),
                                _buildNutritionItem(
                                  '💪',
                                  '${widget.drink.nutrition.protein}g',
                                  'Protein',
                                ),
                                _buildNutritionItem(
                                  '☕',
                                  '${widget.drink.nutrition.caffeine}mg',
                                  'Caffeine',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // ===== SIZE SELECTOR =====
                      const Text(
                        'Select Size',
                        style: TextStyle(
                          fontFamily: 'GintoBold',
                          color: MyColors.secondary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: _sizes.map((size) {
                          final isSelected = _selectedSize == size;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedSize = size;
                                _updatePrice();
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected ? MyColors.primary_50 : Colors.grey[100],
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? MyColors.primary_50 : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                size,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.grey[700],
                                  fontFamily: 'GintoRegNorm',
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // ===== SUGAR LEVEL =====
                      const Text(
                        'Sugar Level',
                        style: TextStyle(
                          fontFamily: 'GintoBold',
                          color: MyColors.secondary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _sugarOptions.map((sugar) {
                          final isSelected = _selectedSugar == sugar;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedSugar = sugar;
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected ? MyColors.primary_50 : Colors.grey[100],
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? MyColors.primary_50 : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                sugar,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.grey[700],
                                  fontFamily: 'GintoRegNorm',
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // ===== ICE LEVEL =====
                      const Text(
                        'Ice Level',
                        style: TextStyle(
                          fontFamily: 'GintoBold',
                          color: MyColors.secondary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: _iceOptions.map((ice) {
                          final isSelected = _selectedIce == ice;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedIce = ice;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected ? MyColors.primary_50 : Colors.grey[100],
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? MyColors.primary_50 : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                ice,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.grey[700],
                                  fontFamily: 'GintoRegNorm',
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // ===== ADD-ONS =====
                      const Text(
                        'Add-Ons (+\$0.75)',
                        style: TextStyle(
                          fontFamily: 'GintoBold',
                          color: MyColors.secondary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _addOns.map((addon) {
                          final isSelected = _selectedAddOn == addon;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedAddOn = addon == 'None' ? null : addon;
                                _updatePrice();
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected ? MyColors.primary_50 : Colors.grey[100],
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? MyColors.primary_50 : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                addon,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.grey[700],
                                  fontFamily: 'GintoRegNorm',
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // ===== SPECIAL INSTRUCTIONS =====
                      const Text(
                        'Special Instructions',
                        style: TextStyle(
                          fontFamily: 'GintoBold',
                          color: MyColors.secondary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F8F8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          style: TextStyle(
                            fontFamily: 'GintoRegNorm',
                          ),
                          controller: _instructionsController,
                          onChanged: (value) {
                            _specialInstructions = value;
                          },
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'E.g., Extra hot, less sweet, no foam...',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontFamily: 'GintoRegNorm',
                              fontSize: 13
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            )
        ),
      ),
      
      // ===== BOTTOM BAR =====
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 0,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Quantity Selector
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 20),
                      onPressed: () {
                        if (_quantity > 1) {
                          setState(() {
                            _quantity--;
                            _updatePrice();
                          });
                        }
                      },
                    ),
                    Text(
                      '$_quantity',
                      style: const TextStyle(
                        fontFamily: 'GintoBold',
                        color: MyColors.primary_50,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 20),
                      onPressed: () {
                        setState(() {
                          _quantity++;
                          _updatePrice();
                        });
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Add to Cart Button
              Expanded(
                child: ElevatedButton(
                  onPressed: _addToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_cart_outlined, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Add to Cart - \$${_totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontFamily: 'Ginto',
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionItem(String icon, String value, String label) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'GintoRegNorm',
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[500],
            fontFamily: 'GintoRegNorm',
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}