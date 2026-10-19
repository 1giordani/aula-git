-- Controle identico nas duas procedures: 1 SELECT,2 INSERT,3 UPDATE,4 DELETE.
-- Use a mesma sessao para preservar @id e LAST_INSERT_ID().
USE universidade_crud;
CALL sp_manipular_aluno(1,NULL,NULL,NULL);
CALL sp_manipular_aluno(2,NULL,'Novo Aluno','novo@example.com');
SET @aluno_id=LAST_INSERT_ID();
CALL sp_manipular_aluno(3,@aluno_id,'Aluno Atualizado','atualizado@example.com');
CALL sp_manipular_aluno(1,@aluno_id,NULL,NULL);
CALL sp_manipular_aluno(4,@aluno_id,NULL,NULL);
CALL sp_manipular_aluno(1,NULL,NULL,NULL);
USE ecommerce_crud;
CALL sp_manipular_produto(1,NULL,NULL,NULL,NULL);
CALL sp_manipular_produto(2,NULL,'Mouse',80.00,30);
SET @produto_id=LAST_INSERT_ID();
CALL sp_manipular_produto(3,@produto_id,'Mouse Atualizado',90.00,25);
CALL sp_manipular_produto(1,@produto_id,NULL,NULL,NULL);
CALL sp_manipular_produto(4,@produto_id,NULL,NULL,NULL);
CALL sp_manipular_produto(1,NULL,NULL,NULL,NULL);
-- Erros propositais (execute individualmente):
-- CALL sp_manipular_produto(9,NULL,NULL,NULL,NULL);
-- CALL sp_manipular_produto(2,NULL,'Invalido',-1,0);
-- CALL universidade_crud.sp_manipular_aluno(4,999,NULL,NULL);
