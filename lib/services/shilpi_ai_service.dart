import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../repositories/product_repository.dart';
import '../repositories/order_repository.dart';
import 'backend_config.dart';

enum AiContextMode { artisan, buyer, product }

class AiResponse {
  final String text;
  final bool isLocal;

  AiResponse({required this.text, required this.isLocal});
}

class ShilpiAiService {
  static final ShilpiAiService instance = ShilpiAiService._internal();
  ShilpiAiService._internal();

  Future<AiResponse> ask(
    String prompt,
    AiContextMode mode, {
    Product? currentProduct,
  }) async {
    final lowerPrompt = prompt.toLowerCase();

    // 1. Local Fallback for Artisan Dashboard Analytics
    if (mode == AiContextMode.artisan) {
      if (lowerPrompt.contains('revenue') || lowerPrompt.contains('sales') || lowerPrompt.contains('earn')) {
        final products = ProductRepository.instance.sellerProducts;
        final productNames = products.map((p) => p.name).toList();
        final revenue = OrderRepository.instance.getSellerRevenue(productNames);
        return AiResponse(
            text: 'Based on your Shilpi data, your total revenue is ₹$revenue.',
            isLocal: true);
      }
      if (lowerPrompt.contains('how many orders') || lowerPrompt.contains('my orders')) {
        final products = ProductRepository.instance.sellerProducts;
        final productNames = products.map((p) => p.name).toList();
        final orders = OrderRepository.instance.getOrdersForSeller(productNames).length;
        return AiResponse(
            text: 'Based on your Shilpi data, you have received $orders orders.',
            isLocal: true);
      }
      if (lowerPrompt.contains('how many products') || lowerPrompt.contains('my products')) {
        final count = ProductRepository.instance.sellerProducts.length;
        return AiResponse(
            text: 'Based on your Shilpi data, you currently have $count products listed.',
            isLocal: true);
      }
    }

    // Prepare Context JSON
    final Map<String, dynamic> payload = {
      'prompt': prompt,
      'mode': mode.toString(),
    };

    if (currentProduct != null) {
      payload['product_context'] = {
        'name': currentProduct.name,
        'category': currentProduct.category,
        'material': currentProduct.material,
        'craftType': currentProduct.craftType,
        'price': currentProduct.price,
        'artisan': currentProduct.artisan,
        'story': currentProduct.story,
      };
    }

    if (mode == AiContextMode.artisan) {
      final products = ProductRepository.instance.sellerProducts;
      payload['seller_context'] = {
        'product_count': products.length,
      };
    }

    // 3. Call AI Backend
    try {
      final response = await http.post(
        Uri.parse(BackendConfig.askAiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AiResponse(
          text: data['response']?.toString() ?? 'I understood your request, but received an empty response.',
          isLocal: false,
        );
      }
    } catch (e) {
      // Backend failed, provide a graceful offline message or generic fallback
      if (mode == AiContextMode.product && currentProduct != null) {
        if (lowerPrompt.contains('material') || lowerPrompt.contains('made of')) {
           return AiResponse(text: 'Based on your Shilpi data, this is made of ${currentProduct.material}. (AI backend offline)', isLocal: true);
        }
        if (lowerPrompt.contains('who made') || lowerPrompt.contains('artisan')) {
           return AiResponse(text: 'Based on your Shilpi data, this was crafted by ${currentProduct.artisan}. (AI backend offline)', isLocal: true);
        }
      }
      
      return AiResponse(
        text: 'The AI backend is currently unreachable. Please check your connection or try again later.',
        isLocal: true,
      );
    }

    return AiResponse(
      text: 'I could not generate a response at this time. Please try again.',
      isLocal: true,
    );
  }
}
