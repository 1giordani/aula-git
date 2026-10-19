# Mapeamento EER e regras implementadas

## Especialização total e exclusiva de cliente

O [modelo conceitual anterior](https://github.com/1giordani/aula-git/tree/projeto-ecommerce-conceitual/projeto-ecommerce-conceitual) representa CLIENTE com subtipos PF e PJ, sujeitos a totalidade e exclusividade.

O mapeamento físico escolhido é **tabela única com discriminador**, uma alternativa relacional para especialização:

- `tipo_cliente` obrigatório indica PF ou PJ.
- PF exige CPF e nome completo e proíbe CNPJ e razão social.
- PJ exige CNPJ e razão social e proíbe CPF e nome completo.
- O CHECK inclui testes IS NOT NULL explícitos para os atributos obrigatórios. Isso evita aceitar um cadastro incompleto por resultado UNKNOWN de uma expressão SQL com NULL.
- CPF e CNPJ são únicos dentro de suas respectivas colunas. Valores NULL da coluna não aplicável não impedem outras contas do outro tipo.
- `vw_cliente_pf` e `vw_cliente_pj` expõem os subtipos como projeções filtradas. Não são tabelas separadas nem impõem a exclusividade: ela já está no CHECK da tabela cliente.

O banco verifica os comprimentos dos documentos e sua unicidade, mas não implementa dígitos verificadores nem validação cadastral externa. Os documentos da massa são fictícios.

## Relações N:N e chaves

- Fornecedor × Produto → fornecimento, com PK composta.
- Produto × Estoque → produto_estoque, com PK composta e quantidade não negativa.
- Vendedor × Produto → oferta, com identificador próprio e par produto/vendedor único.
- Pedido × Oferta → item_pedido, com PK `(id_pedido,numero_item)` e quantidade positiva.

Cada item referencia a oferta e, por ela, o vendedor e o produto. Produto e vendedor da oferta ficam preservados quando ela já foi utilizada em pedido; preço atual e indicador ativo podem mudar.

## Titularidade das formas e pagamentos

Forma de pagamento pertence a um cliente. O cliente pode cadastrar várias; cada pedido pode ter vários pagamentos.

Para impedir o uso da forma de outro cliente, pagamento contém `id_cliente` como redundância controlada, amparada por duas FKs compostas:

```text
pagamento(id_pedido,id_cliente) -> pedido(id_pedido,id_cliente)
pagamento(id_forma,id_cliente)  -> forma_pagamento(id_forma,id_cliente)
```

As chaves únicas correspondentes nas tabelas pai dão suporte explícito a essas FKs. Assim, o mesmo id_cliente precisa ser válido nos dois caminhos. Não basta uma FK isolada para a forma e outra isolada para o pedido.

Pagamentos têm valor positivo. Uma aprovação precisa de data e não pode anteceder a criação do pedido. A soma aprovada não pode exceder o total; um pagamento pendente pode passar para aprovação, recusa ou cancelamento, mantendo sua identidade e valor. Registros finalizados e exclusões de pagamentos ficam bloqueados para preservar o histórico.

A tabela armazena registros demonstrativos, não efetua cobranças reais. Referências de provedor não são credenciais reais. Estornos, chargebacks, juros e parcelamento não estão modelados. Por isso, o cancelamento de um pedido com valor aprovado é bloqueado, exigindo um fluxo de estorno fora desta versão.

## Valores e congelamento do pedido

- Item copia o preço atual de oferta ativa na inclusão e conserva esse preço em alterações de quantidade.
- Itens só podem ser alterados com pedido em RASCUNHO.
- Confirmação exige pelo menos um item e total não negativo.
- Frete, desconto e endereço ficam congelados após a confirmação.
- Subtotal do item é uma coluna gerada: quantidade × preço praticado.
- Total do pedido é calculado em view: soma dos itens + frete − desconto.
- Pagamentos aprovados são agregados separadamente; pendências e recusas não entram no valor aprovado.
- Um rascunho pode estar temporariamente com desconto maior que seu subtotal enquanto é editado, mas não pode ser confirmado assim.

## Entrega e estados

Uma entrega por pedido foi mantida do conceitual: UNIQUE em entrega.id_pedido. Ela possui status, transportadora e código de rastreio, com par transportadora/código único quando preenchido.

A entrega começa em PREPARANDO, apenas para pedido EM_PROCESSAMENTO. Postagem, trânsito e entrega exigem transportadora e código não vazios pelo CHECK. Após a postagem, os identificadores de rastreio não podem ser reescritos; a exclusão da entrega também é bloqueada.

Transições de pedido:

- RASCUNHO → CONFIRMADO ou CANCELADO.
- CONFIRMADO → EM_PROCESSAMENTO ou CANCELADO.
- EM_PROCESSAMENTO → CONCLUIDO ou CANCELADO.
- CONCLUIDO e CANCELADO são terminais.

Processamento exige quitação; conclusão exige quitação e entrega ENTREGUE. Cancelamento com valor aprovado é bloqueado nesta versão sem estornos.

Transições de entrega:

- PREPARANDO → POSTADA ou CANCELADA.
- POSTADA → EM_TRANSITO ou CANCELADA.
- EM_TRANSITO → ENTREGUE ou CANCELADA.
- ENTREGUE e CANCELADA são terminais.

Não há novas remessas nem recuperação automática de entrega cancelada. Esses fluxos dependem de evolução do modelo.

## Vendedor também fornecedor

São papéis distintos. Um CNPJ pode ocorrer uma vez em vendedor e uma vez em fornecedor; sua presença nas duas tabelas caracteriza a mesma empresa nos dois papéis nesta versão. Todos os vendedores da massa são PJ, uma hipótese autoral adicionada para essa identificação. A consulta não compara apenas nomes, que poderiam ser iguais em empresas diferentes.

## Estoque e limites

O saldo de estoque descreve a posição do catálogo nos locais administrados pela plataforma. O projeto não reserva ou baixa estoque automaticamente a cada compra e não acompanha estoque externo de vendedores. A consulta detalhada que combina fornecedor e estoque repete o saldo por combinação; a consulta de saldo total evita juntar fornecedores para não duplicar unidades.

Os bloqueios de linha do pedido coordenam operações dos itens e pagamentos. Os testes foram sequenciais; não se afirma que houve teste de carga, concorrência ou de todos os cenários de produção. A criação e migração de contas, pagamentos e remessas reais estão fora do escopo.
