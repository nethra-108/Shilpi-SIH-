import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class WishlistRepository extends ChangeNotifier {
  static final WishlistRepository instance = WishlistRepository._internal();
  WishlistRepository._internal();

  final List<String> _savedProductIds = [];
  bool _isLoaded = false;

  List<String> get savedProductIds => List.unmodifiable(_savedProductIds);

  Future<void> init() async {
    if (_isLoaded) return;
    await _loadFromDisk();
    _isLoaded = true;
  }

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/shilpi_wishlist.json');
  }

  Future<void> _loadFromDisk() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final decoded = jsonDecode(content);
          if (decoded is List) {
            _savedProductIds.clear();
            for (final item in decoded) {
              if (item is String) {
                _savedProductIds.add(item);
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
      await file.writeAsString(jsonEncode(_savedProductIds));
    } catch (_) {}
  }

  bool isSaved(String productId) => _savedProductIds.contains(productId);

  Future<void> toggleSave(String productId) async {
    if (isSaved(productId)) {
      _savedProductIds.remove(productId);
    } else {
      _savedProductIds.insert(0, productId);
    }
    await _saveToDisk();
    notifyListeners();
  }
}
