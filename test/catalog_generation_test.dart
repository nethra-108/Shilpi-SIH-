import 'package:flutter_test/flutter_test.dart';
import 'package:craftlink_ai/services/catalog_service.dart';


void main() {
  group('AI Catalog Generation Tests', () {
    test('Laptop image input generates laptop catalog without Bamboo Basket data', () {
      final catalog = CatalogService.instance.generateCatalog(
        voiceTranscript: '',
        category: 'Other',
        detectedTitle: 'Laptop Computer',
        material: 'Engineered metal / composite chassis with digital hardware',
        craftType: 'Modern Precision Engineering',
        shape: 'Rectangular clamshell form factor',
        visibleFeatures: 'Detected visual attributes: Laptop, Computer, Screen, Technology',
      );

      // Verify no bamboo basket references exist
      expect(catalog.title.toLowerCase().contains('bamboo'), isFalse);
      expect(catalog.title.toLowerCase().contains('basket'), isFalse);
      expect(catalog.material.toLowerCase().contains('bamboo'), isFalse);
      expect(catalog.shortDescription.toLowerCase().contains('bamboo'), isFalse);
      expect(catalog.detailedDescription.toLowerCase().contains('bamboo'), isFalse);
      expect(catalog.detailedDescription.toLowerCase().contains('basket'), isFalse);
      expect(catalog.detailedDescription.toLowerCase().contains('fruit storage'), isFalse);
      expect(catalog.artisanStory.toLowerCase().contains('bamboo'), isFalse);

      // Verify accurate laptop details are present
      expect(catalog.title, equals('Laptop Computer'));
      expect(catalog.category, equals('Other'));
      expect(catalog.suggestedUse.contains('productivity') || catalog.suggestedUse.contains('workspace'), isTrue);
      expect(catalog.detailedDescription.contains('Laptop, Computer, Screen, Technology'), isTrue);
    });



    test('Textiles category generates textile data without Bamboo Basket references', () {
      final catalog = CatalogService.instance.generateCatalog(
        voiceTranscript: '',
        category: 'Textiles',
        detectedTitle: 'Handcrafted Textile Apparel',
        material: 'Natural cotton / tailored fabric',
        craftType: 'Handwoven / Tailored Textile Craft',
        shape: 'Tailored textile form',
        visibleFeatures: 'Detected visual attributes: T-shirt, Shirt, Clothing, Textile',
      );

      expect(catalog.title.toLowerCase().contains('bamboo'), isFalse);
      expect(catalog.title.toLowerCase().contains('basket'), isFalse);
      expect(catalog.category, equals('Textiles'));
      expect(catalog.title, equals('Handcrafted Textile Apparel'));
    });
  });
}
