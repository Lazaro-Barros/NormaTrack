# 07 — Design system e telas

Identidade visual mínima e inventário das telas principais. **Os valores deste documento prevalecem** sobre os wireframes se os dois divergirem.

| Onde | O quê |
|---|---|
| Este documento | Fonte da verdade: princípios, tokens, componentes, telas |
| [`lib/app/theme/`](../lib/app/theme/) | Implementação dos tokens em Flutter (`AppTheme.light`) |
| [`lib/app/widgets/`](../lib/app/widgets/) | Componentes compartilhados (ex.: `StatusChip`) |
| [`docs/design/wireframes/`](design/wireframes/) | Fonte dos wireframes, uma tela por arquivo `.dc.html` (HTML com estilos inline, legível como referência de layout e textos) |
| [Canvas no Claude](https://claude.ai/artifact/LGB1NY3JgjKgPWPLf7Sw7z) | Os mesmos wireframes renderizados e navegáveis (privado; compartilhar pelo menu Share) |

## Princípios

1. **Situação primeiro.** O usuário abre o app para saber o que vence. A situação e o prazo aparecem antes de qualquer outro dado.
2. **Um padrão, vários módulos.** Prazo, lançamento e relatório têm a mesma aparência em Ambiental, Produtos Controlados e Qualidade.
3. **Nunca só a cor.** Toda situação tem ícone e texto, para funcionar sob sol forte, para daltônicos e na impressão.

## Tokens

Os nomes abaixo são os mesmos usados no código (`lib/app/theme/`). As telas não usam cor, tamanho nem raio soltos.

### Cores

| Token | Hex | Papel no Material 3 |
|---|---|---|
| `primary` | `#0E5A63` | `colorScheme.primary` |
| `primaryStrong` | `#0A434A` | estado pressionado |
| `primarySoft` | `#DCEBEA` | `primaryContainer` |
| `onPrimary` | `#FFFFFF` | `onPrimary` |
| `ground` | `#F5F4EF` | `surface` (fundo das telas) |
| `surface` | `#FFFFFF` | `surfaceContainerLowest` (cards) |
| `surface2` | `#EEEDE7` | `surfaceContainerHigh` |
| `border` | `#DCDAD2` | `outlineVariant` |
| `borderStrong` | `#8E8B82` | `outline` (borda de campos) |
| `ink` | `#1A1D1F` | `onSurface` |
| `ink2` | `#4A5055` | `onSurfaceVariant` |
| `ink3` | `#636A70` | legendas e texto auxiliar |

### Situação do prazo

A situação é derivada de `dueDate` e `alertDaysBefore` (ver [domínio](03-dominio.md#regras-de-negócio-já-identificadas)). Cada uma tem um ícone fixo. Todos os pares texto/fundo têm contraste de pelo menos 4,5:1.

| Situação | Token | Texto | Fundo | Ícone |
|---|---|---|---|---|
| Vencido | `statusOverdue` | `#A8261B` | `#FBE3E0` | x em círculo |
| A vencer | `statusDueSoon` | `#8A4B00` | `#FCEBD2` | relógio |
| Vigente | `statusOk` | `#1D6B45` | `#E2F1E8` | check em círculo |
| Renovado | `statusClosed` | `#4A5055` | `#ECEBE6` | setas de renovação |

Implementado como `ThemeExtension` em `StatusColors` (`StatusColors.of(context).resolve(StatusTone.overdue)`).

### Tipografia

Títulos e números grandes em **Manrope** e o restante em **IBM Plex Sans**, embarcadas como asset (o app é offline). **Pendente:** os arquivos das fontes ainda não estão em `assets/fonts/`; até lá o Flutter usa a fonte padrão do sistema.

| Estilo (`TextTheme`) | Fonte | Peso | Tamanho/altura |
|---|---|---|---|
| `headlineMedium` | Manrope | 800 | 26/32 |
| `titleLarge` | Manrope | 700 | 18/24 |
| `titleMedium` | Manrope | 700 | 15/20 |
| `bodyLarge` | IBM Plex Sans | 400 | 15/22 |
| `bodyMedium` | IBM Plex Sans | 400 | 13/18 |
| `labelLarge` | IBM Plex Sans | 600 | 15/20 |
| `labelMedium` (rótulo de campo) | IBM Plex Sans | 600 | 13/18 |
| `labelSmall` (chips, navegação) | IBM Plex Sans | 600 | 12/16 |
| `bodySmall` (ajuda, legenda) | IBM Plex Sans | 400 | 12/16 |
| `AppTypography.overline` (sobretítulo) | IBM Plex Sans | 600 | 12/16, caixa alta, espaçamento 0,06em |
| `AppTypography.number` (destaque) | Manrope | 800 | 30/36, tabular |

Datas, quantidades e CNPJ usam algarismos tabulares (`FontFeature.tabularFigures()`). Datas sempre em `dd/MM/yyyy`.

### Espaço, raios e elevação

- **Espaçamento** (grade de 4): `xs 4`, `sm 8`, `md 12`, `lg 16`, `xl 24`, `2xl 32`, `3xl 48`. A margem lateral das telas é 16, entre cards 8–12 e entre seções 16.
- **Raios:** `sm 8` (bloco de data, ícones), `md 12` (botões, campos, cards de lista), `lg 16` (cards de seção, FAB), `pill` (chips, navegação).
- **Elevação:** cards sem sombra, com borda de 1 px `border`. A única sombra do app é a do FAB.
- **Toque:** área mínima de 48 × 48.

### Ícones

Traço de 1,8 px com cantos arredondados, no tamanho 20 (16 em chips, 24 em destaque). Usar `Icons.*_outlined` ou `lucide_icons`. Cada módulo tem um ícone fixo: folha (Ambiental), escudo (Produtos Controlados) e frasco (Controle de Qualidade).

## Componentes

Cada componente vira um widget em `lib/app/widgets/` e é a única forma de desenhar aquele elemento.

Botões, campos, chips, segmentado, interruptores, navegação inferior, snackbar e diálogos já saem estilizados pelo `AppTheme`: use os widgets Material padrão (`FilledButton`, `OutlinedButton`, `TextField`, `NavigationBar`…) sem sobrescrever estilo.

| Widget | Uso |
|---|---|
| `StatusChip` ✅ | Situação do prazo. Tem sempre ícone e texto, e há uma variante compacta |
| `DeadlineCard` | Bloco de data + título + "empresa · módulo" + situação + tempo relativo ("em 12 dias") |
| `StatTile` | Contagem por situação no Painel. Um toque filtra a lista |
| `ModuleCard` | Módulo habilitado na tela da empresa, com resumo de pendências |
| `NavRow` / `SwitchRow` | Linhas de lista. A navegável tem chevron. O interruptor aplica na hora |
| `AppTextField` | Rótulo sempre acima do campo (nunca só placeholder). O erro tem ícone e texto |
| `StatusBanner` | Faixa de aviso no topo (prazo vencido, sem backup) |
| `EmptyState` | Explica o próximo passo e oferece a ação |
| Botões | Um primário por tela, no rodapé. O destrutivo tem só contorno e pede confirmação |

## Telas

A navegação inferior tem 3 destinos: **Painel**, **Empresas** e **Ajustes**. Nas telas internas ela dá lugar a uma barra de ações no rodapé.

| Tela | Requisitos | Conteúdo |
|---|---|---|
| Painel | RF-PRZ-05 | Contagem por situação, próximos vencimentos de todas as empresas, lançamentos pendentes |
| Empresas | RF-EMP-01 | Busca, filtro ativas/arquivadas, módulos habilitados e pior situação de cada empresa |
| Empresa | RF-EMP-03 | Aviso de situação e cards só dos módulos habilitados |
| Nova/editar empresa | RF-EMP-01/02 | Dados básicos e interruptores de módulos |
| Módulo (ex.: Ambiental) | RF-AMB-01/05/06 | Abas Prazos · Lançamentos · Relatórios, com prazos agrupados (Licenciamento, ETE, ETA) |
| Detalhe do prazo | RF-PRZ-01/04 | Situação em destaque, dados, histórico de ciclos, renovação |
| Novo prazo | RF-PRZ-01/02 | Categoria, título, órgão, vencimento, antecedência com data calculada do primeiro alerta |
| Lançamento periódico (ex.: Ruídos) | RF-AMB-02 | Navegação por período, um campo por ponto/parâmetro, valor anterior como referência |
| Gerar relatório | RF-REL-01/02/03 | Período, conteúdo, formato `.xlsx`/`.docx`, compartilhar |
| Ajustes | RF-PRZ-03, RNF-04 | Notificações, antecedência padrão, backup e restauração |

Ainda não desenhadas: lançamento mensal de produtos controlados (Fase 3) e lotes/estoque do Controle de Qualidade (Fase 4). Elas devem reutilizar o padrão de lançamento periódico.

## Suposições a validar

- Unidade dos ruídos em dB(A) — pergunta C6.
- ~~CNPJ opcional no cadastro de empresa — pergunta C5.~~ Confirmado em 2026-09-24: só a razão social é obrigatória (RF-EMP-04). O formulário ganha seções de endereço, contato, responsável legal e órgãos (task 003).
- Campo "Nº do documento" no prazo, que não está no modelo — incluir em `Deadline` se a cliente confirmar (C5/C13).
