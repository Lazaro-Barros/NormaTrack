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

**Status:** aceita · 2026-09 (detalhada em D015, task 013)

As entidades centrais serão tipadas. Medições (ruído, ETE/ETA, laudos de análise) usarão a estrutura genérica parâmetro + valor. Reavaliar ao fim da Fase 2.

## D006 — applicationId e distribuição por APK

**Status:** aceita · 2026-09

O `applicationId` é `br.com.normatrack.app`. Por enquanto o app não será publicado na Play Store: será distribuído como APK instalado manualmente.

- *Atenção:* para um APK novo atualizar o já instalado sem perder dados, o `applicationId` e a chave de assinatura precisam ser os mesmos. Antes de distribuir, criar uma keystore de release e guardá-la fora do repositório.

## D007 — Órgãos e módulos como enums de domínio

**Status:** aceita · 2026-09-24 (task 002)

`Authority` (os 9 órgãos) e `ModuleType` são enums fixos no domínio. Cada valor tem um `code` estável em texto (`federal_police`, `controlled_products`…), que é o que vai para o banco e para a futura API, e um rótulo pt-BR. `Deadline.authority` reutiliza o mesmo `Authority`.

- *Por quê:* telas condicionais, relatórios por órgão e regras de módulo precisam de valores conhecidos em tempo de compilação. Guardar `code`, e não `name`/`index`, permite renomear o enum sem migração.
- *Descartado:* tabela de órgãos editável pelo usuário, porque o comportamento passaria a depender de dados. Novo órgão = nova versão do app.

## D008 — Convenções de tabela drift

**Status:** aceita · 2026-09-24 (task 002)

- Toda tabela usa o mixin `EntityColumns` (`lib/core/database/converters.dart`): `id` texto (UUID v7 gerado no app) como chave primária, `createdAt`, `updatedAt` e `deletedAt`.
- A classe de linha gerada leva o sufixo `Row` (`@DataClassName('CompanyRow')`), para não colidir com a entidade do domínio. Linhas não saem de `features/*/data`: o mapper converte para entidade.
- Datas-hora em ISO-8601 UTC (`store_date_time_values_as_text`); datas sem hora como texto `AAAA-MM-DD` (`DateOnlyConverter`). Enums gravados pelo `code` (D007), sem `textEnum`.
- Repositórios que expõem agregados de várias tabelas observam todas elas com uma consulta-gatilho (`customSelect(..., readsFrom: {...}).watch()`) e recarregam o agregado. O SQL da consulta-gatilho é **único por repositório** (`SELECT 1 AS companies_changed`, `SELECT 1 AS deadlines_changed`): o drift reaproveita streams com o mesmo SQL e variáveis sem comparar `readsFrom`, e uma consulta repetida passaria a ouvir só as tabelas da primeira (bug achado na task 007).
- *Por quê:* regras do `CLAUDE.md` (UUID, exclusão lógica) num único lugar, e datas que não mudam de dia por fuso.

## D009 — Design system v0.2

**Status:** aceita · 2026-09-29 (task 004)

A interface usa fundo tingido de petróleo (`#E6EFEE`), cards brancos sem borda nem sombra, faixa de cabeçalho em petróleo no topo de toda tela e, em listas de prazos, bloco de data preenchido com a cor forte da situação no lugar do chip. Detalhes em `docs/07-design-system.md`.

- *Por quê:* a v0.1 ficou branca demais e repetia a mesma situação em chip, cor e texto. Cor passa a marcar estrutura (petróleo) e situação (vermelho, âmbar, verde), e cada informação aparece uma vez por item.
- *Descartado:* uma cor por módulo (proposta B). Pode voltar depois sem conflito, porque não usa as cores de situação.

## D010 — Navegação com go_router 17

**Status:** aceita · 2026-09-29 (task 003)

