# Plano técnico — 014

> **Plano autocontido.** Um agente sem o histórico da conversa deve conseguir implementar a task só com esta pasta, o `CLAUDE.md` e o código. Suposições de negócio estão marcadas com **[suposição]** e viram `// TODO(RF-XXX):` no código. Ver o checklist em `.claude/skills/task/SKILL.md` (passo 3).

## Abordagem

Só apresentação: o domínio e os dados vêm prontos da task 013 (`lib/features/measurements/`). Três peças de UI:

1. **Módulo Ambiental:** seção "Automonitoramento" no topo da lista "Em aberto", com um `NavRow` "Ruídos" e a situação em `StatusText`.
2. **Lançamento de ruídos:** tela com a semana na faixa (`PeriodNavigator`), um `MeasurementInputRow` por ponto e "Salvar" no rodapé. O estado da tela é um rascunho em memória comparado com o que está salvo.
3. **Pontos de medição:** lista dos pontos e um bottom sheet para cadastrar e editar.

Primeiro passo: protótipos de wireframe para o usuário aprovar.

## Contexto do repositório (em 2026-11-27)

- Pronto (task 013): `MeasurementRepository` (`lib/features/measurements/domain/measurement_repository.dart`) e `measurementRepositoryProvider` (`data/local_measurement_repository.dart`); `MeasurementContext.noise` (`defaultUnit` `dB(A)`, módulo Ambiental); `MeasurementFrequency.weekly`; `MeasurementPeriod.containing/next/previous/isoWeek/end`; `MeasurementParameter.check` → `LimitStatus`; `MeasurementEntry(value, note)`; `pendingLaunches` e `watchPendingLaunches(today:, companyId:)`; exceções `MeasurementValidationException` (`parameterErrors`, `entryErrors`), `MeasurementParameterNotFoundException`, `MeasurementModuleNotEnabledException`, `FuturePeriodException`.
- Ainda não existe: nenhuma pasta `lib/features/measurements/presentation/`, nenhum fake de medições em `test/helpers/`.
- Tela do módulo: `lib/features/deadlines/presentation/module_screen.dart` (`_DeadlinesState`): faixa com `BandSegmentedButton` "Em aberto | Encerrados", `EmptyState` quando não há prazo, FAB "Novo prazo". Rotas em `lib/app/router.dart` (`AppRoutes`, módulo em `/empresas/:id/modulos/:modulo`, slug `ambiental` via `ModuleTypeX.slug` em `company_labels.dart`).
- Widgets prontos: `BandTitle`, `SectionCard` (title, caption, description, children), `NavRow` (leadingIcon, title, subtitle, trailing, onTap), `StatusText(label, tone)`, `AppTextField` (label, controller, required, errorText, keyboardType, inputFormatters, suffixIcon, helperText, tabular, onChanged), `AppActionBar(children)`, `EmptyState(icon, title, message, actionLabel, onAction)`, `DestructiveButton`, `showConfirmDialog(context, title:, message:, confirmLabel:, destructive:)`, `FieldErrorText`. Padrão de "Descartar alterações?" com `PopScope` em `deadline_form_screen.dart:294`. Padrão de bottom sheet que devolve resultado em `registration_sheet.dart`.
- Formatação: `formatDate` (`lib/core/utils/date_format.dart`). **Não há** `intl` direto no `pubspec.yaml` (só transitivo): números são formatados à mão.
- Testes de tela: `test/helpers/pump_app.dart` (`pumpApp`, `testNow` = 2026-09-29 12:00 UTC, terça, semana 40: 28/09 a 04/10/2026) com fakes de empresa e prazo; `test/helpers/pump_widget.dart` para widgets soltos; `test/helpers/text_scalers.dart` para fonte grande.
- Armadilha: `testNow` é terça 29/09/2026 → semana ISO 40 (28/09 a 04/10). Semana 39 = 21 a 27/09 (a do wireframe).

## Ordem de implementação

Um commit por passo, direto na `main`, com `dart format .`, `flutter analyze` e `flutter test` verdes e `git push origin main`. Formato: `tipo(escopo): … [task 014, RF-AMB-02]`. Journal a cada passo.

