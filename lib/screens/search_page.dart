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

class SearchPage extends StatefulWidget {
  final String query;
  final void Function(Product) onOpen;

  const SearchPage({
    super.key,
    required this.query,
    required this.onOpen,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController _searchController;
  late String _currentQuery;

  @override
  void initState() {
    super.initState();
    _currentQuery = widget.query;
    _searchController = TextEditingController(text: widget.query);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Product> matches = ProductRepository.instance.search(_currentQuery);
    final List<Product> shown =
        matches.isEmpty ? ProductRepository.instance.products : matches;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search handmade crafts...',
            border: InputBorder.none,
          ),
          onSubmitted: (val) {
            setState(() {
              _currentQuery = val;
            });
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
            child: Text(
              matches.isEmpty
                  ? 'No exact matches for "$_currentQuery". Showing all crafts:'
                  : '${matches.length} craft(s) found for "$_currentQuery":',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(18),
              itemCount: shown.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.67,
              ),
              itemBuilder: (BuildContext context, int index) {
                final Product product = shown[index];
                return ProductCard(
                  product: product,
                  onTap: () => widget.onOpen(product),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}