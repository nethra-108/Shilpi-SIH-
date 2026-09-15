import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class RecentRepository extends ChangeNotifier {
  static final RecentRepository instance = RecentRepository._internal();
  RecentRepository._internal();

  final List<String> _recentProductIds = [];
  bool _isLoaded = false;
  static const int _maxRecents = 10;

  List<String> get recentProductIds => List.unmodifiable(_recentProductIds);

  Future<void> init() async {
    if (_isLoaded) return;
    await _loadFromDisk();
    _isLoaded = true;
  }

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/shilpi_recent.json');
  }

  Future<void> _loadFromDisk() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final decoded = jsonDecode(content);
          if (decoded is List) {
            _recentProductIds.clear();
            for (final item in decoded) {
              if (item is String) {
                _recentProductIds.add(item);
              }
            }
          }
        }
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<void> _saveToDisk() async {
    try {
      final file = await _getFile();
      await file.writeAsString(jsonEncode(_recentProductIds));
    } catch (_) {}
  }

  Future<void> addView(String productId) async {
    _recentProductIds.remove(productId);
    _recentProductIds.insert(0, productId);
    if (_recentProductIds.length > _maxRecents) {
      _recentProductIds.removeLast();
    }
    await _saveToDisk();
    notifyListeners();
  }
}
