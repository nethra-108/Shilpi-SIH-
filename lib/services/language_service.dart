import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class LanguageService extends ChangeNotifier {
  static final LanguageService instance = LanguageService._internal();

  LanguageService._internal();

  String _currentLang = 'en'; // 'en', 'hi', 'te'
  bool _isLoaded = false;
  bool _isFirstLaunch = true;

  String get currentLang => _currentLang;
  bool get isFirstLaunch => _isFirstLaunch;

  Future<void> init() async {
    if (_isLoaded) return;
    await _loadFromDisk();
    _isLoaded = true;
  }

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/shilpi_language.json');
  }

  Future<void> _loadFromDisk() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final decoded = jsonDecode(content);
          if (decoded['lang'] != null) {
            _currentLang = decoded['lang'];
            _isFirstLaunch = false;
          }
        }
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<void> setLanguage(String langCode) async {
    _currentLang = langCode;
    _isFirstLaunch = false;
    notifyListeners();
    try {
      final file = await _getFile();
      await file.writeAsString(jsonEncode({'lang': langCode}));
    } catch (_) {}
  }

  // TRANSLATIONS MAP
  static const Map<String, Map<String, String>> _translations = {
    'en': {
      'greeting_morning': 'Good Morning, Guest 🌅',
      'greeting_afternoon': 'Good Afternoon, Guest ☀️',
      'greeting_evening': 'Good Evening, Guest 🌙',
      'discover': 'What are you looking for today?',
      'search_hint': 'Search for handmade products...',
      'featured_craft': 'FEATURED CRAFT',
      'explore_now': 'Explore Now',
      'browse_by_craft': 'Browse by Craft',
      'view_all': 'View All',
      'your_wishlist': 'Your Wishlist',
      'recommended': 'Recommended for You',
      'recently_viewed': 'Recently Viewed',
      'why_shilpi': 'Why Shilpi?',
      'login_signup': 'Login/Sign Up',
      'change_language': 'Change Language (A/अ)',
      'app_settings': 'App Settings',
      'choose_language': 'Choose Language',
      'home': 'Home',
      'search': 'Search',
      'wishlist': 'Wishlist',
      'cart': 'Cart',
      'profile': 'Profile',
      'pottery': 'Pottery',
      'textiles': 'Textiles',
      'jewellery': 'Jewellery',
      'woodwork': 'Woodwork',
      'decor': 'Decor',
      'shop_now': 'Shop Now',
      'see_all': 'See All >',
      'featured_artisans': 'Featured Artisans',
      'real_people': 'Real People.
Real Crafts.
Real Stories.',
    },
    'hi': {
      'greeting_morning': 'सुप्रभात, अतिथि 🌅',
      'greeting_afternoon': 'नमस्कार, अतिथि ☀️',
      'greeting_evening': 'शुभ संध्या, अतिथि 🌙',
      'discover': 'आज आप क्या ढूंढ रहे हैं?',
      'search_hint': 'हस्तनिर्मित उत्पाद खोजें...',
      'featured_craft': 'विशेष शिल्प',
      'explore_now': 'अभी देखें',
      'browse_by_craft': 'शिल्प द्वारा खोजें',
      'view_all': 'सभी देखें',
      'your_wishlist': 'आपकी विशलिस्ट',
      'recommended': 'आपके लिए अनुशंसित',
      'recently_viewed': 'हाल ही में देखा गया',
      'why_shilpi': 'शिल्पी क्यों?',
      'login_signup': 'लॉगिन / साइन अप',
      'change_language': 'भाषा बदलें (A/अ)',
      'app_settings': 'ऐप सेटिंग्स',
      'choose_language': 'भाषा चुनें',
      'home': 'होम',
      'search': 'खोजें',
      'wishlist': 'विशलिस्ट',
      'cart': 'कार्ट',
      'profile': 'प्रोफ़ाइल',
      'pottery': 'मिट्टी के बर्तन',
      'textiles': 'कपड़ा',
      'jewellery': 'आभूषण',
      'woodwork': 'लकड़ी का काम',
      'decor': 'सजावट',
      'shop_now': 'अभी खरीदें',
      'see_all': 'सभी देखें >',
      'featured_artisans': 'विशेष कारीगर',
      'real_people': 'असली लोग।
असली शिल्प।
असली कहानियाँ।',
    },
    'te': {
      'greeting_morning': 'శుభోదయం, అతిథి 🌅',
      'greeting_afternoon': 'నమస్కారం, అతిథి ☀️',
      'greeting_evening': 'శుభ సాయంత్రం, అతిథి 🌙',
      'discover': 'ఈ రోజు మీరు దేని కోసం వెతుకుతున్నారు?',
      'search_hint': 'చేతితో తయారు చేసిన ఉత్పత్తుల కోసం వెతకండి...',
      'featured_craft': 'ప్రత్యేక కళ',
      'explore_now': 'ఇప్పుడే అన్వేషించండి',
      'browse_by_craft': 'కళ ద్వారా వెతకండి',
      'view_all': 'అన్నీ చూడండి',
      'your_wishlist': 'మీ కోరికల జాబితా',
      'recommended': 'మీ కోసం సిఫార్సు చేయబడినవి',
      'recently_viewed': 'ఇటీవల చూసినవి',
      'why_shilpi': 'శిల్పి ఎందుకు?',
      'login_signup': 'లాగిన్ / సైన్ అప్',
      'change_language': 'భాష మార్చండి (A/అ)',
      'app_settings': 'యాప్ సెట్టింగ్స్',
      'choose_language': 'భాషను ఎంచుకోండి',
      'home': 'హోమ్',
      'search': 'వెతకండి',
      'wishlist': 'కోరికల జాబితా',
      'cart': 'కార్ట్',
      'profile': 'ప్రొఫైల్',
      'pottery': 'కుమ్మరి',
      'textiles': 'వస్త్రాలు',
      'jewellery': 'ఆభరణాలు',
      'woodwork': 'చెక్కపని',
      'decor': 'అలంకరణ',
      'shop_now': 'ఇప్పుడే కొనండి',
      'see_all': 'అన్నీ చూడండి >',
      'featured_artisans': 'ప్రత్యేక కళాకారులు',
      'real_people': 'నిజమైన ప్రజలు.
నిజమైన కళలు.
నిజమైన కథలు.',
    }
  };

  String tr(String key) {
    return _translations[_currentLang]?[key] ?? _translations['en']?[key] ?? key;
  }

  static void showLanguageDialog(BuildContext context, {bool dismissible = false}) {
    showDialog(
      context: context,
      barrierDismissible: dismissible,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(LanguageService.instance.tr('choose_language'), style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
                title: const Text('English', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  LanguageService.instance.setLanguage('en');
                  Navigator.pop(context);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Text('🇮🇳', style: TextStyle(fontSize: 24)),
                title: const Text('हिंदी (Hindi)', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  LanguageService.instance.setLanguage('hi');
                  Navigator.pop(context);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Text('🕉️', style: TextStyle(fontSize: 24)),
                title: const Text('తెలుగు (Telugu)', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  LanguageService.instance.setLanguage('te');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      }
    );
  }
}
