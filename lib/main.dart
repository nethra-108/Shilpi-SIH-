import 'dart:io';

import 'package:flutter/material.dart';

import 'constants.dart';
import 'models/order.dart';
import 'models/product.dart';
import 'repositories/cart_repository.dart';
import 'repositories/order_repository.dart';
import 'repositories/product_repository.dart';
import 'screens/add_product_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/product_details_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/voice_capture_dialog.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ShilpiApp());
}

class ShilpiApp extends StatelessWidget {
  const ShilpiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shilpi',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: kCream,
        colorScheme: ColorScheme.fromSeed(seedColor: kGreen),
        appBarTheme: const AppBarTheme(
          backgroundColor: kCream,
          foregroundColor: kDarkGreen,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      home: const SplashScreen(nextScreen: MainPage()),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedTab = 0;

  void openProduct(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(
          product: product,
          onAdd: () {
            setState(() {});
          },
        ),
      ),
    );
  }

  void searchProducts(String query) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchPage(
          query: query,
          onOpen: openProduct,
        ),
      ),
    );
  }

  Future<void> addSellerProduct() async {
    final Product? product = await Navigator.push<Product>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddProductScreen(),
      ),
    );

    if (product != null) {
      setState(() {
        selectedTab = 4;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: kGreen,
          content: Text('🎉 "${product.name}" is now live on Shilpi!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      ConsumerHome(
        onOpen: openProduct,
        onSearch: searchProducts,
      ),
      ExplorePage(onOpen: openProduct),
      const CartPage(),
      const OrdersPage(),
      SellerPage(
        onAdd: addSellerProduct,
      ),
    ];

    return Scaffold(
      body: SafeArea(child: pages[selectedTab]),
      bottomNavigationBar: ListenableBuilder(
        listenable: CartRepository.instance,
        builder: (context, _) {
          final int cartCount = CartRepository.instance.itemCount;
          return NavigationBar(
            selectedIndex: selectedTab,
            onDestinationSelected: (int index) {
              setState(() {
                selectedTab = index;
              });
            },
            destinations: <NavigationDestination>[
              const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              const NavigationDestination(
                icon: Icon(Icons.search),
                label: 'Explore',
              ),
              NavigationDestination(
                icon: cartCount > 0
                    ? Badge(
                        label: Text('$cartCount'),
                        child: const Icon(Icons.shopping_cart_outlined),
                      )
                    : const Icon(Icons.shopping_cart_outlined),
                selectedIcon: cartCount > 0
                    ? Badge(
                        label: Text('$cartCount'),
                        child: const Icon(Icons.shopping_cart),
                      )
                    : const Icon(Icons.shopping_cart),
                label: 'Cart',
              ),
              const NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long),
                label: 'Orders',
              ),
              const NavigationDestination(
                icon: Icon(Icons.storefront_outlined),
                selectedIcon: Icon(Icons.storefront),
                label: 'Sell',
              ),
            ],
          );
        },
      ),
    );
  }
}

class ConsumerHome extends StatefulWidget {
  final void Function(Product) onOpen;
  final void Function(String) onSearch;

  const ConsumerHome({
    super.key,
    required this.onOpen,
    required this.onSearch,
  });

  @override
  State<ConsumerHome> createState() => _ConsumerHomeState();
}

class _ConsumerHomeState extends State<ConsumerHome> {
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> voiceSearch() async {
    final VoiceResult? result = await showDialog<VoiceResult>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => const VoiceCaptureDialog(
        title: '🎙️ Voice Search',
        instruction: 'Speak naturally in your own language (Telugu, Hindi, English).',
      ),
    );

    if (!mounted || result == null || result.text.trim().isEmpty) return;

