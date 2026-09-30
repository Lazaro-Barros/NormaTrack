# Plano técnico — NNN

> **Plano autocontido.** Um agente sem o histórico da conversa deve conseguir implementar a task só com esta pasta, o `CLAUDE.md` e o código. Suposições de negócio estão marcadas com **[suposição]** e viram `// TODO(RF-XXX):` no código. Ver o checklist em `.claude/skills/task/SKILL.md` (passo 3).

## Abordagem

Resumo da solução em poucas frases.

## Contexto do repositório (em AAAA-MM-DD)

O que já existe, o que ainda não existe, versões e armadilhas conhecidas.

## Ordem de implementação

Branch, passos numerados, formato de commit e fechamento (journal, status, roadmap).

## Setup

Pacotes com versão, arquivos de configuração e comandos de codegen. Omitir se não houver.

## Arquivos

| Camada | Arquivo | Conteúdo |
|---|---|---|
| domain | `lib/features/<feature>/domain/…` | … |
| data | `lib/features/<feature>/data/…` | … |
| presentation | `lib/features/<feature>/presentation/…` | … |

## Valores de referência

Enums e listas fixas: valor, código persistido, rótulo pt-BR. Omitir se não houver.

## Domínio e contratos

Assinaturas de entidades, interfaces de repositório, filtros e exceções. Regras de normalização e validação campo a campo.

## Regras de implementação

Casos de borda (inexistente, excluído, duplicado, idempotência), transações, timestamps e cascata.

## Dados

Tabelas, colunas, tipos, nulidade, índices, FKs e migração drift (versão N → N+1). Omitir se não houver.

## Interface

Telas, rotas, estados (vazio, carregando, erro) e componentes de `lib/app/widgets/` usados ou criados. Seguir `docs/07-design-system.md` e o wireframe.

## Testes

| Arquivo | Cobre |
|---|---|
| `test/…` | casos obrigatórios, com dados de exemplo conferidos |

## Como verificar (definição de pronto)

- `dart format .`, `flutter analyze` e `flutter test` sem erros
- …

## Riscos e alternativas

- Suposições **[suposição]** (também em `docs/06-perguntas-em-aberto.md`).
- *Descartado:* …
