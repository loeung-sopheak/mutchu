// lib/models/cart_item.dart
import 'drink_model.dart';
import 'food_model.dart';

class CartItem {
  // Common fields
  final String category; // 'drink' or 'food'
  final int quantity;
  final String size;
  final String sugarLevel;
  final String iceLevel;
  final String? addOn;
  final String? specialInstructions;
  final double totalPrice;

  // For drinks
  final Drink? drink;
  
  // For foods
  final Food? food;

  // Private constructor
  CartItem({
    this.drink,
    this.food,
    required this.category,
    required this.quantity,
    required this.size,
    this.sugarLevel = '100%',
    this.iceLevel = 'Regular',
    this.addOn,
    this.specialInstructions,
    required this.totalPrice,
  });

  // Factory for Drink
  factory CartItem.fromDrink({
    required Drink drink,
    required int quantity,
    required String size,
    required String sugarLevel,
    required String iceLevel,
    String? addOn,
    String? specialInstructions,
    required double totalPrice,
  }) {
    return CartItem(
      drink: drink,
      category: 'drink',
      quantity: quantity,
      size: size,
      sugarLevel: sugarLevel,
      iceLevel: iceLevel,
      addOn: addOn,
      specialInstructions: specialInstructions,
      totalPrice: totalPrice,
    );
  }

  // Factory for Food
  factory CartItem.fromFood({
    required Food food,
    required int quantity,
    required String size,
    String? addOn,
    String? specialInstructions,
    required double totalPrice,
  }) {
    return CartItem(
      food: food,
      category: 'food',
      quantity: quantity,
      size: size,
      sugarLevel: '0%',
      iceLevel: 'Regular',
      addOn: addOn,
      specialInstructions: specialInstructions,
      totalPrice: totalPrice,
    );
  }

  // Getters
  String get name {
    if (category == 'drink') {
      return drink?.name ?? 'Unknown Drink';
    } else {
      return food?.name ?? 'Unknown Food';
    }
  }

  String get imagePath {
    if (category == 'drink') {
      return drink?.imagePath ?? '';
    } else {
      return food?.imagePath ?? '';
    }
  }

  // Copy With
  CartItem copyWith({
    Drink? drink,
    Food? food,
    String? category,
    int? quantity,
    String? size,
    String? sugarLevel,
    String? iceLevel,
    String? addOn,
    String? specialInstructions,
    double? totalPrice,
  }) {
    return CartItem(
      drink: drink ?? this.drink,
      food: food ?? this.food,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      size: size ?? this.size,
      sugarLevel: sugarLevel ?? this.sugarLevel,
      iceLevel: iceLevel ?? this.iceLevel,
      addOn: addOn ?? this.addOn,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'quantity': quantity,
      'size': size,
      'sugarLevel': sugarLevel,
      'iceLevel': iceLevel,
      'addOn': addOn,
      'specialInstructions': specialInstructions,
      'totalPrice': totalPrice,
      'drinkId': drink?.id,
      'foodId': food?.id,
    };
  }
}