-- Execute uma vez apos 04, em laboratorio. Para testes repetiveis use o Python.
USE ecommerce_gatilhos;
START TRANSACTION;
DELETE FROM usuarios WHERE id=1;
SELECT * FROM usuarios_excluidos;
SELECT * FROM pedidos; -- usuario_id fica NULL; pedido e preservado.
ROLLBACK;
-- Ambos, usuario e pedido, sao restaurados; arquivo da exclusao e desfeito.
SELECT * FROM usuarios;
SELECT * FROM usuarios_excluidos;
DELETE FROM usuarios WHERE id=1; -- arquivamento definitivo.
UPDATE colaboradores SET salario_base=3300 WHERE id=1;
SELECT * FROM usuarios_excluidos;
SELECT * FROM pedidos;
SELECT * FROM historico_salarios; -- 3000 -> 3300.
-- Execute individualmente; erros esperados:
-- INSERT INTO colaboradores VALUES(2,'Invalido',0);
-- UPDATE colaboradores SET salario_base=-1 WHERE id=1;
