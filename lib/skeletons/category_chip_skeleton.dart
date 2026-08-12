// lib/skeleton/category_chip_skeleton.dart
import 'package:flutter/material.dart';

class CategoryChipSkeleton extends StatelessWidget {
  const CategoryChipSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 34,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}