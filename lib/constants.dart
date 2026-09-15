import 'package:flutter/material.dart';

const Color kGreen = Color(0xFF0B6B4F);
const Color kDarkGreen = Color(0xFF153E32);
const Color kCream = Color(0xFFF7F4EC);
const Color kOrange = Color(0xFFD46A3A);

String languageName(String code) {
  final String lower = code.toLowerCase();

  if (lower.startsWith('te') || lower.contains('telugu')) return 'Telugu';
  if (lower.startsWith('hi') || lower.contains('hindi')) return 'Hindi';
  if (lower.startsWith('ta') || lower.contains('tamil')) return 'Tamil';
  if (lower.startsWith('kn') || lower.contains('kannada')) return 'Kannada';
  if (lower.startsWith('ml') || lower.contains('malayalam')) return 'Malayalam';
  if (lower.startsWith('mr') || lower.contains('marathi')) return 'Marathi';
  if (lower.startsWith('bn') || lower.contains('bengali')) return 'Bengali';
  if (lower.startsWith('en') || lower.contains('english')) return 'English';

  return code.isEmpty ? 'Unknown' : code;
}

String detectedLanguageCodeFromName(String name) {
  final String lower = name.toLowerCase();

  if (lower.contains('telugu')) return 'te-IN';
  if (lower.contains('hindi')) return 'hi-IN';
  if (lower.contains('tamil')) return 'ta-IN';
  if (lower.contains('kannada')) return 'kn-IN';
  if (lower.contains('malayalam')) return 'ml-IN';
  if (lower.contains('marathi')) return 'mr-IN';
  if (lower.contains('bengali')) return 'bn-IN';
  return 'en-IN';
}

bool containsAny(String text, List<String> values) {
  return values.any(text.contains);
}

String smartSearchQuery(String transcript) {
  final String lower = transcript.toLowerCase();

  if (containsAny(lower, <String>[
    'bamboo', 'veduru', 'వెదురు', 'బుట్ట', 'basket', 'cane', 'tokri', 'टोकरी'
  ])) {
    return 'bamboo';
  }

  if (containsAny(lower, <String>[
    'wood', 'wooden', 'chekka', 'చెక్క', 'bowl', 'carving', 'lakdi', 'लकड़ी'
  ])) {
    return 'woodwork';
  }

  if (containsAny(lower, <String>[
    'pot', 'pottery', 'clay', 'మట్టి', 'కుండ', 'mitti', 'घड़ा', 'terracotta'
  ])) {
    return 'pottery';
  }

  if (containsAny(lower, <String>[
    'saree', 'cotton', 'textile', 'చీర', 'బట్ట', 'handloom', 'khadi', 'साड़ी'
  ])) {
    return 'textiles';
  }

  if (containsAny(lower, <String>[
    'silver', 'jewellery', 'jewelry', 'earring', 'ఆభరణం', 'ornament', 'gehna'
  ])) {
    return 'jewellery';
  }

  if (containsAny(lower, <String>[
    'decor', 'decoration', 'wall', 'hanging', 'అలంకరణ'
  ])) {
    return 'home decor';
  }

  return transcript;
}
