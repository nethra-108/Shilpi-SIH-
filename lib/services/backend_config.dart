import 'dart:io';

class BackendConfig {
  BackendConfig._();

  static String? _customBaseUrl;

  static const String localAdbUrl = 'http://127.0.0.1:8000';
  static const String androidEmulatorUrl = 'http://10.0.2.2:8000';
  static const String productionHttpsUrl = 'https://api.shilpi.org';

  static String get baseUrl {
    if (_customBaseUrl != null && _customBaseUrl!.isNotEmpty) {
      return _customBaseUrl!;
    }
    try {
      if (Platform.isAndroid) {
        return androidEmulatorUrl;
      }
    } catch (_) {}
    return localAdbUrl;
  }

  static set baseUrl(String url) {
    _customBaseUrl = url.trim();
  }

  static String get speechToTextUrl => '$baseUrl/speech-to-text';
  static String get enhanceImageUrl => '$baseUrl/enhance-image';
  static String get analyzeImageUrl => '$baseUrl/analyze-image';
  static String get healthUrl => '$baseUrl/health';
  static String get askAiUrl => '$baseUrl/ask-ai';
}
