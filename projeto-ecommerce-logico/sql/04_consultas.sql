USE ecommerce_logico;
-- Q01: Quantos pedidos foram feitos por cada cliente, incluindo quem nao possui pedidos?
SELECT c.id_cliente,c.nome_exibicao,c.tipo_cliente,COUNT(p.id_pedido) AS quantidade_pedidos
FROM cliente c LEFT JOIN pedido p USING(id_cliente)
GROUP BY c.id_cliente,c.nome_exibicao,c.tipo_cliente ORDER BY quantidade_pedidos DESC,c.id_cliente;

-- Q02: Algum vendedor tambem e fornecedor, identificado pelo mesmo CNPJ?
SELECT v.id_vendedor,v.nome,v.cnpj,f.id_fornecedor,f.razao_social
FROM vendedor v JOIN fornecedor f ON f.cnpj=v.cnpj ORDER BY v.id_vendedor;

-- Q03: Quais sao os nomes dos fornecedores e os produtos fornecidos?
SELECT f.razao_social,p.descricao,fp.referencia_fornecedor
FROM fornecedor f JOIN fornecimento fp USING(id_fornecedor)
JOIN produto p USING(id_produto) ORDER BY f.id_fornecedor,p.id_produto;

-- Q04: Qual a relacao detalhada entre produtos, fornecedores e estoques?
-- Produto com varios fornecedores e locais aparece em varias combinacoes.
-- Nao somar saldos desta consulta: a quantidade pode se repetir por fornecedor.
SELECT p.id_produto,p.descricao,COALESCE(f.razao_social,'SEM FORNECEDOR') AS fornecedor,
 COALESCE(e.localizacao,'SEM ESTOQUE') AS localizacao,COALESCE(pe.quantidade_disponivel,0) AS quantidade
FROM produto p LEFT JOIN fornecimento fp USING(id_produto)
LEFT JOIN fornecedor f USING(id_fornecedor)
LEFT JOIN produto_estoque pe ON pe.id_produto=p.id_produto
LEFT JOIN estoque e USING(id_estoque)
ORDER BY p.id_produto,f.id_fornecedor,e.id_estoque;

-- Q05: Quais pedidos confirmados ainda possuem saldo a pagar?
SELECT id_pedido,id_cliente,valor_total,valor_aprovado,saldo_pendente
FROM vw_saldo_pedido WHERE status='CONFIRMADO' AND saldo_pendente>0
ORDER BY saldo_pendente DESC,id_pedido;

-- Q06: Qual o valor de produtos, frete, desconto e total por pedido?
SELECT id_pedido,valor_produtos,frete,desconto,valor_total,status
FROM vw_total_pedido ORDER BY valor_total DESC,id_pedido;

-- Q07: Quais clientes cadastraram mais de uma forma de pagamento?
SELECT c.id_cliente,c.nome_exibicao,COUNT(f.id_forma) AS formas
FROM cliente c JOIN forma_pagamento f USING(id_cliente)
GROUP BY c.id_cliente,c.nome_exibicao HAVING COUNT(f.id_forma)>1
ORDER BY formas DESC,c.id_cliente;

-- Q08: Qual a situacao das entregas e quais sao seus codigos de rastreio?
SELECT p.id_pedido,c.nome_exibicao,p.status AS status_pedido,e.status AS status_entrega,
 e.transportadora,e.codigo_rastreio
FROM pedido p JOIN cliente c USING(id_cliente)
JOIN entrega e USING(id_pedido) ORDER BY p.id_pedido;

-- Q09: Qual o saldo fisico total de cada produto, sem duplicar por fornecedor?
SELECT p.id_produto,p.descricao,COALESCE(SUM(pe.quantidade_disponivel),0) AS unidades
FROM produto p LEFT JOIN produto_estoque pe USING(id_produto)
GROUP BY p.id_produto,p.descricao ORDER BY unidades DESC,p.id_produto;

-- Q10: Quais vendedores somam pelo menos R$100 em itens de pedidos confirmados ou posteriores, nao cancelados?
SELECT v.id_vendedor,v.nome,SUM(i.subtotal) AS valor_itens
FROM vendedor v JOIN oferta o USING(id_vendedor)
JOIN item_pedido i USING(id_oferta) JOIN pedido p USING(id_pedido)
WHERE p.status NOT IN('RASCUNHO','CANCELADO')
GROUP BY v.id_vendedor,v.nome HAVING SUM(i.subtotal)>=100
ORDER BY valor_itens DESC,v.id_vendedor;

-- Q11: Quais clientes PF e PJ estao cadastrados e quais documentos identificam suas contas?
SELECT id_cliente,tipo_cliente,nome_exibicao,
 CASE WHEN tipo_cliente='PF' THEN cpf ELSE cnpj END AS documento
FROM cliente ORDER BY tipo_cliente,id_cliente;

-- Q12: Quais clientes ainda nao fizeram nenhum pedido?
SELECT c.id_cliente,c.nome_exibicao FROM cliente c
WHERE NOT EXISTS(SELECT 1 FROM pedido p WHERE p.id_cliente=c.id_cliente)
ORDER BY c.id_cliente;

-- Q13: Quais itens conservaram preco historico diferente da oferta atual?
SELECT i.id_pedido,p.descricao,i.preco_unitario_praticado,o.preco_atual,
 o.preco_atual-i.preco_unitario_praticado AS diferenca_unitaria
FROM item_pedido i JOIN oferta o USING(id_oferta) JOIN produto p USING(id_produto)
WHERE i.preco_unitario_praticado<>o.preco_atual ORDER BY i.id_pedido,i.numero_item;

-- Q14: Qual o ranking dos produtos pela quantidade em pedidos confirmados ou posteriores?
WITH volumes AS (
 SELECT p.id_produto,p.descricao,COALESCE(SUM(CASE WHEN ped.status NOT IN('RASCUNHO','CANCELADO') THEN i.quantidade ELSE 0 END),0) AS unidades
 FROM produto p LEFT JOIN oferta o USING(id_produto)
 LEFT JOIN item_pedido i USING(id_oferta) LEFT JOIN pedido ped USING(id_pedido)
 GROUP BY p.id_produto,p.descricao
)
SELECT id_produto,descricao,unidades,DENSE_RANK() OVER(ORDER BY unidades DESC) AS posicao
FROM volumes ORDER BY posicao,id_produto;

-- Q15: Quanto foi registrado por status de pagamento, sem confundir tentativa com recebimento?
SELECT status,COUNT(*) AS registros,SUM(valor) AS valor FROM pagamento
GROUP BY status ORDER BY status;

-- Q16: Qual a quantidade de itens e pagamentos de cada pedido, sem multiplicar agregacoes?
SELECT p.id_pedido,COALESCE(i.itens,0) AS linhas_itens,COALESCE(a.pagamentos,0) AS registros_pagamento,
 s.valor_total,s.valor_aprovado,s.saldo_pendente
FROM pedido p
LEFT JOIN(SELECT id_pedido,COUNT(*) AS itens FROM item_pedido GROUP BY id_pedido)i USING(id_pedido)
LEFT JOIN(SELECT id_pedido,COUNT(*) AS pagamentos FROM pagamento GROUP BY id_pedido)a USING(id_pedido)
JOIN vw_saldo_pedido s USING(id_pedido) ORDER BY p.id_pedido;
