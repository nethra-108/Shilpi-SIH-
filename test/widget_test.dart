import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:craftlink_ai/screens/splash_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SplashScreen displays Shilpi brand and tagline', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(nextScreen: Scaffold(body: Text('Next'))),
      ),
    );

    expect(find.text('Shilpi'), findsOneWidget);
    expect(find.text('“Artisans to a Brighter Tomorrow”'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
  });
}