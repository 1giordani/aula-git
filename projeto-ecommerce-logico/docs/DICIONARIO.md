# Dicionário físico do e-commerce

Extraído de `information_schema` do MySQL 8.4.6 após a criação e os testes. A definição completa está em `sql/01_estrutura.sql`.

## cliente

| Coluna | Tipo SQL | Aceita NULL | Chave no metadado | Complemento |
| --- | --- | --- | --- | --- |
| id_cliente | `int unsigned` | NO | PRI | — |
| tipo_cliente | `enum('PF','PJ')` | NO | — | — |
| nome_exibicao | `varchar(100)` | NO | — | — |
| email | `varchar(150)` | NO | UNI | — |
| cpf | `char(11)` | YES | UNI | — |
| nome_completo | `varchar(150)` | YES | — | — |
| cnpj | `char(14)` | YES | UNI | — |
| razao_social | `varchar(150)` | YES | — | — |

## entrega

| Coluna | Tipo SQL | Aceita NULL | Chave no metadado | Complemento |
| --- | --- | --- | --- | --- |
| id_entrega | `int unsigned` | NO | PRI | — |
| id_pedido | `int unsigned` | NO | UNI | — |
| status | `enum('PREPARANDO','POSTADA','EM_TRANSITO','ENTREGUE','CANCELADA')` | NO | — | — |
| transportadora | `varchar(80)` | YES | MUL | — |
| codigo_rastreio | `varchar(80)` | YES | — | — |

## estoque

| Coluna | Tipo SQL | Aceita NULL | Chave no metadado | Complemento |
| --- | --- | --- | --- | --- |
| id_estoque | `int unsigned` | NO | PRI | — |
| localizacao | `varchar(120)` | NO | — | — |

## forma_pagamento

| Coluna | Tipo SQL | Aceita NULL | Chave no metadado | Complemento |
| --- | --- | --- | --- | --- |
| id_forma | `int unsigned` | NO | PRI | — |
| id_cliente | `int unsigned` | NO | MUL | — |
| tipo | `enum('CARTAO','PIX','BOLETO')` | NO | — | — |
| apelido | `varchar(80)` | NO | — | — |
| referencia_provedor | `varchar(100)` | YES | — | — |

## fornecedor

| Coluna | Tipo SQL | Aceita NULL | Chave no metadado | Complemento |
| --- | --- | --- | --- | --- |
| id_fornecedor | `int unsigned` | NO | PRI | — |
| razao_social | `varchar(120)` | NO | — | — |
| cnpj | `char(14)` | NO | UNI | — |

## fornecimento

| Coluna | Tipo SQL | Aceita NULL | Chave no metadado | Complemento |
| --- | --- | --- | --- | --- |
| id_fornecedor | `int unsigned` | NO | PRI | — |
| id_produto | `int unsigned` | NO | PRI | — |
| referencia_fornecedor | `varchar(80)` | YES | — | — |

## item_pedido

| Coluna | Tipo SQL | Aceita NULL | Chave no metadado | Complemento |
| --- | --- | --- | --- | --- |
| id_pedido | `int unsigned` | NO | PRI | — |
| numero_item | `smallint unsigned` | NO | PRI | — |
| id_oferta | `int unsigned` | NO | MUL | — |
| quantidade | `int` | NO | — | — |
| preco_unitario_praticado | `decimal(10,2)` | NO | — | — |
| subtotal | `decimal(14,2)` | YES | — | STORED GENERATED |

## oferta

| Coluna | Tipo SQL | Aceita NULL | Chave no metadado | Complemento |
| --- | --- | --- | --- | --- |
| id_oferta | `int unsigned` | NO | PRI | — |
| id_produto | `int unsigned` | NO | MUL | — |
| id_vendedor | `int unsigned` | NO | MUL | — |
| preco_atual | `decimal(10,2)` | NO | — | — |
| ativo | `tinyint(1)` | NO | — | — |

## pagamento

