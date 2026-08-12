// lib/providers/cart_provider.dart
import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/drink_model.dart';
import '../models/food_model.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  double _deliveryFee = 1.50;

  List<CartItem> get items => _items;
  
  int get itemCount {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }
  
  double get subtotal {
    return _items.fold(0, (sum, item) => sum + item.totalPrice);
  }
  
  double get deliveryFee => _deliveryFee;
  
  double get total {
    return subtotal + (_items.isNotEmpty ? deliveryFee : 0);
  }

  // ===== ADD DRINK =====
  void addDrink({
    required Drink drink,
    required int quantity,
    required String size,
    required String sugarLevel,
    required String iceLevel,
    String? addOn,
    String? specialInstructions,
    required double totalPrice,
  }) {
    final existingIndex = _items.indexWhere((item) =>
        item.category == 'drink' &&
        item.drink?.id == drink.id &&
        item.size == size &&
        item.sugarLevel == sugarLevel &&
        item.iceLevel == iceLevel &&
        item.addOn == addOn &&
        item.specialInstructions == specialInstructions);

    if (existingIndex != -1) {
      final existing = _items[existingIndex];
      _items[existingIndex] = existing.copyWith(
        quantity: existing.quantity + quantity,
        totalPrice: existing.totalPrice + totalPrice,
      );
    } else {
      _items.add(CartItem.fromDrink(
        drink: drink,
        quantity: quantity,
        size: size,
        sugarLevel: sugarLevel,
        iceLevel: iceLevel,
        addOn: addOn,
        specialInstructions: specialInstructions,
        totalPrice: totalPrice,
      ));
    }
    notifyListeners();
  }

  // ===== ADD FOOD =====
  void addFood({
    required Food food,
    required int quantity,
    required String size,
    String? addOn,
    String? specialInstructions,
    required double totalPrice,
  }) {
    final existingIndex = _items.indexWhere((item) =>
        item.category == 'food' &&
        item.food?.id == food.id &&
        item.size == size &&
        item.addOn == addOn &&
        item.specialInstructions == specialInstructions);

    if (existingIndex != -1) {
      final existing = _items[existingIndex];
      _items[existingIndex] = existing.copyWith(
        quantity: existing.quantity + quantity,
        totalPrice: existing.totalPrice + totalPrice,
      );
    } else {
      _items.add(CartItem.fromFood(
        food: food,
        quantity: quantity,
        size: size,
        addOn: addOn,
        specialInstructions: specialInstructions,
        totalPrice: totalPrice,
      ));
    }
    notifyListeners();
  }

  // ===== LEGACY SUPPORT =====
  void addItem({
    required Drink drink,
    required int quantity,
    required String size,
    required String sugarLevel,
    required String iceLevel,
    String? addOn,
    String? specialInstructions,
    required double totalPrice,
  }) {
    addDrink(
      drink: drink,
      quantity: quantity,
      size: size,
      sugarLevel: sugarLevel,
      iceLevel: iceLevel,
      addOn: addOn,
      specialInstructions: specialInstructions,
      totalPrice: totalPrice,
    );
  }

  void removeItem(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void updateQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(index);
      return;
    }
    final item = _items[index];
    final pricePerUnit = item.totalPrice / item.quantity;
    _items[index] = item.copyWith(
      quantity: newQuantity,
      totalPrice: pricePerUnit * newQuantity,
    );
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  void updateDeliveryFee(double fee) {
    _deliveryFee = fee;
    notifyListeners();
  }
}