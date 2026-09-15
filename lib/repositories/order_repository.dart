import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/cart_item.dart';
import '../models/order.dart';

class OrderRepository extends ChangeNotifier {
  static final OrderRepository instance = OrderRepository._internal();

  OrderRepository._internal();

  final List<ShilpiOrder> _orders = <ShilpiOrder>[];
  bool _isLoaded = false;

  List<ShilpiOrder> get orders => List<ShilpiOrder>.unmodifiable(_orders);

  Future<void> init() async {
    if (_isLoaded) return;
    await _loadFromDisk();
    _isLoaded = true;
  }

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/shilpi_orders.json');
  }

  Future<void> _loadFromDisk() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final dynamic decoded = jsonDecode(content);
          if (decoded is List) {
            _orders.clear();
            for (final item in decoded) {
              if (item is Map<String, dynamic>) {
                _orders.add(ShilpiOrder.fromJson(item));
              }
            }
            if (_orders.isNotEmpty) {
              notifyListeners();
              return;
            }
          }
        }
      }
    } catch (_) {}

    _seedInitialOrders();
    await _saveToDisk();
    notifyListeners();
  }

  Future<void> _saveToDisk() async {
    try {
      final file = await _getFile();
      final jsonString = jsonEncode(_orders.map((o) => o.toJson()).toList());
      await file.writeAsString(jsonString);
    } catch (_) {}
  }

  Future<ShilpiOrder> createOrder({
    required List<CartItem> items,
    required String customerName,
    required String address,
    String paymentMethod = 'UPI / Card / Cash on Delivery',
  }) async {
    final int subtotal = items.fold<int>(0, (sum, i) => sum + i.totalPrice);
    final int orderNum = 1024 + _orders.length;
    final order = ShilpiOrder(
      orderId: '#SH$orderNum',
      items: List<CartItem>.from(items),
      total: subtotal,
      deliveryFee: 60,
      status: 'Order Placed',
      customerName: customerName.trim().isEmpty ? 'Valued Craft Patron' : customerName.trim(),
      deliveryAddress: address.trim().isEmpty ? 'Hyderabad, Telangana' : address.trim(),
      paymentMethod: paymentMethod,
      createdAt: DateTime.now(),
    );

    _orders.insert(0, order);
    await _saveToDisk();
    notifyListeners();
    return order;
  }

  List<ShilpiOrder> getOrdersForSeller(List<String> sellerProductNames) {
    if (sellerProductNames.isEmpty) {
      return orders;
    }
    final normalized = sellerProductNames.map((e) => e.toLowerCase()).toSet();
    return _orders.where((order) {
      return order.items.any((item) => normalized.contains(item.product.name.toLowerCase()));
    }).toList();
  }

  int getSellerRevenue(List<String> sellerProductNames) {
    if (sellerProductNames.isEmpty) {
      return _orders.fold<int>(0, (sum, o) => sum + o.total);
    }
    final normalized = sellerProductNames.map((e) => e.toLowerCase()).toSet();
    int sum = 0;
    for (final order in _orders) {
      for (final item in order.items) {
        if (normalized.contains(item.product.name.toLowerCase())) {
          sum += item.totalPrice;
        }
      }
    }
    return sum;
  }

  void _seedInitialOrders() {
    _orders.clear();
    _orders.add(
      ShilpiOrder(
        orderId: '#SH1023',
        items: <CartItem>[],
        total: 1250,
        deliveryFee: 60,
        status: 'Delivered',
        customerName: 'Sanjay Verma',
        deliveryAddress: 'Banjara Hills, Hyderabad',
        paymentMethod: 'UPI (PhonePe)',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    );
  }
}
