# 02 — Requisitos

Identificadores no formato `RF-<ÁREA>-<nº>` para rastrear requisitos em tasks e PRs. Itens marcados com **(?)** dependem de resposta em [perguntas em aberto](06-perguntas-em-aberto.md).

## Transversais

### Empresas e módulos

- **RF-EMP-01** — Cadastrar, editar e arquivar empresas.
- **RF-EMP-02** — Habilitar/desabilitar módulos por empresa (Ambiental, Produtos Controlados, Controle de Qualidade).
- **RF-EMP-03** — Exibir para a empresa apenas os módulos habilitados.

### Prazos e alertas

- **RF-PRZ-01** — Todo prazo tem: título, categoria, data de vencimento, antecedência do alerta (dias) e situação (vigente, a vencer, vencido, renovado).
- **RF-PRZ-02** — Antecedência padrão de **150 dias** para licenças, editável por prazo. **(?)** padrão para laudos e manutenções.
- **RF-PRZ-03** — Notificação local no Android ao entrar na janela de alerta. **(?)** frequência de repetição até a renovação.
- **RF-PRZ-04** — Registrar renovação: encerra o ciclo atual e abre o próximo com nova data, mantendo histórico.
- **RF-PRZ-05** — Tela consolidada de próximos vencimentos de todas as empresas.

### Relatórios

- **RF-REL-01** — Exportar lançamentos de um período em planilha (`.xlsx`).
- **RF-REL-02** — Exportar em documento Word (`.docx`) editável, a partir de um modelo. **(?)** existem modelos oficiais por órgão.
- **RF-REL-03** — Compartilhar o arquivo gerado (e-mail, WhatsApp, Drive) pela folha de compartilhamento do Android.

## Módulo Ambiental

### Licenciamento

- **RF-AMB-01** — Licenças ambientais como prazos (RF-PRZ), alerta padrão de 150 dias.

### Automonitoramento

- **RF-AMB-02 — Ruídos**: cadastro de pontos de medição por empresa (exemplo da cliente: 4 pontos); lançamento **semanal** do valor medido em cada ponto. **(?)** unidade e limites.
- **RF-AMB-03 — Resíduos sólidos**: lançamento por classe de resíduo (ex.: Classe I, II-A, II-B) com quantidade gerada no período (**semanal ou mensal**). Exportável.
- **RF-AMB-04 — Resíduos perigosos**: tipo do resíduo, quantidade **gerada** e quantidade **armazenada** no período. Exportável.

### ETE (efluentes) e ETA (água)

Mesma estrutura para as duas estações:

- **RF-AMB-05 — Laudo**: datas em que o laudo deve ser feito, como prazo com alerta.
- **RF-AMB-06 — Manutenção**: equipamentos a comprar/manter, como prazo com alerta e controle de conclusão.
- **RF-AMB-07 — Controle**: lançamento de medições (pH, quantidade de insumo usado no tratamento, outros parâmetros). Exportável. **(?)** lista de parâmetros e periodicidade.

## Módulo Produtos Controlados

Mesma estrutura para **Polícia Federal** e **Exército**:

- **RF-PCT-01** — Licença como prazo com alerta de renovação.
- **RF-PCT-02** — Cadastro dos produtos controlados da empresa.
- **RF-PCT-03** — Lançamento **mensal** por produto: quantidade utilizada, número da nota fiscal e estoque ao fim do mês.
- **RF-PCT-04** — Relatório mensal exportável por órgão.

## Módulo Controle de Qualidade

Exemplo da cliente: indústria de alimentos (biscoito doce, biscoito salgado).

- **RF-QUA-01** — Cadastro de produtos da empresa.
- **RF-QUA-02** — Compras de matéria-prima no mês: item, quantidade e nota fiscal. A compra de um mês pode ser consumida em outro.
- **RF-QUA-03** — Produção no mês **por lote** (lote A, B, C…).
- **RF-QUA-04** — Vendas no mês por lote.
- **RF-QUA-05** — Estoque por lote como saldo calculado (produzido − vendido), acumulando mês a mês.
- **RF-QUA-06** — Consolidação anual por produto: total produzido, vendido e estoque final.
- **RF-QUA-07** — Laudos de análise opcionais por produto (ex.: refrigerante, cachaça): parâmetros (pH etc.) e valor de cada análise. Exportável.

> A cliente destacou que este é o módulo com mais volume de dados (10 produtos × vários itens por mês).

## Não funcionais

- **RNF-01** — Funciona 100% offline; dados persistidos no dispositivo.
- **RNF-02** — Camada de dados isolada atrás de interfaces de repositório, permitindo trocar o banco local por uma API sem alterar telas e regras.
- **RNF-03** — Dados preparados para sincronização futura: IDs gerados no cliente (UUID), `createdAt`/`updatedAt` e exclusão lógica.
- **RNF-04** — Backup e restauração manual do banco (exportar/importar arquivo), já que os dados vivem só no aparelho. **(?)**
- **RNF-05** — Android: versão mínima a definir **(?)**; permissão de notificação no Android 13+.
- **RNF-06** — Interface em português (pt-BR); datas e números no formato brasileiro.
