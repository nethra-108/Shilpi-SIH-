class Product {
  final String id;
  final String name;
  final String category;
  final String artisan;
  final String location;
  final String material;
  final String craftType;
  final String emoji;
  final int price;
  final int marketLow;
  final int marketHigh;
  final int stock;
  final double rating;
  final String story;
  final String? imagePath;
  final String? originalImagePath;
  final double? length;
  final double? width;
  final double? height;
  final bool isSellerProduct;
  final DateTime createdAt;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.artisan,
    required this.location,
    required this.material,
    this.craftType = 'Handcrafted',
    required this.emoji,
    required this.price,
    required this.marketLow,
    required this.marketHigh,
    required this.stock,
    required this.rating,
    required this.story,
    this.imagePath,
    this.originalImagePath,
    this.length,
    this.width,
    this.height,
    this.isSellerProduct = false,
    required this.createdAt,
  });

  Product copyWith({
    String? id,
    String? name,
    String? category,
    String? artisan,
    String? location,
    String? material,
    String? craftType,
    String? emoji,
    int? price,
    int? marketLow,
    int? marketHigh,
    int? stock,
    double? rating,
    String? story,
    String? imagePath,
    String? originalImagePath,
    double? length,
    double? width,
    double? height,
    bool? isSellerProduct,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      artisan: artisan ?? this.artisan,
      location: location ?? this.location,
      material: material ?? this.material,
      craftType: craftType ?? this.craftType,
      emoji: emoji ?? this.emoji,
      price: price ?? this.price,
      marketLow: marketLow ?? this.marketLow,
      marketHigh: marketHigh ?? this.marketHigh,
      stock: stock ?? this.stock,
      rating: rating ?? this.rating,
      story: story ?? this.story,
      imagePath: imagePath ?? this.imagePath,
      originalImagePath: originalImagePath ?? this.originalImagePath,
      length: length ?? this.length,
      width: width ?? this.width,
      height: height ?? this.height,
      isSellerProduct: isSellerProduct ?? this.isSellerProduct,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'category': category,
      'artisan': artisan,
      'location': location,
      'material': material,
      'craftType': craftType,
      'emoji': emoji,
      'price': price,
      'marketLow': marketLow,
      'marketHigh': marketHigh,
      'stock': stock,
      'rating': rating,
      'story': story,
      'imagePath': imagePath,
      'originalImagePath': originalImagePath,
      'length': length,
      'width': width,
      'height': height,
      'isSellerProduct': isSellerProduct,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      artisan: json['artisan']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      material: json['material']?.toString() ?? '',
      craftType: json['craftType']?.toString() ?? 'Handcrafted',
      emoji: json['emoji']?.toString() ?? '??',
      price: (json['price'] as num?)?.toInt() ?? 0,
      marketLow: (json['marketLow'] as num?)?.toInt() ?? 0,
      marketHigh: (json['marketHigh'] as num?)?.toInt() ?? 0,
      stock: (json['stock'] as num?)?.toInt() ?? 1,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      story: json['story']?.toString() ?? '',
      imagePath: json['imagePath']?.toString(),
      originalImagePath: json['originalImagePath']?.toString(),
      length: (json['length'] as num?)?.toDouble(),
      width: (json['width'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      isSellerProduct: json['isSellerProduct'] == true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
