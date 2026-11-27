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
| C3 | Os 150 dias de antecedência valem para todas as licenças? E para laudos e manutenções, qual antecedência? | 🟡 Fase 1 | 2026-09-30 (usuário, task 006): licença 150 dias, laudo e manutenção 30 dias, com lembretes extras de 30, 10 e 3 dias e no dia, editáveis por prazo. Falta confirmar com a cliente. |
| C4 | Depois que o alerta começa, com que frequência ele deve repetir (diário, semanal) até a renovação? | 🟡 Fase 1 | 2026-11-26 (usuário, task 010): só nos dias de lembrete do prazo; depois de vencido, uma vez por semana até renovar, concluir ou cancelar. Uma notificação por prazo, às 8h (fixo). Falta confirmar com a cliente. |
| C5 | Que dados da empresa cadastrar (CNPJ, endereço, responsável técnico, números das licenças)? | 🟡 Fase 1 | 2026-09-24: dados cadastrais, responsável legal e registros em órgãos (RF-EMP-04/05); só a razão social é obrigatória. Responsável **técnico** e anexos seguem em aberto (C13). |
| C6 | Ruídos: sempre 4 pontos ou varia por empresa? Unidade (dB)? Existem limites para destacar valores fora do permitido? | 🟡 Fase 2 | 2026-11-26 (usuário, task 013): quantos pontos a empresa quiser (o app sugere 4 na primeira vez), unidade dB(A), limite máximo opcional por ponto; valor acima aparece com ícone e "Acima do limite". Falta confirmar com a cliente. |
| C7 | Resíduos: quais classes usar? Unidade (kg, t, m³)? Período semanal ou mensal — fixo por empresa? | 🟡 Fase 2 | 2026-11-27 (cliente, WhatsApp): identificar o **tipo** dentro de cada classe (I, II-A, II-B); unidade **kg**; resíduos sólidos lançados **geralmente uma vez por semana**; "resíduos perigosos" **são a Classe I**, com o tipo identificado. Antes (2026-11-26, usuário): perigosos com quantidade gerada e armazenada, mensal. 2026-11-27 (usuário): a quantidade **armazenada** vale para todas as classes, não só a Classe I; todo tipo tem gerada e armazenada. Frequência por tipo de resíduo, padrão semanal (configurável; não precisa perguntar à cliente). |
| C8 | ETE/ETA: quais parâmetros são medidos além de pH e insumo? Com que frequência? | 🟡 Fase 2 | 2026-11-27 (cliente, WhatsApp): **ETE** mede pH, vazão e tipo e quantidade de cada produto químico usado; frequência "por tratamento", **mensal, quinzenal ou semanal**; pH entre **6 e 8**. **ETA** mede pH, cloro, turbidez e produto usado, **diariamente**; faixa de pH possível, mas pouco relevante. **Pode haver mais de uma** ETE ou ETA (ex.: sistema de abastecimento municipal, como o SAAE de Jucás). Suposição (task 013): quinzena = dias 1 a 15 e 16 ao fim do mês. |
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
| C19 | No cadastro de empresa, a UF deve vir pré-selecionada (ex.: CE, onde estão as empresas de hoje)? | ⚪ Fase 1 | Suposição (task 003): sem valor padrão; o usuário escolhe. |
| C20 | Confirmar as suposições dos prazos (task 006): qualquer categoria (licença, laudo, manutenção) em qualquer módulo; a nova data de uma renovação é sempre posterior à anterior; excluir o ciclo atual desfaz a renovação e reabre o anterior; prazos de módulo desabilitado somem do painel. | ⚪ Fase 1 | |
| C21 | Um ciclo de prazo tem data de início ou de emissão própria (ex.: data de emissão da licença)? Hoje o início é o vencimento do ciclo anterior, e o primeiro ciclo não tem início. | ⚪ Fase 1 | 2026-11-16 (task 008): suposição — mantém assim; o histórico mostra "início → vencimento" nos ciclos com anterior e só "Vencimento em …" no mais antigo. |
| C22 | Confirmar as suposições do detalhe do prazo (task 008): a data sugerida ao renovar repete o intervalo do ciclo anterior em meses (sem anterior, um ano); prazos renovados aparecem só no histórico do ciclo atual, não em "Encerrados"; a data de conclusão não pode ser futura; só laudo e manutenção se concluem (licença só se renova ou se cancela). | ⚪ Fase 1 | Suposição adotada (2026-11-16). |
| C23 | Confirmar as suposições do Painel (task 009): a lista traz todos os prazos em aberto, sem limite e sem "Ver todos"; tiles Vencidos · A vencer · Vigentes filtram a lista (tocar de novo limpa); cada item mostra o nome da empresa, sem categoria nem órgão; voltar do detalhe leva ao Painel. | ⚪ Fase 1 | Suposição adotada (2026-11-16): lista e tiles definidos pelo usuário; contexto do card e navegação por conta do agente. |
| C24 | O alerta de vencimento precisa chegar por **e-mail**, como a cliente pediu no vídeo 1, ou a notificação no celular basta até existir a API? | 🟡 Fase 1 | 2026-11-26: suposição — notificação local no MVP (RF-PRZ-03); e-mail na Fase 5, pois exige backend. Alinhar com a cliente. |
| C25 | Backup (RNF-04): formato, salvaguarda ao restaurar, validação e aviso. | 🟡 Fase 1 | 2026-11-26 (usuário, task 012): cópia do banco SQLite (`.ntbackup`) enviada pela folha de compartilhamento; restaurar pede confirmação com resumo e guarda antes uma cópia dos dados atuais ("Desfazer"); aceita backup de versão igual ou mais antiga e recusa mais nova; aviso "Nenhum backup feito ainda" e data do último backup, sem lembrete periódico. Suposições: compartilhamento sem retorno do aparelho não conta como backup; só a cópia de segurança mais recente fica guardada. Falta confirmar com a cliente. |
| C26 | Lançamentos periódicos (Fase 2): o que é "pendente", o que se pode editar e o que fazer quando não houve medição? | 🟡 Fase 2 | 2026-11-26 (usuário, task 013): o período corrente aparece como "A lançar" e cada período anterior sem valor como "Atrasado", a partir do período de início do parâmetro; período com só parte dos pontos continua pendente. Pode salvar parcial; o período atual e os passados podem ser lançados, editados ou apagados; período futuro não aceita lançamento. Semana ISO, de segunda a domingo. Um período pode ser marcado "sem medição" com justificativa, e sai das pendências. Falta confirmar com a cliente. |
| C27 | Confirmar as suposições da tela de ruídos (task 014): o ponto cobra lançamento a partir da semana em que foi cadastrado; valor com uma casa decimal ("61,8"); depois de salvar, a tela fica na mesma semana; um ponto desativado some do lançamento, mas aparece nas semanas em que já tem medição. | ⚪ Fase 2 | Suposição adotada (2026-11-27). Escolhas do usuário na mesma task: Ruídos como seção no módulo (sem abas), "sem medição" por ponto e para a semana, cadastro de pontos um por um, sem "Rascunho". |

