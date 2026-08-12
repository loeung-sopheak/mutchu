import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/drink_model.dart';
import '../models/cart_item.dart';
import '../models/food_model.dart';
import '../models/order_model.dart';
import 'dart:convert';

final supabase = Supabase.instance.client;

class SupabaseService {
  // ============================================================
  // AUTHENTICATION
  // ============================================================

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    return await supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'name': name,
        'phone': phone,
        'created_at': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  // ============================================================
  // DRINKS
  // ============================================================

  Future<List<Drink>> getDrinks() async {
    try {
      final response = await supabase.from('drinks').select().order('name');

      return response.map((data) => _drinkFromJson(data)).toList();
    } catch (e) {
      print('Error fetching drinks: $e');
      return [];
    }
  }

  Future<Drink?> getDrinkById(String id) async {
    try {
      final response = await supabase
          .from('drinks')
          .select()
          .eq('id', id)
          .maybeSingle();

      return response != null ? _drinkFromJson(response) : null;
    } catch (e) {
      print('Error fetching drink: $e');
      return null;
    }
  }

  Future<List<Drink>> getDrinksByCategory(String category) async {
    try {
      final response = await supabase
          .from('drinks')
          .select()
          .eq('category', category)
          .order('name');

      return response.map((data) => _drinkFromJson(data)).toList();
    } catch (e) {
      print('Error fetching drinks by category: $e');
      return [];
    }
  }

  Future<List<Drink>> searchDrinks(String query) async {
    try {
      final response = await supabase
          .from('drinks')
          .select()
          .ilike('name', '%$query%')
          .order('name');

      return response.map((data) => _drinkFromJson(data)).toList();
    } catch (e) {
      print('Error searching drinks: $e');
      return [];
    }
  }

  // ============================================================
  // FOODS
  // ============================================================

  Future<List<Food>> getFoods() async {
    try {
      final response = await supabase.from('foods').select().order('name');

      return response.map((data) => Food.fromJson(data)).toList();
    } catch (e) {
      print('Error fetching foods: $e');
      return [];
    }
  }

  Future<Food?> getFoodById(String id) async {
    try {
      final response = await supabase
          .from('foods')
          .select()
          .eq('id', id)
          .maybeSingle();

      return response != null ? Food.fromJson(response) : null;
    } catch (e) {
      print('Error fetching food: $e');
      return null;
    }
  }

  Future<List<Food>> getFoodsByCategory(String category) async {
    try {
      final response = await supabase
          .from('foods')
          .select()
          .eq('category', category)
          .order('name');

      return response.map((data) => Food.fromJson(data)).toList();
    } catch (e) {
      print('Error fetching foods by category: $e');
      return [];
    }
  }

  // ============================================================
  // FAVORITES
  // ============================================================

