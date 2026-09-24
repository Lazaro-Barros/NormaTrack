import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Tom visual de uma situação. A regra que decide a situação de um prazo fica
/// no domínio; a apresentação só converte essa situação em [StatusTone].
enum StatusTone { overdue, dueSoon, ok, closed }

/// Cor de texto/ícone e de fundo de um [StatusTone].
@immutable
class StatusStyle {
  const StatusStyle({required this.foreground, required this.background});

  final Color foreground;
  final Color background;

  static StatusStyle lerp(StatusStyle a, StatusStyle b, double t) =>
      StatusStyle(
        foreground: Color.lerp(a.foreground, b.foreground, t)!,
        background: Color.lerp(a.background, b.background, t)!,
      );
}

/// Cores de situação do prazo, acessíveis via
/// `Theme.of(context).extension<StatusColors>()!` ou [StatusColors.of].
@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  const StatusColors({
    required this.overdue,
    required this.dueSoon,
    required this.ok,
    required this.closed,
  });

  static const light = StatusColors(
    overdue: StatusStyle(
      foreground: AppColors.overdue,
      background: AppColors.overdueBg,
    ),
    dueSoon: StatusStyle(
      foreground: AppColors.dueSoon,
      background: AppColors.dueSoonBg,
    ),
    ok: StatusStyle(foreground: AppColors.ok, background: AppColors.okBg),
    closed: StatusStyle(
      foreground: AppColors.closed,
      background: AppColors.closedBg,
    ),
  );

  final StatusStyle overdue;
  final StatusStyle dueSoon;
  final StatusStyle ok;
  final StatusStyle closed;

  static StatusColors of(BuildContext context) =>
      Theme.of(context).extension<StatusColors>() ?? light;

  StatusStyle resolve(StatusTone tone) => switch (tone) {
    StatusTone.overdue => overdue,
    StatusTone.dueSoon => dueSoon,
    StatusTone.ok => ok,
    StatusTone.closed => closed,
  };

  @override
  StatusColors copyWith({
    StatusStyle? overdue,
    StatusStyle? dueSoon,
    StatusStyle? ok,
    StatusStyle? closed,
  }) => StatusColors(
    overdue: overdue ?? this.overdue,
    dueSoon: dueSoon ?? this.dueSoon,
    ok: ok ?? this.ok,
    closed: closed ?? this.closed,
  );

  @override
  StatusColors lerp(StatusColors? other, double t) {
    if (other == null) return this;
    return StatusColors(
      overdue: StatusStyle.lerp(overdue, other.overdue, t),
      dueSoon: StatusStyle.lerp(dueSoon, other.dueSoon, t),
      ok: StatusStyle.lerp(ok, other.ok, t),
      closed: StatusStyle.lerp(closed, other.closed, t),
    );
  }
}
