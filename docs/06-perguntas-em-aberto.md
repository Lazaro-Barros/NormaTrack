# 06 — Perguntas em aberto

Quando uma pergunta for respondida, mover a resposta para o documento correspondente e registrar aqui a data e a decisão.

Legenda: 🔴 bloqueia a fase indicada · 🟡 necessária antes da fase · ⚪ pode esperar

## Para o time (decisões técnicas)

| # | Pergunta | Bloqueia | Resposta |
|---|---|---|---|
| T1 | Identificadores no código em inglês (com glossário) ou em português? | 🔴 Fase 0 | |
| T2 | Riverpod para estado/DI está ok, ou há preferência por outra lib (Bloc, Provider)? | 🔴 Fase 0 | |
| T3 | Usar `freezed` + code generation ou manter entidades escritas à mão? | 🟡 Fase 0 | |
| T4 | Versão mínima do Android (minSdk)? | 🟡 Fase 0 | |
| T5 | Nome do pacote / `applicationId` (ex.: `br.com.normatrack.app`)? | 🔴 Fase 0 | 2026-09-23: `br.com.normatrack.app` ([D006](decisoes.md#d006--applicationid-e-distribuição-por-apk)) |
| T6 | Quem mais vai desenvolver? (define o nível de convenção e documentação) | ⚪ | |

## Para a cliente (negócio)

| # | Pergunta | Bloqueia | Resposta |
|---|---|---|---|
| C1 | Quem usa o app: só ela, gerenciando várias empresas, ou cada empresa terá o próprio acesso? | 🟡 Fase 1 | |
| C2 | Precisa de senha/PIN para abrir o app, mesmo offline? | 🟡 Fase 1 | |
| C3 | Os 150 dias de antecedência valem para todas as licenças? E para laudos e manutenções, qual antecedência? | 🟡 Fase 1 | |
| C4 | Depois que o alerta começa, com que frequência ele deve repetir (diário, semanal) até a renovação? | 🟡 Fase 1 | |
| C5 | Que dados da empresa cadastrar (CNPJ, endereço, responsável técnico, números das licenças)? | 🟡 Fase 1 | |
| C6 | Ruídos: sempre 4 pontos ou varia por empresa? Unidade (dB)? Existem limites para destacar valores fora do permitido? | 🟡 Fase 2 | |
| C7 | Resíduos: quais classes usar? Unidade (kg, t, m³)? Período semanal ou mensal — fixo por empresa? | 🟡 Fase 2 | |
| C8 | ETE/ETA: quais parâmetros são medidos além de pH e insumo? Com que frequência? | 🟡 Fase 2 | |
| C9 | Existem **modelos oficiais** de relatório por órgão? Se sim, enviar os arquivos (Word/planilha). | 🔴 Fase 3 | |
| C10 | Produtos controlados: o estoque final é informado ou deve ser calculado a partir do estoque anterior + entradas − uso? | 🟡 Fase 3 | |
| C11 | Controle de qualidade: a compra de matéria-prima se vincula a um produto específico ou é da empresa como um todo? | 🟡 Fase 4 | |
| C12 | Laudos de análise: quais parâmetros por tipo de produto? Existem limites de referência? | ⚪ Fase 4 | |
| C13 | Precisa anexar arquivos (PDF de licenças, laudos, notas fiscais, fotos)? | 🟡 Fase 1 | |
| C14 | O que é "Controle de Processos"? Entra no escopo inicial? | ⚪ | |

## Pendências de material

- [ ] Transcrição do segundo vídeo (17:48, cerca de 2 minutos)
- [ ] Modelos de relatório usados hoje
- [ ] Exemplo real (anonimizado) de uma licença e de um relatório já enviado
