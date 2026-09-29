import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/theme/app_theme.dart';

/// Monta um componente isolado com o tema do app.
Future<void> pumpComponent(WidgetTester tester, Widget child) =>
    tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: child),
      ),
    );
