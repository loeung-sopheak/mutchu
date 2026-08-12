import 'package:flutter/material.dart';
import '../models/drink_model.dart';
import '../screens/drink_detail_screen.dart';
import '../colors.dart';
import 'animated_scale.dart';

class DrinkCard extends StatelessWidget {
  final Drink drink;
  final bool isFavorite;
  final VoidCallback? onFavorite;
  final VoidCallback? onAddToCart;

  const DrinkCard({
    super.key,
    required this.drink,
    this.isFavorite = false,
    this.onFavorite,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScaleWidget(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => FractionallySizedBox(
            heightFactor: 1,
            child: ProductDetailScreen(drink: drink),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            width: 1.0,
            color: Colors.grey.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== IMAGE & BADGES =====
            Expanded(
              flex: 2,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/${drink.imagePath}',
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Discount badge
                  if (drink.discount > 0)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${drink.discount.round()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  // Favorite button
                  Positioned(
                    top: 2,
                    right: 2,
                    child: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          size: 16,
                          color: isFavorite ? Colors.red : Colors.grey,
                        ),
                        onPressed: onFavorite,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 28,
                          minHeight: 28,
                        ),
                      ),
                  ),
                  // Popular badge
                  if (drink.isPopular)
                    Positioned(
                      bottom: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 10,
                            ),
                            const SizedBox(width: 2),
                            const Text(
                              'Popular',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // ===== DETAILS =====
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          drink.name,
                          style: const TextStyle(
                            fontFamily: 'GintoRegNorm',
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              drink.rating.toString(),
                              style: TextStyle(
                                fontSize: 11,
                                fontFamily: 'GintoRegNorm',
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // ===== PRICE & ADD BUTTON =====
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '\$${drink.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontFamily: 'GintoRegNorm',
                                fontSize: 14,
                                color: MyColors.primary,
                              ),
                            ),
                            if (drink.originalPrice > 0)
                              Text(
                                '\$${drink.originalPrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontFamily: 'GintoRegNorm',
                                  fontSize: 9,
                                  color: Colors.grey[400],
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                          ],
                        ),
                        
                      ],
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
}