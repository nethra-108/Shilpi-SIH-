import 'dart:io';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../repositories/cart_repository.dart';
import '../repositories/wishlist_repository.dart';
import '../repositories/recent_repository.dart';
import '../repositories/review_repository.dart';
import '../services/shilpi_ai_service.dart';
import '../theme/colors.dart';
import 'artisan_profile_screen.dart';
import 'craft_passport_sheet.dart';
import 'assistant_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  final VoidCallback? onAdd;

  const ProductDetailsScreen({
    super.key,
    required this.product,
    this.onAdd,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String? _aiSummary;
  bool _isLoadingSummary = false;

  @override
  void initState() {
    super.initState();
    RecentRepository.instance.addView(widget.product.id);
    _fetchAiSummary();
  }

  Future<void> _fetchAiSummary() async {
    final reviews = ReviewRepository.instance.getReviewsForProduct(widget.product.id);
    if (reviews.isEmpty) return;

    setState(() => _isLoadingSummary = true);
    final prompt = "Summarize these reviews in one short, positive sentence: " +
        reviews.map((e) => "${e.rating} stars: ${e.comment}").join(" | ");

    try {
      final res = await ShilpiAiService.instance.ask(prompt, AiContextMode.buyer);
      if (mounted) setState(() => _aiSummary = res.text);
    } catch (_) {}
    if (mounted) setState(() => _isLoadingSummary = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.9),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: ShilpiColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.9),
              child: ListenableBuilder(
                listenable: WishlistRepository.instance,
                builder: (context, _) {
                  final isSaved = WishlistRepository.instance.isSaved(widget.product.id);
                  return IconButton(
                    icon: Icon(isSaved ? Icons.favorite : Icons.favorite_border, color: isSaved ? Colors.red : ShilpiColors.textPrimary),
                    onPressed: () => WishlistRepository.instance.toggleSave(widget.product.id),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ShilpiColors.surface,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Price', style: TextStyle(color: ShilpiColors.textSecondary, fontSize: 12)),
                  Text('₹${widget.product.price}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: ShilpiColors.primaryDark)),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    CartRepository.instance.addItem(widget.product);
                    widget.onAdd?.call();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added ${widget.product.name} to cart'),
                        backgroundColor: ShilpiColors.success,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: const Text('Add to Cart'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Gallery
            SizedBox(
              height: 400,
              width: double.infinity,
              child: (widget.product.imagePath != null && File(widget.product.imagePath!).existsSync())
                  ? Image.file(File(widget.product.imagePath!), fit: BoxFit.cover)
                  : Container(
                      color: ShilpiColors.surfaceMuted,
                      child: Center(child: Text(widget.product.emoji, style: const TextStyle(fontSize: 100))),
                    ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tags
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(label: Text(widget.product.category)),
                      Chip(label: Text(widget.product.material)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Title & Rating
                  Text(widget.product.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: ShilpiColors.primaryDark, height: 1.2)),
                  const SizedBox(height: 12),
                  
                  ListenableBuilder(
                    listenable: ReviewRepository.instance,
                    builder: (context, _) {
                      final reviews = ReviewRepository.instance.getReviewsForProduct(widget.product.id);
                      if (reviews.isEmpty) return const SizedBox.shrink();
                      final avg = reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
                      return Row(
                        children: [
                          const Icon(Icons.star, color: ShilpiColors.warning, size: 20),
                          const SizedBox(width: 4),
                          Text(avg.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(width: 8),
                          Text('(${reviews.length} reviews)', style: const TextStyle(color: ShilpiColors.textSecondary)),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // AI Chat Action
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AssistantScreen(productContext: widget.product)));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ShilpiColors.primaryLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: ShilpiColors.primary.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: const Icon(Icons.auto_awesome, color: ShilpiColors.primary),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Ask Shilpi AI', style: TextStyle(fontWeight: FontWeight.bold, color: ShilpiColors.primaryDark)),
                                Text('Have questions about this craft?', style: TextStyle(fontSize: 13, color: ShilpiColors.textSecondary)),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: ShilpiColors.primary),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Description
                  const Text('Description', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: ShilpiColors.primaryDark)),
                  const SizedBox(height: 12),
                  Text(widget.product.story, style: const TextStyle(fontSize: 16, height: 1.6, color: ShilpiColors.textSecondary)),
                  const SizedBox(height: 32),

                  // Provenance & Maker
                  const Text('Authenticity', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: ShilpiColors.primaryDark)),
                  const SizedBox(height: 16),
                  
                  // Craft Passport
                  GestureDetector(
                    onTap: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => CraftPassportSheet(product: widget.product),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: ShilpiColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: ShilpiColors.border),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.qr_code_scanner, size: 32, color: ShilpiColors.primary),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Craft Passport', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: ShilpiColors.primaryDark)),
                                const SizedBox(height: 4),
                                Text('Verified Shilpi provenance record', style: TextStyle(fontSize: 13, color: ShilpiColors.textSecondary)),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: ShilpiColors.textMuted),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Meet the Maker
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ArtisanProfileScreen(artisanName: widget.product.artisan)));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: ShilpiColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: ShilpiColors.border),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: ShilpiColors.primaryLight,
                            child: Text(widget.product.artisan[0], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: ShilpiColors.primary)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Meet the Maker', style: TextStyle(fontSize: 12, color: ShilpiColors.textSecondary, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                const SizedBox(height: 4),
                                Text(widget.product.artisan, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: ShilpiColors.primaryDark)),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: ShilpiColors.textMuted),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  const Text('Customer Reviews', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: ShilpiColors.primaryDark)),
                  const SizedBox(height: 16),
                  
                  if (_isLoadingSummary)
                    const Padding(padding: EdgeInsets.all(16.0), child: Center(child: CircularProgressIndicator()))
                  else if (_aiSummary != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: ShilpiColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: ShilpiColors.primaryLight, width: 2),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.auto_awesome, color: ShilpiColors.primary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('AI Review Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: ShilpiColors.primary)),
                                const SizedBox(height: 4),
                                Text(_aiSummary!, style: const TextStyle(fontSize: 14, color: ShilpiColors.textPrimary, height: 1.4)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  ListenableBuilder(
                    listenable: ReviewRepository.instance,
                    builder: (context, _) {
                      final reviews = ReviewRepository.instance.getReviewsForProduct(widget.product.id);
                      if (reviews.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('No reviews yet. Be the first to review after purchase!', style: TextStyle(color: ShilpiColors.textSecondary)),
                        );
                      }
                      return Column(
                        children: reviews.map((r) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(radius: 16, backgroundColor: ShilpiColors.surfaceMuted, child: Text(r.reviewerName[0], style: const TextStyle(color: ShilpiColors.textSecondary, fontSize: 12))),
                                  const SizedBox(width: 12),
                                  Text(r.reviewerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const Spacer(),
                                  Row(children: List.generate(5, (index) => Icon(Icons.star, size: 14, color: index < r.rating.round() ? ShilpiColors.warning : ShilpiColors.surfaceMuted))),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(r.comment, style: const TextStyle(color: ShilpiColors.textSecondary, height: 1.4)),
                              const Divider(height: 24),
                            ],
                          ),
                        )).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
