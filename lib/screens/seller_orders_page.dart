import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/order.dart';
import '../repositories/order_repository.dart';
import '../repositories/product_repository.dart';

class SellerOrdersPage extends StatelessWidget {
  const SellerOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Store Orders')),
      body: ListenableBuilder(
        listenable: OrderRepository.instance,
        builder: (context, _) {
          final sellerProducts = ProductRepository.instance.sellerProducts;
          final names = sellerProducts.map((p) => p.name).toList();
          final orders = OrderRepository.instance.getOrdersForSeller(names);

          if (orders.isEmpty) {
            return const Center(
              child: Text('No orders yet.', style: TextStyle(color: Colors.grey)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                color: Colors.white,
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.orderId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Buyer: ${order.customerName}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      Text('Address: ${order.deliveryAddress}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: kCream,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(order.status, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: kDarkGreen)),
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text('Update Status'),
                            onPressed: () => _updateStatusDialog(context, order),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _updateStatusDialog(BuildContext context, ShilpiOrder order) {
    final statuses = ['Placed', 'Confirmed', 'Preparing', 'Shipped', 'Delivered'];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Order Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: statuses.map((s) => ListTile(
              title: Text(s),
              trailing: order.status == s ? const Icon(Icons.check, color: kGreen) : null,
              onTap: () {
                OrderRepository.instance.updateOrderStatus(order.orderId, s);
                Navigator.pop(context);
              },
            )).toList(),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))
          ],
        );
      }
    );
  }
}
