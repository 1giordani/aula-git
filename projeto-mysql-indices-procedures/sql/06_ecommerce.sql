CREATE DATABASE ecommerce_crud CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE ecommerce_crud;
CREATE TABLE produtos (
 id INT PRIMARY KEY AUTO_INCREMENT,nome VARCHAR(100) NOT NULL,
 preco DECIMAL(10,2) NOT NULL CHECK(preco>0),
 estoque INT NOT NULL CHECK(estoque>=0)
) ENGINE=InnoDB;
INSERT INTO produtos(nome,preco,estoque) VALUES('Teclado',150.00,20);
DELIMITER $$
CREATE PROCEDURE sp_manipular_produto(
 IN p_acao TINYINT,IN p_id INT,IN p_nome VARCHAR(100),
 IN p_preco DECIMAL(10,2),IN p_estoque INT
)
BEGIN
 DECLARE v_id INT DEFAULT NULL;
 DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_id=NULL;
 DECLARE EXIT HANDLER FOR SQLEXCEPTION
 BEGIN
  ROLLBACK;
  RESIGNAL;
 END;
 START TRANSACTION;
 CASE p_acao
 WHEN 1 THEN
  SELECT id,nome,preco,estoque FROM produtos WHERE p_id IS NULL OR id=p_id ORDER BY id;
 WHEN 2 THEN
  IF p_nome IS NULL OR CHAR_LENGTH(TRIM(p_nome))=0 OR
     p_preco IS NULL OR p_preco<=0 OR p_estoque IS NULL OR p_estoque<0 THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Informe nome, preco positivo e estoque nao negativo';
  END IF;
  INSERT INTO produtos(nome,preco,estoque) VALUES(TRIM(p_nome),p_preco,p_estoque);
  SELECT LAST_INSERT_ID() AS produto_inserido;
 WHEN 3 THEN
  IF p_nome IS NULL OR CHAR_LENGTH(TRIM(p_nome))=0 OR
     p_preco IS NULL OR p_preco<=0 OR p_estoque IS NULL OR p_estoque<0 THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Informe nome, preco positivo e estoque nao negativo';
  END IF;
  SELECT id INTO v_id FROM produtos WHERE id=p_id FOR UPDATE;
  IF v_id IS NULL THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Produto nao encontrado';
  END IF;
  UPDATE produtos SET nome=TRIM(p_nome),preco=p_preco,estoque=p_estoque WHERE id=p_id;
 WHEN 4 THEN
  DELETE FROM produtos WHERE id=p_id;
  IF ROW_COUNT()=0 THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Produto nao encontrado';
  END IF;
 ELSE
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Acao invalida: use 1,2,3 ou 4';
 END CASE;
 COMMIT;
END$$
DELIMITER ;
