import 'package:flutter/material.dart';
import '../services/shilpi_ai_service.dart';
import '../widgets/empty_state.dart';

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

class SellerPage extends StatelessWidget {
  final VoidCallback onAdd;

  const SellerPage({
    super.key,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ProductRepository.instance,
      builder: (BuildContext context, _) {
        return ListenableBuilder(
          listenable: OrderRepository.instance,
          builder: (BuildContext context, _) {
            final products = ProductRepository.instance.sellerProducts;
            final productNames = products.map((p) => p.name).toList();
            final int totalEarned = OrderRepository.instance.getSellerRevenue(productNames);
            final int totalOrders = OrderRepository.instance.getOrdersForSeller(productNames).length;

            return CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('My Craft Store', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: ShilpiColors.primaryDark)),
                          const SizedBox(height: 24),
                          
                          // Revenue Card
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: const LinearGradient(
                                colors: [ShilpiColors.primaryDark, ShilpiColors.primary],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(color: ShilpiColors.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Total Revenue', style: TextStyle(color: Colors.white70, fontSize: 14)),
                                    Icon(Icons.account_balance_wallet, color: Colors.white, size: 20),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text('₹$totalEarned', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -1)),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildMetric(Icons.shopping_bag, 'Orders', totalOrders.toString()),
                                    ),
                                    Container(width: 1, height: 30, color: Colors.white30),
                                    Expanded(
                                      child: _buildMetric(Icons.inventory, 'Products', products.length.toString()),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Quick Actions
                          Row(
                            children: [
                              Expanded(
                                child: _buildQuickAction(
                                  context,
                                  Icons.add_circle,
                                  'Add Product',
                                  ShilpiColors.primaryLight,
                                  ShilpiColors.primaryDark,
                                  onAdd,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildQuickAction(
                                  context,
                                  Icons.list_alt,
                                  'View Orders',
                                  ShilpiColors.secondaryLight,
                                  ShilpiColors.secondary,
                                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SellerOrdersPage())),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('My Products', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: ShilpiColors.primaryDark)),
                              TextButton(
                                onPressed: onAdd,
                                style: TextButton.styleFrom(foregroundColor: ShilpiColors.primary),
                                child: Text('Add New'),
                              )
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
                
                if (products.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.storefront,
                      title: 'Your store is empty',
                      message: 'Add your first handmade product and let Shilpi AI help you write the perfect description.',
                      actionLabel: 'Add Product',
                      onAction: onAdd,
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          final product = products[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: ShilpiColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: ShilpiColors.border),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    color: ShilpiColors.surfaceMuted,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(child: Text(product.emoji, style: const TextStyle(fontSize: 40))),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: ShilpiColors.primaryDark)),
                                      const SizedBox(height: 4),
                                      Text('₹${product.price} • ${product.stock} in stock', style: const TextStyle(fontSize: 13, color: ShilpiColors.textSecondary)),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        children: [
                                          _buildTag('Edit', Icons.edit, () => _showEditDialog(context, product)),
                                          _buildTag('AI Promo', Icons.auto_awesome, () => _showPromoDialog(context, product)),
                                          _buildTag('Delete', Icons.delete, () => ProductRepository.instance.deleteProduct(product.id)),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        childCount: products.length,
                      ),
                    ),
                  ),
                  
                  const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
              ],
            );
          },
        );
      },
    );
  }
  
  Widget _buildMetric(IconData icon, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        )
      ],
    );
  }
  
  Widget _buildQuickAction(BuildContext context, IconData icon, String label, Color bgColor, Color iconColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: iconColor, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTag(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: ShilpiColors.surfaceMuted,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: ShilpiColors.textPrimary),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: ShilpiColors.textPrimary)),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) {
        final priceController = TextEditingController(text: product.price.toString());
        final stockController = TextEditingController(text: product.stock.toString());
        return AlertDialog(
          title: Text('Edit Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price (₹)'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Stock'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            FilledButton(
              onPressed: () {
                final newPrice = int.tryParse(priceController.text) ?? product.price;
                final newStock = int.tryParse(stockController.text) ?? product.stock;
                final updatedProduct = Product(
                  id: product.id,
                  name: product.name,
                  category: product.category,
                  artisan: product.artisan,
                  location: product.location,
                  material: product.material,
                  craftType: product.craftType,
                  emoji: product.emoji,
                  price: newPrice,
                  marketLow: product.marketLow,
                  marketHigh: product.marketHigh,
                  stock: newStock,
                  rating: product.rating,
                  story: product.story,
                  imagePath: product.imagePath,
                  originalImagePath: product.originalImagePath,
                  length: product.length,
                  width: product.width,
                  height: product.height,
                  isSellerProduct: product.isSellerProduct,
                  createdAt: product.createdAt,
                );
                ProductRepository.instance.updateProduct(updatedProduct);
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showPromoDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return FutureBuilder(
          future: ShilpiAiService.instance.ask(
            'Write a short, engaging social media caption for this product. Include hashtags. Keep it concise.',
            AiContextMode.product,
            currentProduct: product,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Shilpi AI is writing...')
                  ],
                ),
              );
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return AlertDialog(
                title: Text('Error'),
                content: Text('Could not generate promo. Please try again later.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: Text('Close'))
                ],
              );
            }
            final text = snapshot.data!.text;
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.auto_awesome, color: ShilpiColors.primary),
                  SizedBox(width: 8),
                  Text('AI Promo', style: TextStyle(color: ShilpiColors.primaryDark)),
                ],
              ),
              content: SingleChildScrollView(child: Text(text, style: const TextStyle(fontSize: 14))),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text('Close')),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.copy, size: 16),
                  label: Text('Done'),
                )
              ],
            );
          }
        );
      }
    );
  }

}