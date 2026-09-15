import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/review.dart';

class ReviewRepository extends ChangeNotifier {
  static final ReviewRepository instance = ReviewRepository._internal();
  ReviewRepository._internal();

  final List<Review> _reviews = [];
  bool _isLoaded = false;

  List<Review> get reviews => List.unmodifiable(_reviews);

  Future<void> init() async {
    if (_isLoaded) return;
    await _loadFromDisk();
    _isLoaded = true;
  }

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/shilpi_reviews.json');
  }

  Future<void> _loadFromDisk() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final decoded = jsonDecode(content);
          if (decoded is List) {
            _reviews.clear();
            for (final item in decoded) {
              if (item is Map<String, dynamic>) {
                _reviews.add(Review.fromJson(item));
              }
            }
            if (_reviews.isNotEmpty) {
              notifyListeners();
              return;
            }
          }
        }
      }
    } catch (_) {}

    _seedInitialReviews();
    await _saveToDisk();
    notifyListeners();
  }

  Future<void> _saveToDisk() async {
    try {
      final file = await _getFile();
      final jsonString = jsonEncode(_reviews.map((r) => r.toJson()).toList());
      await file.writeAsString(jsonString);
    } catch (_) {}
  }

  void _seedInitialReviews() {
    _reviews.clear();

  }

  List<Review> getReviewsForProduct(String productId) {
    return _reviews.where((r) => r.productId == productId).toList();
  }

  double getAverageRating(String productId) {
    final productReviews = getReviewsForProduct(productId);
    if (productReviews.isEmpty) return 0.0;
    
    double total = 0;
    for (var r in productReviews) {
      total += r.rating;
    }
    return total / productReviews.length;
  }

  Future<void> addReview(Review review) async {
    _reviews.insert(0, review);
    await _saveToDisk();
    notifyListeners();
  }
}
