# 07 — Design system e telas

**Versão 0.2** (2026-09-29, [task 004](../tasks/004-refinamento-visual/)): fundo tingido, cards sem borda, faixa de cabeçalho em petróleo, situação na cor forte do bloco de data e menos informação repetida. A v0.1 está no histórico do git.

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
2. **Uma informação, um lugar.** Cada dado aparece uma vez por item: nada de chip, cor e texto repetindo a mesma situação. Metadados secundários (CNPJ, módulo) ficam no detalhe, não nas listas.
3. **Cor com propósito.** Petróleo marca estrutura (faixa de cabeçalho, ações). Vermelho, âmbar e verde são só para situação.
4. **Nunca só a cor.** Toda situação tem texto ou ícone junto, para funcionar sob sol forte, para daltônicos e na impressão.
5. **Um padrão, vários módulos.** Prazo, lançamento e relatório têm a mesma aparência em Ambiental, Produtos Controlados e Qualidade.

## Tokens

Os nomes abaixo são os mesmos usados no código (`lib/app/theme/`). As telas não usam cor, tamanho nem raio soltos.

### Cores

| Token | Hex | Papel no Material 3 |
|---|---|---|
| `primary` | `#0E5A63` | `colorScheme.primary` |
| `primaryStrong` | `#0A434A` | estado pressionado |
| `primarySoft` | `#DCEBEA` | `primaryContainer` |
| `onPrimary` | `#FFFFFF` | `onPrimary` |
| `onBandMuted` | `#CFE5E3` | texto secundário na faixa de cabeçalho |
| `ground` | `#E6EFEE` | `surface` (fundo das telas, petróleo bem claro) |
| `surface` | `#FFFFFF` | `surfaceContainerLowest` (cards, barras, sheets) |
| `surface2` | `#EDF2F1` | `surfaceContainerHigh` (trilho do segmentado) |
| `divider` | `#E1E8E7` | `outlineVariant` (divisórias dentro de cards) |
| `borderStrong` | `#7F8B8A` | `outline` (borda de campos) |
| `ink` | `#1A1D1F` | `onSurface` |
| `ink2` | `#4A5055` | `onSurfaceVariant` |
| `ink3` | `#5E666B` | legendas e texto auxiliar |
| `placeholder` | `#6B7176` | placeholder de campos |

### Situação do prazo

