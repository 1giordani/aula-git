# Regras de negócio e cardinalidades

## Cliente PF ou PJ

1. Cada CLIENTE é obrigatoriamente uma PESSOA FÍSICA ou uma PESSOA JURÍDICA: especialização **total e disjunta**.
2. Para uma conta, `quantidade_de_registros_PF + quantidade_de_registros_PJ = 1`.
3. `tipo_cliente = PF` implica um registro PF e nenhum PJ; `tipo_cliente = PJ` implica o inverso.
4. O subtipo herda o identificador do cliente; ele é PK no subtipo e FK para CLIENTE.
5. CPF é único entre pessoas físicas; CNPJ é único entre pessoas jurídicas. Nome de exibição pode ser diferente do nome legal.
6. Os diagramas mostram os subtipos como entidades separadas. Numa implementação futura, PK/FK isoladamente não garantem totalidade nem XOR; essas regras precisarão de mecanismo transacional específico ou de mapeamento alternativo em tabela única com restrições apropriadas.

## Formas e pagamentos

1. Cliente recém-cadastrado pode ter zero formas; pode cadastrar várias depois. Cada forma pertence a exatamente um cliente.
2. Cada PAGAMENTO está associado a exatamente um PEDIDO e uma FORMA DE PAGAMENTO.
3. A forma usada deve pertencer ao cliente que realizou o pedido. Formalmente: `Pedido.id_cliente = FormaPagamento.id_cliente` para todo pagamento que os vincule.
4. Essa igualdade entre caminhos não é garantida apenas pelas FKs simples desenhadas: é uma restrição de negócio adicional para a implementação física.
5. Valor de um pagamento deve ser positivo. O status pode ser pendente, aprovado, recusado ou cancelado.
6. Data de pagamento pode estar ausente antes da aprovação. O registro do meio contém tipo, apelido ou referência do provedor; o esquema não exige armazenar número completo do cartão nem código de segurança.
7. Um pedido pode ter zero ou muitos pagamentos: zero antes do pagamento e vários para divisão ou tentativas. Na regra desta versão, a soma dos valores aprovados não pode superar o total do pedido, e só há quitação quando a soma aprovada o alcança.
8. Estornos, chargebacks, parcelamento detalhado e juros não são modelados nesta versão.

## Pedido, item e oferta

1. Cada pedido pertence a um único cliente; cada cliente pode realizar zero ou muitos pedidos.
2. Pedido em rascunho aceita zero itens; pedido confirmado precisa ter ao menos um. Essa restrição depende do estado do pedido e não cabe apenas na cardinalidade estática.
3. Cada item pertence a um único pedido e tem um número único dentro dele. Sua PK é `(id_pedido, numero_item)`.
4. Cada item aponta para uma única oferta. Uma oferta pode aparecer em muitos itens ao longo do tempo.
5. Cada oferta vincula um produto a um vendedor. O par é único nesta versão. Desativar uma oferta impede novas vendas sem excluir referências históricas.
6. Produto e vendedor de oferta já referenciada em pedido são imutáveis; preço atual e disponibilidade podem mudar. A oferta própria usa um VENDEDOR do tipo plataforma.
7. A quantidade do item deve ser positiva e seu preço praticado não negativo. Frete e desconto também são não negativos.
8. Total do pedido é derivado: `soma(quantidade × preco_unitario_praticado) + frete − desconto`, sem resultado negativo.
9. O endereço de entrega é guardado como cópia histórica no pedido. O cadastro completo de endereços reutilizáveis não faz parte desta versão.

## Entrega

1. Pedido pode ter zero ou uma entrega. Uma entrega pertence a exatamente um pedido, com `id_pedido` único na entidade ENTREGA.
2. O status pode ser em preparação, postada, em trânsito, entregue ou cancelada.
3. A partir da postagem, transportadora e código de rastreio são obrigatórios. Em preparação, o código pode ainda não existir. Em cancelamento, preserva-se o código caso já tenha sido emitido.
4. O par transportadora/código de rastreio é único quando informado.
5. A hipótese de uma entrega por pedido é uma simplificação autoral. Para remessas parciais futuras, seria preciso 1:N de pedido para entrega e uma associação dos itens a cada remessa.

## Fornecimento e estoque

1. Fornecedor pode fornecer vários produtos e produto pode ser fornecido por vários fornecedores. FORNECIMENTO resolve o N:N com PK composta.
2. Produto pode existir em vários locais de estoque e cada local pode conter vários produtos. PRODUTO NO ESTOQUE resolve esse N:N e guarda a quantidade por par.
3. Quantidade disponível não pode ser negativa. Não se armazena a mesma quantidade em PRODUTO, evitando duas fontes independentes para o saldo.
4. O estoque deste modelo representa os locais administrados pela plataforma. Estoques externos de vendedores, reservas e movimentações detalhadas não estão incluídos.

## Resumo de cardinalidades

Em cada linha abaixo, um registro da entidade à direita tem exatamente um registro pai da entidade à esquerda. A última coluna informa quantos filhos cada pai pode ter.

| Entidade pai | Entidade filha | Filhos por pai |
| --- | --- | --- |
| Cliente | Pessoa física | 0..1, sujeito a totalidade + XOR com PJ |
| Cliente | Pessoa jurídica | 0..1, sujeito a totalidade + XOR com PF |
| Cliente | Pedido | 0..N |
| Cliente | Forma de pagamento | 0..N |
| Pedido | Pagamento | 0..N |
| Forma de pagamento | Pagamento | 0..N |
| Pedido | Entrega | 0..1 |
| Pedido | Item do pedido | 0..N; ao menos 1 se confirmado |
| Oferta | Item do pedido | 0..N |
| Produto | Oferta | 0..N |
| Vendedor | Oferta | 0..N |
| Fornecedor | Fornecimento | 0..N |
| Produto | Fornecimento | 0..N |
| Estoque | Produto no estoque | 0..N |
| Produto | Produto no estoque | 0..N |
