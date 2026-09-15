import 'dart:async';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../repositories/cart_repository.dart';
import '../repositories/order_repository.dart';
import '../repositories/product_repository.dart';
import '../services/tts_service.dart';

class SplashScreen extends StatefulWidget {
  final Widget nextScreen;

  const SplashScreen({
    super.key,
    required this.nextScreen,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    _initAndNavigate();
  }

  Future<void> _initAndNavigate() async {
    await Future.wait([
      ProductRepository.instance.init(),
      CartRepository.instance.init(),
      OrderRepository.instance.init(),
      TtsService.instance.init(),
      Future<void>.delayed(const Duration(milliseconds: 1400)),
    ]);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, secondaryAnimation) => widget.nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: kGreen,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x220B6B4F),
                        blurRadius: 16,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '🏺',
                      style: TextStyle(fontSize: 48),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Shilpi',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: kDarkGreen,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '“Artisans to a Brighter Tomorrow”',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: kGreen,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tradition meets Technology.\nReal Hands. Brighter Futures.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 36),
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: kGreen,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
