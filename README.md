# NormaTrack

Aplicativo de gestão de conformidade regulatória para indústrias: controle de licenças e prazos com alertas, lançamentos periódicos de monitoramento (ambiental, produtos controlados, qualidade) e geração de relatórios para órgãos fiscalizadores.

> Status: **fase de refinamento**. Nada de código ainda — a documentação abaixo é a fonte da verdade enquanto o escopo é definido.

## Documentação

| Documento | Conteúdo |
|---|---|
| [01 — Visão geral](docs/01-visao-geral.md) | Contexto, problema, usuários, padrões que se repetem no sistema |
| [02 — Requisitos](docs/02-requisitos.md) | Requisitos funcionais por módulo e não funcionais |
| [03 — Domínio](docs/03-dominio.md) | Glossário, entidades e modelo de dados preliminar |
| [04 — Arquitetura](docs/04-arquitetura.md) | Stack Flutter, camadas, persistência local preparada para API |
| [05 — Roadmap](docs/05-roadmap.md) | Fases de entrega, começando pelo MVP |
| [06 — Perguntas em aberto](docs/06-perguntas-em-aberto.md) | O que precisa ser respondido antes/durante o desenvolvimento |
| [Decisões](docs/decisoes.md) | Registro de decisões técnicas (ADR simplificado) |

## Stack (fase 1)

- Flutter, alvo **Android**
- Banco local no dispositivo (SQLite via `drift`)
- Camada de repositório abstrata, para trocar o armazenamento local por uma API no futuro

## Origem dos requisitos

Dois vídeos da cliente explicando o sistema sobre um mapa mental desenhado à mão (16/09/2026). A transcrição do primeiro vídeo foi a base destes documentos; a do segundo ainda está pendente.
