import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../services/language_service.dart';
import 'notifications_page.dart';
import '../repositories/notification_repository.dart';

class PremiumHomeScreen extends StatelessWidget {
  final VoidCallback onProfileTap;
  final VoidCallback onSearchTap;
  final void Function(String)? onSearchSubmit;
  
  const PremiumHomeScreen({
    super.key,
    required this.onProfileTap,
    required this.onSearchTap,
    this.onSearchSubmit,
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
              _SearchBar(onTap: onSearchTap, onSearchSubmit: onSearchSubmit),
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
        const SizedBox(width: 12),
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
                icon: const Icon(Icons.language, color: Color(0xFF1B4332), size: 24),
                onPressed: () {
                  LanguageService.showLanguageDialog(context, dismissible: true);
                },
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 4)),
                ],
              ),
              child: IconButton(
                icon: ListenableBuilder(
                  listenable: NotificationRepository.instance,
                  builder: (context, _) {
                    final unreadCount = NotificationRepository.instance.notifications.where((n) => !n.isRead).length;
                    return Badge(
                      isLabelVisible: unreadCount > 0,
                      label: Text('$unreadCount'),
                      child: const Icon(Icons.notifications_outlined, color: Color(0xFF1B4332), size: 24),
                    );
                  },
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsPage()));
                },
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
                  radius: 20,
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
  final void Function(String)? onSearchSubmit;
  const _SearchBar({required this.onTap, this.onSearchSubmit});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: TextField(
        onSubmitted: (query) {
          if (onSearchSubmit != null && query.isNotEmpty) {
            onSearchSubmit!(query);
          }
        },
        decoration: InputDecoration(
          hintText: LanguageService.instance.tr('search_hint'),
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15, fontFamily: 'Inter'),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 16.0, right: 12.0),
            child: Icon(Icons.search, color: Colors.grey, size: 22),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 40),
          suffixIcon: GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const VoiceSearchScreen(),
              );
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(Icons.mic_none, color: Color(0xFF1B4332), size: 24),
            ),
          ),
          suffixIconConstraints: const BoxConstraints(minWidth: 40),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
          return GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => CategoryDetailScreen(category: LanguageService.instance.tr(cat['key'] as String))));
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
                    LanguageService.instance.tr(cat['key'] as String),
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
      {'name': 'Meenakshi Devi', 'craft_key': 'pottery', 'image': 'https://images.unsplash.com/photo-1590736969955-71cc94901144?auto=format&fit=crop&w=800&q=80'},
      {'name': 'Ramesh Kumar', 'craft_key': 'woodwork', 'image': 'https://images.unsplash.com/photo-1552528148-356bc0c5765c?auto=format&fit=crop&w=800&q=80'},
      {'name': 'Lakshmi Bai', 'craft_key': 'textiles', 'image': 'https://images.unsplash.com/photo-1589156229687-496a31ad1d1f?auto=format&fit=crop&w=800&q=80'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              LanguageService.instance.tr('featured_artisans'),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B4332), fontFamily: 'Inter', letterSpacing: -0.5),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AllArtisansScreen()));
              },
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF1B4332)),
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
              return GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => ArtisanProfileScreen(
                      name: artisan['name']!, 
                      craft: LanguageService.instance.tr(artisan['craft_key']!), 
                      imageUrl: artisan['image']!
                    )
                  ));
                },
                child: Container(
                  width: 170,
                  margin: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 140,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          image: DecorationImage(image: NetworkImage(artisan['image']!), fit: BoxFit.cover),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(artisan['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1B4332)), maxLines: 1),
                            const SizedBox(height: 6),
                            Text(LanguageService.instance.tr(artisan['craft_key']!), style: const TextStyle(color: Colors.grey, fontSize: 13), maxLines: 1),
                          ],
                        ),
                      )
                    ],
                  ),
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
// AI CHAT SCREEN
// ==========================================

