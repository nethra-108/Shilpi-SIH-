import 'package:flutter/material.dart';

import '../constants.dart';
import '../repositories/cart_repository.dart';
import '../repositories/order_repository.dart';
import 'orders_page.dart';

class CheckoutScreen extends StatefulWidget {
  final int total;

  const CheckoutScreen({super.key, required this.total});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController nameController =
      TextEditingController(text: 'Ananya Sharma');
  final TextEditingController addressController =
      TextEditingController(text: 'Road No. 12, Banjara Hills, Hyderabad, Telangana');
  String selectedPayment = 'UPI (GPay / PhonePe)';

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    final cartItems = CartRepository.instance.items;
    final order = await OrderRepository.instance.createOrder(
      items: cartItems,
      customerName: nameController.text.trim(),
      address: addressController.text.trim(),
      paymentMethod: selectedPayment,
    );

    await CartRepository.instance.clearCart();

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: <Widget>[
              Text('🎉 ', style: TextStyle(fontSize: 24)),
              Text('Order Confirmed!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Order ${order.orderId}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: kDarkGreen,
                ),
              ),
              const SizedBox(height: 6),
              Text('Total Paid: ₹${order.grandTotal}'),
              const SizedBox(height: 4),
              Text('Status: ${order.status}'),
              const SizedBox(height: 4),
              Text('Delivery To: ${order.deliveryAddress}', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 12),
              const Text(
                'Thank you for directly supporting local Indian artisans!',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: kGreen,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => OrdersPage()),
                );
              },
              child: const Text('View Orders'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final int grandTotal = widget.total + 60;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Row(
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: Color(0xFFE5EFE9),
                      child: Icon(Icons.location_on_outlined, color: kGreen),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Delivery Details',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    filled: true,
                    fillColor: const Color(0xFFF7F4EC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: addressController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Delivery Address',
                    filled: true,
                    fillColor: const Color(0xFFF7F4EC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Row(
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: Color(0xFFE5EFE9),
                      child: Icon(Icons.payment, color: kGreen),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Payment Method',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: selectedPayment,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF7F4EC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: const <String>[
                    'UPI (GPay / PhonePe)',
                    'Credit / Debit Card',
                    'Cash on Delivery',
                  ].map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  onChanged: (String? val) {
                    if (val != null) {
                      setState(() {
                        selectedPayment = val;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: <Widget>[
                summaryLine('Items Subtotal', '₹${widget.total}'),
                summaryLine('Artisan Logistics & Delivery', '₹60'),
                const Divider(height: 20),
                summaryLine('Total Amount', '₹$grandTotal', bold: true),
              ],
            ),
          ),
          const SizedBox(height: 22),

          FilledButton(
            onPressed: _placeOrder,
            child: const Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                'Place Order & Support Artisan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget summaryLine(String title, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: bold ? FontWeight.w900 : FontWeight.normal,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: bold ? 18 : 14,
              fontWeight: bold ? FontWeight.w900 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
