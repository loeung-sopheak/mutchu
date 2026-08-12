// lib/skeleton/home_tab_skeleton.dart
import 'package:flutter/material.dart';
import '../widgets/shimmer.dart';
import 'drink_card_skeleton.dart';
import 'food_card_skeleton.dart';
import 'category_chip_skeleton.dart';

class HomeTabSkeleton extends StatelessWidget {
  const HomeTabSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: SingleChildScrollView(  // ← ADD THIS
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Promo banner
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 24),

            // Categories
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(height: 20, width: 100, color: Colors.grey[200]),
                Container(height: 16, width: 60, color: Colors.grey[200]),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) => const CategoryChipSkeleton(),
              ),
            ),
            const SizedBox(height: 16),

            // Foods grid
            GridView.builder(
              shrinkWrap: true,  // ← ADD THIS
              physics: const NeverScrollableScrollPhysics(),  // ← ADD THIS
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.60,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: 4,
              itemBuilder: (context, index) => const FoodCardSkeleton(),
            ),
            const SizedBox(height: 16),

            // Drinks categories
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(height: 20, width: 120, color: Colors.grey[200]),
                Container(height: 16, width: 60, color: Colors.grey[200]),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) => const CategoryChipSkeleton(),
              ),
            ),
            const SizedBox(height: 16),

            // Drinks grid
            GridView.builder(
              shrinkWrap: true,  // ← ADD THIS
              physics: const NeverScrollableScrollPhysics(),  // ← ADD THIS
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.60,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: 4,
              itemBuilder: (context, index) => const DrinkCardSkeleton(),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}