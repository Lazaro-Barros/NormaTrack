import 'package:flutter/material.dart';

import '../formatters/decimal_input_formatter.dart';
import '../theme/app_theme.dart';
import 'field_error_text.dart';
import 'status_text.dart';

/// Linha de lançamento de um ponto ou parâmetro dentro de um card: número,
/// nome, valor anterior, campo decimal com unidade e menu "sem medição". Com
/// [skippedReason], mostra "Sem medição: motivo" abaixo do nome e só
/// "Desfazer" no lugar do campo.
class MeasurementInputRow extends StatelessWidget {
  const MeasurementInputRow({
    super.key,
    required this.number,
    required this.name,
    this.previousLabel,
    required this.controller,
    required this.unit,
    required this.fieldLabel,
    this.errorText,
    this.limitLabel,
    this.skippedReason,
    required this.menuLabel,
    required this.onSkip,
    required this.onUndoSkip,
    this.onChanged,
    this.decimals = 1,
  });

  /// Largura do campo de valor.
  static const fieldWidth = 112.0;

  /// Acima desta escala de texto, o campo desce para baixo do nome.
  static const stackedTextScale = 1.3;

  final int number;
  final String name;
  final String? previousLabel;
  final TextEditingController controller;
  final String unit;

  /// Rótulo acessível do campo (ex.: "Valor no ponto 1").
  final String fieldLabel;
  final String? errorText;

  /// Aviso de limite (ex.: "Acima do limite (70,0)"), em vermelho com ícone.
  final String? limitLabel;
  final String? skippedReason;
  final String menuLabel;
  final VoidCallback onSkip;
  final VoidCallback onUndoSkip;
  final ValueChanged<String>? onChanged;
  final int decimals;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final colors = theme.colorScheme;
    final skippedReason = this.skippedReason;
    final sub = skippedReason != null
        ? 'Sem medição: $skippedReason'
        : previousLabel;
    final limitLabel = this.limitLabel;
    final errorText = this.errorText;
    // Com a fonte do sistema grande, o campo desce para baixo do nome.
    final stacked =
        MediaQuery.textScalerOf(context).scale(16) > 16 * stackedTextScale;
    final indent = stacked ? 0.0 : 28 + AppSpacing.md;
    final head = <Widget>[
      Container(
        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
        padding: const EdgeInsets.all(AppSpacing.xs),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: Text(
          '$number',
          style: AppTypography.tabular(text.labelMedium)
              .copyWith(color: colors.primary),
        ),
      ),
      const SizedBox(width: AppSpacing.md),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: text.labelLarge),
            if (sub != null)
              Text(
                sub,
                style: AppTypography.tabular(text.bodySmall)
                    .copyWith(color: colors.onSurfaceVariant),
              ),
          ],
        ),
      ),
    ];
    final trailing = <Widget>[
      if (skippedReason != null)
        TextButton(onPressed: onUndoSkip, child: const Text('Desfazer'))
      else ...[
        SizedBox(
          width: stacked ? fieldWidth * 1.5 : fieldWidth,
          child: Semantics(
            label: fieldLabel,
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [DecimalInputFormatter(decimals: decimals)],
              textAlign: TextAlign.end,
              style: AppTypography.tabular(text.labelLarge),
              decoration: InputDecoration(
                hintText: decimals > 0 ? '0,${'0' * decimals}' : '0',
                suffixText: unit,
                // Borda de erro sem texto: a mensagem vai abaixo da linha,
                // que tem largura para ela.
                error: errorText == null ? null : const SizedBox.shrink(),
              ),
            ),
          ),
        ),
        // `onSelected` roda depois de o menu fechar: quem abre uma sheet em
        // [onSkip] não a vê fechada junto com o menu.
        PopupMenuButton<int>(
          tooltip: 'Mais opções',
          icon: Icon(Icons.more_vert, color: colors.onSurfaceVariant),
          onSelected: (_) => onSkip(),
          itemBuilder: (context) => [
            PopupMenuItem(value: 0, child: Text(menuLabel)),
          ],
        ),
      ],
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.xs,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (stacked) ...[
            Row(children: head),
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: trailing,
              ),
            ),
          ] else
            Row(
              children: [
                ...head,
                const SizedBox(width: AppSpacing.sm),
                ...trailing,
              ],
            ),
          if (limitLabel != null && skippedReason == null)
            Padding(
              padding: EdgeInsets.only(left: indent, top: AppSpacing.xs),
              child: StatusText(label: limitLabel, tone: StatusTone.overdue),
            ),
          if (errorText != null && skippedReason == null)
            Padding(
              padding: EdgeInsets.only(left: indent, top: AppSpacing.xs),
              child: FieldErrorText(errorText),
            ),
        ],
      ),
    );
  }
}