class AiChatScreen extends StatefulWidget {
  final String? initialMessage;
  const AiChatScreen({super.key, this.initialMessage});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messages.add({"role": "ai", "text": "Hello! I am your artisan assistant. How can I help you discover authentic crafts today?"});
    if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
      _controller.text = widget.initialMessage!;
      _sendMessage();
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "text": text});
      _isLoading = true;
    });
    _controller.clear();

    try {
      final response = await http.post(
        Uri.parse('http://192.168.0.110:8000/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': text}),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _messages.add({"role": "ai", "text": data['reply'] ?? 'Received your message.'});
        });
      } else {
        setState(() {
          _messages.add({"role": "ai", "text": "Sorry, I am having trouble connecting to the server."});
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({"role": "ai", "text": "Sorry, an error occurred. Is the local backend running?"});
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B4332),
        foregroundColor: Colors.white,
        title: const Text('AI Assistant', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF1B4332) : Colors.white,
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(16),
                        bottomLeft: !isUser ? const Radius.circular(0) : const Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    child: Text(
                      msg['text']!,
                      style: TextStyle(
                        color: isUser ? Colors.white : const Color(0xFF1B4332),
                        fontFamily: 'Inter',
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(color: Color(0xFF1B4332)),
            ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontFamily: 'Inter'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1B4332),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ==========================================
// VOICE SEARCH BOTTOM SHEET
// ==========================================

class VoiceSearchScreen extends StatefulWidget {
  const VoiceSearchScreen({super.key});

  @override
  State<VoiceSearchScreen> createState() => _VoiceSearchScreenState();
}

class _VoiceSearchScreenState extends State<VoiceSearchScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  bool _isProcessing = false;
  String? _audioPath;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _startRecording();
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        _audioPath = '${dir.path}/voice_query.m4a';
        await _audioRecorder.start(const RecordConfig(), path: _audioPath!);
        setState(() => _isRecording = true);
      } else {
        Navigator.pop(context); // No permission
      }
    } catch (e) {
      Navigator.pop(context);
    }
  }

  Future<void> _stopAndSend() async {
    if (!_isRecording) return;
    setState(() {
      _isRecording = false;
      _isProcessing = true;
    });
    
    await _audioRecorder.stop();
    _animationController.stop();
    
    if (_audioPath != null) {
      try {
        final request = http.MultipartRequest('POST', Uri.parse('http://192.168.0.110:8000/speech-to-text'));
        request.files.add(await http.MultipartFile.fromPath('audio', _audioPath!));
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);
        
        if (response.statusCode == 200 && mounted) {
          final text = jsonDecode(response.body)['text'] ?? '';
          Navigator.pop(context); // Close voice sheet
          Navigator.push(context, MaterialPageRoute(builder: (context) => AiChatScreen(initialMessage: text)));
          return;
        }
      } catch (_) {}
    }
    
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _isProcessing ? 'Processing audio...' : 'Listening...',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B4332), fontFamily: 'Inter'),
          ),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: _isProcessing ? null : _stopAndSend,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Container(
                  padding: EdgeInsets.all(32 + (_animationController.value * 16)),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9).withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1B4332),
                      shape: BoxShape.circle,
                    ),
                    child: _isProcessing 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Icon(Icons.mic, color: Colors.white, size: 48),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'Tap to stop recording',
            style: TextStyle(color: Colors.grey, fontFamily: 'Inter'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ==========================================
// PLACEHOLDER SCREENS
// ==========================================

class CategoryDetailScreen extends StatelessWidget {
  final String category;
  const CategoryDetailScreen({super.key, required this.category});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(category, style: const TextStyle(color: Color(0xFF1B4332)))),
      body: Center(child: Text('Explore $category crafts')),
    );
  }
}

class ArtisanProfileScreen extends StatelessWidget {
  final String name;
  final String craft;
  final String imageUrl;
  
  const ArtisanProfileScreen({super.key, required this.name, required this.craft, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(imageUrl, fit: BoxFit.cover),
            ),
            backgroundColor: const Color(0xFF1B4332),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1B4332), fontFamily: 'Inter')),
                  const SizedBox(height: 8),
                  Text(craft, style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
                  const SizedBox(height: 24),
                  const Text('About the Artisan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B4332), fontFamily: 'Inter')),
                  const SizedBox(height: 12),
                  const Text(
                    "Handcrafting authentic goods for over 20 years. Every piece is made with love, passion, and a dedication to preserving traditional techniques passed down through generations. Supporting this craft empowers local communities.",
                    style: TextStyle(fontSize: 15, color: Colors.black87, height: 1.6, fontFamily: 'Inter'),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B4332),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Support & Shop', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class AllArtisansScreen extends StatelessWidget {
  const AllArtisansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mockArtisans = [
      {'name': 'Meenakshi Devi', 'craft': 'Terracotta Pottery', 'image': 'https://images.unsplash.com/photo-1590736969955-71cc94901144?auto=format&fit=crop&w=800&q=80'},
      {'name': 'Ramesh Kumar', 'craft': 'Wooden Sculptures', 'image': 'https://images.unsplash.com/photo-1552528148-356bc0c5765c?auto=format&fit=crop&w=800&q=80'},
      {'name': 'Lakshmi Bai', 'craft': 'Handwoven Sarees', 'image': 'https://images.unsplash.com/photo-1589156229687-496a31ad1d1f?auto=format&fit=crop&w=800&q=80'},
      {'name': 'Sanjay Sharma', 'craft': 'Brass Metalwork', 'image': 'https://images.unsplash.com/photo-1552528148-356bc0c5765c?auto=format&fit=crop&w=800&q=80'},
      {'name': 'Anita Desai', 'craft': 'Beaded Jewellery', 'image': 'https://images.unsplash.com/photo-1589156229687-496a31ad1d1f?auto=format&fit=crop&w=800&q=80'},
      {'name': 'Karan Singh', 'craft': 'Blue Pottery', 'image': 'https://images.unsplash.com/photo-1590736969955-71cc94901144?auto=format&fit=crop&w=800&q=80'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Featured Artisans', style: TextStyle(color: Color(0xFF1B4332), fontWeight: FontWeight.bold, fontFamily: 'Inter')),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1B4332)),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: mockArtisans.length,
        itemBuilder: (context, index) {
          final artisan = mockArtisans[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => ArtisanProfileScreen(name: artisan['name']!, craft: artisan['craft']!, imageUrl: artisan['image']!)
              ));
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        image: DecorationImage(image: NetworkImage(artisan['image']!), fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(artisan['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1B4332)), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(artisan['craft']!, style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
