# 002 — Empresas: domínio e dados

| | |
|---|---|
| **Status** | planejada |
| **Fase** | 1 ([roadmap](../../docs/05-roadmap.md)); traz junto o mínimo da Fase 0 (drift, uuid, Riverpod) |
| **Requisitos** | RF-EMP-01, RF-EMP-02, RF-EMP-04, RF-EMP-05 · RNF-02, RNF-03 |
| **Depende de** | 001 (concluída) |
| **Wireframe** | — (sem UI; telas na [task 003](../003-empresas-telas/)) |

## Objetivo

Ter o cadastro de empresa modelado e persistido: dados cadastrais, módulos habilitados e registros em órgãos. O modelo deve servir de fonte única para os outros fluxos: telas condicionais por módulo ou órgão, cabeçalho de relatórios e vínculo com prazos.

## Escopo

- Infra mínima que ainda não existe: `drift` + `AppDatabase` (schema v1), `uuid`, `flutter_riverpod`, provider do repositório.
- Domínio (Dart puro):
  - `Company` com os dados cadastrais: razão social, nome fantasia, CNPJ, inscrição estadual, endereço completo (`Address`), telefone, e-mail e responsável legal (`LegalRepresentative`: nome, CPF, telefone, e-mail).
  - `ModuleType` (enum: ambiental, produtos controlados, controle de qualidade) e módulos habilitados por empresa.
  - `Authority` (enum fixo com os 9 órgãos) e `AuthorityRegistration`: situação (possui registro / precisa obter), nº do registro e validade.
  - Validadores puros: CNPJ e CPF (dígitos verificadores), e-mail, CEP, UF.
  - `CompanyRepository` (interface) com consultas pensadas para reuso (ver plano).
- Dados: tabelas `companies`, `company_modules` e `company_authorities`, mappers e `LocalCompanyRepository`.
- Formatação pt-BR pura de CNPJ, CPF, CEP e telefone em `core/utils` (para telas e relatórios).

## Fora de escopo

- Telas (task 003).
- Alerta/prazo automático a partir da validade do registro no órgão (ver pergunta C16). A validade é só guardada e exposta.
- Consulta de CNPJ/CEP online (o app é offline).
- Anexos (C13) e múltiplos telefones/e-mails.

## Critérios de aceite

- [ ] Só a razão social é obrigatória. CNPJ (numérico e alfanumérico), CPF, e-mail, CEP e telefone, quando preenchidos, são validados, e o erro é um tipo do domínio.
- [ ] CNPJ não se repete entre empresas não excluídas. Documentos são guardados sem máscara (CNPJ em maiúsculas).
- [ ] Criar, editar, arquivar, desarquivar e excluir (lógico) empresa. Listagem reativa (`Stream`) com filtro ativas/arquivadas.
- [ ] Habilitar e desabilitar cada módulo por empresa. `Company.hasModule(...)` responde sem consultar o banco.
- [ ] Para cada um dos 9 órgãos: situação, nº e validade opcionais. "Não se aplica" = sem registro. Dá para consultar as empresas por módulo e por órgão.
- [ ] Todas as tabelas têm `id` UUID, `createdAt`, `updatedAt` e `deletedAt`. Teste de migração do schema v1.
- [x] `docs/02-requisitos.md`, `docs/03-dominio.md` e `docs/06-perguntas-em-aberto.md` refletem o modelo (feito na criação da task, 2026-09-24).
- [ ] `dart format .`, `flutter analyze` e `flutter test` sem erros

## Para quem vai implementar

Comece pelo [plano](plan.md): ele é autocontido (ordem dos passos, contratos, valores de referência, regras, testes e como verificar). Depois leia o fim do [journal](journal.md).

## Links

- [Plano técnico](plan.md) · [Journal](journal.md) · [Protótipos](prototypes/)
