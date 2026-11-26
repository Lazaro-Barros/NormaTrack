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
| T6 | Quem mais vai desenvolver? (define o nível de convenção e documentação) | ⚪ | 2026-11-26: um único desenvolvedor. Commits direto na `main`, sem PR ([D012](decisoes.md#d012--commits-direto-na-main-sem-pr)). |

## Para a cliente (negócio)

| # | Pergunta | Bloqueia | Resposta |
|---|---|---|---|
| C1 | Quem usa o app: só ela, gerenciando várias empresas, ou cada empresa terá o próprio acesso? | 🟡 Fase 1 | |
| C2 | Precisa de senha/PIN para abrir o app, mesmo offline? | 🟡 Fase 1 | |
| C3 | Os 150 dias de antecedência valem para todas as licenças? E para laudos e manutenções, qual antecedência? | 🟡 Fase 1 | 2026-09-30 (usuária, task 006): licença 150 dias, laudo e manutenção 30 dias, com lembretes extras de 30, 10 e 3 dias e no dia, editáveis por prazo. Falta confirmar com a cliente. |
| C4 | Depois que o alerta começa, com que frequência ele deve repetir (diário, semanal) até a renovação? | 🟡 Fase 1 | 2026-11-26 (usuário, task 010): só nos dias de lembrete do prazo; depois de vencido, uma vez por semana até renovar, concluir ou cancelar. Uma notificação por prazo, às 8h (fixo). Falta confirmar com a cliente. |
| C5 | Que dados da empresa cadastrar (CNPJ, endereço, responsável técnico, números das licenças)? | 🟡 Fase 1 | 2026-09-24: dados cadastrais, responsável legal e registros em órgãos (RF-EMP-04/05); só a razão social é obrigatória. Responsável **técnico** e anexos seguem em aberto (C13). |
| C6 | Ruídos: sempre 4 pontos ou varia por empresa? Unidade (dB)? Existem limites para destacar valores fora do permitido? | 🟡 Fase 2 | |
| C7 | Resíduos: quais classes usar? Unidade (kg, t, m³)? Período semanal ou mensal — fixo por empresa? | 🟡 Fase 2 | |
| C8 | ETE/ETA: quais parâmetros são medidos além de pH e insumo? Com que frequência? | 🟡 Fase 2 | |
| C9 | Existem **modelos oficiais** de relatório por órgão? Se sim, enviar os arquivos (Word/planilha). | 🔴 Fase 3 | |
| C10 | Produtos controlados: o estoque final é informado ou deve ser calculado a partir do estoque anterior + entradas − uso? | 🟡 Fase 3 | 2026-11-26 (vídeo 1, [briefing](briefing-videos.md)): indício de que é **informado** ("a quantidade que ficou em estoque naquele mês"). Confirmar. |
| C11 | Controle de qualidade: a compra de matéria-prima se vincula a um produto específico ou é da empresa como um todo? | 🟡 Fase 4 | 2026-11-26 (vídeo 2, [briefing](briefing-videos.md)): indício de vínculo com o **produto**; no desenho e na fala a compra fica dentro do "Produto A". Confirmar. |
| C12 | Laudos de análise: quais parâmetros por tipo de produto? Existem limites de referência? | ⚪ Fase 4 | |
| C13 | Precisa anexar arquivos (PDF de licenças, laudos, notas fiscais, fotos)? | 🟡 Fase 1 | 2026-11-16 (task 008): suposição — sem anexos e sem "Nº do documento" no prazo por enquanto. Levar à cliente. |
| C14 | O que é "Controle de Processos"? Entra no escopo inicial? | ⚪ | 2026-11-26: o vídeo 1 só cita "controle de processos" como exemplo de aba possível, sem detalhe. Segue em aberto. |
| C15 | Quais órgãos se ligam a quais módulos (ex.: SEMACE/IBAMA/Sec. Meio Ambiente → Ambiental; ANVISA/MAPA → Qualidade)? Um registro deve habilitar ou sugerir o módulo? | 🟡 Fase 1 | |
| C16 | A validade do registro no órgão deve gerar um prazo com alerta, como as licenças? | 🟡 Fase 1 | |
| C17 | Conselho de Classe e Secretaria de Meio Ambiente precisam de detalhe (qual conselho; municipal ou estadual)? Pode haver mais de um registro no mesmo órgão? | 🟡 Fase 1 | Suposição: um registro por órgão, com observação livre. |
| C18 | Confirmar as suposições do cadastro de empresa (task 002): um telefone e um e-mail por empresa, com 10 ou 11 dígitos; nenhum módulo habilitado por padrão; o registro no órgão vale até o dia da validade, inclusive. | ⚪ Fase 1 | |
| C19 | No cadastro de empresa, a UF deve vir pré-selecionada (ex.: CE, onde estão as empresas de hoje)? | ⚪ Fase 1 | Suposição (task 003): sem valor padrão; a usuária escolhe. |
| C20 | Confirmar as suposições dos prazos (task 006): qualquer categoria (licença, laudo, manutenção) em qualquer módulo; a nova data de uma renovação é sempre posterior à anterior; excluir o ciclo atual desfaz a renovação e reabre o anterior; prazos de módulo desabilitado somem do painel. | ⚪ Fase 1 | |
| C21 | Um ciclo de prazo tem data de início ou de emissão própria (ex.: data de emissão da licença)? Hoje o início é o vencimento do ciclo anterior, e o primeiro ciclo não tem início. | ⚪ Fase 1 | 2026-11-16 (task 008): suposição — mantém assim; o histórico mostra "início → vencimento" nos ciclos com anterior e só "Vencimento em …" no mais antigo. |
| C22 | Confirmar as suposições do detalhe do prazo (task 008): a data sugerida ao renovar repete o intervalo do ciclo anterior em meses (sem anterior, um ano); prazos renovados aparecem só no histórico do ciclo atual, não em "Encerrados"; a data de conclusão não pode ser futura; só laudo e manutenção se concluem (licença só se renova ou se cancela). | ⚪ Fase 1 | Suposição adotada (2026-11-16). |
| C23 | Confirmar as suposições do Painel (task 009): a lista traz todos os prazos em aberto, sem limite e sem "Ver todos"; tiles Vencidos · A vencer · Vigentes filtram a lista (tocar de novo limpa); cada item mostra o nome da empresa, sem categoria nem órgão; voltar do detalhe leva ao Painel. | ⚪ Fase 1 | Suposição adotada (2026-11-16): lista e tiles definidos pela usuária; contexto do card e navegação por conta do agente. |
| C24 | O alerta de vencimento precisa chegar por **e-mail**, como a cliente pediu no vídeo 1, ou a notificação no celular basta até existir a API? | 🟡 Fase 1 | 2026-11-26: suposição — notificação local no MVP (RF-PRZ-03); e-mail na Fase 5, pois exige backend. Alinhar com a cliente. |

## Pendências de material

- [x] Transcrição dos dois vídeos (17:46 e 17:48) — 2026-11-26, em [briefing-videos.md](briefing-videos.md)
- [ ] Modelos de relatório usados hoje
- [ ] Exemplo real (anonimizado) de uma licença e de um relatório já enviado
