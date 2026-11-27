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
