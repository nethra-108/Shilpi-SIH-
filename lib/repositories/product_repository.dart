import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/product.dart';

class ProductRepository extends ChangeNotifier {
  static final ProductRepository instance = ProductRepository._internal();

  ProductRepository._internal();

  final List<Product> _products = <Product>[];
  bool _isLoaded = false;

  List<Product> get products => List<Product>.unmodifiable(_products);

  List<Product> get sellerProducts =>
      List<Product>.unmodifiable(_products.where((p) => p.isSellerProduct));

  Future<void> init() async {
    if (_isLoaded) return;
    await _loadFromDisk();
    _isLoaded = true;
  }

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/shilpi_products.json');
  }

  Future<void> _loadFromDisk() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final dynamic decoded = jsonDecode(content);
          if (decoded is List) {
            _products.clear();
            for (final item in decoded) {
              if (item is Map<String, dynamic>) {
                _products.add(Product.fromJson(item));
              }
            }
            if (_products.isNotEmpty) {
              notifyListeners();
              return;
            }
          }
        }
      }
    } catch (_) {}

    // Seed defaults if no persisted items
    _seedDefaultProducts();
    await _saveToDisk();
    notifyListeners();
  }

  Future<void> _saveToDisk() async {
    try {
      final file = await _getFile();
      final jsonString = jsonEncode(_products.map((p) => p.toJson()).toList());
      await file.writeAsString(jsonString);
    } catch (_) {}
  }

  Future<void> addProduct(Product product) async {
    _products.insert(0, product);
    await _saveToDisk();
    notifyListeners();
  }

  List<Product> search(String query) {
    if (query.trim().isEmpty) return products;
    final q = query.trim().toLowerCase();
    return _products.where((p) {
      final text =
          '${p.name} ${p.category} ${p.material} ${p.craftType} ${p.artisan} ${p.location} ${p.story}'
              .toLowerCase();
      return text.contains(q);
    }).toList();
  }

  List<Product> searchAdvanced({
    String? keyword,
    int? maxPrice,
    String? category,
    String? material,
  }) {
    return _products.where((p) {
      if (maxPrice != null && maxPrice > 0 && p.price > maxPrice) {
        return false;
      }
      if (category != null && category.isNotEmpty) {
        if (!p.category.toLowerCase().contains(category.toLowerCase())) {
          return false;
        }
      }
      if (material != null && material.isNotEmpty) {
        if (!p.material.toLowerCase().contains(material.toLowerCase())) {
          return false;
        }
      }
      if (keyword != null && keyword.isNotEmpty) {
        final text =
            '${p.name} ${p.category} ${p.material} ${p.craftType} ${p.artisan} ${p.location} ${p.story}'
                .toLowerCase();
        if (!text.contains(keyword.toLowerCase())) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  void _seedDefaultProducts() {
    _products.clear();
    _products.addAll(<Product>[
      Product(
        id: 'p_terracotta_pot',
        name: 'Handmade Terracotta Pot',
        category: 'Pottery',
        artisan: 'Meenakshi Devi',
        location: 'Warangal, Telangana',
        material: 'Natural clay',
        craftType: 'Wheel-thrown Pottery',
        emoji: '🏺',
        price: 850,
        marketLow: 700,
        marketHigh: 1000,
        stock: 8,
        rating: 4.8,
        story:
            'Hand-painted terracotta crafted using a 500-year-old regional pottery tradition passed down through five generations.',
        createdAt: DateTime(2026, 1, 1),
      ),
      Product(
        id: 'p_cotton_saree',
        name: 'Handwoven Cotton Saree',
        category: 'Textiles',
        artisan: 'Lakshmi Weaver Collective',
        location: 'Pochampally, Telangana',
        material: 'Handloom cotton',
        craftType: 'Ikat Handloom Weaving',
        emoji: '🧣',
        price: 1250,
        marketLow: 1100,
        marketHigh: 1500,
        stock: 5,
        rating: 4.7,
        story:
            'Every thread is hand-spun and vegetable-dyed, representing the rich ikat geometric weaving heritage of Telangana.',
        createdAt: DateTime(2026, 1, 2),
      ),
      Product(
        id: 'p_bamboo_basket',
        name: 'Bamboo Storage Basket',
        category: 'Bamboo',
        artisan: 'Ramesh Bamboo Crafts',
        location: 'Adilabad, Telangana',
        material: 'Natural bamboo',
        craftType: 'Artisanal Splint Weaving',
        emoji: '🧺',
        price: 899,
        marketLow: 750,
        marketHigh: 1050,
        stock: 12,
        rating: 4.9,
        story:
            'Woven from resilient native bamboo harvested sustainably from forest groves by tribal artisans.',
        createdAt: DateTime(2026, 1, 3),
      ),
      Product(
        id: 'p_wood_bowl',
        name: 'Handcrafted Wooden Bowl',
        category: 'Woodwork',
        artisan: 'Srinivas Wood Art',
        location: 'Nirmal, Telangana',
        material: 'Indian hardwood',
        craftType: 'Hand-lathe Nirmal Carving',
        emoji: '🥣',
        price: 650,
        marketLow: 550,
        marketHigh: 800,
        stock: 7,
        rating: 4.6,
        story:
            'Hand-sculpted and polished with beeswax following traditional Nirmal craft woodworking disciplines.',
        createdAt: DateTime(2026, 1, 4),
      ),
      Product(
        id: 'p_silver_earrings',
        name: 'Tribal Silver Earrings',
        category: 'Jewellery',
        artisan: 'Asha Tribal Crafts',
        location: 'Bastar, Chhattisgarh',
        material: 'Silver alloy',
        craftType: 'Dhokra Lost-Wax Casting',
        emoji: '💎',
        price: 1400,
        marketLow: 1200,
        marketHigh: 1700,
        stock: 4,
        rating: 4.8,
        story:
            'Ancient lost-wax bell-metal technique capturing sacred tribal motifs and celestial nature symbols.',
        createdAt: DateTime(2026, 1, 5),
      ),
      Product(
        id: 'p_palm_decor',
        name: 'Palm Leaf Wall Decor',
        category: 'Home Decor',
        artisan: 'Savita Craft Group',
        location: 'Karnataka',
        material: 'Palm leaf',
        craftType: 'Braided Palm Weave',
        emoji: '🌿',
        price: 450,
        marketLow: 350,
        marketHigh: 600,
        stock: 10,
        rating: 4.7,
        story:
            'Eco-friendly sustainable wall decoration braided by self-help women artisans from sun-dried palm fronds.',
        createdAt: DateTime(2026, 1, 6),
      ),
    ]);
  }
}
