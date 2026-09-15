import 'dart:io';

import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class CraftAnalysisResult {
  final bool success;
  final String? error;
  final String category;
  final String productName;
  final String material;
  final String craftType;
  final String shape;
  final String visibleFeatures;
  final List<String> labels;

  const CraftAnalysisResult({
    this.success = true,
    this.error,
    required this.category,
    required this.productName,
    required this.material,
    required this.craftType,
    required this.shape,
    required this.visibleFeatures,
    required this.labels,
  });

  factory CraftAnalysisResult.failure(String message) {
    return CraftAnalysisResult(
      success: false,
      error: message,
      category: 'Other',
      productName: '',
      material: '',
      craftType: '',
      shape: '',
      visibleFeatures: '',
      labels: const <String>[],
    );
  }
}

class ImageAnalysisService {
  static final ImageAnalysisService instance = ImageAnalysisService._internal();

  ImageAnalysisService._internal();

  Future<CraftAnalysisResult> analyzeImage(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists() || await file.length() == 0) {
        return CraftAnalysisResult.failure('Unable to analyze this image: File not found or empty.');
      }

      final inputImage = InputImage.fromFilePath(filePath);
      final imageLabeler = ImageLabeler(
        options: ImageLabelerOptions(confidenceThreshold: 0.35),
      );

      final List<ImageLabel> rawLabels = await imageLabeler.processImage(inputImage);
      await imageLabeler.close();

      if (rawLabels.isEmpty) {
        return CraftAnalysisResult.failure('Unable to analyze this image: No recognizable features detected.');
      }

      final List<String> labelTexts = rawLabels.map((l) => l.label).take(8).toList();
      final joined = labelTexts.join(' ').toLowerCase();

      String category;
      String productName;
      String material;
      String craftType;
      String shape;

      // 1. Laptop / Computer / Electronics
      if (_matches(joined, <String>[
        'laptop', 'computer', 'notebook', 'netbook', 'personal computer',
        'gadget', 'electronic', 'electronics', 'display', 'screen',
        'keyboard', 'technology', 'multimedia', 'monitor', 'hardware'
      ])) {
        category = 'Other';
        productName = 'Laptop Computer';
        material = 'Engineered metal / composite chassis with digital hardware';
        craftType = 'Modern Precision Engineering';
        shape = 'Rectangular clamshell form factor';
      }
      // 2. Bamboo / Cane / Wicker
      else if (_matches(joined, <String>[
        'basket', 'bamboo', 'wicker', 'straw', 'weave', 'cane', 'rattan'
      ])) {
        category = 'Bamboo';
        productName = _matches(joined, <String>['basket'])
            ? 'Handwoven Wicker Basket'
            : 'Handmade Bamboo Craft';
        material = 'Natural bamboo / wicker';
        craftType = 'Artisanal Splint Weaving';
        shape = _matches(joined, <String>['basket'])
            ? 'Woven basket form'
            : 'Handcrafted bamboo structural form';
      }
      // 3. Pottery / Ceramics
      else if (_matches(joined, <String>[
        'pot', 'pottery', 'vase', 'ceramic', 'clay', 'earthenware', 'terracotta', 'porcelain', 'urn', 'jar'
      ])) {
        category = 'Pottery';
        productName = _matches(joined, <String>['vase'])
            ? 'Handcrafted Ceramic Vase'
            : 'Handmade Terracotta Pottery';
        material = 'Natural clay / terracotta';
        craftType = 'Wheel-thrown & kiln-fired';
        shape = 'Traditional pottery vessel';
      }
      // 4. Woodwork
      else if (_matches(joined, <String>[
        'wood', 'wooden', 'bowl', 'carving', 'timber', 'carpentry', 'furniture', 'hardwood', 'plywood'
      ])) {
        category = 'Woodwork';
        productName = 'Handcrafted Wooden Craft';
        material = 'Seasoned carved hardwood';
        craftType = 'Hand-carved Woodwork';
        shape = 'Sculpted wooden form';
      }
      // 5. Textiles / Apparel
      else if (_matches(joined, <String>[
        'textile', 'cloth', 'fabric', 'saree', 'sari', 'dress', 'linen', 'cotton',
        'silk', 'clothing', 'shirt', 't-shirt', 'top', 'apparel', 'garment', 'sleeve',
        'outerwear', 'jeans', 'pattern'
      ])) {
        category = 'Textiles';
        productName = _matches(joined, <String>['t-shirt', 'shirt', 'top', 'apparel', 'clothing'])
            ? 'Handcrafted Textile Apparel'
            : 'Authentic Handloom Textile';
        material = 'Natural cotton / handloom fabric';
        craftType = 'Handwoven / Tailored Textile Craft';
        shape = 'Tailored textile form';
      }
      // 6. Jewellery
      else if (_matches(joined, <String>[
        'jewelry', 'jewellery', 'metal', 'silver', 'gold', 'brass', 'earring',
        'necklace', 'gemstone', 'bracelet', 'ring', 'bangle', 'bead', 'pendant'
      ])) {
        category = 'Jewellery';
        productName = 'Artisanal Handcrafted Jewellery';
        material = 'Traditional metal craft / silver alloy';
        craftType = 'Hand-cast metalwork';
        shape = 'Artisanal jewellery ornamental form';
      }
      // 7. Home Decor
      else if (_matches(joined, <String>[
        'decor', 'leaf', 'flower', 'wall', 'hanging', 'ornament', 'candle', 'sculpture', 'statue', 'figurine'
      ])) {
        category = 'Home Decor';
        productName = 'Handcrafted Home Decor Accent';
        material = 'Eco-friendly natural craft materials';
        craftType = 'Handcrafted decor technique';
        shape = 'Decorative craft form';
      }
      // 8. Other general detected objects
      else {
        category = 'Other';
        final String topLabel = labelTexts.first;
        productName = 'Handcrafted $topLabel Item';
        material = 'Identified material: ${labelTexts.take(2).join(" / ")}';
        craftType = 'Custom Crafted Technique';
        shape = 'Form as observed in photo';
      }

      final String features = 'Detected visual attributes: ${labelTexts.join(", ")}';

      return CraftAnalysisResult(
        success: true,
        category: category,
        productName: productName,
        material: material,
        craftType: craftType,
        shape: shape,
        visibleFeatures: features,
        labels: labelTexts,
      );
    } catch (e) {
      return CraftAnalysisResult.failure('Unable to analyze this image: $e');
    }
  }

  bool _matches(String text, List<String> terms) {
    return terms.any((t) => text.contains(t));
  }
}
