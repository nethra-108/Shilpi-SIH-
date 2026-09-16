import 'dart:io';
import 'dart:math';
import 'repositories/wishlist_repository.dart';
import 'repositories/recent_repository.dart';
import 'screens/seller_orders_page.dart';
import 'services/shilpi_ai_service.dart';
import 'services/language_service.dart';
import 'screens/premium_home_screen.dart';

import 'theme/theme.dart';
import 'theme/colors.dart';
import 'widgets/empty_state.dart';
import 'widgets/app_card.dart';
import 'widgets/product_card.dart';

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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LanguageService.instance.init();
  runApp(const ShilpiApp());
}

class ShilpiApp extends StatelessWidget {
  const ShilpiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LanguageService.instance,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Shilpi',
          theme: ShilpiTheme.lightTheme,
          home: const SplashScreen(nextScreen: MainPage()),
        );
      }
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (LanguageService.instance.isFirstLaunch) {
        LanguageService.showLanguageDialog(context);
      }
    });
  }

  void _showProfileBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFFE8F5E9),
                child: Icon(Icons.person, size: 40, color: Color(0xFF1B4332)),
              ),
              const SizedBox(height: 16),
              const Text(
                'Demo User',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B4332), fontFamily: 'Inter'),
              ),
              const SizedBox(height: 4),
              const Text(
                'Tech Enthusiast',
                style: TextStyle(fontSize: 14, color: Colors.grey, fontFamily: 'Inter'),
              ),
              const SizedBox(height: 32),
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: Color(0xFF1B4332)),
                title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Inter')),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () => Navigator.pop(context),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF1B4332)),
                title: const Text('My Orders', style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Inter')),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => selectedTab = 3);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red, fontFamily: 'Inter')),
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

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
      PremiumHomeScreen(
        onProfileTap: () {
          _showProfileBottomSheet(context);
        },
        onSearchTap: () {
          setState(() => selectedTab = 1);
        },
        onSearchSubmit: (query) {
          setState(() => selectedTab = 1);
          searchProducts(query);
        },
      ),
      ExplorePage(onOpen: openProduct),
      WishlistPage(onOpen: openProduct), // Real Wishlist at index 2
      const CartPage(), // Real Cart at index 3
      SellerPage(
        onAdd: addSellerProduct,
      ),
    ];

    return Scaffold(
      body: SafeArea(child: pages[selectedTab]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AiChatScreen()));
        },
        backgroundColor: Colors.orange.shade700,
        child: const Icon(Icons.auto_awesome, color: Colors.white),
      ),
      bottomNavigationBar: ListenableBuilder(
        listenable: CartRepository.instance,
        builder: (context, _) {
          final int cartCount = CartRepository.instance.itemCount;
          return Container(
            decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: NavigationBar(
              backgroundColor: Colors.white,
              indicatorColor: const Color(0xFFE8F5E9),
              selectedIndex: selectedTab,
              onDestinationSelected: (int index) {
                setState(() {
                  selectedTab = index;
                });
              },
              destinations: <NavigationDestination>[
                NavigationDestination(
                  icon: Icon(Icons.home_outlined, color: Colors.grey),
                  selectedIcon: Icon(Icons.home, color: Color(0xFF1B4332)),
                  label: LanguageService.instance.tr('home'),
                ),
                NavigationDestination(
                  icon: Icon(Icons.search, color: Colors.grey),
                  selectedIcon: Icon(Icons.search, color: Color(0xFF1B4332)),
                  label: LanguageService.instance.tr('search'),
                ),
                NavigationDestination(
                  icon: Icon(Icons.favorite_border, color: Colors.grey),
                  selectedIcon: Icon(Icons.favorite, color: Color(0xFF1B4332)),
                  label: LanguageService.instance.tr('wishlist'),
                ),
                NavigationDestination(
                  icon: cartCount > 0
                      ? Badge(
                          label: Text('$cartCount'),
                          child: const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
                        )
                      : const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
                  selectedIcon: const Icon(Icons.shopping_bag, color: Color(0xFF1B4332)),
                  label: LanguageService.instance.tr('cart'),
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline, color: Colors.grey),
                  selectedIcon: Icon(Icons.person, color: Color(0xFF1B4332)),
                  label: LanguageService.instance.tr('profile'),
                ),
              ],
            ),
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
  bool _isListeningSimulated = false;

  String _getDynamicGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return LanguageService.instance.tr('greeting_morning');
    } else if (hour < 17) {
      return LanguageService.instance.tr('greeting_afternoon');
    } else {
      return LanguageService.instance.tr('greeting_evening');
    }
  }

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
              child: Text('Edit'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext);
                widget.onSearch(
                  smartSearchQuery(result.text.trim()),
                );
              },
              icon: const Icon(Icons.search),
              label: Text('Search'),
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
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getDynamicGreeting(),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: ShilpiColors.textSecondary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                LanguageService.instance.tr('discover'),
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: ShilpiColors.primaryDark, height: 1.2, letterSpacing: -0.5),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                ),
                                builder: (context) => SafeArea(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(height: 16),
                                      Container(
                                        width: 40,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade300,
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      ListTile(
                                        leading: const Icon(Icons.login, color: ShilpiColors.primary),
                                        title: Text(LanguageService.instance.tr('login_signup'), style: TextStyle(fontWeight: FontWeight.bold)),
                                        onTap: () => Navigator.pop(context),
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.language, color: ShilpiColors.primary),
                                        title: Text(LanguageService.instance.tr('change_language'), style: const TextStyle(fontWeight: FontWeight.bold)),
                                        onTap: () {
                                          Navigator.pop(context);
                                          LanguageService.showLanguageDialog(context, dismissible: true);
                                        },
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.settings, color: ShilpiColors.primary),
                                        title: Text(LanguageService.instance.tr('app_settings'), style: TextStyle(fontWeight: FontWeight.bold)),
                                        onTap: () => Navigator.pop(context),
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                  ),
                                ),
                              );
                            },
                            child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: ShilpiColors.primary, width: 2),
                            ),
                            child: const CircleAvatar(
                              backgroundColor: ShilpiColors.primaryLight,
                              radius: 20,
                              child: Icon(Icons.person, color: ShilpiColors.primary),
                            ),
                          ),
                          )
                        ],
                      ),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: () {},
                        child: TextField(
                          controller: searchController,
                          onSubmitted: widget.onSearch,
                          decoration: InputDecoration(
                            hintText: LanguageService.instance.tr('search_hint'),
                            prefixIcon: const Icon(Icons.search, color: ShilpiColors.textMuted),
                            suffixIcon: IconButton(
                              onPressed: () async {
                                setState(() {
                                  _isListeningSimulated = true;
                                });
                                await Future.delayed(const Duration(seconds: 2));
                                if (mounted) {
                                  setState(() {
                                    _isListeningSimulated = false;
                                  });
                                  voiceSearch();
                                }
                              },
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _isListeningSimulated ? Colors.red.shade50 : ShilpiColors.primaryLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: _isListeningSimulated 
                                  ? const SizedBox(
                                      width: 20, 
                                      height: 20, 
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red),
                                    )
                                  : const Icon(Icons.mic, color: ShilpiColors.primary, size: 20),
                              ),
                            ),
                            filled: true,
                            fillColor: ShilpiColors.surface,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: ShilpiColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: ShilpiColors.border),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            colors: [ShilpiColors.primaryDark, ShilpiColors.primary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: ShilpiColors.secondary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(LanguageService.instance.tr('featured_craft'), style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'The Art of Terracotta',
                              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Support 500-year-old traditions from rural artisans.',
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed: () => widget.onSearch('Pottery'),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: ShilpiColors.primaryDark,
                                minimumSize: const Size(120, 40),
                              ),
                              child: Text(LanguageService.instance.tr('explore_now')),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(LanguageService.instance.tr('browse_by_craft'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: ShilpiColors.primaryDark)),
                          TextButton(
                            onPressed: () => widget.onSearch(''),
                            style: TextButton.styleFrom(foregroundColor: ShilpiColors.primary),
                            child: Text(LanguageService.instance.tr('view_all')),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 100,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          clipBehavior: Clip.none,
                          children: [
                            _buildCategoryTile('Pottery', '🏺', () => widget.onSearch('Pottery')),
                            _buildCategoryTile('Textiles', '🧣', () => widget.onSearch('Textiles')),
                            _buildCategoryTile('Jewellery', '💎', () => widget.onSearch('Jewellery')),
                            _buildCategoryTile('Bamboo', '🧺', () => widget.onSearch('Bamboo')),
                            _buildCategoryTile('Woodwork', '🥣', () => widget.onSearch('Woodwork')),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ListenableBuilder(
                        listenable: WishlistRepository.instance,
                        builder: (context, _) {
                          final savedIds = WishlistRepository.instance.savedProductIds;
                          if (savedIds.isEmpty) return const SizedBox.shrink();
                          final saved = savedIds.map((id) => products.firstWhere((p) => p.id == id, orElse: () => products.first)).toSet().toList();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(LanguageService.instance.tr('your_wishlist'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: ShilpiColors.primaryDark)),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 260,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  clipBehavior: Clip.none,
                                  itemCount: saved.length,
                                  itemBuilder: (context, index) {
                                    final p = saved[index];
                                    return SizedBox(
                                      width: 160,
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 16),
                                        child: ProductCard(product: p, onTap: () => widget.onOpen(p)),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          );
                        }
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(LanguageService.instance.tr('recommended'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: ShilpiColors.primaryDark)),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    final Product product = products[products.length - 1 - index];
                    return ProductCard(
                      product: product,
                      onTap: () => widget.onOpen(product),
                    );
                  },
                  childCount: min(4, products.length),
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.65,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    ListenableBuilder(
                      listenable: RecentRepository.instance,
                      builder: (context, _) {
                        final recentIds = RecentRepository.instance.recentProductIds;
                        if (recentIds.isEmpty) return const SizedBox.shrink();
                        final recents = recentIds.map((id) => products.firstWhere((p) => p.id == id, orElse: () => products.first)).toSet().toList();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(LanguageService.instance.tr('recently_viewed'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: ShilpiColors.primaryDark)),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                clipBehavior: Clip.none,
                                itemCount: recents.length,
                                itemBuilder: (context, index) {
                                  final p = recents[index];
                                  return GestureDetector(
                                    onTap: () => widget.onOpen(p),
                                    child: Container(
                                      width: 100,
                                      margin: const EdgeInsets.only(right: 12),
                                      decoration: BoxDecoration(
                                        color: ShilpiColors.surface,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: ShilpiColors.border),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(p.emoji, style: const TextStyle(fontSize: 40)),
                                          const SizedBox(height: 8),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                            child: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: ShilpiColors.textMuted)),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        );
                      }
                    ),
                    AppCard(
                      color: ShilpiColors.primaryLight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.verified_user, color: ShilpiColors.primary),
                              SizedBox(width: 8),
                              Text(LanguageService.instance.tr('why_shilpi'), style: TextStyle(fontWeight: FontWeight.bold, color: ShilpiColors.primaryDark, fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildTrustRow(Icons.handshake, 'Direct Artisan Benefit', '100% of the sale goes to the maker.'),
                          const SizedBox(height: 12),
                          _buildTrustRow(Icons.qr_code_scanner, 'Digital Provenance', 'Every product has a Craft Passport.'),
                          const SizedBox(height: 12),
                          _buildTrustRow(Icons.auto_awesome, 'AI Powered', 'We use AI to bridge language barriers.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTrustRow(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: ShilpiColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: ShilpiColors.primaryDark)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: ShilpiColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTile(String label, String emoji, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                color: ShilpiColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: ShilpiColors.border),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 28))),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ShilpiColors.textPrimary)),
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
                                    child: (product.imagePath != null)
                                        ? (product.imagePath!.startsWith('http') 
                                            ? Image.network(product.imagePath!, fit: BoxFit.contain)
                                            : (File(product.imagePath!).existsSync() ? Image.file(File(product.imagePath!), fit: BoxFit.contain) : Center(child: Text(product.emoji, style: const TextStyle(fontSize: 26)))))
                                        : Center(child: Text(product.emoji, style: const TextStyle(fontSize: 26))),
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
                        Text('Subtotal', style: TextStyle(color: Colors.grey)),
                        Text('₹${cartRepo.subtotal}',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Delivery', style: TextStyle(color: Colors.grey)),
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
                        Text(
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
                        child: Text(
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
            Text(
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
