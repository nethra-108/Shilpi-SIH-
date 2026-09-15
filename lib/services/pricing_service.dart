class PriceRecommendation {
  final int marketLow;
  final int marketHigh;
  final int suggestedPrice;
  final int recommendedPrice;
  final String explanation;
  final bool isFlaggedUnfair;
  final String? warningMessage;
  final String label;

  const PriceRecommendation({
    required this.marketLow,
    required this.marketHigh,
    required this.suggestedPrice,
    required this.recommendedPrice,
    required this.explanation,
    this.isFlaggedUnfair = false,
    this.warningMessage,
    this.label = 'Prototype Market Estimate',
  });
}

class PricingService {
  static final PricingService instance = PricingService._internal();

  PricingService._internal();

  PriceRecommendation estimatePricing({
    required String category,
    required String material,
    int? artisanExpected,
    int? makingDays,
  }) {
    int baseLow;
    int baseHigh;
    int baseSuggested;

    switch (category.toLowerCase()) {
      case 'pottery':
        baseLow = 650;
        baseHigh = 1050;
        baseSuggested = 850;
        break;
      case 'textiles':
        baseLow = 1100;
        baseHigh = 1650;
        baseSuggested = 1350;
        break;
      case 'bamboo':
        baseLow = 750;
        baseHigh = 1150;
        baseSuggested = 950;
        break;
      case 'woodwork':
        baseLow = 600;
        baseHigh = 950;
        baseSuggested = 780;
        break;
      case 'jewellery':
        baseLow = 1200;
        baseHigh = 1850;
        baseSuggested = 1450;
        break;
      case 'home decor':
        baseLow = 550;
        baseHigh = 900;
        baseSuggested = 720;
        break;
      case 'other':
      default:
        if (artisanExpected != null && artisanExpected > 0) {
          baseLow = (artisanExpected * 0.85).round();
          baseHigh = (artisanExpected * 1.25).round();
          baseSuggested = artisanExpected;
        } else {
          baseLow = 0;
          baseHigh = 0;
          baseSuggested = 0;
        }
        break;
    }

    if (baseSuggested == 0 && (artisanExpected == null || artisanExpected == 0)) {
      return const PriceRecommendation(
        marketLow: 0,
        marketHigh: 0,
        suggestedPrice: 0,
        recommendedPrice: 0,
        isFlaggedUnfair: false,
        warningMessage: null,
        explanation: 'Enter expected selling price to receive fair market analysis.',
      );
    }

    if (makingDays != null && makingDays > 3) {
      final additional = (makingDays - 3) * 60;
      baseLow += additional;
      baseHigh += (additional * 1.3).round();
      baseSuggested += additional;
    }

    int recommended = baseSuggested;
    bool isFlagged = false;
    String? warning;

    if (artisanExpected != null && artisanExpected > 0) {
      if (artisanExpected < (baseLow * 0.75)) {
        isFlagged = true;
        warning =
            'Fair Price Alert: ₹$artisanExpected is significantly below the fair market range (₹$baseLow – ₹$baseHigh). Recommend raising to at least ₹$baseLow to ensure fair wages.';
        recommended = baseLow;
      } else if (artisanExpected > (baseHigh * 1.25)) {
        isFlagged = true;
        warning =
            'Market Notice: ₹$artisanExpected is higher than typical benchmark prices (₹$baseLow – ₹$baseHigh). Buyers may compare with similar listings, but artisan retains full discretion.';
        recommended = artisanExpected;
      } else {
        recommended = artisanExpected;
      }
    }

    return PriceRecommendation(
      marketLow: baseLow,
      marketHigh: baseHigh,
      suggestedPrice: baseSuggested,
      recommendedPrice: recommended,
      isFlaggedUnfair: isFlagged,
      warningMessage: warning,
      explanation:
          'Estimated using craft complexity, raw material cost ($material), regional artisanal benchmarks, and artisan expectation. Prototype calculation for hackathon demonstration.',
    );
  }

  String checkBuyerOffer(int offerPrice, int marketLow, int marketHigh) {
    if (offerPrice < marketLow * 0.70) {
      final counter = (marketLow * 0.90).round();
      return 'This offer (₹$offerPrice) is significantly below the estimated fair range (₹$marketLow – ₹$marketHigh). Suggested counter-offer: ₹$counter.';
    } else if (offerPrice < marketLow) {
      return 'This offer is slightly below the estimated fair range. You may accept or counter at ₹$marketLow.';
    }
    return 'Offer is within the healthy fair market range.';
  }
}
