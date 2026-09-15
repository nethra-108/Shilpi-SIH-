import 'cart_item.dart';

class ShilpiOrder {
  final String orderId;
  final List<CartItem> items;
  final int total;
  final int deliveryFee;
  final String status;
  final String customerName;
  final String deliveryAddress;
  final String paymentMethod;
  final DateTime createdAt;

  const ShilpiOrder({
    required this.orderId,
    required this.items,
    required this.total,
    this.deliveryFee = 60,
    this.status = 'Order Placed',
    required this.customerName,
    required this.deliveryAddress,
    this.paymentMethod = 'UPI / Cash on Delivery',
    required this.createdAt,
  });

  int get grandTotal => total + deliveryFee;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'orderId': orderId,
      'items': items.map((CartItem e) => e.toJson()).toList(),
      'total': total,
      'deliveryFee': deliveryFee,
      'status': status,
      'customerName': customerName,
      'deliveryAddress': deliveryAddress,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ShilpiOrder.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawItems = (json['items'] as List<dynamic>?) ?? <dynamic>[];
    return ShilpiOrder(
      orderId: json['orderId']?.toString() ?? '',
      items: rawItems
          .map((dynamic item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
      deliveryFee: (json['deliveryFee'] as num?)?.toInt() ?? 60,
      status: json['status']?.toString() ?? 'Order Placed',
      customerName: json['customerName']?.toString() ?? 'Artisan Patron',
      deliveryAddress: json['deliveryAddress']?.toString() ?? 'Warangal, Telangana',
      paymentMethod: json['paymentMethod']?.toString() ?? 'UPI / Cash on Delivery',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
