import 'package:flutter/material.dart';

/// Paleta do design system (docs/07-design-system.md).
///
/// Widgets não usam estas constantes diretamente: leem `Theme.of(context)`
/// (`colorScheme`) ou a extensão [StatusColors]. Elas existem para montar o
/// tema e para testes.
abstract final class AppColors {
  // Marca
  static const primary = Color(0xFF0E5A63);
  static const primaryStrong = Color(0xFF0A434A);
  static const primarySoft = Color(0xFFDCEBEA);
  static const onPrimary = Color(0xFFFFFFFF);

  // Neutros
  static const ground = Color(0xFFF5F4EF);
  static const surface = Color(0xFFFFFFFF);
  static const surface2 = Color(0xFFEEEDE7);
  static const border = Color(0xFFDCDAD2);
  static const borderStrong = Color(0xFF8E8B82);
  static const ink = Color(0xFF1A1D1F);
  static const ink2 = Color(0xFF4A5055);
  static const ink3 = Color(0xFF636A70);

  // Situação do prazo: texto e fundo
  static const overdue = Color(0xFFA8261B);
  static const overdueBg = Color(0xFFFBE3E0);
  static const dueSoon = Color(0xFF8A4B00);
  static const dueSoonBg = Color(0xFFFCEBD2);
  static const ok = Color(0xFF1D6B45);
  static const okBg = Color(0xFFE2F1E8);
  static const closed = Color(0xFF4A5055);
  static const closedBg = Color(0xFFECEBE6);
}
