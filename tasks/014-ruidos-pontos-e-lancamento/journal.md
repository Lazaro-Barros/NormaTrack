# Journal — 014

Entradas em ordem cronológica, mais recentes no fim. Não apagar entradas antigas.

## 2026-11-27 — Task criada e refinada

**Feito**
- Task criada a partir da quebra da Fase 2 (`tasks/README.md`), depois da 013. Lidos o wireframe `Lancamento`, `ModuloAmbiental`, a tela do módulo (`module_screen.dart`), as rotas e os widgets de `lib/app/widgets/`.

**Decidido** (respostas do usuário)
- Ruídos entra no módulo Ambiental como seção "Automonitoramento" no topo da lista, com a linha "Ruídos" e a situação à direita. A faixa do módulo não muda (as abas do wireframe ficam descartadas: a faixa já tem "Em aberto | Encerrados" e o design system permite um bloco).
- "Sem medição": para a semana inteira (pontos vazios) **e** por ponto, sempre com motivo.
- Primeira vez sem pontos: cadastrar um por um (sem o atalho "Criar 4 pontos").
- Sem botão "Rascunho": só "Salvar", que grava parcial; a semana segue pendente até completar.

**Pendente / dúvidas**
- Mostrar o plano ao usuário antes de implementar.

## 2026-11-27 — Passo 1: protótipos aprovados

**Feito**
- Plano aprovado pelo usuário. Status → `em andamento`.
- Protótipos `Lancamento`, `PontosMedicao`, `PontoSheet` e `ModuloAmbiental` (gerados a partir do `Lancamento` antigo, conferidos em 390 × 844) aprovados pelo usuário e copiados para `docs/design/wireframes/` (substituem `Lancamento` e `ModuloAmbiental`).
- Dúvida do usuário respondida: o caminho é Empresas → empresa → Ambiental → Ruídos; o atalho para todas as empresas é o Painel com pendências (task 015).

**Decidido**
- `ModuloAmbiental` passa a mostrar a faixa como está no app ("Em aberto | Encerrados"), sem as abas e sem o botão de relatório (que entra na 018).

## 2026-11-27 — Passo 2: componentes

**Feito**
- `PeriodNavigator`, `MeasurementInputRow` (`lib/app/widgets/`) e `DecimalInputFormatter` com `parseDecimal`/`formatDecimal` (`lib/app/formatters/`), com testes (fonte 1,3×, 2× e não linear sem estouro). `docs/07-design-system.md` atualizado.

**Decidido**
- Desvio do protótipo, achado pelos testes de fonte grande: na linha sem medição, o texto vira "Sem medição: motivo" abaixo do nome e à direita fica só "Desfazer" (o par "Sem medição" + "Desfazer" estourava a linha). Acima de 1,3× de fonte, o campo desce para baixo do nome. Wireframe `Lancamento` ajustado.
- `StatusText` passa a quebrar a linha em vez de estourar (`Flexible`), o que vale para todo o app; os testes existentes seguem verdes.

## 2026-11-27 — Passo 3: rótulos, providers e fake

**Feito**
- `measurement_labels.dart` (período, intervalo, anterior, limite, situação do módulo, subtítulos), `measurement_providers.dart`, `isoDate`/`parseIsoDate` em `date_format.dart`.
- `test/helpers/fake_measurement_repository.dart` (pendências pelo mesmo `pendingLaunches` do domínio; `saved` guarda o que a tela enviou) e override no `pumpApp`.

## 2026-11-27 — Passo 4: pontos de medição

**Feito**
- `ModuleGate` (`lib/features/companies/presentation/module_gate.dart`): a checagem "Módulo não encontrado / desligado / Empresa não encontrada" saiu do `ModuleScreen` para ser usada também pelas telas de ruídos (parâmetro `only` restringe ao Ambiental). Testes do módulo seguem verdes.
- `NoisePointsScreen`, `point_sheet.dart` e `openPointSheet` (grava, trata erros e mostra SnackBar; reaproveitado pelo lançamento). Rota provisória `…/modulos/:modulo/ruidos/pontos` (vira filha de `ruidos` no passo 5).
- 7 testes de tela: vazio → cadastrar com limite (unidade dB(A), semanal, início no dia), nome vazio e repetido com a sheet aberta, editar e tirar limite, desativar/reativar, excluir com confirmação (apaga as medições), módulo desligado e fora do Ambiental.

