// lib/screens/food_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food_model.dart';
import '../providers/cart_provider.dart';
import '../colors.dart';

class FoodDetailScreen extends StatefulWidget {
  final Food food;

  const FoodDetailScreen({super.key, required this.food});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  int _quantity = 1;
  String _selectedOption = 'Regular';
  String? _selectedAddOn;
  String _specialInstructions = '';
  double _totalPrice = 0;

  final TextEditingController _instructionsController = TextEditingController();

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
      double basePrice = widget.food.price;

      if (_selectedOption == 'Large') {
        basePrice += 2.00;
      } else if (_selectedOption == 'Small') {
        basePrice -= 1.00;
      }

      if (_selectedAddOn != null && _selectedAddOn != 'None') {
        basePrice += 1.50;
      }

      _totalPrice = basePrice * _quantity;
    });
  }

  void _addToCart() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    cartProvider.addFood(
      food: widget.food,
      quantity: _quantity,
      size: _selectedOption,
      addOn: _selectedAddOn != 'None' ? _selectedAddOn : null,
      specialInstructions: _specialInstructions.isNotEmpty
          ? _specialInstructions
          : null,
      totalPrice: _totalPrice,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('✅ Added ${_quantity}x ${widget.food.name}!'),
            Text(
              '\$${_totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.primary,
      appBar: null,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              pinned: true,
              expandedHeight: 0,
              toolbarHeight: 100,
              elevation: 0,
              backgroundColor: !innerBoxIsScrolled
                  ? MyColors.primary
                  : MyColors.secondary,

              leading: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 8, top: 46),
                  child: CircleAvatar(
                    backgroundColor: innerBoxIsScrolled
                        ? Colors.transparent
                        : Colors.white.withValues(alpha: 0.9),
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: MyColors.primary_50,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ),

              title: innerBoxIsScrolled
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 8, top: 46),
                      child: Text(
                        widget.food.name,
                        style: TextStyle(
                          color: MyColors.primary,
                          fontFamily: 'Ginto',
                          fontSize: 14,
                        ),
                      ),
                    )
                  : null,
            ),
          ];
        },
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== FOOD IMAGE =====
              Container(
                margin: const EdgeInsets.all(16),
                height: 200,
                decoration: BoxDecoration(
                  color: MyColors.secondary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/${widget.food.imagePath}',
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
                                widget.food.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontFamily: 'GintoBold',
                                  color: MyColors.secondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.food.rating.toString(),
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
                        if (widget.food.discount > 0)
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
                              '${widget.food.discount.round()}% OFF',
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
                        if (widget.food.originalPrice > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            '\$${widget.food.originalPrice.toStringAsFixed(2)}',
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

                    SizedBox(height: widget.food.description != "" ? 16 : 0),

                    // Description
                    Text(
                      widget.food.description,
                      style: TextStyle(
                        color: MyColors.secondary,
                        fontFamily: 'Ginto',
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: widget.food.description != "" ? 20 : 0),

                    // nutrition info
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
                              const Icon(
                                Icons.food_bank,
                                color: MyColors.primary,
                                size: 18,
                              ),
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
                                widget.food.nutrition.servingSize,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
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
                                '${widget.food.nutrition.calories}',
                                'Calories',
                              ),
                              _buildNutritionItem(
                                '💪',
                                '${widget.food.nutrition.protein}g',
                                'Protein',
                              ),
                              _buildNutritionItem(
                                '🧈',
                                '${widget.food.nutrition.fat}g',
                                'Fat',
                              ),
                              _buildNutritionItem(
                                '🌾',
                                '${widget.food.nutrition.carbs}g',
                                'Carbs',
                              ),
                            ],
                          ),
                          if (widget.food.isVegan)
                            const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                '🌱 Vegan Friendly',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontFamily: 'GintoBold',
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),

                    // special instrucitons
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
                        controller: _instructionsController,
                        onChanged: (value) {
                          _specialInstructions = value;
                        },
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText:
                              'E.g., No cheese, extra crispy, gluten-free...',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontFamily: 'GintoRegNorm',
                            fontSize: 13,
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
          ),
        ),
      ),
      
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              width: 2.0,
              color: Colors.grey.withValues(alpha: 0.4)
            )
          )
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
                          fontFamily: 'GintoRegNorm',
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
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 10)),
      ],
    );
  }
}
