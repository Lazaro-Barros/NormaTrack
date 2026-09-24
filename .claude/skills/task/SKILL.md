---
name: task
description: Fluxo de tasks do NormaTrack. Use sempre que for criar, quebrar, refinar, planejar, prototipar, implementar, retomar ou concluir uma task do projeto, ou quando o usuário disser "nova task", "quebrar em tasks", "próxima task", "continuar a task NNN", "registrar no journal" ou pedir para implementar algo do roadmap/requisitos. Toda implementação no repositório acontece dentro de uma task em tasks/.
---

# Tasks do NormaTrack

Todo trabalho de implementação vive em `tasks/NNN-slug/`. A pasta da task guarda o escopo, o plano técnico, os protótipos e o diário (journal) do que foi feito e decidido. Um agente que abre a pasta deve conseguir retomar o trabalho sem o histórico da conversa.

## Estrutura

```
tasks/
├── README.md                 # índice de todas as tasks (tabela)
├── _template/                # copiar para criar uma task
└── NNN-slug/
    ├── README.md             # escopo, critérios de aceite, status
    ├── plan.md               # plano técnico
    ├── journal.md            # diário datado: feito, decidido, pendente
    └── prototypes/           # wireframes, spikes, rascunhos de SQL/JSON, imagens
```

- `NNN`: número sequencial com 3 dígitos. Próximo = maior número existente em `tasks/` + 1. Nunca reutilize um número, nem de task cancelada.
- `slug`: kebab-case em português, curto, sem acentos (`crud-empresas`, `renovacao-de-prazo`).
- Status (no README da task e no índice): `rascunho` → `planejada` → `em andamento` → `concluída`. Ou `bloqueada` (diga por quê) e `cancelada` (diga por quê).

## Fluxo

### 1. Criar

1. Leia `tasks/README.md` para achar o próximo número e evitar duplicata.
2. Copie `tasks/_template/` para `tasks/NNN-slug/`.
3. Preencha o `README.md` da task: objetivo, requisitos (`RF-*`/`RNF-*` de `docs/02-requisitos.md`), fase do roadmap, dependências (outras tasks), fora de escopo e critérios de aceite verificáveis.
4. Adicione a linha no índice `tasks/README.md` com status `rascunho`.
5. Primeira entrada no `journal.md`: task criada e de onde veio.

Uma task deve caber em um PR revisável. Se o escopo tem mais de uma tela grande, mais de uma tabela nova com regras próprias, ou critérios de aceite que não cabem em ~8 itens, quebre em várias tasks e registre a dependência entre elas.

### 2. Refinar

- Ambiguidade de negócio: **não invente regra**. Pergunte ao usuário. Se não houver resposta, registre em `docs/06-perguntas-em-aberto.md`, siga com a suposição mais simples e marque no código com `// TODO(RF-XXX):` e no journal.
- Registre no journal as respostas recebidas e o que mudou no escopo.

### 3. Planejar (`plan.md`)

Antes de escrever código de produção, preencha o `plan.md`:

- Arquivos/camadas afetados, seguindo `docs/04-arquitetura.md` (domain puro, data, presentation).
- Modelo de dados e migração drift (se houver).
- Interfaces de repositório e casos de uso.
- Telas e componentes. Toda UI segue o design system: `docs/07-design-system.md`, `lib/app/theme/`, `lib/app/widgets/` e o wireframe em `docs/design/wireframes/`.
- Estratégia de testes (unitário de domínio, banco em memória, widget).
- Riscos e alternativas descartadas.

Status → `planejada`. Para planos com decisões relevantes, mostre o plano ao usuário antes de implementar.

### 4. Prototipar (`prototypes/`)

Quando houver incerteza de UI ou técnica, prototipe antes de implementar:

- **UI:** wireframe da tela ou variação dela. Reaproveite `docs/design/wireframes/*.dc.html` como base. Se o protótipo for aprovado e virar a tela oficial, atualize também `docs/design/wireframes/`.
- **Técnico:** spike de código (`.dart`), consulta SQL, exemplo de arquivo gerado (xlsx/docx). Código em `prototypes/` é descartável: não é importado por `lib/` e fica fora do `flutter analyze` (`tasks/**` está excluído em `analysis_options.yaml`).
- Cite no journal o que cada protótipo provou ou descartou.

### 5. Implementar

- Status → `em andamento`. Siga o `CLAUDE.md` (arquitetura, design system, convenções).
- Escreva no journal **durante** o trabalho, não só no fim: a cada decisão, desvio do plano, descoberta ou bloqueio. Se o plano mudar, atualize o `plan.md` e explique no journal.
- Referencie `NNN` e os `RF-*` nos commits e no PR (ex.: `feat(empresas): CRUD de empresas [task 003, RF-EMP-01]`).
- Antes de concluir: `dart format .`, `flutter analyze` e `flutter test` sem erros.

### 6. Concluir

1. Marque os critérios de aceite atendidos no `README.md` da task. Critério não atendido: explique no journal ou crie uma task nova.
2. Última entrada no journal: resumo final, como verificar e pendências.
3. Status → `concluída` no README da task e no índice.
4. Propague o que for do projeto e não só da task:
   - Decisão técnica que vale para o projeto todo → nova entrada em `docs/decisoes.md` (`D0NN`), com link no journal.
   - Pergunta respondida → mover para o documento correspondente e anotar em `docs/06-perguntas-em-aberto.md`.
   - Item do roadmap entregue → marcar em `docs/05-roadmap.md` com o número da task.
   - Mudança no design system → `docs/07-design-system.md`.

## Journal

Arquivo cronológico, entradas mais recentes **no fim**. Nunca apague entradas antigas; se algo estava errado, corrija em uma entrada nova. Formato:

```markdown
## 2026-09-24 — título curto do que aconteceu

**Feito**
- …

**Decidido**
- Decisão — motivo. Alternativa descartada: … (se relevante)

**Pendente / dúvidas**
- …

**Refs:** commit abc1234 · PR #12 · docs/decisoes.md#d007
```

Omita seções vazias. Datas absolutas (`AAAA-MM-DD`), nunca "hoje" ou "ontem".

## Retomar uma task

Leia, nesta ordem: `README.md` da task (escopo e status), o fim do `journal.md` (onde parou), `plan.md`. Depois confira o código real antes de confiar no que está escrito. Continue registrando no journal.