1. **Protótipos** (`docs(design): wireframes de ruídos`): `prototypes/Lancamento.dc.html` (sem "Rascunho", com ponto sem medição, aviso de limite e "Sem medição nesta semana"), `prototypes/PontosMedicao.dc.html` (lista + sheet) e `prototypes/ModuloAmbiental.dc.html` (seção Automonitoramento). **Mostrar ao usuário e esperar aprovação**; aprovados, copiar para `docs/design/wireframes/` (substituindo `Lancamento` e `ModuloAmbiental`).
2. **Componentes** (`feat(design): PeriodNavigator, MeasurementInputRow e DecimalInputFormatter`): widgets + testes + `docs/07-design-system.md`.
3. **Rótulos, providers e fake** (`feat(ruidos): rótulos e providers de medições`): `measurement_labels.dart`, `measurement_providers.dart`, `test/helpers/fake_measurement_repository.dart`, `pumpApp` com override.
4. **Pontos de medição** (`feat(ruidos): pontos de medição`): rota, tela e sheet + testes.
5. **Lançamento** (`feat(ruidos): lançamento semanal de ruídos`): rota, tela, sheet de motivo + testes.
6. **Módulo** (`feat(ruidos): Ruídos no módulo Ambiental`): seção Automonitoramento + testes.
7. **Emulador** e **fechamento** (`docs(ruidos): fechamento da task 014`): critérios, journal, status, `docs/07-design-system.md` (telas), roadmap, `docs/06`.

## Setup

Nenhum pacote novo.

## Arquivos

| Camada | Arquivo | Conteúdo |
|---|---|---|
| app | `lib/app/widgets/period_navigator.dart` | `PeriodNavigator` |
| app | `lib/app/widgets/measurement_input_row.dart` | `MeasurementInputRow` |
| app | `lib/app/formatters/decimal_input_formatter.dart` | `DecimalInputFormatter`, `parseDecimal`, `formatDecimal` |
| app | `lib/app/router.dart` | rotas `ruidos` e `ruidos/pontos` |
| presentation | `lib/features/measurements/presentation/measurement_labels.dart` | rótulos de período, valor, limite e situação |
| presentation | `lib/features/measurements/presentation/measurement_providers.dart` | providers |
| presentation | `lib/features/measurements/presentation/noise_launch_screen.dart` | tela de lançamento |
| presentation | `lib/features/measurements/presentation/noise_points_screen.dart` | tela de pontos |
| presentation | `lib/features/measurements/presentation/point_sheet.dart` | sheet de cadastro/edição do ponto |
| presentation | `lib/features/measurements/presentation/skip_reason_sheet.dart` | sheet do motivo de "sem medição" |
| presentation | `lib/features/measurements/presentation/monitoring_section.dart` | seção Automonitoramento (usada pelo módulo) |
| presentation | `lib/features/deadlines/presentation/module_screen.dart` | inclui a seção |

## Rotas

Abaixo de `modulos/:modulo` (navigator raiz, como os prazos), **antes** de `prazos/:prazo` não importa (prefixos diferentes):

```dart
static String noise(String companyId, {DateTime? week}) =>
    '${module(companyId, ModuleType.environmental)}/ruidos'
    '${week == null ? '' : '?semana=${isoDate(week)}'}';
static String noisePoints(String companyId) =>
    '${module(companyId, ModuleType.environmental)}/ruidos/pontos';
```

`GoRoute(path: 'ruidos', builder: NoiseLaunchScreen(companyId:, slug:, week: state.uri.queryParameters['semana']), routes: [GoRoute(path: 'pontos', builder: NoisePointsScreen(companyId:, slug:))])`. A data da query é `AAAA-MM-DD` (mesmo texto do `DateOnlyConverter`; criar `String isoDate(DateTime)` e `DateTime? parseIsoDate(String)` em `date_format.dart`). Slug diferente de `ambiental` ou empresa sem o módulo → mesmas mensagens do `ModuleScreen` ("Módulo não encontrado", "Módulo desligado", "Empresa não encontrada"). Data inválida ou futura na query → semana atual.

## Componentes (lib/app/widgets/)

### `PeriodNavigator`

Bloco da faixa (`AppBar.bottom`): botão "anterior" (`Icons.chevron_left`), no centro o título (`titleMedium`, branco, `AppTypography.tabular`) e o subtítulo (`bodyMedium`, `BandColors.muted`, tabular), botão "próximo" (`Icons.chevron_right`). Botões `IconButton` 48 × 48 brancos; desabilitado = `onNext == null` (cor `BandColors.muted` com opacidade do tema).

