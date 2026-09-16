import 'package:flutter/material.dart';
import '../constants.dart';
import '../theme/colors.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../widgets/product_card.dart';
import '../repositories/product_repository.dart';
import '../repositories/cart_repository.dart';
import '../repositories/wishlist_repository.dart';
import '../repositories/order_repository.dart';
import '../services/language_service.dart';
import 'checkout_screen.dart';
import 'add_product_screen.dart';
import 'seller_orders_page.dart';

class WishlistPage extends StatelessWidget {
  final void Function(Product) onOpen;
  
  const WishlistPage({super.key, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Your Wishlist', style: TextStyle(color: Color(0xFF1B4332), fontWeight: FontWeight.bold, fontFamily: 'Inter')),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListenableBuilder(
        listenable: WishlistRepository.instance,
        builder: (context, _) {
          final savedIds = WishlistRepository.instance.savedProductIds;
          final allProducts = ProductRepository.instance.products;
          
          final savedProducts = allProducts.where((p) => savedIds.contains(p.id)).toList();
          
          if (savedProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('No items in your wishlist yet', style: TextStyle(fontSize: 18, color: Colors.grey, fontFamily: 'Inter')),
                  const SizedBox(height: 8),
                  const Text('Tap the heart icon on any product to save it here.', style: TextStyle(fontSize: 14, color: Colors.grey, fontFamily: 'Inter')),
                ],
              ),
            );
          }
          
          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.67,
            ),
            itemCount: savedProducts.length,
            itemBuilder: (BuildContext context, int index) {
              final Product product = savedProducts[index];
              return ProductCard(
                product: product,
                onTap: () => onOpen(product),
              );
            },
          );
        },
      ),
    );
  }
}