import 'package:flutter_test/flutter_test.dart';

import 'package:dojo_partner/app.dart';

void main() {
  testWidgets('DOJO Partner app loads', (tester) async {
    await tester.pumpWidget(const DojoPartnerApp());

    expect(find.text('DOJO'), findsWidgets);
  });
}