  Future<void> addFavorite(String userId, String drinkId) async {
    await supabase.from('favorites').insert({
      'user_id': userId,
      'drink_id': drinkId,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> removeFavorite(String userId, String drinkId) async {
    await supabase.from('favorites').delete().match({
      'user_id': userId,
      'drink_id': drinkId,
    });
  }

  Future<List<String>> getFavorites(String userId) async {
    try {
      final response = await supabase
          .from('favorites')
          .select('drink_id')
          .eq('user_id', userId);

      return response
          .map<String>((data) => data['drink_id'] as String)
          .toList();
    } catch (e) {
      print('Error fetching favorites: $e');
      return [];
    }
  }

  Future<bool> isFavorite(String userId, String drinkId) async {
    try {
      final response = await supabase.from('favorites').select().match({
        'user_id': userId,
        'drink_id': drinkId,
      }).maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // CART
  // ============================================================

  Future<void> addToCart({
    required String userId,
    required CartItem cartItem,
  }) async {
    final existing = await supabase.from('cart').select().match({
      'user_id': userId,
      'item_type': cartItem.category,
      if (cartItem.category == 'drink') 'drink_id': cartItem.drink!.id,
      if (cartItem.category == 'food') 'food_id': cartItem.food!.id,
      'size': cartItem.size,
      'sugar_level': cartItem.sugarLevel,
      'ice_level': cartItem.iceLevel,
      'add_on': cartItem.addOn ?? '',
      'special_instructions': cartItem.specialInstructions ?? '',
    }).maybeSingle();

    if (existing != null) {
      final newQuantity = (existing['quantity'] as int) + cartItem.quantity;
      final newTotal =
          (existing['total_price'] as double) + cartItem.totalPrice;

      await supabase
          .from('cart')
          .update({
            'quantity': newQuantity,
            'total_price': newTotal,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', existing['id']);
    } else {
      await supabase.from('cart').insert({
        'user_id': userId,
        'item_type': cartItem.category,
        if (cartItem.category == 'drink') 'drink_id': cartItem.drink!.id,
        if (cartItem.category == 'food') 'food_id': cartItem.food!.id,
        'quantity': cartItem.quantity,
        'size': cartItem.size,
        'sugar_level': cartItem.sugarLevel,
        'ice_level': cartItem.iceLevel,
        'add_on': cartItem.addOn ?? '',
        'special_instructions': cartItem.specialInstructions ?? '',
        'total_price': cartItem.totalPrice,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<List<CartItem>> getCartItems(String userId) async {
    try {
      final response = await supabase
          .from('cart')
          .select('*')
          .eq('user_id', userId)
          .order('created_at');

      final items = <CartItem>[];

      for (var data in response) {
        final itemType = data['item_type'] ?? 'drink';

        if (itemType == 'drink') {
          final drinkResponse = await supabase
              .from('drinks')
              .select('*')
              .eq('id', data['drink_id'])
              .maybeSingle();

          if (drinkResponse != null) {
            items.add(
              CartItem.fromDrink(
                drink: _drinkFromJson(drinkResponse),
                quantity: data['quantity'] as int,
                size: data['size'] ?? 'M',
                sugarLevel: data['sugar_level'] ?? '100%',
                iceLevel: data['ice_level'] ?? 'Regular',
                addOn: data['add_on'],
                specialInstructions: data['special_instructions'],
                totalPrice: (data['total_price'] as num).toDouble(),
              ),
            );
          }
        } else {
          // Food
          final foodResponse = await supabase
              .from('foods')
              .select('*')
              .eq('id', data['food_id'])
              .maybeSingle();

          if (foodResponse != null) {
            items.add(
              CartItem.fromFood(
                food: _foodFromJson(foodResponse),
                quantity: data['quantity'] as int,
                size: data['size'] ?? 'Regular',
                addOn: data['add_on'],
                specialInstructions: data['special_instructions'],
                totalPrice: (data['total_price'] as num).toDouble(),
              ),
            );
          }
        }
      }

      return items;
    } catch (e) {
      print('Error fetching cart: $e');
      return [];
    }
  }

  Future<void> updateCartQuantity(String cartId, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(cartId);
      return;
    }

    final item = await supabase.from('cart').select().eq('id', cartId).single();

    final pricePerUnit =
        (item['total_price'] as double) / (item['quantity'] as int);

    await supabase
        .from('cart')
        .update({
          'quantity': quantity,
          'total_price': pricePerUnit * quantity,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', cartId);
  }

  Future<void> removeFromCart(String cartId) async {
    await supabase.from('cart').delete().eq('id', cartId);
  }

  Future<void> clearCart(String userId) async {
    await supabase.from('cart').delete().eq('user_id', userId);
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await supabase
        .from('orders')
        .update({
          'status': status,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', orderId);
  }

  Future<String> createOrder({
    required String userId,
    required String orderNumber,
    required List<CartItem> items,
    required double subtotal,
    required double deliveryFee,
    required double total,
    required String paymentMethod,
    required Address address,
    String? notes,
  }) async {
    final orderResponse = await supabase
        .from('orders')
        .insert({
          'user_id': userId,
          'order_number': orderNumber,
          'subtotal': subtotal,
          'delivery_fee': deliveryFee,
          'total': total,
          'payment_method': paymentMethod,
          'status': 'pending',
          'delivery_address': address.toJson(),
          'notes': notes,
          'created_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();

    final orderId = orderResponse['id'] as String;

    for (var item in items) {
      if (item.category == 'drink') {
        await supabase.from('order_items').insert({
          'order_id': orderId,
          'item_type': 'drink',
          'drink_id': item.drink!.id,
          'food_id': null,
          'quantity': item.quantity,
          'size': item.size,
          'sugar_level': item.sugarLevel,
          'ice_level': item.iceLevel,
          'add_on': item.addOn,
          'special_instructions': item.specialInstructions,
          'price': item.totalPrice,
        });
      } else {
        await supabase.from('order_items').insert({
          'order_id': orderId,
          'item_type': 'food',
          'drink_id': null,
          'food_id': item.food!.id,
          'quantity': item.quantity,
          'size': item.size,
          'sugar_level': '0%',
          'ice_level': 'Regular',
          'add_on': item.addOn,
          'special_instructions': item.specialInstructions,
          'price': item.totalPrice,
        });
      }
    }

    await supabase.from('cart').delete().eq('user_id', userId);

    return orderId;
  }

  Future<List<Order>> getOrders(String userId) async {
    print('📌 Fetching orders for user: $userId');
    try {
      final ordersResponse = await supabase
          .from('orders')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      print('📊 Found ${ordersResponse.length} orders');

      List<Order> orders = [];

      for (var orderData in ordersResponse) {
        final orderId = orderData['id'];

        // Use the helper method
        final items = await _buildOrderItems(orderId);

        // Parse delivery_address
        Map<String, dynamic> addressMap;
        final addressData = orderData['delivery_address'];
        if (addressData is String) {
          addressMap = jsonDecode(addressData);
        } else {
          addressMap = addressData as Map<String, dynamic>;
        }

        orders.add(
          Order(
            id: orderData['id'],
            userId: orderData['user_id'],
            orderNumber: orderData['order_number'],
            items: items,
            subtotal: (orderData['subtotal'] as num).toDouble(),
            deliveryFee: (orderData['delivery_fee'] as num).toDouble(),
            total: (orderData['total'] as num).toDouble(),
            paymentMethod: orderData['payment_method'],
            status: orderData['status'],
            createdAt: DateTime.parse(orderData['created_at']),
            deliveryAddress: Address.fromJson(addressMap),
            notes: orderData['notes'],
          ),
        );
      }

      return orders;
    } catch (e) {
      print('❌ Error fetching orders: $e');
      return [];
    }
  }

  Future<Order?> getOrderById(String orderId) async {
    try {
      final orderResponse = await supabase
          .from('orders')
          .select('*')
          .eq('id', orderId)
          .maybeSingle();

      if (orderResponse == null) return null;

      // Use the helper method
      final items = await _buildOrderItems(orderId);

      // Parse delivery_address
      Map<String, dynamic> addressMap;
      final addressData = orderResponse['delivery_address'];
      if (addressData is String) {
        addressMap = jsonDecode(addressData);
      } else {
        addressMap = addressData as Map<String, dynamic>;
      }

      return Order(
        id: orderResponse['id'],
        userId: orderResponse['user_id'],
        orderNumber: orderResponse['order_number'],
        items: items,
        subtotal: (orderResponse['subtotal'] as num).toDouble(),
        deliveryFee: (orderResponse['delivery_fee'] as num).toDouble(),
        total: (orderResponse['total'] as num).toDouble(),
        paymentMethod: orderResponse['payment_method'],
        status: orderResponse['status'],
        createdAt: DateTime.parse(orderResponse['created_at']),
        deliveryAddress: Address.fromJson(addressMap),
        notes: orderResponse['notes'],
      );
    } catch (e) {
      print('❌ Error fetching order: $e');
      return null;
    }
  }

  // ============================================================
  // POPULAR ITEMS
  // ============================================================

  Future<List<Map<String, dynamic>>> getPopularItems() async {
    try {
      final response = await supabase
          .from('popular_items')  // ← This is your view
          .select('*')
          .limit(10);
      
      return response;
    } catch (e) {
      print('❌ Error fetching popular items: $e');
      return [];
    }
  }

  // Alternative: Get popular drinks only
  Future<List<Drink>> getPopularDrinks() async {
    try {
      final response = await supabase
          .from('drinks')
          .select('*')
          .eq('is_popular', true)
          .order('rating', ascending: false)
          .limit(5);
      
      return response.map((data) => _drinkFromJson(data)).toList();
    } catch (e) {
      print('❌ Error fetching popular drinks: $e');
      return [];
    }
  }

  // Alternative: Get popular foods only
  Future<List<Food>> getPopularFoods() async {
    try {
      final response = await supabase
          .from('foods')
          .select('*')
          .eq('is_popular', true)
          .order('rating', ascending: false)
          .limit(5);
      
      return response.map((data) => _foodFromJson(data)).toList();
    } catch (e) {
      print('❌ Error fetching popular foods: $e');
      return [];
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================

  Drink _drinkFromJson(Map<String, dynamic> data) {
    return Drink(
      id: data['id'],
      name: data['name'],
      description: data['description'] ?? '',
      price: (data['price'] as num).toDouble(),
      originalPrice: (data['original_price'] as num?)?.toDouble() ?? 0,
      imagePath: data['image_path'] ?? '',
      category: data['category'] ?? '',
      isPopular: data['is_popular'] ?? false,
      isVegan: data['is_vegan'] ?? false,
      isNew: data['is_new'] ?? false,
      rating: (data['rating'] as num?)?.toDouble() ?? 4.5,
      preparationTime: data['preparation_time'] ?? 5,
      tags: data['tags'] is List ? List<String>.from(data['tags']) : [],
      nutrition: NutritionInfo(
        calories: data['calories'] ?? 0,
        sugar: data['sugar'] ?? 0,
        protein: data['protein'] ?? 0,
        caffeine: data['caffeine'] ?? 0,
        servingSize: data['serving_size'] ?? '12 fl oz',
      ),
    );
  }

  Food _foodFromJson(Map<String, dynamic> data) {
    return Food(
      id: data['id'],
      name: data['name'],
      description: data['description'] ?? '',
      price: (data['price'] as num).toDouble(),
      originalPrice: (data['original_price'] as num?)?.toDouble() ?? 0,
      imagePath: data['image_path'] ?? '',
      category: data['category'] ?? '',
      isPopular: data['is_popular'] ?? false,
      isVegan: data['is_vegan'] ?? false,
      isNew: data['is_new'] ?? false,
      rating: (data['rating'] as num?)?.toDouble() ?? 4.5,
      preparationTime: data['preparation_time'] ?? 10,
      tags: data['tags'] is List ? List<String>.from(data['tags']) : [],
      nutrition: FoodNutrition(
        calories: data['calories'] ?? 0,
        protein: data['protein'] ?? 0,
        fat: data['fat'] ?? 0,
        carbs: data['carbs'] ?? 0,
        servingSize: data['serving_size'] ?? '1 serving',
      ),
    );
  }

  Future<List<CartItem>> _buildOrderItems(String orderId) async {
    final itemsResponse = await supabase
        .from('order_items')
        .select('*')
        .eq('order_id', orderId);

    final items = <CartItem>[];

    for (var itemData in itemsResponse) {
      final itemType = itemData['item_type'] ?? 'drink';

      if (itemType == 'drink') {
        final drinkId = itemData['drink_id'] as String;
        final drinkResponse = await supabase
            .from('drinks')
            .select('*')
            .eq('id', drinkId)
            .maybeSingle();

        if (drinkResponse != null) {
          items.add(
            CartItem.fromDrink(
              drink: _drinkFromJson(drinkResponse),
              quantity: itemData['quantity'] as int,
              size: itemData['size'] ?? 'M',
              sugarLevel: itemData['sugar_level'] ?? '100%',
              iceLevel: itemData['ice_level'] ?? 'Regular',
              addOn: itemData['add_on'],
              specialInstructions: itemData['special_instructions'],
              totalPrice: (itemData['price'] as num).toDouble(),
            ),
          );
        }
      } else {
        // Food
        final foodId = itemData['food_id'] as String;
        final foodResponse = await supabase
            .from('foods')
            .select('*')
            .eq('id', foodId)
            .maybeSingle();

        if (foodResponse != null) {
          items.add(
            CartItem.fromFood(
              food: _foodFromJson(foodResponse),
              quantity: itemData['quantity'] as int,
              size: itemData['size'] ?? 'Regular',
              addOn: itemData['add_on'],
              specialInstructions: itemData['special_instructions'],
              totalPrice: (itemData['price'] as num).toDouble(),
            ),
          );
        }
      }
    }

    return items;
  }
}
