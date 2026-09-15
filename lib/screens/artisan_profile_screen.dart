import 'dart:io';
import 'package:flutter/material.dart';
import '../repositories/product_repository.dart';
import '../constants.dart';
import 'product_details_screen.dart';

class ArtisanProfileScreen extends StatelessWidget {
  final String artisanName;

  const ArtisanProfileScreen({
    super.key,
    required this.artisanName,
  });

  @override
  Widget build(BuildContext context) {
    final products = ProductRepository.instance.products
        .where((p) => p.artisan == artisanName)
        .toList();

    String region = 'Unknown Region';
    String specialization = 'Traditional Crafts';
    
    if (products.isNotEmpty) {
      region = products.first.location;
      specialization = products.first.category;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meet the Maker'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFFE6E3D8),
              child: Text(
                artisanName.isNotEmpty ? artisanName[0].toUpperCase() : 'A',
                style: const TextStyle(fontSize: 40, color: kDarkGreen),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  artisanName,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: kDarkGreen),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.verified, color: kGreen, size: 24),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '$specialization Artisan • $region',
              style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Artisan Story',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Dedicated to preserving traditional crafting methods passed down through generations. '
            'Every piece is handmade with authentic, locally sourced materials to ensure quality and cultural heritage.',
            style: TextStyle(fontSize: 15, height: 1.4),
          ),
          const SizedBox(height: 24),
          Text(
            'Crafts by $artisanName',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final p = products[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailsScreen(product: p),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F1EA),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          child: (p.imagePath != null && File(p.imagePath!).existsSync())
                              ? ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                  child: Image.file(File(p.imagePath!), fit: BoxFit.cover),
                                )
                              : Center(child: Text(p.emoji, style: const TextStyle(fontSize: 40))),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text('₹${p.price}', style: const TextStyle(fontWeight: FontWeight.w900, color: kDarkGreen, fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
