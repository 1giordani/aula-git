USE ecommerce;
SELECT * FROM clientes ORDER BY id;
SELECT * FROM produtos ORDER BY id;
SELECT * FROM vw_resumo_pedidos ORDER BY id;
SELECT * FROM itens_pedido ORDER BY pedido_id,produto_id;
SELECT * FROM auditoria_estoque ORDER BY id;
SELECT * FROM logistica.centros_distribuicao;
SELECT ROUTINE_NAME,ROUTINE_TYPE FROM information_schema.ROUTINES
 WHERE ROUTINE_SCHEMA='ecommerce';
SELECT TRIGGER_NAME FROM information_schema.TRIGGERS WHERE TRIGGER_SCHEMA='ecommerce';
SELECT EVENT_NAME,STATUS FROM information_schema.EVENTS WHERE EVENT_SCHEMA='ecommerce';
