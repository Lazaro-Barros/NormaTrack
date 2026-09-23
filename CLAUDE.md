# CLAUDE.md

Contexto para agentes de código trabalhando neste repositório.

## Projeto

NormaTrack é um app Flutter (Android) de conformidade regulatória para indústrias: prazos com alerta, lançamentos periódicos e relatórios exportáveis. Leia `docs/` antes de implementar qualquer coisa. `docs/02-requisitos.md` e `docs/03-dominio.md` são a fonte da verdade do escopo.

## Regras de arquitetura

- `features/*/domain` é Dart puro: sem imports de Flutter, drift ou HTTP.
- A UI acessa dados **apenas** por interfaces de repositório injetadas via Riverpod. Nunca use o `AppDatabase` diretamente em widgets.
- Toda tabela tem `id` UUID (gerado no app), `createdAt`, `updatedAt` e `deletedAt`. Exclusão é lógica.
- Valores derivados (estoque por lote, situação de prazo) são calculados, não persistidos.
- Toda alteração de schema vem acompanhada de migração drift versionada e teste.

## Convenções

- Interface do usuário em pt-BR; nomes em código conforme o glossário de `docs/03-dominio.md`.
- Referencie o ID do requisito (ex.: `RF-PRZ-03`) no commit ou PR.
- Antes de concluir: `dart format .`, `flutter analyze` e `flutter test` sem erros.

## Comandos

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # drift / codegen
flutter test
flutter run
```

## Ao encontrar ambiguidade

Não invente regra de negócio. Registre a dúvida em `docs/06-perguntas-em-aberto.md` e siga com a suposição mais simples, marcada com `// TODO(RF-XXX):`.
