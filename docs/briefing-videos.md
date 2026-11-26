# Briefing em vídeo da cliente

Dois vídeos enviados pela cliente por WhatsApp em 2026-09-16, explicando o app com um mapa desenhado à mão. Os requisitos derivados estão em [02-requisitos.md](02-requisitos.md); dúvidas que sobraram, em [06-perguntas-em-aberto.md](06-perguntas-em-aberto.md).

Transcrição automática (reconhecimento de fala local do macOS, 2026-11-26), com revisão leve: pontuação, termos técnicos óbvios ("efluentes", "Classe II-A") e muletas repetidas. Trechos incertos marcados com `[?]`. Os tempos indicam o início de cada trecho.

## O desenho

Mapa em folha A4, lido da esquerda para a direita:

```text
APP
└── Empresa A   (B, C… "o tanto que tiver")
    ├── Ambiental
    │   ├── Licenciamento
    │   │   ├── ① Data de vencimento
    │   │   ├── ② Alerta da data de renovação (150 dias antes)
    │   │   └── ③ Automonitoramento
    │   │       ├── 3.1 Ruídos        → preencher dados → baixar um relatório em Word
    │   │       ├── 3.2 R.S.          → ″   (resíduos sólidos)
    │   │       └── 3.3 R.P.          → ″   (resíduos perigosos)
    │   ├── ETE → Laudo · Manutenção · Controle
    │   └── ETA → Laudo · Manutenção · Controle
    ├── Produtos Controlados
    │   ├── Polícia Federal → Lembrete de renovação · Preencher dados e lançar relatório
    │   └── Exército        → Lembrete de renovação · Preencher dados e lançar relatório
    └── Controle de Qualidade
        └── Tipos → Produto A (outros riscados)
            ├── Quantidade de matéria-prima comprada no mês (janeiro)
            ├── Quantidade fabricada no mês (janeiro) — por lote
            ├── Quantidade vendida no mês (janeiro) — por lote
            ├── Estoque por lote
            └── * Final do ano: contabilizar [riscado] o estoque
```

No papel, o Automonitoramento aparece como item 3 dentro de Licenciamento; nos requisitos ele é uma seção própria do módulo Ambiental.

## Vídeo 1 — visão geral, Ambiental e Produtos Controlados (17:46, 3 min 53 s)

**[0:00]** Eu fiz mais ou menos aqui, vê se dá pra tu entender. Nesse caso já tem um aplicativo, né? Você abre o aplicativo, aí você vai ter empresa A, B, C, D, o tanto que tiver. Você vai cadastrar a empresa.

**[0:15]** No aplicativo, cada empresa vai ter os itens. Por exemplo, o que eu coloquei: ambiental, controle de qualidade; aí pode ter processos, controle de processos.

**[0:28]** Então, assim, a gente pode colocar várias abas, mas nem todas as empresas precisam de tudo. Por exemplo, eu coloquei uma aqui, a empresa A.

**[0:40]** Ela vai ter ambiental, produtos controlados e controle de qualidade, um exemplo. As outras abas, se tiver, deixe em branco; pra essa empresa eu só vou precisar desses três. Então, na área ambiental, eu vou ter o licenciamento.

**[0:57]** Em relação ao licenciamento, eu quero que conste lá a data de vencimento da licença, e queria que o aplicativo desse um alerta de renovação, por exemplo, 150 dias antes da licença ele começar a alertar, por e-mail ou com algum outro tipo de alerta.

**[1:15]** Do automonitoramento, eu tenho ruídos, resíduos sólidos e resíduos perigosos. Dos ruídos, eu gostaria que tivesse uma aba semanalmente,

**[1:30]** com, por exemplo, quatro pontos, pra eu colocar o valor que deu na medição do ruído. Certo? De resíduos sólidos, então vai ter um resíduo, por exemplo,

**[1:43]** Classe I, Classe II-A, entendeu, Classe II-B, e aí vai preencher a quantidade de resíduo que foi gerado de resíduos sólidos por semana ou por mês, entendeu?

**[1:58]** Pode ser até por mês. E eu quero que, preenchendo esses dados da quantidade, tenha como baixar um relatório, tipo uma planilha, alguma coisa do tipo, um documento em Word, pra que eu possa editar e assinar esse relatório

