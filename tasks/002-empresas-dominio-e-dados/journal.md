# Journal — 002

Entradas em ordem cronológica, mais recentes no fim. Não apagar entradas antigas.

## 2026-09-24 — Task criada

**Feito**
- Task criada a partir do pedido da usuária: cadastro de empresa com dados cadastrais, módulos ativos e órgãos (setores) em que a empresa tem ou precisa ter registro, estruturado para reuso em fluxos, relatórios e telas condicionais.
- Escopo dividido em duas tasks: esta (domínio + dados) e a [003](../003-empresas-telas/) (telas). Juntas passariam de uma tela grande e três tabelas, acima do limite de um PR revisável.
- Plano técnico escrito (status `planejada`).
- Requisitos RF-EMP-04 e RF-EMP-05 adicionados; domínio, perguntas em aberto, roadmap e decisões atualizados.

**Decidido** (respostas da usuária)
- Por órgão: situação (possui registro / precisa obter) + nº do registro + validade. "Não se aplica" = sem registro.
- Lista de órgãos fixa no código (enum com os 9). Incluir outro exige nova versão → [D007](../../docs/decisoes.md#d007--órgãos-e-módulos-como-enums-de-domínio).
- Só a razão social é obrigatória. Isso responde C5 em parte.
- Responsável legal: nome, CPF, telefone e e-mail.
- Endereço e responsável como colunas em `companies` (1:1), não tabelas próprias.
- A infra mínima (drift, uuid, Riverpod) entra nesta task porque é a primeira tabela do app.

**Pendente / dúvidas**
- C15: relação órgão ↔ módulo para telas condicionais (além de PF/Exército → Produtos Controlados, que já está nos requisitos).
- C16: a validade do registro deve gerar prazo com alerta?
- C17: Conselho de Classe e Secretaria de Meio Ambiente precisam de detalhe (qual conselho, municipal/estadual)? Suposição: campo `notes` livre, `// TODO(RF-EMP-05)`.

## 2026-09-24 — Plano completado para ser autocontido

**Feito**
- Revisão do plano mostrou lacunas que obrigariam outro agente a adivinhar. O `plan.md` foi reescrito com: contexto do repositório, ordem de implementação e commits, setup (versões, `build.yaml`, comandos), contratos completos (`CompanyInput`, exceções, filtros), valores de referência dos enums, normalização, tabela de validação, regras do repositório (transação, timestamps, upsert de filhos, cascata na exclusão), schema com índices e FKs, providers, testes por arquivo e como verificar.
- APIs conferidas no pub cache (drift 2.35.0, drift_dev 2.35.0, drift_flutter 0.3.1, uuid 4.6.0): `TableIndex.sql`, `make-migrations`, opções `databases`/`test_dir`/`schema_dir`/`store_date_time_values_as_text` e `Uuid().v7()`.
- Casos de teste do CNPJ conferidos com script (os dois válidos passam, os dois inválidos falham).
- Critério "docs refletem o modelo" marcado (feito na criação).

**Decidido**
- CNPJ alfanumérico suportado (IN RFB nº 2.229/2024, vigente desde julho de 2026). Também registrado em RF-EMP-04.
- Validade guardada como texto `AAAA-MM-DD`, para não mudar de dia por fuso. Timestamps em UTC, ISO-8601.
- UUID v7 (ordenado no tempo, melhor para índice e sync).
- Filtros de busca/módulo/órgão em Dart, sobre as empresas não excluídas: volume pequeno, e o `LIKE` do SQLite não trata acento.
- Entidades escritas à mão, sem `freezed` (T3 em aberto). Edição via `CompanyInput`, sem `copyWith`.
- Excluir a empresa exclui (lógico) também seus módulos e registros.

**Pendente / dúvidas**
- Suposições enviadas para confirmação em C18: telefone com 10/11 dígitos, um telefone/e-mail, nenhum módulo por padrão, validade inclusiva.
