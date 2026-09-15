import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/product.dart';
import '../constants.dart';

class CraftPassportSheet extends StatelessWidget {
  final Product product;

  const CraftPassportSheet({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // Generate deterministic passport ID for demo
    final passportId = 'SHL-CRAFT-${product.createdAt.year}-${product.id.length >= 6 ? product.id.substring(0,6).toUpperCase() : "001"}';
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.assignment_turned_in, color: kGreen, size: 28),
                SizedBox(width: 8),
                Text('Shilpi Craft Passport', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: kDarkGreen)),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Verified Artisan Origin Record',
              style: TextStyle(fontSize: 14, color: Colors.blueGrey),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F1EA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE6E3D8), width: 2),
              ),
              child: QrImageView(
                data: 'shilpi://passport/$passportId',
                version: QrVersions.auto,
                size: 180.0,
                backgroundColor: Colors.transparent,
              ),
            ),
            const SizedBox(height: 24),
            Text(passportId, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
            const SizedBox(height: 24),
            _buildDetailRow('Craft Name', product.name),
            _buildDetailRow('Artisan', product.artisan),
            _buildDetailRow('Region', product.location),
            _buildDetailRow('Materials', product.material),
            _buildDetailRow('Craft Type', product.craftType),
            _buildDetailRow('Registered', '${product.createdAt.day}/${product.createdAt.month}/${product.createdAt.year}'),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'This is a local Shilpi marketplace record to ensure authenticity and direct artisan origin.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey))),
          Expanded(flex: 3, child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
