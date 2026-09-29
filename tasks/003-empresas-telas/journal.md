# Journal — 003

Entradas em ordem cronológica, mais recentes no fim. Não apagar entradas antigas.

## 2026-09-24 — Task criada

**Feito**
- Task criada junto com a [002](../002-empresas-dominio-e-dados/), a partir do pedido de cadastro de empresa. Esta task cobre só a interface. Modelo e decisões de dados estão no journal da 002.

**Pendente / dúvidas**
- Plano técnico a escrever depois que a 002 estiver implementada (os nomes do domínio podem mudar). Ele precisa passar no teste do agente novo (skill `task`, passo 3) antes do status `planejada`, com o mesmo nível de detalhe do plano da 002.
- O formulário ficou longo (6 seções). Prototipar antes: uma tela rolável com seções ou etapas.

## 2026-09-29 — Wireframes refeitos no design system v0.2

**Feito**
- Na [task 004](../004-refinamento-visual/) os wireframes `Empresas`, `EmpresaForm` e `EmpresaDetalhe` foram refeitos na direção A, e foi criado `EmpresaOrgao` (bottom sheet de registro em órgão).

**Decidido**
- Formulário: uma tela rolável com seções em cards (não etapas). Cada órgão é uma linha com a situação em pílula; tocar abre o bottom sheet com situação, nº, validade e observações. Mantém a tela curta mesmo com 9 órgãos.
- Lista de empresas mostra só nome, cidade/UF e pior situação; CNPJ e módulos ficam no detalhe.
- Detalhe mostra só os órgãos que se aplicam, com link "Ver todos os 9 órgãos".

**Pendente / dúvidas**
- Aprovação da usuária para os wireframes v0.2 (critério de aceite desta task).
- Componentes novos da v0.2 que esta task vai precisar: `NavRow`, `SwitchRow`, `AppTextField`, `EmptyState` e a faixa de cabeçalho com bloco extra (busca na lista, resumo no detalhe).

## 2026-09-29 — Wireframes v0.2 aprovados

**Decidido**
- Usuária aprovou os wireframes v0.2 de `Empresas`, `EmpresaForm`, `EmpresaOrgao` e `EmpresaDetalhe`. Critério de aceite do wireframe do formulário atendido.

## 2026-09-29 — Plano técnico escrito

**Feito**
- `plan.md` preenchido no nível do plano da 002: contexto do repositório, ordem de implementação em 9 passos, setup com versões, rotas, contratos dos 12 componentes novos, textos pt-BR de cada tela, regras de salvar/descartar/arquivar e testes por arquivo com dados conferidos. Status → `planejada`.
- APIs conferidas no pub cache / SDK: `go_router` 17.5.0 (`StatefulShellRoute.indexedStack`, `goBranch`), Riverpod 3.4.3 (`StreamProvider.autoDispose.family`, `AsyncValue.when`), `SearchBarThemeData`, `GlobalMaterialLocalizations.delegates`, `InputDecoration.error`, `DropdownButtonFormField.initialValue`, `showDatePicker`, `SegmentedButton`.
- Dígitos verificadores dos CNPJs/CPFs de teste calculados por script.

**Decidido**
- Usuária: omitir por ora tudo que depende de prazos (situação na lista, pílulas no detalhe, pendências por módulo) e o que depende de telas inexistentes ("Gerar relatório", abrir módulo). Ficam como TODO.
- `go_router` fixado em `^17.5.0`: a 18.x migrou para `material_ui`, separado do `package:flutter/material.dart` do app. Vira D010 no fechamento.
- Situação do registro em órgão calculada no domínio (`AuthorityRegistration.situationOn` → `RegistrationSituation`) e mostrada igual no formulário e no detalhe com `StatusText` (texto colorido + ícone), em vez da pílula do wireframe do formulário.
- No bottom sheet, "Precisa obter" descarta nº e validade (critério de aceite), embora o domínio aceite.
- Testes de widget usam `FakeCompanyRepository`, não drift (timers do stream e `path_provider`).
- Nova extensão de tema `BandColors`, porque `onBandMuted` não está no `ColorScheme` e widgets não podem usar `AppColors`.
- UF sem valor padrão (não pré-selecionar CE).

**Pendente / dúvidas**
- Nenhuma pergunta de negócio nova. C15–C18 seguem abertas e já estão marcadas no código da 002.


## 2026-09-29 — Implementação iniciada (passo 1: setup)

**Feito**
- Status → `em andamento` (README da task e índice).
- `flutter pub add 'go_router:^17.5.0' 'flutter_localizations:{"sdk":"flutter"}'`: resolveu `go_router 17.5.0` e `intl 0.20.3` (transitiva), como no plano. `flutter analyze` e `flutter test` (75 testes) verdes.

## 2026-09-29 — Passo 2: tema e utilitários

**Feito**
- `BandColors` (extensão com `muted`), `searchBarTheme`, `formatDate` e os quatro input formatters (`_MaskFormatter` com máscara por tamanho), com testes.

**Decidido**
- O telefone troca de máscara pelo número de dígitos brutos (`mask(length)`), em vez de duas classes: é o mesmo `_MaskFormatter` para os quatro campos.

## 2026-09-29 — Passo 3: navegação

**Feito**
- `router.dart` (`AppRoutes`, `createAppRouter`, `routerProvider`), `AppShell`, `DashboardPlaceholderScreen`/`SettingsPlaceholderScreen`, `NormaTrackApp` com `MaterialApp.router` em pt-BR. `BandTitle` e `EmptyState` com testes. `test/widget_test.dart` reescrito com `pumpApp`.

**Decidido**
- Desvio temporário: neste passo o ramo `/empresas` aponta para um `Scaffold` só com a faixa "Empresas", porque `CompanyListScreen` só nasce no passo 6. O caso "tocar em Empresas mostra 'Nenhuma empresa cadastrada'" do `widget_test.dart` entra no passo 6, junto com a tela.
- `test/helpers/pump_widget.dart` (`pumpComponent`) monta componentes isolados em `MaterialApp(theme: AppTheme.light, home: Scaffold(body: ...))`, como o plano pede para os testes de `lib/app/widgets/`.
- `pumpApp` ganha o parâmetro `repository` no passo 6, com o `FakeCompanyRepository`.

## 2026-09-29 — Passo 4: componentes

**Feito**
- `SectionCard`, `StatusText`, `NavRow`, `SwitchRow`, `InfoRow`, `AppTextField`, `AppDropdownField`, `AppActionBar`, `DestructiveButton` e `showConfirmDialog` (`confirm_dialog.dart`), cada um com teste em `test/app/widgets/`.

**Decidido**
- Dois auxiliares compartilhados em `lib/app/widgets/`, fora da lista do plano, para não duplicar layout: `RowLayout` (em `nav_row.dart`, usado por `NavRow` e `SwitchRow`) e `FieldParts` (`field_parts.dart`: rótulo com `*`, erro com ícone e coluna rótulo + campo, usado por `AppTextField` e `AppDropdownField`). São públicos porque o Dart não tem privado entre arquivos; o comentário de cada um diz para não usar fora de `lib/app/widgets/`.
- `AppDropdownField` usa `isExpanded: true` e textos com reticências: no campo UF (flex 1) o menu tem a largura do campo e `CE · Ceará` pode aparecer cortado. Esta versão do Flutter não tem `menuWidth` no `DropdownButtonFormField`. Aceito; conferir no emulador.
- `StatusText` e o `caption` do `SectionCard` usam algarismos tabulares (têm datas e contagens).
