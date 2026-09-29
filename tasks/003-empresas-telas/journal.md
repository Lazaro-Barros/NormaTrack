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

## 2026-09-29 — Passo 5: situação do registro

**Feito**
- `RegistrationSituation` e `AuthorityRegistration.situationOn` em `authority.dart`, com os quatro casos do plano em `company_test.dart`. `TODO(RF-EMP-05)` do alerta antes da validade (C16) no enum.

## 2026-09-29 — Passo 6: lista de empresas

**Feito**
- `company_providers.dart`, `company_labels.dart` (`ModuleTypeUi`, `registrationDisplay`, `cityState`, `companyFieldMessage`, `duplicateCnpjMessage`), `CompanyListScreen` ligada ao ramo `/empresas`. `FakeCompanyRepository` e `pumpApp(repository:)` em `test/helpers/`. Testes de rótulos e da lista; `widget_test.dart` agora cobre "tocar em Empresas mostra 'Nenhuma empresa cadastrada'".

**Decidido**
- Os casos de navegação a partir da lista (ação do vazio e FAB abrem "Nova empresa"; tocar em Alfa abre o detalhe e esconde a barra) entram nos passos 7 e 8, quando as rotas `nova` e `:id` existirem.
- Trocar ativas/arquivadas limpa a lista anterior (`_last = null`): mostrar as ativas por um instante sob "Arquivadas" seria enganoso. A lista anterior só é mantida durante a busca, como o plano pede.
- `FakeCompanyRepository` expõe `all` (empresas vivas) para os testes conferirem o que foi gravado.

## 2026-09-29 — Passo 7: formulário e registro em órgão

**Feito**
- `CompanyFormScreen` (criar e editar, seis seções, salvar com erros por campo, CNPJ duplicado, descartar alterações) e `showRegistrationSheet`. Rotas `nova`, `:id` e `:id/editar` no navigator raiz. Testes do formulário, do sheet e da navegação da lista para o formulário (ação do vazio e FAB). Helper `test/helpers/finders.dart` (`fieldLabeled`, `fieldText`).

**Decidido**
- Desvio do plano: o corpo do formulário é `SingleChildScrollView` + `Column`, não `ListView`. O `ListView` só monta o que está perto da tela, e aí `Scrollable.ensureVisible` não acha o primeiro campo com erro se ele estiver fora dela (a `GlobalKey` fica sem contexto). São ~20 campos, custo desprezível. Comentário no código.
- Todo campo chama `setState` no `onChanged`, para o `PopScope.canPop` refletir `_isDirty` na hora (não só o campo com erro).
- A validade no sheet usa um `TextEditingController` de estado, atualizado ao escolher ou remover a data, em vez de recriar o campo.
- Enquanto a empresa carrega ou não existe, o `PopScope` libera a saída e a barra de ações não aparece (não há o que salvar).
- A rota `:id` aponta para um `Scaffold` provisório com a faixa "Empresa" até o passo 8. Por isso o teste "só a razão social" confere o repositório, o SnackBar e a saída do formulário; abrir o detalhe com o nome certo entra no passo 8.
- Nos testes, o título é buscado no `BandTitle`: o FAB da lista também diz "Nova empresa".

## 2026-09-29 — Passo 8: detalhe da empresa

**Feito**
- `CompanyDetailScreen` na rota `/empresas/:id`: faixa com CNPJ e "Arquivada", módulos habilitados (ou "Habilitar módulos"), órgãos que se aplicam com `StatusText` e "Ver todos os 9 órgãos"/"Informar órgãos", dados cadastrais em `InfoRow`, arquivar (confirmação + SnackBar com Desfazer) e desarquivar. `TODO(RF-PRZ-05)`, `TODO(RF-REL-01)` e `TODO(RF-EMP-03)` nos lugares previstos.
- Testes do detalhe (inclui Desfazer, empresa só com a razão social e id inexistente). Os testes do formulário agora conferem que salvar abre o detalhe com o nome certo e que editar volta ao detalhe com o valor novo; o de navegação da lista confere que o detalhe esconde a barra inferior.

**Decidido**
- Endereço, 1ª linha: `logradouro, número - complemento`, omitindo o que falta (sem logradouro nem número, fica só o complemento). O plano não cobria esse caso; é formatação, não regra de negócio.
- O "9" de "N de 9" e "Ver todos os 9 órgãos" vem de `Authority.values.length`, não de literal.

