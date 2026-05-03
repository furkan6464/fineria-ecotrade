import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/network/dio_client.dart';
import 'package:mobile/core/storage/secure_token_storage.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('Role select screen is shown by default', (
    WidgetTester tester,
  ) async {
    final dio = DioClient.create(SecureTokenStorage());

    await tester.pumpWidget(EcoTradeApp(dio: dio));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Üreticiyim'), findsOneWidget);
    expect(find.text('Tüketiciyim'), findsOneWidget);
  });
}
