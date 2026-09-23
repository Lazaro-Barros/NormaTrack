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
