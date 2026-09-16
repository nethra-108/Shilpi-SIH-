import 'dart:io';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../repositories/wishlist_repository.dart';
import '../theme/colors.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: ShilpiColors.surfaceMuted,
                    ),
                    child: (product.imagePath != null)
                        ? (product.imagePath!.startsWith('http') 
                            ? Image.network(product.imagePath!, fit: BoxFit.cover)
                            : (File(product.imagePath!).existsSync() ? Image.file(File(product.imagePath!), fit: BoxFit.cover) : Center(child: Text(product.emoji, style: const TextStyle(fontSize: 60)))))
                        : Center(child: Text(product.emoji, style: const TextStyle(fontSize: 60))),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: ListenableBuilder(
                      listenable: WishlistRepository.instance,
                      builder: (context, _) {
                        final isSaved = WishlistRepository.instance.isSaved(product.id);
                        return Material(
                          color: Colors.white.withOpacity(0.9),
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => WishlistRepository.instance.toggleSave(product.id),
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Icon(
                                isSaved ? Icons.favorite : Icons.favorite_border,
                                size: 18,
                                color: isSaved ? Colors.red : ShilpiColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: ShilpiColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.artisan,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: ShilpiColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${product.price}',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: ShilpiColors.primaryDark),
                      ),
                      if (product.rating > 0)
                        Row(
                          children: [
                            const Icon(Icons.star, size: 14, color: ShilpiColors.warning),
                            const SizedBox(width: 4),
                            Text(
                              product.rating.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
