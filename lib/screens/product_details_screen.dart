import 'dart:io';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../models/product.dart';
import '../repositories/cart_repository.dart';
import 'checkout_screen.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;
  final VoidCallback? onAdd;

  const ProductDetailsScreen({
    super.key,
    required this.product,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Craft link copied to clipboard')),
              );
            },
            icon: const Icon(Icons.share_outlined),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Saved to your Favorites')),
              );
            },
            icon: const Icon(Icons.favorite_border),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 7, 14, 12),
          child: Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    CartRepository.instance.addItem(product);
                    if (onAdd != null) onAdd!();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: kGreen,
                        content: Text('Added "${product.name}" to cart'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.shopping_cart_outlined),
                  label: const Text('Add to Cart'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    CartRepository.instance.addItem(product);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) =>
                            CheckoutScreen(total: product.price),
                      ),
                    );
                  },
                  child: const Text('Buy Now'),
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: <Widget>[
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFE6E3D8),
              borderRadius: BorderRadius.circular(22),
              gradient: product.imagePath == null
                  ? const LinearGradient(
                      colors: <Color>[Color(0xFFE6E3D8), Color(0xFFD9E7DD)],
                    )
                  : null,
            ),
            child: (product.imagePath != null && File(product.imagePath!).existsSync())
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.file(
                      File(product.imagePath!),
                      fit: BoxFit.contain,
                    ),
                  )
                : Center(
                    child: Text(
                      product.emoji,
                      style: const TextStyle(fontSize: 110),
                    ),
                  ),
          ),
          const SizedBox(height: 16),

          Text(
            product.name,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
              color: kDarkGreen,
            ),
          ),
          const SizedBox(height: 6),

          Row(
            children: <Widget>[
              Text(
                '⭐ ${product.rating}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(width: 8),
              const Text('•', style: TextStyle(color: Colors.grey)),
              const SizedBox(width: 8),
              const Icon(Icons.verified, size: 16, color: kGreen),
              const SizedBox(width: 4),
              Text(
                product.artisan,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: kDarkGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Text(
                '₹${product.price}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: kDarkGreen,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5EFE9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Fair Price Verified',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: kGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: const <Widget>[
              Chip(label: Text('🌱 Eco Friendly')),
              Chip(label: Text('✓ 100% Authentic')),
              Chip(label: Text('🤝 Direct Artisan Benefit')),
            ],
          ),
          const SizedBox(height: 18),

          if (product.length != null || product.width != null || product.height != null) ...<Widget>[
            const Text(
              'Dimensions',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.straighten, color: kGreen, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    '${product.length ?? "-"} cm (L)  ×  ${product.width ?? "-"} cm (W)  ×  ${product.height ?? "-"} cm (H)',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],

          const Text(
            'About this Craft',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            'Handcrafted ${product.category.toLowerCase()} crafted from ${product.material}. '
            'Craft technique: ${product.craftType}. Created directly by ${product.artisan} in ${product.location}.',
            style: const TextStyle(height: 1.4, fontSize: 14),
          ),
          const SizedBox(height: 20),

          const Text(
            'The Story Behind This Craft',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              product.story,
              style: const TextStyle(height: 1.45, fontSize: 14, color: Colors.black87),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: <Widget>[
              const Icon(Icons.location_on, color: kGreen, size: 18),
              const SizedBox(width: 6),
              Text(
                product.location,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
