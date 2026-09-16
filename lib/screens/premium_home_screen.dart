import 'package:flutter/material.dart';
import '../services/language_service.dart';

class PremiumHomeScreen extends StatelessWidget {
  final VoidCallback onProfileTap;
  final VoidCallback onSearchTap;
  
  const PremiumHomeScreen({
    super.key,
    required this.onProfileTap,
    required this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HomeAppBar(onProfileTap: onProfileTap),
              const SizedBox(height: 32),
              _SearchBar(onTap: onSearchTap),
              const SizedBox(height: 32),
              const _FeaturedBanner(),
              const SizedBox(height: 40),
              const _CategoriesRow(),
              const SizedBox(height: 40),
              const _FeaturedArtisansRow(),
              const SizedBox(height: 100), // Breathing room for FAB
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeAppBar extends StatelessWidget {
  final VoidCallback onProfileTap;
  const _HomeAppBar({required this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting = LanguageService.instance.tr('greeting_morning');
    if (hour >= 12 && hour < 17) {
      greeting = LanguageService.instance.tr('greeting_afternoon');
    } else if (hour >= 17) {
      greeting = LanguageService.instance.tr('greeting_evening');
    }
    greeting = greeting.replaceAll('🌅', '').replaceAll('☀️', '').replaceAll('🌙', '').trim();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 6),
              Text(
                LanguageService.instance.tr('discover'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B4332),
                  fontFamily: 'Inter',
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 4)),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Color(0xFF1B4332), size: 26),
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onProfileTap,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                ),
                child: const CircleAvatar(
                  radius: 22,
                  backgroundColor: Color(0xFFE8F5E9),
                  child: Icon(Icons.person, color: Color(0xFF1B4332)),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  final VoidCallback onTap;
  const _SearchBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.grey, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                LanguageService.instance.tr('search_hint'),
                style: TextStyle(color: Colors.grey.shade400, fontSize: 15, fontFamily: 'Inter'),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const VoiceSearchScreen()));
              },
              child: const Icon(Icons.mic_none, color: Color(0xFF1B4332), size: 24),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedBanner extends StatelessWidget {
  const _FeaturedBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B4332).withOpacity(0.2),
            blurRadius: 24,
            offset: const Offset(0, 12),
          )
        ],
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1610715936287-6c2ad208cdbf?auto=format&fit=crop&w=800&q=80'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.8),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            Text(
              LanguageService.instance.tr('real_people'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
                height: 1.25,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AllArtisansScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1B4332),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                shadowColor: Colors.black.withOpacity(0.2),
              ),
              child: Text(LanguageService.instance.tr('shop_now'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'Inter')),
            )
          ],
        ),
      ),
    );
  }
}

class _CategoriesRow extends StatelessWidget {
  const _CategoriesRow();

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'key': 'pottery', 'icon': Icons.coffee_maker, 'color': Colors.green.shade50, 'iconColor': Colors.green.shade800},
      {'key': 'textiles', 'icon': Icons.checkroom, 'color': Colors.pink.shade50, 'iconColor': Colors.pink.shade800},
      {'key': 'jewellery', 'icon': Icons.diamond, 'color': Colors.amber.shade50, 'iconColor': Colors.amber.shade800},
      {'key': 'woodwork', 'icon': Icons.chair, 'color': Colors.brown.shade50, 'iconColor': Colors.brown.shade800},
      {'key': 'decor', 'icon': Icons.home, 'color': Colors.blue.shade50, 'iconColor': Colors.blue.shade800},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: categories.map((cat) {
          final translatedName = LanguageService.instance.tr(cat['key'] as String);
          return GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => CategoryDetailScreen(category: translatedName)));
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 28.0),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: cat['color'] as Color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: (cat['iconColor'] as Color).withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 6)),
                      ],
                    ),
                    child: Icon(cat['icon'] as IconData, color: cat['iconColor'] as Color, size: 30),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    translatedName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B4332),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FeaturedArtisansRow extends StatelessWidget {
  const _FeaturedArtisansRow();

  @override
  Widget build(BuildContext context) {
    final artisans = [
      {'name': 'Meenakshi Devi', 'craft_key': 'pottery', 'image': 'https://images.unsplash.com/photo-1552528148-356bc0c5765c?auto=format&fit=crop&w=400&q=80'},
      {'name': 'Ramesh Kumar', 'craft_key': 'woodwork', 'image': 'https://images.unsplash.com/photo-1605369651581-2292cefc2754?auto=format&fit=crop&w=400&q=80'},
      {'name': 'Lakshmi Bai', 'craft_key': 'textiles', 'image': 'https://images.unsplash.com/photo-1589156229687-496a31ad1d1f?auto=format&fit=crop&w=400&q=80'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              LanguageService.instance.tr('featured_artisans'),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B4332),
                fontFamily: 'Inter',
                letterSpacing: -0.5,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AllArtisansScreen()));
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1B4332),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(LanguageService.instance.tr('see_all'), style: const TextStyle(fontWeight: FontWeight.bold)),
            )
          ],
        ),
        const SizedBox(height: 20),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: artisans.map((artisan) {
              return Container(
                width: 170,
                margin: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 140,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        image: DecorationImage(
                          image: NetworkImage(artisan['image']!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            artisan['name']!,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1B4332), fontFamily: 'Inter'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            LanguageService.instance.tr(artisan['craft_key']!),
                            style: const TextStyle(color: Colors.grey, fontSize: 13, fontFamily: 'Inter'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            }).toList(),
          ),
        )
      ],
    );
  }
}

// ==========================================
// PLACEHOLDER SCREENS FOR NAVIGATION
// ==========================================

class AiChatScreen extends StatelessWidget {
  const AiChatScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Assistant')),
      body: const Center(child: Text('AI Chat Implementation Here')),
    );
  }
}

class VoiceSearchScreen extends StatelessWidget {
  const VoiceSearchScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voice Search')),
      body: const Center(child: Text('Listening...')),
    );
  }
}

class CategoryDetailScreen extends StatelessWidget {
  final String category;
  const CategoryDetailScreen({super.key, required this.category});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(category)),
      body: Center(child: Text('Explore $category crafts')),
    );
  }
}

class AllArtisansScreen extends StatelessWidget {
  const AllArtisansScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Artisans')),
      body: const Center(child: Text('List of all artisans here')),
    );
  }
}