```dart
const PeriodNavigator({required String title, required String subtitle,
  required VoidCallback? onPrevious, required VoidCallback? onNext,
  String previousTooltip = 'Período anterior', String nextTooltip = 'Próximo período'});
static double heightOf(BuildContext context); // para o AppBar.bottom
```

Altura: `max(48, linhas do título + subtítulo)` + `AppSpacing.lg` embaixo; com fonte grande, limitar a escala em 1,5 (regra "Fonte do sistema grande" do design system) e calcular com `AppTypography.lineHeight`. Semântica: os dois botões com tooltip; título e subtítulo lidos juntos (`MergeSemantics`).

### `MeasurementInputRow`

Linha de um card (separada por `divider` no `SectionCard`):

- À esquerda, círculo 28 × 28 em `primaryContainer` com o número (`labelMedium`, `primary`, tabular).
- No meio, o nome (`bodyLarge`) e, abaixo, `previousLabel` ("Anterior: 61,8", `bodySmall`, `onSurfaceVariant`, tabular), se houver.
- À direita, o campo (largura 112) — `TextField` com `keyboardType: TextInputType.numberWithOptions(decimal: true)`, `DecimalInputFormatter`, `textAlign: TextAlign.end`, tabular, `suffixText` = unidade, `hintText` "0,0", rótulo acessível via `Semantics(label: fieldLabel)`; e um `IconButton` `Icons.more_vert` (48) com `PopupMenuButton` de um item `menuLabel` ("Sem medição neste ponto").
- Abaixo (largura total, recuo do número): `StatusText(label: limitLabel, tone: StatusTone.overdue)` quando `limitLabel != null`; erro do campo com `FieldErrorText` quando `errorText != null`.
- **Modo sem medição** (`skippedReason != null`): no lugar do campo e do menu, `Text('Sem medição', labelMedium, onSurfaceVariant)` e um `TextButton('Desfazer', onPressed: onUndoSkip)`; abaixo do nome, o motivo (`bodySmall`, itálico não: normal).

```dart
const MeasurementInputRow({required int number, required String name,
  String? previousLabel, required TextEditingController controller,
  required String unit, required String fieldLabel, String? errorText,
  String? limitLabel, String? skippedReason, required String menuLabel,
  required VoidCallback onSkip, required VoidCallback onUndoSkip,
  ValueChanged<String>? onChanged});
```

### `DecimalInputFormatter` (`lib/app/formatters/`)

Aceita dígitos e **uma** vírgula (ponto digitado vira vírgula), no máximo `decimals` casas (padrão 1) e `maxIntegerDigits` (padrão 4); sem sinal. Rejeita a edição que viola (devolve o valor antigo). Funções: `double? parseDecimal(String text)` ("61,8" → 61.8; "61," → 61.0; "" ou "," → null) e `String formatDecimal(double v, {int decimals = 1})` ("61,8", 64 → "64,0", arredonda meio para cima com `toStringAsFixed`).

## Rótulos (`measurement_labels.dart`)

| Função | Resultado |
|---|---|
| `periodTitle(MeasurementPeriod p)` | semanal "Semana 48"; mensal "Novembro/2026"; quinzenal "1ª quinzena de novembro" / "2ª quinzena de novembro"; diária "26/11/2026" |
| `periodRange(MeasurementPeriod p)` | "23 a 29/11/2026"; mês diferente "28/12/2026 a 03/01/2027" e "30/11 a 06/12/2026" (ano só no fim quando é o mesmo); diária "" |
| `previousLabel(Measurement? m)` | `null` sem medição anterior; "Anterior: 61,8"; "Anterior: sem medição" |
| `limitLabel(MeasurementParameter p, double? v)` | só com `aboveMax`: "Acima do limite (70,0)"; `belowMin`: "Abaixo do limite (6,0)"; senão `null` |
| `monitoringStatus(List<PendingLaunch> noise, int activePoints)` | `(label, tone)`: 0 pontos → ("Nenhum ponto cadastrado", null); n atrasados (`overdue`) → ("1 semana atrasada" / "n semanas atrasadas", overdue); só a atual → ("A lançar", dueSoon); nenhum → ("Em dia", ok) |
| `pointsSubtitle(int n)` | "1 ponto · semanal" / "n pontos · semanal" |

Meses em minúsculas no meio da frase, primeira maiúscula no título ("Novembro/2026").

## Providers (`measurement_providers.dart`)

