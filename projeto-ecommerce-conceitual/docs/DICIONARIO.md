# Dicionário de entidades

Os atributos e as chaves de cada entidade estão nas imagens e em `modelo.json`. PK significa chave primária; FK, chave estrangeira; UK, chave única.

| Entidade | Identificador | Papel e vínculos |
| --- | --- | --- |
| Cliente | id_cliente | Conta e discriminador PF/PJ; realiza pedidos e cadastra formas |
| Pessoa física | id_cliente, herdado do cliente | Subtipo exclusivo com CPF único e nome completo |
| Pessoa jurídica | id_cliente, herdado do cliente | Subtipo exclusivo com CNPJ único e razão social |
| Forma de pagamento | id_forma | Meio cadastrado por um cliente, com tipo e referência |
| Pedido | id_pedido | Compra de um cliente, com estado, frete, desconto e cópia do endereço |
| Pagamento | id_pagamento | Uso de uma forma em um pedido; valor, estado e data |
| Entrega | id_entrega | Expedição de um pedido, com estado, transportadora e rastreio |
| Produto | id_produto | Descrição e categoria do item de catálogo |
| Item do pedido | id_pedido + numero_item | Oferta comprada, quantidade e preço histórico |
| Oferta | id_oferta | Produto disponibilizado por vendedor; par produto/vendedor único |
| Vendedor | id_vendedor | Responsável pela venda: plataforma ou terceiro |
| Fornecedor | id_fornecedor | Origem do abastecimento, com CNPJ único |
| Fornecimento | id_fornecedor + id_produto | Associação N:N entre fornecedor e produto |
| Estoque | id_estoque | Local de armazenagem administrado pela plataforma |
| Produto no estoque | id_produto + id_estoque | Saldo disponível de um produto em determinado local |

## Estados sugeridos

| Atributo | Domínio proposto |
| --- | --- |
| tipo_cliente | PF, PJ |
| tipo da forma | cartão, PIX, boleto |
| status_pedido | rascunho, confirmado, em processamento, concluído, cancelado |
| status_pagamento | pendente, aprovado, recusado, cancelado |
| status_entrega | em preparação, postada, em trânsito, entregue, cancelada |
| tipo do vendedor | plataforma, terceiro |

Os domínios são decisões autorais. A especificação conceitual não fixa tamanho de campos, tipos SQL, índices físicos nem implementação de transições de estado.