A situação é derivada de `dueDate` e `alertDaysBefore` (ver [domínio](03-dominio.md#regras-de-negócio-já-identificadas)). Cada uma tem um ícone fixo. A cor **forte** vai no bloco de data (com texto branco), no texto de situação e no ícone; a **suave** vai no fundo dos números do Painel, dos avisos e dos chips. Todos os pares têm contraste de pelo menos 4,5:1 (coberto por teste).

| Situação | Token | Forte | Suave | Ícone |
|---|---|---|---|---|
| Vencido | `statusOverdue` | `#A8261B` | `#FBE3E0` | x em círculo |
| A vencer | `statusDueSoon` | `#8A4B00` | `#FCEBD2` | relógio |
| Vigente | `statusOk` | `#1D6B45` | `#E2F1E8` | check em círculo |
| Renovado | `statusClosed` | `#4A5055` | `#E9ECEB` | setas de renovação |

Implementado como `ThemeExtension` em `StatusColors` (`StatusColors.of(context).resolve(StatusTone.overdue)`).

### Tipografia

Títulos e números grandes em **Manrope** e o restante em **IBM Plex Sans**, embarcadas como asset (o app é offline). **Pendente:** os arquivos das fontes ainda não estão em `assets/fonts/`; até lá o Flutter usa a fonte padrão do sistema.

| Estilo (`TextTheme`) | Fonte | Peso | Tamanho/altura |
|---|---|---|---|
| `headlineMedium` | Manrope | 800 | 26/32 |
| `titleLarge` (título da faixa) | Manrope | 800 | 22/28 |
| `titleMedium` (título de seção) | Manrope | 700 | 16/22 |
| `bodyLarge` | IBM Plex Sans | 400 | 15/22 |
| `bodyMedium` | IBM Plex Sans | 400 | 13/18 |
| `labelLarge` | IBM Plex Sans | 600 | 15/20 |
| `labelMedium` (rótulo de campo) | IBM Plex Sans | 600 | 13/18 |
| `labelSmall` (chips, navegação) | IBM Plex Sans | 600 | 12/16 |
| `bodySmall` (ajuda, legenda) | IBM Plex Sans | 400 | 12/16 |
| `AppTypography.number` (destaque) | Manrope | 800 | 30/36, tabular |

Títulos de seção em frase normal, nunca em caixa alta (o sobretítulo da v0.1 saiu). Datas, quantidades e CNPJ usam algarismos tabulares (`FontFeature.tabularFigures()`). Datas sempre em `dd/MM/yyyy`.

### Espaço, raios e elevação

- **Espaçamento** (grade de 4): `xs 4`, `sm 8`, `md 12`, `lg 16`, `xl 24`, `2xl 32`, `3xl 48`. Margem lateral 16, entre cards 8, entre seções 16–18, dentro de card 16.
- **Raios:** `sm 8` (ícones pequenos), `md 12` (botões, campos, bloco de data), `lg 16` (cards, FAB), `xl 24` (faixa de cabeçalho, bottom sheets), `pill` (chips, segmentado, busca, navegação).
- **Superfícies:** cards brancos **sem borda e sem sombra** sobre o fundo tingido; itens de um mesmo grupo ficam num só card, separados por `divider`. A única sombra do app é a do FAB. Barra de navegação e barra de ações são brancas com cantos superiores arredondados.
- **Toque:** área mínima de 48 × 48.

### Ícones

Traço de 1,8 px com cantos arredondados, no tamanho 20 (16 em chips, 24 em destaque). Usar `Icons.*_outlined` ou `lucide_icons`. Cada módulo tem um ícone fixo: folha (Ambiental), escudo (Produtos Controlados) e frasco (Controle de Qualidade).

## Componentes

Cada componente vira um widget em `lib/app/widgets/` e é a única forma de desenhar aquele elemento.

Botões, campos, chips, segmentado, interruptores, navegação inferior, snackbar e diálogos já saem estilizados pelo `AppTheme`: use os widgets Material padrão (`FilledButton`, `OutlinedButton`, `TextField`, `NavigationBar`…) sem sobrescrever estilo.

| Widget | Uso |
|---|---|
| Faixa de cabeçalho | `AppBar` do tema (petróleo, cantos inferiores 24). Título, subtítulo em `onBandMuted`, ações e no máximo **um** bloco extra abaixo: números, resumo em pílulas, abas (segmentado claro) ou busca. Se o bloco não couber no `AppBar`, criar `AppHeaderBand` em `lib/app/widgets/` |
| `StatusChip` ✅ | Situação com ícone e texto. Só onde não há bloco de data: histórico de ciclos, tabelas |
| `DeadlineCard` | Bloco de data preenchido com a cor forte da situação + título + uma linha de contexto (empresa **ou** categoria) + texto relativo na cor da situação ("Vence / em 12 dias"). Sem chip |
| `StatTile` | Número + rótulo na cor suave da situação, dentro da faixa do Painel. Tocar filtra a lista; o selecionado ganha anel |
| `PendingRow` | Lançamento periódico a fazer, com botão tonal "Lançar" |
| `NavRow` / `SwitchRow` | Linhas dentro de um card, separadas por `divider`. A navegável tem chevron; situação em texto colorido à direita. O interruptor aplica na hora |
| `AppTextField` | Rótulo acima (obrigatório com `*`), nunca só placeholder. Erro com ícone e texto. Formulários longos em seções, cada uma num card |
| `StatusBanner` | Aviso no topo do conteúdo, na cor suave da situação (prazo vencido, sem backup) |
| `EmptyState` | Explica o próximo passo e oferece a ação |
| Botões | `FilledButton` primário: um por tela, no rodapé. `FilledButton.tonal`: ação secundária de destaque. `OutlinedButton`: secundária. Destrutivo: contorno vermelho + confirmação |

## Telas

A navegação inferior tem 3 destinos: **Painel**, **Empresas** e **Ajustes**. Nas telas internas ela dá lugar a uma barra de ações no rodapé.

| Tela | Requisitos | Conteúdo |
|---|---|---|
| Painel | RF-PRZ-05 | Contagem por situação, próximos vencimentos de todas as empresas, lançamentos pendentes |
| Empresas | RF-EMP-01 | Busca na faixa, segmentado ativas/arquivadas; por empresa só nome, cidade/UF e pior situação |
| Empresa | RF-EMP-03/05 | Resumo de situação na faixa; módulos habilitados; órgãos que se aplicam com situação do registro; dados cadastrais; gerar relatório e arquivar |
| Nova/editar empresa | RF-EMP-01/02/04/05 | Tela rolável em seções: Identificação · Endereço · Contato · Responsável legal · Módulos · Órgãos. Só a razão social é obrigatória |
| Registro em órgão | RF-EMP-05 | Bottom sheet aberto a partir de um órgão no formulário: situação (não se aplica / possui / precisa obter), nº, validade e observações |
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
