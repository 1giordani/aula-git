USE ecommerce_logico;
-- Fluxo completo dentro de uma transacao; ROLLBACK preserva a massa de dados.
START TRANSACTION;
INSERT INTO pedido(id_pedido,id_cliente,data_criacao,endereco_entrega_snapshot)
VALUES(2001,1,'2026-10-19 10:00:00','Rua Exemplo 1');
INSERT INTO item_pedido(id_pedido,numero_item,id_oferta,quantidade) VALUES(2001,1,1,1);
-- Referencia atual: 160.00, enquanto a compra antiga manteve 150.00.
UPDATE pedido SET status='CONFIRMADO' WHERE id_pedido=2001;
INSERT INTO pagamento VALUES(99,2001,1,1,160,'APROVADO','2026-10-19 11:00:00');
UPDATE pedido SET status='EM_PROCESSAMENTO' WHERE id_pedido=2001;
INSERT INTO entrega(id_entrega,id_pedido) VALUES(99,2001);
UPDATE entrega SET status='POSTADA',transportadora='Transportadora Teste',codigo_rastreio='EX-TESTE' WHERE id_entrega=99;
UPDATE entrega SET status='EM_TRANSITO' WHERE id_entrega=99;
UPDATE entrega SET status='ENTREGUE' WHERE id_entrega=99;
UPDATE pedido SET status='CONCLUIDO' WHERE id_pedido=2001;
SELECT id_pedido,status,valor_total,valor_aprovado,saldo_pendente FROM vw_saldo_pedido WHERE id_pedido=2001;
ROLLBACK;
SELECT COUNT(*) AS pedido_exemplo_persistido FROM pedido WHERE id_pedido=2001;
