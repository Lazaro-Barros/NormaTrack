import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:normatrack/app/widgets/app_text_field.dart';

/// `TextField` do `AppTextField` com o rótulo [label].
Finder fieldLabeled(String label) => find.descendant(
  of: find.byWidgetPredicate((w) => w is AppTextField && w.label == label),
  matching: find.byType(TextField),
);

/// Texto atual do campo.
String fieldText(WidgetTester tester, Finder field) =>
    tester.widget<TextField>(field).controller!.text;
