class Review {
  final String id;
  final String productId;
  final String reviewerName;
  final double rating;
  final String comment;
  final DateTime date;

  const Review({
    required this.id,
    required this.productId,
    required this.reviewerName,
    required this.rating,
    required this.comment,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'reviewerName': reviewerName,
      'rating': rating,
      'comment': comment,
      'date': date.toIso8601String(),
    };
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      reviewerName: json['reviewerName']?.toString() ?? 'Anonymous',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      comment: json['comment']?.toString() ?? '',
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
