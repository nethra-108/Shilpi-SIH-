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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HomeAppBar(onProfileTap: onProfileTap),
              const SizedBox(height: 24),
              _SearchBar(onTap: onSearchTap),
              const SizedBox(height: 24),
              const _FeaturedBanner(),
              const SizedBox(height: 32),
              const _CategoriesRow(),
              const SizedBox(height: 32),
              const _FeaturedArtisansRow(),
              const SizedBox(height: 80), // Space for FAB
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
      greeting = LanguageService.instance.tr('greeting_afternoon') ?? 'Good Afternoon';
    } else if (hour >= 17) {
      greeting = LanguageService.instance.tr('greeting_evening') ?? 'Good Evening';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting.replaceAll('🌅', '').replaceAll('☀️', '').replaceAll('🌙', '').trim(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'What are you looking for today?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B4332),
                  fontFamily: 'Inter',
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Color(0xFF1B4332), size: 28),
              onPressed: () {},
            ),
            GestureDetector(
              onTap: onProfileTap,
              child: const CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFFE8F5E9),
                child: Icon(Icons.person, color: Color(0xFF1B4332)),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Search for handmade products...',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14, fontFamily: 'Inter'),
              ),
            ),
            const Icon(Icons.mic_none, color: Color(0xFF1B4332)),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1B4332),
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(
          image: const NetworkImage('https://images.unsplash.com/photo-1610715936287-6c2ad208cdbf?auto=format&fit=crop&w=800&q=80'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B4332).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Real People.\nReal Crafts.\nReal Stories.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
              height: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1B4332),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            child: const Text('Shop Now', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter')),
          )
        ],
      ),
    );
  }
}

class _CategoriesRow extends StatelessWidget {
  const _CategoriesRow();

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'name': 'Pottery', 'icon': Icons.coffee_maker, 'color': Colors.green.shade100, 'iconColor': Colors.green.shade800},
      {'name': 'Textiles', 'icon': Icons.checkroom, 'color': Colors.pink.shade100, 'iconColor': Colors.pink.shade800},
      {'name': 'Jewellery', 'icon': Icons.diamond, 'color': Colors.amber.shade100, 'iconColor': Colors.amber.shade800},
      {'name': 'Woodwork', 'icon': Icons.chair, 'color': Colors.brown.shade100, 'iconColor': Colors.brown.shade800},
      {'name': 'Decor', 'icon': Icons.home, 'color': Colors.blue.shade100, 'iconColor': Colors.blue.shade800},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: categories.map((cat) {
          return Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: cat['color'] as Color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(cat['icon'] as IconData, color: cat['iconColor'] as Color, size: 28),
                ),
                const SizedBox(height: 8),
                Text(
                  cat['name'] as String,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1B4332),
                    fontFamily: 'Inter',
                  ),
                ),
              ],
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
      {'name': 'Meenakshi Devi', 'craft': 'Terracotta Pottery', 'image': 'https://images.unsplash.com/photo-1552528148-356bc0c5765c?auto=format&fit=crop&w=400&q=80'},
      {'name': 'Ramesh Kumar', 'craft': 'Wooden Sculptures', 'image': 'https://images.unsplash.com/photo-1605369651581-2292cefc2754?auto=format&fit=crop&w=400&q=80'},
      {'name': 'Lakshmi Bai', 'craft': 'Handwoven Sarees', 'image': 'https://images.unsplash.com/photo-1589156229687-496a31ad1d1f?auto=format&fit=crop&w=400&q=80'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Featured Artisans',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B4332),
                fontFamily: 'Inter',
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('See All >', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            )
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: artisans.map((artisan) {
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        image: DecorationImage(
                          image: NetworkImage(artisan['image']!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            artisan['name']!,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1B4332), fontFamily: 'Inter'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            artisan['craft']!,
                            style: const TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'Inter'),
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
