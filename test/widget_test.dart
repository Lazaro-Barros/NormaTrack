import 'package:flutter_test/flutter_test.dart';

import 'package:normatrack/main.dart';

void main() {
  testWidgets('app abre com o tema do design system', (tester) async {
    await tester.pumpWidget(const NormaTrackApp());

    expect(find.text('NormaTrack'), findsOneWidget);
  });
}