Rotas com `go_router` fixado em `^17.5.0` (`lib/app/router.dart`). Um `StatefulShellRoute` com três ramos (Painel `/painel`, Empresas `/empresas`, Ajustes `/ajustes`) guarda a pilha de cada ramo. O `AppShell` é o `navigatorContainerBuilder`: `IndexedStack` dos ramos (como o `.indexedStack`, mais `HeroMode` desligado nos ramos fora da tela) e a `NavigationBar` embaixo, **sem `Scaffold` próprio**, para que o `Scaffold` de cada tela seja o raiz e o SnackBar apareça acima do FAB dela. Telas internas (`/empresas/nova`, `/empresas/:id`, `/empresas/:id/editar`) usam o navigator raiz (`parentNavigatorKey`) e cobrem a barra, que dá lugar à barra de ações. O `GoRouter` vem do `routerProvider` (Riverpod), sobrescrito nos testes com `createAppRouter(initialLocation: ...)`.

- *Por quê:* navegação declarativa por URL, pilha por aba sem código próprio, e rotas testáveis.
- *Descartado:* `go_router` 18.x, que migrou para os pacotes `material_ui`/`cupertino_ui`, separados do `package:flutter/material.dart` que o app usa (o `Theme` passaria a ser outra classe). Reavaliar quando o app migrar para `material_ui`. Também descartado `go_router_builder` (codegen) enquanto há poucas rotas.

## D011 — Lembretes de prazo em tabela filha

**Status:** aceita · 2026-09-30 (task 006)

Os lembretes de cada prazo ficam em `deadline_reminders` (uma linha por dia de aviso, `(deadline_id, days_before)` único), e não num campo `alertDaysBefore`. O maior valor abre a janela "a vencer"; os demais alimentam as notificações (RF-PRZ-03). Editar a lista reaproveita a linha do mesmo valor, mesmo excluída, como os registros em órgão.

- *Por quê:* o usuário quer vários avisos personalizáveis por prazo (ex.: 150, 30, 10, 3 dias e no dia), e a tabela segue a convenção de linhas com `id` e exclusão lógica (D008), boa para sincronização.
- *Descartado:* a lista numa coluna de texto (`"150,30,10,3,0"`), que não segue a convenção nem permite consultar por dia; e `alertDaysBefore` separado dos lembretes, que seriam duas fontes para a mesma janela.

## D012 — Commits direto na main, sem PR

**Status:** aceita · 2026-11-26

O app tem um único desenvolvedor. Todo trabalho vai em commits direto na `main` e sobe com `git push origin main`, sem branch de task e sem pull request. Cada passo da task vira um commit com `dart format .`, `flutter analyze` e `flutter test` verdes. O rastro de revisão fica nas mensagens de commit (`[task NNN, RF-…]`) e no journal da task.

- *Por quê:* PR só acrescenta passos quando quem escreve e quem revisa é a mesma pessoa.
- *Descartado:* branch por task com PR (usado até a task 009). Volta a valer se entrar outra pessoa no projeto (T6).

## D013 — Notificações locais: planejador, sincronização e limites do Android

**Status:** aceita · 2026-11-26 (task 010)

As notificações de prazo (RF-PRZ-03) usam `flutter_local_notifications` 23 com agendamento **inexato** (`inexactAllowWhileIdle`), sem permissão de alarme exato. Um planejador em Dart puro gera o plano (8h de cada dia de lembrete futuro e semanal depois do vencimento), e um sincronizador substitui **todos** os pendentes a cada mudança, com ids estáveis (FNV-1a de prazo + data + tipo), teto de 400 agendamentos e uma substituição por vez (só a mais recente). O ajuste ligado/desligado fica em `shared_preferences`, fora do banco.