```dart
final noisePointsProvider = StreamProvider.autoDispose.family<List<MeasurementParameter>, String>(
  (ref, companyId) => repo.watchParameters(companyId, MeasurementContext.noise, includeArchived: true));
final noiseMeasurementsProvider = StreamProvider.autoDispose.family<List<Measurement>, String>(
  (ref, companyId) => repo.watchMeasurements(companyId, MeasurementContext.noise));
final companyPendingLaunchesProvider = StreamProvider.autoDispose.family<List<PendingLaunch>, ({String companyId, DateTime today})>(
  (ref, k) => repo.watchPendingLaunches(today: k.today, companyId: k.companyId));
```

`today` = `ref.read(clockProvider)().toLocal()` sem hora, calculado na tela. Todas as medições da empresa (sem filtro de período) bastam para "anterior" e para o rascunho: volume pequeno (52 semanas × poucos pontos por ano).

## Telas

### Módulo Ambiental (`monitoring_section.dart` + `module_screen.dart`)

Só no módulo Ambiental e só na vista "Em aberto". A lista passa a ter, antes das categorias de prazo, `SectionCard(title: 'Automonitoramento', children: [NavRow(leadingIcon: Icons.graphic_eq, title: 'Ruídos', subtitle: pointsSubtitle(n) ou null, trailing: StatusText(...), onTap)])`. `n` = pontos ativos (não arquivados). Tocar: vai para `AppRoutes.noise(companyId, week: <semana pendente mais antiga>)`, ou sem `week` se não houver pendência.

Sem prazos em aberto: hoje a tela inteira vira `EmptyState`. No Ambiental, a lista mostra a seção e, abaixo, um card `EmptyState` "Nenhum prazo em aberto" (mesmos textos e ação). Outros módulos não mudam.

### Pontos de medição (`noise_points_screen.dart`)

- Faixa: `BandTitle(title: 'Pontos de medição', subtitle: company.displayName)`.
- Corpo: `SectionCard(title: 'Ativos', caption: '$n')` com um `NavRow` por ponto ativo (title: nome; subtitle: "Limite 70,0 dB(A)" ou "Sem limite"; onTap: sheet de edição). Se houver desativados, `SectionCard(title: 'Desativados')` igual, subtítulo "Desativado".
- Sem nenhum ponto: `EmptyState(icon: Icons.graphic_eq, title: 'Nenhum ponto de medição', message: 'Cadastre os lugares onde o ruído é medido, como o portão ou a divisa do terreno.', actionLabel: 'Cadastrar ponto')`.
- FAB `FloatingActionButton.extended(icon: add, label: 'Novo ponto')` quando há pontos.
- Ordem: a do repositório (posição; novos no fim).

### Sheet do ponto (`point_sheet.dart`)

`showPointSheet(context, {MeasurementParameter? current}) → Future<PointSheetResult?>`, onde o resultado é `save(name, limitMax)`, `archive`, `unarchive` ou `delete`. Quem chama grava e trata erros; a sheet só coleta.

- Título (`titleMedium`): "Novo ponto" / "Editar ponto".
- `AppTextField(label: 'Nome', required: true, hint: 'Ex.: Portão principal', textCapitalization: sentences)`.
- `AppTextField(label: 'Limite máximo', suffix dB(A) via suffixIcon de texto, keyboardType decimal, DecimalInputFormatter, helperText: 'Opcional. Valores acima aparecem como "Acima do limite".')`.
- Rodapé: `FilledButton('Salvar')` (largura total). Na edição, acima: `OutlinedButton('Desativar')` (ou `'Reativar'`) e `DestructiveButton('Excluir')`, lado a lado.
- Validação na sheet: nome vazio → "Informe o nome". Duplicado vem do repositório: a tela reabre a sheet? **Não**: a sheet recebe `Future<String?> Function(String name, double? limit) onSave` que devolve a mensagem de erro (ou `null` = salvou e fecha). Assim o erro "Já existe um ponto com esse nome" aparece no campo sem fechar. Desativar, reativar e excluir fecham a sheet e a tela executa.
- Excluir: `showConfirmDialog(title: 'Excluir ponto?', message: 'As medições deste ponto também serão excluídas. Isso não pode ser desfeito.', confirmLabel: 'Excluir', destructive: true)`.
- Criar usa `MeasurementParameterInput(name, unit: MeasurementContext.noise.defaultUnit, frequency: weekly, startDate: hoje local, limitMax: limite)`. Editar mantém `frequency` e `startDate` do ponto (`toInput()` com nome e limite novos). **[suposição]** o ponto cobra a partir da semana do cadastro (`// TODO(RF-AMB-02):`).
- SnackBars: "Ponto cadastrado", "Ponto atualizado", "Ponto desativado", "Ponto reativado", "Ponto excluído".