    searchController.text = result.text.trim();

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: <Widget>[
              Icon(Icons.mic, color: kGreen),
              SizedBox(width: 8),
              Text('Speech Recognized', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '"${result.text.trim()}"',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: kDarkGreen,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5EFE9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Detected Language: ${languageName(result.language)}',
                    style: const TextStyle(color: kGreen, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Edit'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext);
                widget.onSearch(
                  smartSearchQuery(result.text.trim()),
                );
              },
              icon: const Icon(Icons.search),
              label: const Text('Search'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ProductRepository.instance,
      builder: (context, _) {
        final products = ProductRepository.instance.products;

        return CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const CircleAvatar(
                          backgroundColor: kGreen,
                          radius: 20,
                          child: Icon(Icons.eco, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'SHILPI',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                  color: kDarkGreen,
                                ),
                              ),
                              Text(
                                'Artisans to a Brighter Tomorrow',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('No new notifications')),
                            );
                          },
                          icon: const Icon(Icons.notifications_none),
                        ),
                        IconButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Favorites feature coming soon')),
                            );
                          },
                          icon: const Icon(Icons.favorite_border),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: searchController,
                      onSubmitted: widget.onSearch,
                      decoration: InputDecoration(
                        hintText: 'Search handmade crafts, artisans...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          onPressed: voiceSearch,
                          icon: const Icon(Icons.mic, color: kGreen),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        gradient: const LinearGradient(
                          colors: <Color>[Color(0xFF075C45), Color(0xFF2A8063)],
                        ),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Real Hands.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'Brighter Futures.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Artisans to a Brighter Tomorrow • Discover authentic crafts directly from local artisans.',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Shop by Category',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: kDarkGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 94,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: <Widget>[
                          categoryTile('🏺', 'Pottery', () => widget.onSearch('Pottery')),
                          categoryTile('🧣', 'Textiles', () => widget.onSearch('Textiles')),
                          categoryTile('💎', 'Jewellery', () => widget.onSearch('Jewellery')),
                          categoryTile('🧺', 'Bamboo', () => widget.onSearch('Bamboo')),
                          categoryTile('🥣', 'Woodwork', () => widget.onSearch('Woodwork')),
                          categoryTile('🌿', 'Decor', () => widget.onSearch('Decor')),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Featured Crafts',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: kDarkGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    final Product product = products[index];
                    return ProductCard(
                      product: product,
                      onTap: () => widget.onOpen(product),
                    );
                  },
                  childCount: products.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.67,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget categoryTile(String emoji, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 78,
        child: Column(
          children: <Widget>[
            CircleAvatar(
              radius: 26,
              backgroundColor: Colors.white,
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 22),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 135,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: product.imagePath == null
                    ? const LinearGradient(
                        colors: <Color>[Color(0xFFE6E3D8), Color(0xFFD9E7DD)],
                      )
                    : null,
                color: const Color(0xFFF4F1EA),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: (product.imagePath != null &&
                        File(product.imagePath!).existsSync())
                    ? Image.file(
                        File(product.imagePath!),
                        fit: BoxFit.contain,
                      )
                    : Center(
                        child: Text(
                          product.emoji,
                          style: const TextStyle(fontSize: 65),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            Text(
              product.artisan,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '⭐ ${product.rating}',
              style: const TextStyle(fontSize: 11),
            ),
            const Spacer(),
            Text(
              '₹${product.price}',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: kDarkGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  color: kDarkGreen,
                ),
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

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CartRepository.instance,
      builder: (BuildContext context, _) {
        final cartRepo = CartRepository.instance;
        final items = cartRepo.items;

        return Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 18, 18, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Your Cart',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    color: kDarkGreen,
                  ),
                ),
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? const Center(
                      child: Text(
                        '🛒\nYour cart is empty',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(18),
                      itemCount: items.length,
                      itemBuilder: (BuildContext context, int index) {
                        final item = items[index];
                        final product = item.product;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: const <BoxShadow>[
                              BoxShadow(
                                color: Color(0x0A000000),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  width: 54,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE6E3D8),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: (product.imagePath != null &&
                                            File(product.imagePath!).existsSync())
                                        ? Image.file(
                                            File(product.imagePath!),
                                            fit: BoxFit.contain,
                                          )
                                        : Center(
                                            child: Text(
                                              product.emoji,
                                              style: const TextStyle(fontSize: 26),
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        product.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        '₹${product.price} each',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '₹${item.totalPrice}',
                                        style: const TextStyle(
                                          color: kDarkGreen,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: <Widget>[
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      icon: const Icon(Icons.remove_circle_outline,
                                          color: Colors.grey),
                                      onPressed: () => cartRepo.decrement(product),
                                    ),
                                    Text(
                                      '${item.quantity}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      icon: const Icon(Icons.add_circle_outline,
                                          color: kGreen),
                                      onPressed: () => cartRepo.increment(product),
                                    ),
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      icon: const Icon(Icons.delete_outline,
                                          color: Colors.redAccent),
                                      onPressed: () => cartRepo.removeItem(product),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            if (items.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Color(0x10000000),
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const Text('Subtotal', style: TextStyle(color: Colors.grey)),
                        Text('₹${cartRepo.subtotal}',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const Text('Delivery', style: TextStyle(color: Colors.grey)),
                        Text(
                          cartRepo.deliveryFee == 0 ? 'FREE' : '₹${cartRepo.deliveryFee}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: kGreen),
                        ),
                      ],
                    ),
                    const Divider(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: kDarkGreen,
                          ),
                        ),
                        Text(
                          '₹${cartRepo.total}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: kDarkGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  CheckoutScreen(total: cartRepo.total),
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: kGreen,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Proceed to Checkout',
                          style:
                              TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: OrderRepository.instance,
      builder: (BuildContext context, _) {
        final orders = OrderRepository.instance.orders;
        return ListView(
          padding: const EdgeInsets.all(18),
          children: <Widget>[
            const Text(
              'My Orders',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w900,
                color: kDarkGreen,
              ),
            ),
            const SizedBox(height: 14),
            if (orders.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text(
                    '📦\nNo orders yet',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
              ),
            ...orders.map<Widget>((ShilpiOrder order) {
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x0C000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const CircleAvatar(
                          backgroundColor: Color(0xFFE6E3D8),
                          child: Icon(Icons.inventory_2_outlined, color: kDarkGreen),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                order.orderId,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                  color: kDarkGreen,
                                ),
                              ),
                              Text(
                                '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}  •  ${order.items.length} item(s)',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: order.status == 'Delivered'
                                ? const Color(0xFFE5EFE9)
                                : const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            order.status,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: order.status == 'Delivered' ? kGreen : kOrange,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    ...order.items.map<Widget>((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              '${item.product.emoji} ${item.product.name} × ${item.quantity}',
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              '₹${item.totalPrice}',
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    }),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Payment: ${order.paymentMethod}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          'Total: ₹${order.total}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: kDarkGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

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
        final products = ProductRepository.instance.sellerProducts;
        final int totalEarned = 12450 + (products.length * 850);

        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 25),
          children: <Widget>[
            const Text(
              'My Craft Store',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w900,
                color: kDarkGreen,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  colors: <Color>[Color(0xFF075C45), Color(0xFF2A8063)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Hello, Artisan 👋',
                    style: TextStyle(color: Colors.white70),
                  ),
                  Text(
                    '₹$totalEarned',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Text(
                    'Total Sales  •  ↑ 12% this month',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                sellerStat('${products.length + 3}', 'Products'),
                sellerStat('12', 'Orders'),
                sellerStat('1.2k', 'Views'),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                style: FilledButton.styleFrom(
                  backgroundColor: kGreen,
                  padding: const EdgeInsets.all(14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                label: const Text(
                  'Add Product (Voice Assisted)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'AI Business Insights',
              style: TextStyle(
                  fontSize: 19, fontWeight: FontWeight.w900, color: kDarkGreen),
            ),
            sellerInsight('🔥 High demand',
                'Bamboo home decor & terracotta pots are trending in Hyderabad.'),
            sellerInsight(
              '🛡 Fair Price Protection',
              'AI flags predatory offers below regional fair craftsmanship value.',
            ),
            sellerInsight(
              '📈 Demand Prediction',
              'Festival season approaching: expect +35% higher handicraft demand.',
            ),
            const SizedBox(height: 18),
            const Text(
              'My Products',
              style: TextStyle(
                  fontSize: 19, fontWeight: FontWeight.w900, color: kDarkGreen),
            ),
            if (products.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(
                    'No custom products added yet. Tap Add Product to start with voice!'),
              ),
            ...products.map<Widget>((Product product) {
              return Container(
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6E3D8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: (product.imagePath != null &&
                              File(product.imagePath!).existsSync())
                          ? Image.file(File(product.imagePath!), fit: BoxFit.cover)
                          : Center(
                              child: Text(product.emoji,
                                  style: const TextStyle(fontSize: 24))),
                    ),
                  ),
                  title: Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '₹${product.price} • ${product.stock} in stock • ${product.craftType}',
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

Widget sellerStat(String value, String label) {
  return Expanded(
    child: Container(
      margin: const EdgeInsets.only(right: 7),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: <Widget>[
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget sellerInsight(String title, String subtitle) {
  return Container(
    margin: const EdgeInsets.only(top: 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: <Widget>[
        const Icon(Icons.auto_awesome, color: kGreen),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
