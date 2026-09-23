# 03 — Domínio

## Glossário

Nomes em código propostos em inglês — **a confirmar** (ver perguntas em aberto).

| Termo (cliente) | Significado | Nome em código |
|---|---|---|
| Empresa | Indústria atendida | `Company` |
| Módulo | Área regulatória habilitável por empresa | `ModuleType` |
| Licença | Autorização com validade emitida por órgão | `Deadline` (categoria `license`) |
| Prazo / vencimento | Qualquer data que exige ação e alerta | `Deadline` |
| Alerta | Aviso antes do vencimento | `Reminder` |
| Automonitoramento | Medições que a empresa é obrigada a fazer | — (agrupador) |
| Ponto de medição | Local fixo onde se mede ruído | `NoisePoint` |
| R.S. — resíduos sólidos | Resíduos classificados por classe | `WasteRecord` (tipo `solid`) |
| R.P. — resíduos perigosos | Resíduos perigosos gerados/armazenados | `WasteRecord` (tipo `hazardous`) |
| ETE | Estação de Tratamento de Efluentes | `TreatmentStation` (tipo `effluent`) |
| ETA | Estação de Tratamento de Água | `TreatmentStation` (tipo `water`) |
| Laudo | Análise técnica com data/resultado (não confundir com relatório exportado) | `Deadline` (datas) / `AnalysisResult` (valores) |
| Produto controlado | Produto químico fiscalizado por PF ou Exército | `ControlledProduct` |
| Órgão | PF, Exército, órgão ambiental | `Authority` |
| Nota fiscal | Documento fiscal da compra/uso | `invoiceNumber` |
| Lote | Unidade de produção rastreável | `Batch` |
| Matéria-prima | Insumo comprado para produção | `RawMaterialPurchase` |
| Relatório | Arquivo exportado (xlsx/docx) para o órgão | `ExportReport` |

## Decisão de modelagem

Os módulos têm campos diferentes e a cliente disse que "pode incluir mais coisas". Duas abordagens foram consideradas:

1. **Tabelas específicas** por tipo de registro — tipagem forte, relatórios simples, mas cada novo tipo exige migração.
2. **Registros genéricos configuráveis** (tipo de lançamento + campos dinâmicos) — flexível, mas complexo de validar e de exportar.

**Proposta: híbrido começando pelo simples.** Entidades centrais tipadas (empresa, prazo, produto, lote). Para medições, uma estrutura semi-genérica de *parâmetro + valor* (`MeasurementParameter` / `Measurement`), que cobre ruído, ETE/ETA e laudos de análise sem uma tabela para cada caso. Reavaliar após a Fase 2.

## Modelo preliminar

Campos de controle omitidos no diagrama, mas presentes em todas as tabelas: `id` (UUID), `createdAt`, `updatedAt`, `deletedAt`.

```mermaid
erDiagram
    Company ||--o{ CompanyModule : habilita
    Company ||--o{ Deadline : possui
    Company ||--o{ MeasurementParameter : define
    Company ||--o{ WasteRecord : lanca
    Company ||--o{ TreatmentStation : possui
    Company ||--o{ ControlledProduct : possui
    Company ||--o{ Product : fabrica

    MeasurementParameter ||--o{ Measurement : recebe
    TreatmentStation ||--o{ MeasurementParameter : agrupa

    ControlledProduct ||--o{ ControlledProductEntry : movimenta

    Product ||--o{ RawMaterialPurchase : consome
    Product ||--o{ Batch : produz
    Batch ||--o{ BatchSale : vende
    Product ||--o{ MeasurementParameter : analisa

    Company {
        string name
        string cnpj
        bool archived
    }
    CompanyModule {
        string moduleType "environmental | controlled_products | quality"
        bool enabled
    }
    Deadline {
        string module
        string category "license | lab_report | maintenance"
        string authority "environmental | federal_police | army | null"
        string title
        date dueDate
        int alertDaysBefore "padrao 150"
        string status "active | renewed | cancelled"
        string previousDeadlineId "ciclo anterior"
    }
    MeasurementParameter {
        string context "noise_point | effluent | water | product_analysis"
        string ownerId "station ou product, opcional"
        string name "Ponto 1, pH, Cloro..."
        string unit
        string frequency "weekly | monthly | on_demand"
    }
    Measurement {
        date referenceDate
        decimal value
        string notes
    }
    WasteRecord {
        string wasteType "solid | hazardous"
        string wasteClass
        string description
        date periodStart
        date periodEnd
        decimal quantityGenerated
        decimal quantityStored "somente perigosos"
        string unit
    }
    TreatmentStation {
        string type "effluent | water"
        string name
    }
    ControlledProduct {
        string authority "federal_police | army"
        string name
    }
    ControlledProductEntry {
        string month "YYYY-MM"
        decimal quantityUsed
        string invoiceNumber
        decimal closingStock
    }
    Product {
        string name
    }
    RawMaterialPurchase {
        string month
        string material
        decimal quantity
        string unit
        string invoiceNumber
    }
    Batch {
        string code
        string month
        decimal quantityProduced
    }
    BatchSale {
        string month
        decimal quantity
    }
```

### Regras de negócio já identificadas

- **Estoque por lote** = `quantityProduced` − soma de `BatchSale.quantity`. É **calculado**, não digitado.
- **Consolidação anual** de um produto = soma dos lotes produzidos no ano, soma das vendas no ano e soma dos saldos em aberto.
- **Situação de um prazo** é derivada de `dueDate` e `alertDaysBefore` em relação à data atual: *vigente* → *a vencer* (dentro da janela de alerta) → *vencido*.
- **Renovar** cria um novo `Deadline` apontando para o anterior e marca o anterior como `renewed`.
- **Produtos controlados:** o estoque ao fim do mês é informado pela cliente, não calculado. **(?)** confirmar se deveria ser calculado a partir do estoque anterior e das entradas/saídas.