### Lançamento (`noise_launch_screen.dart`)

Estado: `period` (semana exibida), mapa `parameterId → _Draft` com `TextEditingController` e `skipReason`. `_Draft` é criado a partir do salvo ao entrar na semana e quando o salvo muda **sem** alterações locais (stream emite depois de salvar).

- Faixa: `BandTitle(title: 'Ruídos', subtitle: company.displayName)`; ação `IconButton(Icons.tune, tooltip: 'Pontos de medição')` → `AppRoutes.noisePoints`; `bottom`: `PeriodNavigator(title: periodTitle, subtitle: periodRange, onPrevious, onNext: período == atual ? null : …)`.
- **Linhas** da semana: pontos ativos com `firstPeriod.start <= period.start`, mais qualquer ponto (desativado ou com início posterior) que tenha medição salva nesta semana; na ordem do repositório; número = posição na lista exibida (1, 2, 3…).
- Corpo: `SectionCard(title: 'Pontos de medição', caption: '$preenchidos de $total')`, preenchidos = linhas com valor ou motivo no rascunho. Abaixo do card, se alguma linha está vazia: `OutlinedButton.icon(Icons.block, 'Sem medição nesta semana')`.
- Linha: `MeasurementInputRow(number, name, previousLabel(última medição do ponto com periodStart < period.start), controller, unit 'dB(A)', fieldLabel: 'Valor no ponto $number', limitLabel: limitLabel(ponto, parseDecimal(texto)), skippedReason, menuLabel: 'Sem medição neste ponto')`.
- Sem pontos ativos e nada salvo na semana: `EmptyState` "Nenhum ponto de medição" com "Cadastrar ponto" (abre a sheet do ponto direto, nesta tela).
- "Sem medição neste ponto" / "nesta semana": `showSkipReasonSheet(context, {required String title}) → Future<String?>`: `AppTextField(label: 'Motivo', required, hint: 'Ex.: fábrica parada')`, `FilledButton('Aplicar')`; motivo vazio → "Informe o motivo". Semana: aplica a todas as linhas sem valor e sem motivo; o campo fica vazio. "Desfazer" na linha limpa o motivo.
- Rodapé: `AppActionBar([FilledButton('Salvar')])`, habilitado só com alteração (`_dirty`: algum rascunho difere do salvo).
- **Salvar**: monta `entries` só das linhas alteradas: valor → `MeasurementEntry(value, note: nota salva se já havia valor)`; motivo → `MeasurementEntry(note: motivo)`; vazio → `null`. Chama `savePeriod(period, entries, today:)`. Sucesso: SnackBar "Semana 48 salva" e fica na tela. Erros: `FuturePeriodException` → SnackBar "Não dá para lançar uma semana futura"; `MeasurementValidationException` → erro na linha ("Valor inválido" / "Informe o motivo"); outros → SnackBar "Não foi possível salvar. Tente de novo.".
- Texto que não é número (ex.: só ",") → `errorText: 'Valor inválido'` ao salvar, sem gravar nada.
- **Alterações pendentes**: anterior/próxima e voltar (`PopScope(canPop: !_dirty)`) pedem `showConfirmDialog(title: 'Descartar alterações?', message: 'O que foi digitado nesta semana não foi salvo.', confirmLabel: 'Descartar', destructive: true)`.
- Semana atual pela query (`week`) se válida e não futura; senão a que contém hoje.

## Valores de referência

Textos fixos já listados acima. Ícones: Ruídos `Icons.graphic_eq`; pontos `Icons.tune`; sem medição `Icons.block`.

## Testes

