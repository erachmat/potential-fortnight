import 'package:flutter_test/flutter_test.dart';
import 'package:nitip/app/app.dart';
import 'package:nitip/data/backend.dart';

void main() {
  testWidgets('app boots ke splash lalu role picker', (tester) async {
    final b = Backend(autoTick: false);
    await tester.pumpWidget(NitipApp(backend: b));
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle(const Duration(milliseconds: 200));
    expect(find.textContaining('siapa', findRichText: true), findsWidgets);
    b.dispose();
  });
}