**Decidido**
- O erro de nome repetido vem do repositório e aparece no campo sem fechar a sheet: a sheet recebe `onSave` que devolve a mensagem.

## 2026-11-27 — Passo 5: lançamento semanal

**Feito**
- `NoiseLaunchScreen` (rota `…/modulos/ambiental/ruidos?semana=AAAA-MM-DD`, com `pontos` como filha) e `skip_reason_sheet.dart`. Rascunho por ponto em memória, comparado com o salvo para saber se há alteração; "Salvar" envia só as linhas alteradas e preserva a observação que já existia junto de um valor.
- 15 testes de tela: faixa e navegação (próxima desabilitada na semana atual), anterior, aviso de limite ao digitar, salvar parcial, apagar remove, observação preservada, sem medição por ponto (motivo obrigatório, Desfazer) e na semana (só os vazios), confirmação ao trocar de semana e ao voltar, valor inválido, semana pela rota (futura abre a atual), linhas com ponto desativado e início posterior, estado vazio, ação dos pontos.

**Decidido**
- `MeasurementInputRow` usa `PopupMenuButton.onSelected` em vez de `PopupMenuItem.onTap`: o `onTap` roda antes de o menu fechar, e o fechamento derrubaria a sheet do motivo recém-aberta.
- Depois de salvar, a tela fica na mesma semana, com SnackBar "Semana 40 salva" **[suposição]**.

## 2026-11-27 — Passo 6: Ruídos no módulo Ambiental

**Feito**
- `MonitoringSection` (seção "Automonitoramento" com o `NavRow` "Ruídos") no topo da vista "Em aberto" do Ambiental; sem prazos, o vazio de prazos aparece abaixo dela. `EmptyState` ganhou `inline: true` (só o card, para ficar numa lista), com teste.
- 6 testes novos no `module_screen_test.dart`: sem pontos, as três situações reagindo aos lançamentos, toque abre a semana atrasada mais antiga ou a atual, Encerrados e Produtos controlados sem a seção. `docs/07-design-system.md` (telas do módulo, lançamento e pontos; `EmptyState.inline`).

**Decidido**
- Tentativa descartada: tornar flexível o conteúdo à direita de todo `NavRow` (para a situação longa quebrar linha) quebrou outras telas que põem uma linha inteira à direita (formulário de prazo, Ajustes). Ficou só na seção: a situação tem largura máxima de 40% da tela e quebra a linha.

## 2026-11-27 — Verificação no emulador e correções

**Feito** (emulador `Medium_Phone_API_37.0`; cópia do banco antes; `adb install -r`)
- Empresas → Indústria Alfa Ltda → Ambiental: seção "Automonitoramento › Ruídos" com "Nenhum ponto cadastrado". Ruídos abre na semana 48 (23 a 29/11/2026), próxima desabilitada, estado vazio com "Cadastrar ponto".
- Ponto "Divisa norte" com limite 70 → 72,5 (digitado "72.5", vira vírgula) mostra "Acima do limite (70,0)"; "Semana 48 salva". Banco: `Divisa norte | dB(A) | weekly | 2026-11-27 | 70.0` e `2026-11-23 | 72.5`. Módulo passa a "Em dia" com "1 ponto · semanal".
- Segundo ponto pela ação da faixa; "Sem medição neste ponto" pelo menu (a sheet do motivo fica aberta) → "Sem medição: Obra no galpao" com "Desfazer", contador "2 de 2"; trocar de semana com alteração pede "Descartar alterações?"; Cancelar e Salvar gravam a justificativa (`value` nulo, `note` com o motivo).
- Fonte do sistema 2,0: campos descem para baixo do nome, sem corte; fonte voltou a 1,0.
- Depois de tudo, as 5 tabelas antigas iguais à cópia de antes; os dois pontos e as medições ficam como dados de teste da Indústria Alfa Ltda.

**Decidido** (achados corrigidos nesta entrada)
- "0,0" colado em "dB(A)" no campo: `suffix` com espaço em vez de `suffixText`.
- "dB(A)" no alto do campo de limite da sheet: sufixo centralizado.
- Semana anterior ao cadastro dos pontos mostrava "Nenhum ponto de medição · Cadastrar ponto"; agora mostra "Nenhum ponto nesta semana" sem ação quando já existem pontos ativos (teste novo).
- Teclado de letras no campo decimal: o campo pede `inputType=0x2002` (número com decimal, conferido com `dumpsys input_method`); é o Gboard deste emulador que mostra letras. Não é defeito do app.
