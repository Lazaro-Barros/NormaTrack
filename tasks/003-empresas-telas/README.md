# 003 — Empresas: telas de lista, cadastro e detalhe

| | |
|---|---|
| **Status** | planejada |
| **Fase** | 1 ([roadmap](../../docs/05-roadmap.md)); traz junto o mínimo da Fase 0 (go_router, barra inferior, localização pt-BR) |
| **Requisitos** | RF-EMP-01, RF-EMP-02, RF-EMP-03, RF-EMP-04, RF-EMP-05 · RNF-06 |
| **Depende de** | 001, [002](../002-empresas-dominio-e-dados/), [004](../004-refinamento-visual/) (design system v0.2) |
| **Wireframe** | [Empresas](../../docs/design/wireframes/Empresas.dc.html) · [EmpresaForm](../../docs/design/wireframes/EmpresaForm.dc.html) · [EmpresaDetalhe](../../docs/design/wireframes/EmpresaDetalhe.dc.html) · [EmpresaOrgao](../../docs/design/wireframes/EmpresaOrgao.dc.html) (v0.2) |

> **Para implementar, comece pelo [plano técnico](plan.md).** Ele é autocontido: contratos, textos, rotas, componentes e testes.

## Objetivo

A usuária cadastra, edita, arquiva e consulta empresas no app, com dados cadastrais, módulos ativos e registros em órgãos. O detalhe da empresa mostra só os módulos habilitados.

## Escopo

- Navegação: `go_router` com barra inferior (Painel, Empresas, Ajustes). Painel e Ajustes ficam como `EmptyState`.
- Lista de empresas: busca na faixa, segmentado ativas/arquivadas, nome e cidade/UF por empresa, `EmptyState`.
- Formulário (novo/editar) em seções: Identificação · Endereço · Contato · Responsável legal · Módulos · Órgãos.
  - Máscaras de CNPJ, CPF, CEP e telefone; UF em lista; erros com ícone + texto.
  - Órgãos: para cada um dos 9, situação (não se aplica / possui registro / precisa obter). Com "possui registro", mostra nº e validade.
- Detalhe: dados cadastrais formatados, órgãos que se aplicam com situação, módulos habilitados e ações arquivar/desarquivar (arquivar com contorno vermelho + confirmação).
- Componentes de `lib/app/widgets/` que ainda faltam (cada um com teste): `AppTextField`, `AppDropdownField`, `SwitchRow`, `NavRow`, `StatusText`, `InfoRow`, `SectionCard`, `EmptyState`, `BandTitle`, `AppActionBar`, `DestructiveButton` e `showConfirmDialog`. No tema: `BandColors` e `searchBarTheme`.
- ~~Atualizar o wireframe `EmpresaForm` com as novas seções~~ — feito na task 004: tela rolável com seções em cards; órgãos abrem um bottom sheet (`EmpresaOrgao`).

## Fora de escopo

- `ModuleCard` com resumo de pendências (depende de prazos). No detalhe, os módulos aparecem só como itens.
- Painel e Ajustes funcionais.
- Excluir empresa pela UI (só arquivar), a menos que a usuária peça.
- Tudo que depende de prazos ou relatórios (decisão da usuária, 2026-09-29): situação por empresa na lista, pílulas de resumo no cabeçalho do detalhe, pendências por módulo, botão "Gerar relatório" e navegação para a tela do módulo. Ficam como `TODO(RF-PRZ-05)`, `TODO(RF-REL-01)` e `TODO(RF-EMP-03)`.

## Critérios de aceite

- [x] Wireframe do formulário atualizado e aprovado pela usuária antes da implementação (v0.2, 2026-09-29)
- [ ] Criar empresa só com a razão social, e editar todos os campos
- [ ] CNPJ/CPF/e-mail/CEP inválidos mostram erro no campo. CNPJ duplicado mostra erro claro
- [ ] Módulos ligados/desligados no formulário refletem no detalhe (só os habilitados aparecem)
- [ ] Órgãos: nº e validade só aparecem com "possui registro". Validade vencida aparece destacada (ícone + texto)
- [ ] Arquivar pede confirmação, e a empresa some das ativas e aparece em arquivadas
- [ ] Telas seguem o design system (sem cor/fonte/espaço avulsos); testes de widget do formulário e da lista
- [ ] `dart format .`, `flutter analyze` e `flutter test` sem erros

## Links

- [Plano técnico](plan.md) · [Journal](journal.md) · [Protótipos](prototypes/)