## 2026-09-29 — Passo 9: docs e fechamento

**Feito**
- `docs/07-design-system.md`: componentes novos marcados ✅ com uma linha de uso, `BandColors` e `searchBarTheme` (seção "Faixa de cabeçalho") e a tabela de situação do registro em órgão (`StatusText`, não pílula).
- `docs/05-roadmap.md`: "CRUD de empresas", "Dados cadastrais e registros em órgãos", "Habilitar módulos por empresa" e, na Fase 0, "Riverpod, go_router, tema e localização pt-BR" marcados.
- `docs/decisoes.md`: [D010 — Navegação com go_router 17](../../docs/decisoes.md#d010--navegação-com-go_router-17).
- `docs/06-perguntas-em-aberto.md`: nova C19 (UF pré-selecionada?), a suposição do plano que ainda não estava registrada; o `TODO(RF-EMP-04)` do campo UF aponta para ela.
- Critérios de aceite marcados e status → `concluída` (README e índice).

**Decidido**
- O grep de cores do "Como verificar" casava `StatusColors.`/`BandColors.` (substring de `Colors.`), inclusive no `status_chip.dart` que já existia, então nunca sairia vazio. Corrigido no `plan.md` com limite de palavra: `(^|[^A-Za-z])Colors\.`. Com ele, os três greps saem vazios.

**Como verificar**
- `flutter pub get`, `dart format .` (0 alterados), `flutter analyze` (sem problemas), `flutter test` (146 testes verdes) e os três greps do plano (vazios). `flutter build apk --debug` compila.
- Critérios de aceite e onde estão cobertos: criar só com razão social e editar (`company_form_screen_test`); erros de CNPJ/CPF/e-mail/CEP e CNPJ duplicado (idem); módulos no detalhe (`company_form_screen_test` grava o módulo, `company_detail_screen_test` mostra só os habilitados); nº/validade só com "Possui" e validade vencida com ícone + texto (`registration_sheet_test`, `company_detail_screen_test`); arquivar com confirmação e Arquivadas (`company_detail_screen_test`).

**Pendente / dúvidas**
- **Não verificado no emulador**: não havia dispositivo Android conectado nesta sessão, então o `flutter run` do "Como verificar" (criar, editar, órgão com validade vencida, arquivar/desfazer) fica para a usuária. Pontos a olhar: menu da UF estreito (`CE · Ceará` pode aparecer cortado, passo 4), teclado sobre o bottom sheet, cursor no fim ao editar no meio de CNPJ/telefone (limitação aceita no plano).
- "Editar todos os campos": todos os campos são editáveis no formulário, mas o teste de edição altera só o nome fantasia (e confere que CNPJ e telefone chegam formatados).
- Seguem os TODOs de prazos e relatórios: `TODO(RF-PRZ-05)` (lista, faixa do detalhe, Painel), `TODO(RF-REL-01)` (gerar relatório), `TODO(RF-EMP-03)` (tela do módulo), `TODO(RF-PRZ-03)` (Ajustes). C15–C19 abertas.

## 2026-09-29 — Verificação no emulador

**Feito**
- `flutter run` no emulador Android (sdk gphone16k arm64, API 37), dirigido por `adb` com capturas de tela. Sem exceções nem overflow no log.
- Funcionou como esperado: barra inferior e localização pt-BR ("Guia 1 de 3", seletor de data em português); lista vazia e FAB; erro de razão social vazia com rolagem até o campo; máscaras de CNPJ alfanumérico (`12.ABC.345/01DE-35`), telefone e CPF; erros de e-mail e CPF com ícone + texto, que somem ao editar; CNPJ duplicado; sheet de órgão (nº e validade só com "Possui", aviso "Validade vencida em 02/08/2026", sheet acima do teclado); detalhe com só o módulo ligado, "2 de 9 se aplicam", "Precisa obter" e "Venceu 02/08/2026"; editar volta ao detalhe com o valor novo; Voltar do sistema e X pedem "Descartar alterações?"; arquivar com confirmação, SnackBar com Desfazer, aba Arquivadas, faixa "· Arquivada" e Desarquivar; busca por CNPJ parcial e "Nenhuma empresa encontrada"; dados persistem depois de reiniciar o app (drift).
- Digitação rápida pelo `adb input text` perdia caracteres no campo com máscara; digitando com pausa, a máscara sai certa. É artefato da injeção de teclas, não do app.

**Pendente / dúvidas** (achados, não corrigidos)
- **Foco volta ao campo ao fechar o sheet ou o diálogo:** depois de "Aplicar" no sheet de órgão ou de "Cancelar" em "Descartar alterações?", o último campo focado recupera o foco e o teclado reabre sozinho (o formulário rola até ele). Correção provável: `FocusScope.of(context).unfocus()` antes de abrir o sheet e o diálogo.
- **Barra de ações escondida pelo teclado:** com o teclado aberto, "Salvar empresa" fica atrás dele (comportamento padrão de `Scaffold.bottomNavigationBar`). É preciso fechar o teclado para salvar. Agrava o item anterior.
- **SnackBar cobre o FAB:** depois de arquivar, "Empresa arquivada / Desfazer" aparece sobre o FAB "Nova empresa". O SnackBar vai para o `Scaffold` do `AppShell`, que não tem FAB, então o FAB não sobe.
- **Botão tonal sai como primário:** o `filledButtonTheme` pinta também o `FilledButton.tonal` de petróleo cheio, então a ação do `EmptyState` ("Ver empresas", "Cadastrar empresa") parece um botão primário. Vem do tema (task 001/004), não desta task.
- **Menu da UF cortado:** confirmado. O menu tem a largura do campo ("AL · Alago…", "MS · Mato …"). A sigla aparece sempre, então dá para usar.

## 2026-09-29 — Correções da verificação no emulador (itens 1 a 3)

**Feito**
- **Foco:** `CompanyFormScreen` tira o foco (`FocusManager.instance.primaryFocus?.unfocus()`) antes de abrir o sheet de órgão e o diálogo de descarte, e o sheet faz o mesmo antes do seletor de data. Ao fechar, a rota não tem mais foco para devolver, e o teclado fica fechado.
- **Barra de ações:** `AppActionBar` ganhou padding inferior de `viewInsets.bottom` e sobe junto com o teclado. O `Scaffold` desconta a altura da barra do corpo, então nada fica escondido.
- **SnackBar sobre o FAB:** `AppShell` deixou de ter `Scaffold`; o `Scaffold` da lista vira o raiz e o Flutter põe o SnackBar flutuante acima do FAB. O `AppShell` passa a ser o `navigatorContainerBuilder` de um `StatefulShellRoute` (não mais `.indexedStack`), com o mesmo `IndexedStack` do `go_router` mais `HeroMode` desligado nos ramos fora da tela.
- Testes novos: fechar o sheet e cancelar o descarte não reabrem o teclado; "Salvar empresa" fica acima de um teclado de 300; `AppActionBar` sobe com `viewInsets`; o SnackBar de arquivar não sobrepõe o FAB; arquivar depois de visitar o Painel não lança erro. Todos falham com o código anterior (conferido com `git stash` de `lib/`) e passam agora. 151 testes verdes.
- Conferido de novo no emulador: teclado fechado depois do sheet, do diálogo e do seletor de data; barra acima do teclado; SnackBar acima do FAB; abas e Desfazer funcionando; sem exceções no log.

**Decidido**
- Tirar o `Scaffold` do `AppShell` teve dois efeitos colaterais, os dois corrigidos: (1) a `NavigationBar` passou a receber o padding da barra de status e ficou 24dp mais alta; resolvido com `MediaQuery.removePadding(removeTop: true)`, como o `Scaffold` fazia. (2) Os `Scaffold`s de todos os ramos já visitados viram raiz e mostram o SnackBar ao mesmo tempo; o do Painel, fora da tela, gerava "multiple heroes share the same tag" na volta do detalhe. Resolvido com `HeroMode(enabled: false)` nos ramos inativos. As telas também recebem `removePadding(removeBottom: true)`, porque a barra já trata a área de gestos.
- Descartado: manter o `Scaffold` no shell e mostrar o SnackBar pelo `ScaffoldMessenger` do ramo. O detalhe fica no navigator raiz e não enxerga esse messenger; seria preciso expor uma `GlobalKey`.
- `plan.md` (Navegação e `AppActionBar`) e D010 atualizados.

**Pendente / dúvidas**
- Item 4 (botão tonal com cor de primário, vem do tema) fica para uma task própria, porque mexe no tema e em `docs/07-design-system.md`.
