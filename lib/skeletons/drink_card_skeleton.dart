// lib/skeleton/drink_card_skeleton.dart
import 'package:flutter/material.dart';

class DrinkCardSkeleton extends StatelessWidget {
  const DrinkCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(width: 1, color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
          const SizedBox(height: 8),

          // Name
          Container(
            height: 14,
            width: 100,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            color: Colors.grey[200],
          ),
          const SizedBox(height: 4),

          // Rating
          Container(
            height: 12,
            width: 60,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            color: Colors.grey[200],
          ),
          const SizedBox(height: 8),

          // Price & Add button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 14,
                  width: 50,
                  color: Colors.grey[200],
                ),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}