**[2:14]** e mandar pros órgãos fiscalizadores. Assim com resíduo perigoso também: eu coloco lá o tipo de resíduo e a quantidade que foi gerada e armazenada naquele período, entendeu? É, ainda da parte ambiental, né: estação de tratamento de efluentes.

**[2:32]** Laudo: esse laudo é só a data que tem que fazer o laudo, entendeu? Vai ter as datas e o alerta. Manutenção: essa manutenção é algum equipamento que vem a ter que comprar, entendeu? É só questão de alerta e controle.

**[2:50]** E nesse caso o controle são as medições, né? Eu vou medir pH, vou medir o quanto de substância que foi utilizada no tratamento, e aí também, no final, ter um relatório, uma planilha que possa gerar, entendeu, com esses dados que a gente alimenta.

**[3:08]** Estação de tratamento de água, a mesma coisa. Isso da parte ambiental, né? Se houver mais alguma coisa, é incluir aqui nesses itens, mas normalmente é isso. Aí produtos controlados: aí tem pela Polícia Federal e pelo Exército. Aí é só o lembrete da renovação da licença

**[3:26]** e preencher os dados e lançar relatório, que no caso é com a quantidade de produto que foi utilizado naquele mês, o nome do produto, o número da nota fiscal e a quantidade que ficou em estoque naquele mês.

**[3:40]** Da mesma forma no Exército, né. Aí vem controle de qualidade. Nem toda empresa tem o controle de qualidade, né; nesse caso eu coloquei, incluí aqui, mas… *(o vídeo termina)*

## Vídeo 2 — Controle de Qualidade (17:48, 1 min 53 s)

**[0:00]** Mas aqui é como se fosse uma indústria de alimentos. Então, por exemplo, controle de qualidade: aí vem aqui os tipos de produto. Digamos que é uma fábrica de biscoito. Aí ele tem um biscoito doce, um biscoito salgado; aí eu coloquei só biscoito doce aqui, ó, produto A.

**[0:16]** Em relação ao produto A: a quantidade de matéria-prima comprada no mês de janeiro pra produzir — nem que eu fique com estoque e produza só em fevereiro, mas no mês de janeiro foi comprado as matérias-primas X, Y e Z — e o número da nota fiscal.

**[0:33]** A quantidade fabricada no mês de janeiro, né, por lote. Então, se tiver três lotes, eu vou registrar a quantidade que foi fabricada no lote A, lote B, lote C; a quantidade que foi vendida no mês de janeiro por lote; e o estoque por lote.

**[0:51]** Então, no final do mês, você vai ter um saldo, né, vai ter um saldo que é o estoque, e que no final do ano pode contabilizar um estoque total produzido do ano e o quanto de estoque que ficou, quer dizer, o tanto que vendeu e o estoque que ficou. Dá pra contabilizar se isso aqui for feito mês a mês

**[1:10]** de cada produto, né. O que eu acho assim que tem mais itens é esse controle de qualidade, porque se tiver 10 produtos, então são vários itens de cada produto. É, ainda tem outras coisas que podem ser incluídas aqui,

**[1:25]** como o laudo de análise, né. Ele pode ser incluído aqui dependendo do produto. Por exemplo, se for uma massa, um biscoito, não é feito, né, mas se for um refrigerante, uma cachaça, aí já tem um laudo que a gente pode colocar, como coloca

**[1:40]** aqui em cima, né, pra preencher [?] o valor do pH, entendeu? Cada análise e o valor que deu, a gente vai colocar aqui, né, pra no final também gerar uma planilha.

## O que os vídeos indicam sobre perguntas em aberto

- **C10**: o estoque de produtos controlados parece ser **informado** ("a quantidade que ficou em estoque naquele mês"), não calculado. Confirmar.
- **C11**: a compra de matéria-prima aparece **dentro do produto** no desenho e na fala ("em relação ao produto A, a quantidade de matéria-prima comprada"). Indício de vínculo com o produto. Confirmar.
- **C14**: "controle de processos" é citado só de passagem, como exemplo de aba possível; nada além disso.
- **Alerta por e-mail**: pedido explícito ("por e-mail ou com algum outro tipo de alerta"). No MVP o alerta é notificação local; e-mail fica para a Fase 5 (exige backend). Alinhar com a cliente (C24).
