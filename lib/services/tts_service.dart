import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService instance = TtsService._internal();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  TtsService._internal();

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      await _flutterTts.setSpeechRate(0.46);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setVolume(1.0);
      _isInitialized = true;
    } catch (_) {}
  }

  static String normalizeLangCode(String? lang) {
    if (lang == null || lang.isEmpty) return 'en-IN';
    final lower = lang.toLowerCase();
    if (lower.startsWith('te') || lower.contains('telugu')) return 'te-IN';
    if (lower.startsWith('hi') || lower.contains('hindi')) return 'hi-IN';
    if (lower.startsWith('ta') || lower.contains('tamil')) return 'ta-IN';
    if (lower.startsWith('kn') || lower.contains('kannada')) return 'kn-IN';
    if (lower.startsWith('ml') || lower.contains('malayalam')) return 'ml-IN';
    if (lower.startsWith('mr') || lower.contains('marathi')) return 'mr-IN';
    if (lower.startsWith('bn') || lower.contains('bengali')) return 'bn-IN';
    return 'en-IN';
  }

  Future<void> speak(String text, {String? languageCode}) async {
    try {
      await init();
      final code = normalizeLangCode(languageCode);
      await _flutterTts.setLanguage(code);
      await _flutterTts.speak(text);
    } catch (_) {}
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (_) {}
  }

  static String getPromptForPhoto(String? langCode) {
    final code = normalizeLangCode(langCode);
    if (code.startsWith('te')) {
      return 'మీ చేతివృత్తి ఉత్పత్తి యొక్క స్పష్టమైన ఫోటో తీయండి లేదా గ్యాలరీ నుండి ఎంచుకోండి.';
    } else if (code.startsWith('hi')) {
      return 'कृपया अपने हस्तशिल्प उत्पाद का एक स्पष्ट फोटो लें या गैलरी से चुनें।';
    }
    return 'Please take a clear photo of your handmade craft or choose one from your gallery.';
  }

  static String getPromptForDimensions(String? langCode) {
    final code = normalizeLangCode(langCode);
    if (code.startsWith('te')) {
      return 'ఫోటో విశ్లేషణ పూర్తయింది. దయచేసి కొలతలను సరిచూడండి.';
    } else if (code.startsWith('hi')) {
      return 'फोटो का विश्लेषण हो गया है। कृपया अपने उत्पाद के माप की पुष्टि करें।';
    }
    return 'Photo analyzed. Please confirm the product dimensions before proceeding.';
  }

  static String getPromptForPublishConfirmation(String? langCode, String productName, int price) {
    final code = normalizeLangCode(langCode);
    if (code.startsWith('te')) {
      return 'మీ $productName అమ్మకానికి సిద్ధంగా ఉంది. నిర్ణయించిన ధర ₹$price. మార్కెట్లో ప్రచురించమంటారా?';
    } else if (code.startsWith('hi')) {
      return 'आपका $productName तैयार है। चुनी गई कीमत ₹$price है। क्या आप इसे बाजार में प्रकाशित करना चाहते हैं?';
    }
    return 'Your $productName is ready. The selected price is ₹$price. Would you like to publish it to the marketplace?';
  }
}
