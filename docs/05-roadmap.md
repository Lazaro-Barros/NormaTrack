# 05 — Roadmap

As fases seguem a lógica dos [três padrões](01-visao-geral.md#os-três-padrões-do-sistema). Primeiro vem **prazo com alerta**, que aparece em todos os módulos e é o que mais evita prejuízo. Depois vêm os lançamentos e, por último, o estoque por lote, que é a parte mais complexa.

## Fase 0 — Fundação

- [ ] Projeto Flutter criado no repo, alvo Android, `applicationId` definido
- [ ] Lints (`flutter_lints` ou `very_good_analysis`) e formatação
- [ ] Estrutura de pastas conforme a [arquitetura](04-arquitetura.md)
- [ ] `AppDatabase` (drift) com migração inicial e testes de banco em memória
- [ ] Riverpod, go_router, tema e localização pt-BR
- [ ] CI simples: `flutter analyze` e `flutter test` a cada push

**Pronto quando:** o app abre em uma tela vazia, com banco criado e pipeline verde.

## Fase 1 — MVP: empresas e prazos

Entrega o padrão "prazo com alerta" para **todos** os módulos de uma vez.

- [ ] CRUD de empresas (RF-EMP-01)
- [ ] Habilitar módulos por empresa (RF-EMP-02/03)
- [ ] CRUD de prazos por módulo e categoria: licença ambiental, laudo e manutenção de ETE/ETA, licença PF e licença Exército (RF-PRZ-01/02, RF-AMB-01/05/06, RF-PCT-01)
- [ ] Renovação com histórico (RF-PRZ-04)
- [ ] Painel de próximos vencimentos (RF-PRZ-05)
- [ ] Notificações locais (RF-PRZ-03)
- [ ] Backup e restauração manual do banco (RNF-04)

**Pronto quando:** a cliente consegue cadastrar suas empresas e licenças reais e recebe o alerta no celular.

## Fase 2 — Automonitoramento ambiental

- [ ] Parâmetros e medições (estrutura genérica do [domínio](03-dominio.md))
- [ ] Ruídos: pontos e lançamento semanal (RF-AMB-02)
- [ ] Resíduos sólidos e perigosos (RF-AMB-03/04)
- [ ] Controle de ETE/ETA (RF-AMB-07)
- [ ] Exportação `.xlsx` e compartilhamento (RF-REL-01/03)
- [ ] Prova de conceito de `.docx` a partir de modelo

## Fase 3 — Produtos controlados e relatórios Word

- [ ] Produtos controlados e lançamentos mensais PF/Exército (RF-PCT-02/03)
- [ ] Relatórios mensais por órgão (RF-PCT-04)
- [ ] Exportação `.docx` com os modelos da cliente (RF-REL-02)

## Fase 4 — Controle de qualidade

- [ ] Produtos, compras de matéria-prima e lotes (RF-QUA-01/02/03)
- [ ] Vendas por lote e estoque calculado (RF-QUA-04/05)
- [ ] Consolidação anual (RF-QUA-06)
- [ ] Laudos de análise por produto (RF-QUA-07)

## Fase 5 — API (futuro)

- [ ] Backend (candidato natural: Go) com autenticação
- [ ] Repositórios remotos e sincronização offline-first
- [ ] Alertas por e-mail enviados pelo servidor
- [ ] Multiusuário e acesso por empresa
