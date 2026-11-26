import 'package:flutter/widgets.dart';

/// Soma 4 a qualquer tamanho: fontes pequenas crescem proporcionalmente mais,
/// como a escala não linear do Android 14+. `clamp` devolve o próprio
/// scaler (sem limite).
class NonLinearScaler extends TextScaler {
  const NonLinearScaler();

  @override
  double scale(double fontSize) => fontSize + 4;

  @override
  // ignore: deprecated_member_use
  double get textScaleFactor => 1.2;

  @override
  TextScaler clamp({
    double minScaleFactor = 0,
    double maxScaleFactor = double.infinity,
  }) => this;
}

/// Envolve [child] com a escala de texto [scaler].
Widget withTextScaler(TextScaler scaler, Widget child) => Builder(
  builder: (context) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: scaler),
    child: child,
  ),
);