## Perguntas para levar à cliente (Fase 2)

Versão simples de C7 e C8, enviada por WhatsApp em 2026-11-26 e respondida pela cliente em 2026-11-27 (respostas na tabela acima).

**Resíduos sólidos (C7).** As classes vêm da norma ABNT NBR 10004: **Classe I** são os perigosos (óleo usado, solvente, borra de tinta, estopa suja de óleo); **Classe II-A** são os não perigosos que se decompõem ou se dissolvem (restos de comida, papel, papelão, madeira, lodo comum); **Classe II-B** são os não perigosos que não mudam com o tempo (entulho, vidro, metal, alguns plásticos).

1. Para os resíduos sólidos, basta lançar o total de cada classe (I, II-A e II-B) ou você precisa separar por tipo dentro da classe (ex.: papelão e madeira dentro da II-A)?
2. Você anota o peso em quilos (kg)? Ou às vezes em toneladas ou em metros cúbicos?
3. Você lança uma vez por mês ou toda semana? É igual para todas as empresas?
4. A "Classe I" dos resíduos sólidos é a mesma coisa que os "resíduos perigosos" que você lança separado, ou são lançamentos diferentes?

**ETE e ETA (C8).** ETE é a estação que limpa a água suja que sai da fábrica antes de ir para a rede ou o rio; ETA é a estação que trata a água que entra (de poço ou rio) para a fábrica usar. O "controle" são as medições que você anota de cada uma.

5. Na ETE, o que você mede além do pH? (ex.: vazão, temperatura, quantidade de cada produto químico usado). E na ETA? (ex.: pH, cloro, turbidez, produto usado)
6. Cada medição é feita todo dia, toda semana ou todo mês?
7. Existe uma faixa permitida que o app deveria avisar quando sair dela? (ex.: pH entre 6 e 9)
8. Alguma empresa tem mais de uma ETE ou mais de uma ETA?

## Pendências de material

- [x] Transcrição dos dois vídeos (17:46 e 17:48) — 2026-11-26, em [briefing-videos.md](briefing-videos.md)
- [ ] Modelos de relatório usados hoje
- [ ] Exemplo real (anonimizado) de uma licença e de um relatório já enviado
