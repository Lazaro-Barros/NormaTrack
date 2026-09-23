# 01 — Visão geral

## Problema

Indústrias precisam cumprir obrigações com vários órgãos (ambiental, Polícia Federal, Exército, vigilância sanitária etc.). Essas obrigações têm duas naturezas:

1. **Prazos** — licenças, laudos e manutenções que vencem e precisam ser renovados com antecedência.
2. **Registros periódicos** — medições e movimentações (ruído, resíduos, efluentes, produtos controlados, produção por lote) que precisam ser lançadas semanal ou mensalmente e depois entregues como relatório.

Hoje isso é controlado de forma manual. Perder um prazo de licença ou não conseguir montar um relatório no período gera multa e risco operacional.

## Proposta

Um app onde se cadastram **empresas**, e cada empresa habilita apenas os **módulos** de que precisa. Cada módulo agrupa prazos, lançamentos e relatórios de uma área regulatória.

```
App
└── Empresa (A, B, C, …)
    ├── Ambiental
    ├── Produtos Controlados
    ├── Controle de Qualidade
    └── Controle de Processos (futuro)
```

Módulos não habilitados ficam ocultos para aquela empresa.

## Os três padrões do sistema

Praticamente tudo que a cliente descreveu é uma combinação de três padrões. Construir bem esses três resolve a maior parte do produto:

| Padrão | O que é | Exemplos |
|---|---|---|
| **Prazo com alerta** | Uma data de vencimento e um aviso com antecedência configurável | Licença ambiental (alerta 150 dias antes), licença PF, licença Exército, laudo da ETE, manutenção |
| **Lançamento periódico** | Formulário de valores por período (semana/mês) | Ruído em 4 pontos por semana, resíduos por classe por mês, pH da ETE, movimentação de produto controlado |
| **Relatório exportável** | Consolidação dos lançamentos em arquivo editável | Planilha e documento Word para assinar e enviar ao órgão |

O relatório precisa ser **editável** (Word/planilha), porque a cliente ajusta, assina e envia ao órgão fiscalizador.

## Usuários

A definir — ver [perguntas em aberto](06-perguntas-em-aberto.md). A hipótese de trabalho é um único usuário (responsável técnico/consultor) gerenciando várias empresas no próprio celular.

## Fora do escopo inicial

- Envio de alertas por e-mail (exige backend — entra com a API)
- Multiusuário, login e sincronização entre dispositivos
- iOS e web
- Envio direto de relatórios aos órgãos
