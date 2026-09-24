import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/theme/app_theme.dart';
import 'package:normatrack/app/widgets/status_chip.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  group('AppTheme', () {
    final theme = AppTheme.light;

    test('usa as cores de marca do design system', () {
      expect(theme.colorScheme.primary, AppColors.primary);
      expect(theme.colorScheme.surface, AppColors.ground);
      expect(theme.scaffoldBackgroundColor, AppColors.ground);
    });

    test('registra a extensão de situação', () {
      expect(theme.extension<StatusColors>(), StatusColors.light);
    });

    test('pares de situação têm contraste de pelo menos 4,5:1', () {
      for (final tone in StatusTone.values) {
        final s = StatusColors.light.resolve(tone);
        expect(
          _contrast(s.foreground, s.background),
          greaterThanOrEqualTo(4.5),
          reason: tone.name,
        );
      }
    });

    test('texto principal e secundário têm contraste de pelo menos 4,5:1', () {
      for (final fg in [AppColors.ink, AppColors.ink2, AppColors.ink3]) {
        expect(_contrast(fg, AppColors.ground), greaterThanOrEqualTo(4.5));
        expect(_contrast(fg, AppColors.surface), greaterThanOrEqualTo(4.5));
      }
      expect(
        _contrast(AppColors.onPrimary, AppColors.primary),
        greaterThanOrEqualTo(4.5),
      );
    });
  });

  testWidgets('StatusChip mostra ícone e texto na cor da situação', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: StatusChip(tone: StatusTone.overdue, label: 'Vencido'),
        ),
      ),
    );

    final text = tester.widget<Text>(find.text('Vencido'));
    expect(text.style?.color, AppColors.overdue);
    expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);
  });
}
