USE ecommerce;
-- Execute os blocos de erro individualmente no Workbench.
CALL sp_registrar_pedido(1,1,2,FALSE);
-- Esperado apos 02_transacoes.sql: estoque 25, um pedido de 300.00.
SELECT * FROM vw_resumo_pedidos;
SELECT * FROM produtos;
-- Esperado: erro proposital e nenhuma mudanca persistida, incluindo auditoria.
CALL sp_registrar_pedido(1,1,3,TRUE);
-- Execute os SELECTs abaixo mesmo apos o erro anterior.
SELECT * FROM produtos;
SELECT * FROM vw_resumo_pedidos;
SELECT * FROM auditoria_estoque;
-- Mais casos negativos, cada um executado separadamente:
-- CALL sp_registrar_pedido(1,1,999,FALSE);
-- CALL sp_registrar_pedido(999,1,1,FALSE);
-- CALL sp_registrar_pedido(1,1,0,FALSE);