- *Por quê:* refazer o plano inteiro é simples e sempre correto (renovar, concluir, excluir, arquivar, desligar módulo); o teto respeita o limite de 500 alarmes de alguns aparelhos; o ajuste é preferência do aparelho, não dado do domínio.
- *Limite do plugin:* com `DateTimeComponents.dayOfWeekAndTime`, o Android repete a partir da próxima ocorrência do dia da semana contando de agora, ignorando a data de início. Por isso a semanal só é repetitiva quando a primeira ocorrência está a menos de 7 dias; antes disso são 4 avisos semanais avulsos, trocados pela repetição numa abertura futura do app.
- *Exige:* AGP ≥ 9.1.1, compileSdk 37 e desugaring (`android/`).
- *Descartado:* alarme exato; `WorkManager` com checagem diária; tabela drift para o ajuste.

## D014 — Backup é uma cópia do banco SQLite

**Status:** aceita · 2026-11-26 (task 012)

O backup (RNF-04) é uma cópia do banco feita com `VACUUM INTO` num arquivo `NormaTrack-backup-AAAA-MM-DD-HHMM.ntbackup`, entregue pela folha de compartilhamento (`share_plus`). Restaurar escolhe o arquivo com `file_picker`, valida com `sqlite3` só leitura (`user_version` de 1 até o `schemaVersion` do app, tabelas de cada versão, `quick_check`), guarda uma cópia dos dados atuais (`VACUUM INTO`), fecha o `AppDatabase`, troca o arquivo e reabre o banco por uma "época" no Riverpod (`databaseEpochProvider`). Repositórios, telas e a sincronização das notificações se reconstroem sozinhos; um backup antigo é migrado na abertura, e se a abertura falhar o app volta para a cópia. Preferências do aparelho (`shared_preferences`, D013), incluindo a data do último backup, ficam fora do backup.

- *Por quê:* a cópia do arquivo leva tudo, inclusive tabelas futuras, sem código de exportação por tabela; `VACUUM INTO` é consistente com o banco aberto; reabrir pelo provider evita reiniciar o app.
- *Regra para o futuro:* toda nova versão de schema precisa entrar em `_tablesByVersion` (`lib/features/backup/data/local_backup_service.dart`), e a migração drift é o que torna um backup antigo restaurável.
- *Descartado:* exportação JSON (manutenção por tabela, mais risco na importação); copiar o `.sqlite` direto com o banco aberto; reiniciar o app depois de restaurar; escolher pasta com `FilePicker.saveFile`; filtro de extensão no seletor (o Android não conhece o MIME de `.ntbackup`).

## D015 — Medições genéricas por período

**Status:** aceita · 2026-11-27 (task 013)

Ruídos e controle de ETE/ETA usam duas tabelas genéricas: `measurement_parameters` (o que se mede: empresa, contexto `noise`/`effluent`/`water`, nome, unidade, frequência, posição, data de início, limites opcionais, arquivamento) e `measurements` (valor ou justificativa de um parâmetro num período). O período é guardado só pela data de início (`period_start`, `AAAA-MM-DD`), calculada pelo `MeasurementPeriod` do domínio para as frequências diária, semanal (ISO), quinzenal e mensal; um índice parcial único garante uma medição viva por parâmetro e período. As pendências ("A lançar" / "Atrasado") são calculadas no domínio (`pendingLaunches`), nunca gravadas.

- *Por quê:* uma estrutura serve a todos os automonitoramentos com lista de parâmetros variável (ruídos com quantos pontos a empresa tiver, ETE com pH, vazão e produtos); frequência por parâmetro cobre a ETA diária e a ETE semanal, quinzenal ou mensal (C8) sem migração; uma coluna de data ordena e filtra bem para qualquer frequência.
- *Regras:* frequência nova = código novo no enum (sem migração); mudar a frequência de um parâmetro com medições é recusado; medição apagada e relançada vira linha nova (não há lista editável que justifique reaproveitar a linha, como em D011); `value` é `REAL` e a formatação fica na apresentação.
- *Descartado:* tabela por tipo de medição; período como texto `AAAA-Www`/`AAAA-MM`; gravar a situação "pendente"; tabela de estações já na task 013 (entra na 017, quando houver tela para ela).

