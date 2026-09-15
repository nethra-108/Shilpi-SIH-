class GeneratedCatalog {
  final String title;
  final String shortDescription;
  final String detailedDescription;
  final String material;
  final String category;
  final String craftType;
  final String colour;
  final String pattern;
  final String shape;
  final String suggestedUse;
  final String artisanStory;

  const GeneratedCatalog({
    required this.title,
    required this.shortDescription,
    required this.detailedDescription,
    required this.material,
    required this.category,
    required this.craftType,
    required this.colour,
    required this.pattern,
    required this.shape,
    required this.suggestedUse,
    required this.artisanStory,
  });
}

class CatalogService {
  static final CatalogService instance = CatalogService._internal();

  CatalogService._internal();

  GeneratedCatalog generateCatalog({
    required String voiceTranscript,
    required String category,
    required String material,
    required String craftType,
    required String shape,
    String? detectedTitle,
    String? visibleFeatures,
    String? colour,
    String? pattern,
    double? length,
    double? width,
    double? height,
    String? artisanName,
    String? location,
    String? makingTime,
  }) {
    final String artName = (artisanName != null && artisanName.isNotEmpty)
        ? artisanName
        : 'Dedicated Rural Artisan';
    final String loc = (location != null && location.isNotEmpty)
        ? location
        : 'Telangana Heritage Cluster, India';
    final String color = (colour != null && colour.isNotEmpty) ? colour : 'Natural Earth Tone';
    final String pat = (pattern != null && pattern.isNotEmpty) ? pattern : 'Traditional Regional Motif';

    String title;
    String suggestedUse;

    if (detectedTitle != null && detectedTitle.trim().isNotEmpty) {
      title = detectedTitle.trim();
      if (title.toLowerCase().contains('laptop')) {
        suggestedUse = 'Personal productivity, digital workspace, and portable computing';
      } else {
        suggestedUse = 'Everyday utility, authentic living, and sustainable aesthetics';
      }
    } else {
      switch (category.toLowerCase()) {
        case 'bamboo':
          title = 'Handmade Bamboo Craft';
          suggestedUse = 'Eco-friendly utility, organization, or home aesthetics';
          break;
        case 'pottery':
          title = 'Handmade Terracotta Pottery';
          suggestedUse = 'Natural cooling, traditional cooking, or indoor styling';
          break;
        case 'textiles':
          title = 'Authentic Handloom Textile';
          suggestedUse = 'Traditional occasions, gifting, or festive wear';
          break;
        case 'woodwork':
          title = 'Handcrafted Carved Hardwood Vessel';
          suggestedUse = 'Dining centerpiece, dry food serving, or artistic display';
          break;
        case 'jewellery':
          title = 'Tribal Hand-Cast Filigree Ornament';
          suggestedUse = 'Festive wear, ethnic ceremonies, and statement jewelry';
          break;
        case 'home decor':
          title = 'Artisanal Natural Fiber Wall Accent';
          suggestedUse = 'Eco-friendly interior wall styling and sustainable living';
          break;
        case 'other':
        default:
          title = 'Handcrafted Artisan Item';
          suggestedUse = 'Personal utility and everyday use';
          break;
      }
    }

    final dimStr = (length != null && width != null && height != null)
        ? ' Dimensions: ${length}cm × ${width}cm × ${height}cm.'
        : '';

    final String featureNote = (visibleFeatures != null && visibleFeatures.isNotEmpty)
        ? ' $visibleFeatures.'
        : '';

    final bool isTechOrOther = category.toLowerCase() == 'other' ||
        title.toLowerCase().contains('laptop') ||
        title.toLowerCase().contains('computer');

    final String shortDesc = isTechOrOther
        ? '$title in good condition presented by $artName.$dimStr'
        : 'An authentic $craftType $category masterpiece hand-crafted from $material by $artName in $loc.$dimStr';

    final String timeInfo = (makingTime != null && makingTime.isNotEmpty)
        ? ' Each piece requires approximately $makingTime of focused handmade labor.'
        : (isTechOrOther ? '' : ' Meticulously created one piece at a time using generational hand-tools.');

    final String detailedDesc;
    if (isTechOrOther) {
      detailedDesc =
          '$title presented with clean $shape and $material.$featureNote'
          ' Ideal for $suggestedUse.$dimStr';
    } else {
      detailedDesc =
          '$title is fashioned from pure, sustainably sourced $material. '
          'Crafted in a distinctive $shape with $pat styling, it celebrates indigenous handicraft traditions.$featureNote '
          '$timeInfo Ideal for $suggestedUse.$dimStr';
    }

    final String story;
    if (isTechOrOther) {
      story =
          'Listed directly by $artName through the Shilpi platform. '
          'Verified marketplace item with condition and visual details accurately confirmed from photo. '
          'Empowering sellers and creators by eliminating middlemen.';
    } else {
      story =
          'Crafted by $artName, an artisan practicing traditional techniques in $loc. '
          'Every line and contour embodies community heritage and generational dedication. '
          'By purchasing this directly through Shilpi, you eliminate middlemen and help secure a brighter tomorrow for artisan families.';
    }

    return GeneratedCatalog(
      title: title,
      shortDescription: shortDesc,
      detailedDescription: detailedDesc,
      material: material,
      category: category,
      craftType: craftType,
      colour: color,
      pattern: pat,
      shape: shape,
      suggestedUse: suggestedUse,
      artisanStory: story,
    );
  }
}
