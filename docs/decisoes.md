# Decisões

Registro curto de decisões técnicas. Cada entrada responde: o que foi decidido, por quê e o que foi descartado. Decisões não se apagam; se uma mudar, cria-se uma nova entrada que substitui a antiga.

---

## D001 — Flutter, Android primeiro

**Status:** aceita · 2026-09

App em Flutter com alvo inicial apenas Android. O Flutter mantém aberta a porta para iOS sem reescrita. Focar em uma plataforma reduz a superfície de teste no começo.

## D002 — Banco local com drift, atrás de repositórios

**Status:** aceita · 2026-09

A persistência será em SQLite via `drift`, acessada apenas por implementações de interfaces de repositório definidas no domínio.

- *Por quê:* SQL relacional combina com o domínio (lotes, somatórios, relatórios por período). O drift tem tipagem, migrações e queries reativas. Os repositórios isolam a troca futura por uma API.
- *Descartados:* `sqflite` puro (sem tipagem, mais boilerplate); Hive/Isar (chave-valor/documento, fracos para agregações e com manutenção incerta).

## D003 — IDs UUID e campos de sincronização desde o início

**Status:** aceita · 2026-09

Todas as tabelas terão `id` UUID gerado no app, além de `createdAt`, `updatedAt` e `deletedAt`. Isso custa pouco agora e evita migração dolorosa quando a API e a sincronização chegarem.

## D004 — Alertas por notificação local na fase offline

**Status:** aceita · 2026-09

E-mail exige servidor. Até a API existir, os alertas serão notificações locais, e a tela inicial sempre mostrará prazos a vencer e vencidos.

## D005 — Modelagem híbrida para medições

**Status:** proposta · 2026-09

As entidades centrais serão tipadas. Medições (ruído, ETE/ETA, laudos de análise) usarão a estrutura genérica parâmetro + valor. Reavaliar ao fim da Fase 2.

## D006 — applicationId e distribuição por APK

**Status:** aceita · 2026-09

O `applicationId` é `br.com.normatrack.app`. Por enquanto o app não será publicado na Play Store: será distribuído como APK instalado manualmente.

- *Atenção:* para um APK novo atualizar o já instalado sem perder dados, o `applicationId` e a chave de assinatura precisam ser os mesmos. Antes de distribuir, criar uma keystore de release e guardá-la fora do repositório.

## D007 — Órgãos e módulos como enums de domínio

**Status:** aceita · 2026-09-24 (task 002)

`Authority` (os 9 órgãos) e `ModuleType` são enums fixos no domínio. Cada valor tem um `code` estável em texto (`federal_police`, `controlled_products`…), que é o que vai para o banco e para a futura API, e um rótulo pt-BR. `Deadline.authority` reutiliza o mesmo `Authority`.

- *Por quê:* telas condicionais, relatórios por órgão e regras de módulo precisam de valores conhecidos em tempo de compilação. Guardar `code`, e não `name`/`index`, permite renomear o enum sem migração.
- *Descartado:* tabela de órgãos editável pela usuária, porque o comportamento passaria a depender de dados. Novo órgão = nova versão do app.

## D008 — Convenções de tabela drift

**Status:** aceita · 2026-09-24 (task 002)

- Toda tabela usa o mixin `EntityColumns` (`lib/core/database/converters.dart`): `id` texto (UUID v7 gerado no app) como chave primária, `createdAt`, `updatedAt` e `deletedAt`.
- A classe de linha gerada leva o sufixo `Row` (`@DataClassName('CompanyRow')`), para não colidir com a entidade do domínio. Linhas não saem de `features/*/data`: o mapper converte para entidade.
- Datas-hora em ISO-8601 UTC (`store_date_time_values_as_text`); datas sem hora como texto `AAAA-MM-DD` (`DateOnlyConverter`). Enums gravados pelo `code` (D007), sem `textEnum`.
- Repositórios que expõem agregados de várias tabelas observam todas elas com uma consulta-gatilho (`customSelect(..., readsFrom: {...}).watch()`) e recarregam o agregado.
- *Por quê:* regras do `CLAUDE.md` (UUID, exclusão lógica) num único lugar, e datas que não mudam de dia por fuso.

## D009 — Design system v0.2

**Status:** aceita · 2026-09-29 (task 004)

A interface usa fundo tingido de petróleo (`#E6EFEE`), cards brancos sem borda nem sombra, faixa de cabeçalho em petróleo no topo de toda tela e, em listas de prazos, bloco de data preenchido com a cor forte da situação no lugar do chip. Detalhes em `docs/07-design-system.md`.

- *Por quê:* a v0.1 ficou branca demais e repetia a mesma situação em chip, cor e texto. Cor passa a marcar estrutura (petróleo) e situação (vermelho, âmbar, verde), e cada informação aparece uma vez por item.
- *Descartado:* uma cor por módulo (proposta B). Pode voltar depois sem conflito, porque não usa as cores de situação.

## D010 — Navegação com go_router 17

**Status:** aceita · 2026-09-29 (task 003)

Rotas com `go_router` fixado em `^17.5.0` (`lib/app/router.dart`). Um `StatefulShellRoute.indexedStack` com três ramos (Painel `/painel`, Empresas `/empresas`, Ajustes `/ajustes`) monta a barra inferior (`AppShell`) e guarda a pilha de cada ramo. Telas internas (`/empresas/nova`, `/empresas/:id`, `/empresas/:id/editar`) usam o navigator raiz (`parentNavigatorKey`) e cobrem a barra, que dá lugar à barra de ações. O `GoRouter` vem do `routerProvider` (Riverpod), sobrescrito nos testes com `createAppRouter(initialLocation: ...)`.

- *Por quê:* navegação declarativa por URL, pilha por aba sem código próprio, e rotas testáveis.
- *Descartado:* `go_router` 18.x, que migrou para os pacotes `material_ui`/`cupertino_ui`, separados do `package:flutter/material.dart` que o app usa (o `Theme` passaria a ser outra classe). Reavaliar quando o app migrar para `material_ui`. Também descartado `go_router_builder` (codegen) enquanto há poucas rotas.