| Arquivo | Cobre |
|---|---|
| `test/app/formatters/decimal_input_formatter_test.dart` | aceita "61,8", "61.8" → "61,8"; rejeita "61,85", "1,2,3", "-1", "12345" (com 4 inteiros); `parseDecimal` ("61,8", "61,", "", ","); `formatDecimal` (64 → "64,0", 61.85 → "61,9") |
| `test/app/widgets/period_navigator_test.dart` | título/subtítulo, callbacks, próximo desabilitado, tooltips, altura com fonte 1,0 e 2,0 (sem overflow) |
| `test/app/widgets/measurement_input_row_test.dart` | número, nome, anterior, sufixo, limite (`StatusText` com ícone), erro, menu "Sem medição neste ponto" chama `onSkip`, modo sem medição com motivo e "Desfazer", semântica do campo, fonte 2,0 sem overflow |
| `test/features/measurements/presentation/measurement_labels_test.dart` | `periodTitle` (semana 39 de 2026, novembro, quinzenas, dia), `periodRange` (21 a 27/09/2026; 28/12/2026 a 03/01/2027; 30/11 a 06/12/2026), `previousLabel`, `limitLabel`, `monitoringStatus` (os 4 casos, plural), `pointsSubtitle` |
| `test/helpers/fake_measurement_repository.dart` | fake em memória com `pendingLaunches` do domínio; confere módulo via `FakeCompanyRepository` |
| `test/features/measurements/presentation/noise_points_screen_test.dart` | vazio → cadastrar; cadastrar com limite; nome vazio e duplicado (erro no campo, sheet aberta); editar; desativar/reativar (muda de seção); excluir com confirmação |
| `test/features/measurements/presentation/noise_launch_screen_test.dart` | com `testNow` (semana 40): título "Semana 40" e "28/09 a 04/10/2026"; próxima desabilitada; anterior → semana 39 "21 a 27/09/2026"; "Anterior: 61,8"; digitar 72 com limite 70 → "Acima do limite (70,0)"; salvar parcial grava só o ponto digitado e mostra "1 de 2"; apagar o valor e salvar remove; sem medição por ponto e "Desfazer"; sem medição na semana só nos vazios; trocar de semana com alteração pede confirmação (Cancelar mantém, Descartar troca); voltar com alteração pede confirmação; query `semana=2026-09-21` abre a semana 39; query futura abre a atual; ponto desativado com medição na semana aparece; sem pontos → `EmptyState` e cadastro |
| `test/features/deadlines/presentation/module_screen_test.dart` | Ambiental mostra "Automonitoramento › Ruídos" com cada situação; tocar abre a semana atrasada mais antiga (`semana=` na rota); Ambiental sem prazos mostra a seção e o card vazio; Produtos controlados não mostra a seção; "Encerrados" não mostra |

Dados de exemplo conferidos: `testNow` 2026-09-29 (terça) → semana 40, 28/09 a 04/10/2026; semana 39 = 21 a 27/09/2026; ponto com início 2026-09-14 (semana 38) e nada lançado → 2 semanas atrasadas (38 e 39) + atual "A lançar" → status "2 semanas atrasadas" e o toque abre `semana=2026-09-14`.

## Como verificar (definição de pronto)

```bash
dart format . && flutter analyze && flutter test
```

Emulador `Medium_Phone_API_37.0` (dados de teste; sem `pm clear`, sem desinstalar; `adb install -r`): copiar o banco antes; empresa com Ambiental → Ruídos → cadastrar 2 pontos (um com limite 70) → lançar a semana atual com um valor acima do limite → ver o aviso → salvar parcial → ver "A lançar" no módulo → completar → "Em dia" → semana anterior com "sem medição na semana" → fonte do sistema grande (1,3 e 2,0) sem corte. Conferir no banco (`sqlite3`) as linhas gravadas. Depois, apagar os pontos de teste pelo app (excluir) se não forem úteis como dados de exemplo.

## Riscos e alternativas

- **[suposição]** início da cobrança = dia do cadastro do ponto (C26).
- **[suposição]** uma casa decimal para ruído (como no wireframe: "61,8", "64,0"), até 4 dígitos inteiros.
- **[suposição]** depois de salvar, a tela fica na mesma semana (para lançar várias semanas atrasadas em sequência).
- A tela do módulo cresce: a seção entra só no Ambiental; Produtos Controlados e Qualidade ganham a sua nas fases 3 e 4.
- *Descartado:* abas no módulo (decisão do usuário, a faixa já tem o segmentado); botão "Rascunho" (decisão do usuário); atalho "Criar 4 pontos" (decisão do usuário); reordenar pontos na tela (fora de escopo, o repositório já suporta); `intl` como dependência direta só para formatar números (a formatação de uma casa é simples).