| Coluna | Tipo SQL | Aceita NULL | Chave no metadado | Complemento |
| --- | --- | --- | --- | --- |
| id_pagamento | `int unsigned` | NO | PRI | — |
| id_pedido | `int unsigned` | NO | MUL | — |
| id_forma | `int unsigned` | NO | MUL | — |
| id_cliente | `int unsigned` | NO | — | — |
| valor | `decimal(14,2)` | NO | — | — |
| status | `enum('PENDENTE','APROVADO','RECUSADO','CANCELADO')` | NO | — | — |
| data_pagamento | `datetime` | YES | — | — |

## pedido

| Coluna | Tipo SQL | Aceita NULL | Chave no metadado | Complemento |
| --- | --- | --- | --- | --- |
| id_pedido | `int unsigned` | NO | PRI | — |
| id_cliente | `int unsigned` | NO | MUL | — |
| data_criacao | `datetime` | NO | — | — |
| status | `enum('RASCUNHO','CONFIRMADO','EM_PROCESSAMENTO','CONCLUIDO','CANCELADO')` | NO | — | — |
| endereco_entrega_snapshot | `varchar(250)` | NO | — | — |
| frete | `decimal(10,2)` | NO | — | — |
| desconto | `decimal(10,2)` | NO | — | — |

## produto

| Coluna | Tipo SQL | Aceita NULL | Chave no metadado | Complemento |
| --- | --- | --- | --- | --- |
| id_produto | `int unsigned` | NO | PRI | — |
| descricao | `varchar(120)` | NO | — | — |
| categoria | `varchar(80)` | NO | — | — |

## produto_estoque

| Coluna | Tipo SQL | Aceita NULL | Chave no metadado | Complemento |
| --- | --- | --- | --- | --- |
| id_produto | `int unsigned` | NO | PRI | — |
| id_estoque | `int unsigned` | NO | PRI | — |
| quantidade_disponivel | `int` | NO | — | — |

## vendedor

| Coluna | Tipo SQL | Aceita NULL | Chave no metadado | Complemento |
| --- | --- | --- | --- | --- |
| id_vendedor | `int unsigned` | NO | PRI | — |
| nome | `varchar(120)` | NO | — | — |
| cnpj | `char(14)` | NO | UNI | — |
| tipo | `enum('PLATAFORMA','TERCEIRO')` | NO | — | — |

## Chaves estrangeiras

Uma chave composta aparece em duas linhas com o mesmo nome de constraint.

| Tabela | Constraint | Coluna | Referência |
| --- | --- | --- | --- |
| entrega | entrega_ibfk_1 | id_pedido | pedido.id_pedido |
| forma_pagamento | forma_pagamento_ibfk_1 | id_cliente | cliente.id_cliente |
| fornecimento | fornecimento_ibfk_1 | id_fornecedor | fornecedor.id_fornecedor |
| fornecimento | fornecimento_ibfk_2 | id_produto | produto.id_produto |
| item_pedido | item_pedido_ibfk_1 | id_pedido | pedido.id_pedido |
| item_pedido | item_pedido_ibfk_2 | id_oferta | oferta.id_oferta |
| oferta | oferta_ibfk_1 | id_produto | produto.id_produto |
| oferta | oferta_ibfk_2 | id_vendedor | vendedor.id_vendedor |
| pagamento | pagamento_ibfk_1 | id_pedido | pedido.id_pedido |
| pagamento | pagamento_ibfk_1 | id_cliente | pedido.id_cliente |
| pagamento | pagamento_ibfk_2 | id_forma | forma_pagamento.id_forma |
| pagamento | pagamento_ibfk_2 | id_cliente | forma_pagamento.id_cliente |
| pedido | pedido_ibfk_1 | id_cliente | cliente.id_cliente |
| produto_estoque | produto_estoque_ibfk_1 | id_produto | produto.id_produto |
| produto_estoque | produto_estoque_ibfk_2 | id_estoque | estoque.id_estoque |

## Views

- `vw_cliente_pf`: projeção dos atributos específicos de PF.
- `vw_cliente_pj`: projeção dos atributos específicos de PJ.
- `vw_total_pedido`: dados do pedido, valor dos produtos e total com frete e desconto.
- `vw_saldo_pedido`: valor aprovado e saldo pendente, contando somente pagamentos aprovados.

As views de PF e PJ não são tabelas independentes e não possuem PK/FK físicas. A exclusividade é implementada no CHECK da tabela cliente.