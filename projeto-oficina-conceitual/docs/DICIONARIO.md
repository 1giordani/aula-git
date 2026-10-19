# Dicionário de entidades

PK = chave primária; FK = chave estrangeira; UK = chave única. Todos os atributos aparecem nos diagramas e na fonte `modelo.json`.

| Entidade | Identificador | Descrição |
| --- | --- | --- |
| Cliente | id_cliente | Pessoa que leva o veículo e solicita os trabalhos; contém nome e contato |
| Veículo | id_veiculo | Bem atendido, com placa única, marca, modelo, ano e cliente atual |
| Equipe | id_equipe | Grupo responsável pela avaliação e execução das OSs |
| Mecânico | codigo_mecanico | Profissional com nome, endereço e especialidade |
| Composição da equipe | id_equipe + codigo_mecanico + data_inicio | Participação do mecânico numa equipe, com período de validade |
| Ordem de serviço | numero_os | Atendimento que une veículo, solicitante e equipe; contém emissão, previsão, conclusão efetiva, status e total derivado |
| Autorização | id_autorizacao | Decisão do cliente sobre uma OS, com número da OS único, data e valor do orçamento |
| Serviço / mão de obra | id_servico | Catálogo de serviços e tabela de referência de valores por hora ou por execução |
| Serviço da OS | numero_os + id_servico | Serviço orçado, com quantidade e preço histórico aplicado |
| Peça | id_peca | Catálogo de peças e valores de referência |
| Peça da OS | numero_os + id_peca | Peça incluída na OS, com quantidade e preço histórico aplicado |

## Atributos derivados e opcionais

- `subtotal` dos itens: quantidade × valor unitário aplicado.
- `valor_total` da OS: soma dos subtotais dos serviços e das peças.
- `data_efetiva_conclusao`: ausente antes do encerramento dos trabalhos.
- `data_fim` da participação: ausente enquanto a participação permanece ativa.
- AUTORIZAÇÃO é uma entidade opcional para a OS antes da decisão; seu registro não é criado com decisão pendente.

## O que foi definido como hipótese

Contato do cliente, placa única, proprietário atual, histórico do solicitante, períodos de composição, enumeração de status, uma decisão por OS e regras para revisão de orçamento foram acrescentados pelo autor por não terem detalhes definidos na narrativa. O README descreve essas decisões.

Não foram especificados tipos SQL, tamanhos de colunas, índices físicos, rotinas de execução nem procedimentos de validação de documentos pessoais: o entregável é conceitual.
