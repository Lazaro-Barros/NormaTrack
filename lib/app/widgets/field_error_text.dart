import 'package:flutter/material.dart';

import 'field_parts.dart';

/// Mensagem de erro com ícone fora de um campo (ex.: abaixo de uma lista).
/// Mesmo visual do erro do `AppTextField`.
class FieldErrorText extends StatelessWidget {
  const FieldErrorText(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) => FieldParts.error(context, message)!;
}
