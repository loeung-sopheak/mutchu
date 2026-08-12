class PaymentMethod {
  final String id;
  final String type; // 'credit_card', 'debit_card', 'paypal', 'apple_pay', 'google_pay'
  final String last4;
  final String cardholderName;
  final String expiryDate;
  final bool isDefault;
  final String? brand; // Visa, Mastercard, Amex, etc.

  PaymentMethod({
    required this.id,
    required this.type,
    required this.last4,
    required this.cardholderName,
    required this.expiryDate,
    this.isDefault = false,
    this.brand,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'last4': last4,
    'cardholderName': cardholderName,
    'expiryDate': expiryDate,
    'isDefault': isDefault,
    'brand': brand,
  };

  factory PaymentMethod.fromJson(Map<String, dynamic> json) => PaymentMethod(
    id: json['id'],
    type: json['type'],
    last4: json['last4'],
    cardholderName: json['cardholderName'],
    expiryDate: json['expiryDate'],
    isDefault: json['isDefault'] ?? false,
    brand: json['brand'],
  );
}

class Payment {
  final String id;
  final String orderId;
  final double amount;
  final String method; // 'credit_card', 'cash', 'paypal'
  final String status; // 'pending', 'completed', 'failed', 'refunded'
  final String? transactionId;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  Payment({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.method,
    required this.status,
    this.transactionId,
    required this.timestamp,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'orderId': orderId,
    'amount': amount,
    'method': method,
    'status': status,
    'transactionId': transactionId,
    'timestamp': timestamp.toIso8601String(),
    'metadata': metadata,
  };

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
    id: json['id'],
    orderId: json['orderId'],
    amount: json['amount'],
    method: json['method'],
    status: json['status'],
    transactionId: json['transactionId'],
    timestamp: DateTime.parse(json['timestamp']),
    metadata: json['metadata'],
  );
}