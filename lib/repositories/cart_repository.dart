import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

class CartRepository extends ChangeNotifier {
  static final CartRepository instance = CartRepository._internal();

  CartRepository._internal();

  final List<CartItem> _items = <CartItem>[];
  bool _isLoaded = false;

  List<CartItem> get items => List<CartItem>.unmodifiable(_items);

  int get itemCount => _items.fold<int>(0, (sum, item) => sum + item.quantity);

  int get subtotal => _items.fold<int>(0, (sum, item) => sum + item.totalPrice);

  int get deliveryFee => _items.isEmpty ? 0 : 60;

  int get total => subtotal + deliveryFee;

  bool get isEmpty => _items.isEmpty;

  Future<void> init() async {
    if (_isLoaded) return;
    await _loadFromDisk();
    _isLoaded = true;
  }

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/shilpi_cart.json');
  }

  Future<void> _loadFromDisk() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final dynamic decoded = jsonDecode(content);
          if (decoded is List) {
            _items.clear();
            for (final item in decoded) {
              if (item is Map<String, dynamic>) {
                _items.add(CartItem.fromJson(item));
              }
            }
            notifyListeners();
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _saveToDisk() async {
    try {
      final file = await _getFile();
      final jsonString = jsonEncode(_items.map((i) => i.toJson()).toList());
      await file.writeAsString(jsonString);
    } catch (_) {}
  }

  Future<void> addItem(Product product) async {
    final index = _items.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      _items[index].quantity += 1;
    } else {
      _items.add(CartItem(product: product, quantity: 1));
    }
    await _saveToDisk();
    notifyListeners();
  }

  Future<void> removeItem(Product product) async {
    _items.removeWhere((i) => i.product.id == product.id);
    await _saveToDisk();
    notifyListeners();
  }

  Future<void> increment(Product product) async {
    final index = _items.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      _items[index].quantity += 1;
      await _saveToDisk();
      notifyListeners();
    }
  }

  Future<void> decrement(Product product) async {
    final index = _items.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity -= 1;
      } else {
        _items.removeAt(index);
      }
      await _saveToDisk();
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    _items.clear();
    await _saveToDisk();
    notifyListeners();
  }
}
