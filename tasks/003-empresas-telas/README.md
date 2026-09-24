# 003 — Empresas: telas de lista, cadastro e detalhe

| | |
|---|---|
| **Status** | rascunho |
| **Fase** | 1 ([roadmap](../../docs/05-roadmap.md)); traz junto o mínimo da Fase 0 (go_router, barra inferior, localização pt-BR) |
| **Requisitos** | RF-EMP-01, RF-EMP-02, RF-EMP-03, RF-EMP-04, RF-EMP-05 · RNF-06 |
| **Depende de** | 001, [002](../002-empresas-dominio-e-dados/) |
| **Wireframe** | [Empresas](../../docs/design/wireframes/Empresas.dc.html) · [EmpresaForm](../../docs/design/wireframes/EmpresaForm.dc.html) · [EmpresaDetalhe](../../docs/design/wireframes/EmpresaDetalhe.dc.html) |

## Objetivo

A usuária cadastra, edita, arquiva e consulta empresas no app, com dados cadastrais, módulos ativos e registros em órgãos. O detalhe da empresa mostra só os módulos habilitados.

## Escopo

- Navegação: `go_router` com barra inferior (Painel, Empresas, Ajustes). Painel e Ajustes ficam como `EmptyState`.
- Lista de empresas: busca, filtro ativas/arquivadas, módulos habilitados e `EmptyState`.
- Formulário (novo/editar) em seções: Identificação · Endereço · Contato · Responsável legal · Módulos · Órgãos.
  - Máscaras de CNPJ, CPF, CEP e telefone; UF em lista; erros com ícone + texto.
  - Órgãos: para cada um dos 9, situação (não se aplica / possui registro / precisa obter). Com "possui registro", mostra nº e validade.
- Detalhe: dados cadastrais formatados, órgãos com situação, módulos habilitados e ações arquivar/desarquivar (contorno + confirmação).
- Componentes de `lib/app/widgets/` que ainda faltam: `AppTextField`, `SwitchRow`, `NavRow`, `EmptyState` (cada um com teste).
- Atualizar o wireframe `EmpresaForm` com as novas seções (protótipo aprovado primeiro).

## Fora de escopo

- `ModuleCard` com resumo de pendências (depende de prazos). No detalhe, os módulos aparecem só como itens.
- Painel e Ajustes funcionais.
- Excluir empresa pela UI (só arquivar), a menos que a usuária peça.

## Critérios de aceite

- [ ] Wireframe do formulário atualizado e aprovado pela usuária antes da implementação
- [ ] Criar empresa só com a razão social, e editar todos os campos
- [ ] CNPJ/CPF/e-mail/CEP inválidos mostram erro no campo. CNPJ duplicado mostra erro claro
- [ ] Módulos ligados/desligados no formulário refletem no detalhe (só os habilitados aparecem)
- [ ] Órgãos: nº e validade só aparecem com "possui registro". Validade vencida aparece destacada (ícone + texto)
- [ ] Arquivar pede confirmação, e a empresa some das ativas e aparece em arquivadas
- [ ] Telas seguem o design system (sem cor/fonte/espaço avulsos); testes de widget do formulário e da lista
- [ ] `dart format .`, `flutter analyze` e `flutter test` sem erros

## Links

- [Plano técnico](plan.md) · [Journal](journal.md) · [Protótipos](prototypes/)
