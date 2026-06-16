import 'package:brandy/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders brands screen flow entry', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: BrandyApp(),
      ),
    );

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('Brands'), findsOneWidget);
  });
}

