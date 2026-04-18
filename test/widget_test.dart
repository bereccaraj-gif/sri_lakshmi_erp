import 'package:flutter_test/flutter_test.dart';
import 'package:sri_lakshmi_erp/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const CollegeApp());

    expect(find.text('SRI LAKSHMI COLLEGE'), findsOneWidget);
  });
}
