// lib/models/order_model.dart
import 'cart_item.dart';
import 'drink_model.dart';
import 'food_model.dart';

class Order {
  final String id;
  final String userId;
  final String orderNumber;
  final List<CartItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;
  final Address deliveryAddress;
  final String? notes;

  Order({
    required this.id,
    required this.userId,
    required this.orderNumber,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    required this.deliveryAddress,
    this.notes,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['id'],
    userId: json['user_id'],
    orderNumber: json['order_number'],
    items: (json['items'] as List?)?.map((i) {
      final category = i['category'] ?? 'drink';
      
      if (category == 'drink') {
        return CartItem.fromDrink(
          drink: Drink.fromJson(i['drink'] ?? {}),
          quantity: i['quantity'] as int,
          size: i['size'] ?? 'M',
          sugarLevel: i['sugarLevel'] ?? '100%',
          iceLevel: i['iceLevel'] ?? 'Regular',
          addOn: i['addOn'],
          specialInstructions: i['specialInstructions'],
          totalPrice: (i['totalPrice'] as num).toDouble(),
        );
      } else {
        // Food
        return CartItem.fromFood(
          food: Food.fromJson(i['food'] ?? {}),
          quantity: i['quantity'] as int,
          size: i['size'] ?? 'Regular',
          addOn: i['addOn'],
          specialInstructions: i['specialInstructions'],
          totalPrice: (i['totalPrice'] as num).toDouble(),
        );
      }
    }).toList() ?? [],
    subtotal: (json['subtotal'] as num).toDouble(),
    deliveryFee: (json['delivery_fee'] as num).toDouble(),
    total: (json['total'] as num).toDouble(),
    paymentMethod: json['payment_method'],
    status: json['status'],
    createdAt: DateTime.parse(json['created_at']),
    deliveryAddress: Address.fromJson(json['delivery_address']),
    notes: json['notes'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'order_number': orderNumber,
    'items': items.map((i) => i.toJson()).toList(),
    'subtotal': subtotal,
    'delivery_fee': deliveryFee,
    'total': total,
    'payment_method': paymentMethod,
    'status': status,
    'created_at': createdAt.toIso8601String(),
    'delivery_address': deliveryAddress.toJson(),
    'notes': notes,
  };
}

class Address {
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final String? apartment;
  final String? phone;

  Address({
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    this.apartment,
    this.phone,
  });

  String get fullAddress {
    String full = '$street, $city, $state $zipCode, $country';
    if (apartment != null && apartment!.isNotEmpty) {
      full = '${apartment!}, $full';
    }
    return full;
  }

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    street: json['street'],
    city: json['city'],
    state: json['state'],
    zipCode: json['zip_code'],
    country: json['country'],
    apartment: json['apartment'],
    phone: json['phone'],
  );

  Map<String, dynamic> toJson() => {
    'street': street,
    'city': city,
    'state': state,
    'zip_code': zipCode,
    'country': country,
    'apartment': apartment,
    'phone': phone,
  };
}