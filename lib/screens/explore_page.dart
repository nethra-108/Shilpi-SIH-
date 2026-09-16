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

class ExplorePage extends StatefulWidget {
  final void Function(Product) onOpen;

  const ExplorePage({super.key, required this.onOpen});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  String selectedCategory = 'All';

  final List<String> categories = const <String>[
    'All',
    'Pottery',
    'Textiles',
    'Jewellery',
    'Bamboo',
    'Woodwork',
    'Home Decor',
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ProductRepository.instance,
      builder: (BuildContext context, _) {
        final allProducts = ProductRepository.instance.products;
        final filtered = selectedCategory == 'All'
            ? allProducts
            : allProducts
                .where((p) =>
                    p.category.toLowerCase().contains(selectedCategory.toLowerCase()))
                .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 18, 18, 8),
              child: Text(
                'Explore & Shop',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: ShilpiColors.primaryDark),
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = cat == selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: kGreen,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : kDarkGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      backgroundColor: Colors.white,
                      checkmarkColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? kGreen : const Color(0xFFE0DBD0),
                        ),
                      ),
                      onSelected: (_) {
                        setState(() {
                          selectedCategory = cat;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: Text('No crafts found in this category'),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(18),
                      itemCount: filtered.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.67,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        final Product product = filtered[index];
                        return ProductCard(
                          product: product,
                          onTap: () => widget.onOpen(product),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}