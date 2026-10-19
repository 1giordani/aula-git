CREATE DATABASE universidade_crud CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE universidade_crud;
CREATE TABLE alunos (
 id INT PRIMARY KEY AUTO_INCREMENT,nome VARCHAR(100) NOT NULL,
 email VARCHAR(150) NOT NULL,
 UNIQUE KEY uk_alunos_email(email)
) ENGINE=InnoDB;
INSERT INTO alunos(nome,email) VALUES('Aluno Demonstracao','aluno@example.com');
DELIMITER $$
CREATE PROCEDURE sp_manipular_aluno(
 IN p_acao TINYINT,IN p_id INT,IN p_nome VARCHAR(100),IN p_email VARCHAR(150)
)
BEGIN
 DECLARE v_id INT DEFAULT NULL;
 DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_id=NULL;
 DECLARE EXIT HANDLER FOR SQLEXCEPTION
 BEGIN
  ROLLBACK;
  RESIGNAL;
 END;
 -- A procedure e dona da transacao; chamar sem transacao externa aberta.
 START TRANSACTION;
 CASE p_acao
 WHEN 1 THEN
  SELECT id,nome,email FROM alunos WHERE p_id IS NULL OR id=p_id ORDER BY id;
 WHEN 2 THEN
  IF p_nome IS NULL OR CHAR_LENGTH(TRIM(p_nome))=0 OR
     p_email IS NULL OR CHAR_LENGTH(TRIM(p_email))=0 THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Nome e email sao obrigatorios';
  END IF;
  INSERT INTO alunos(nome,email) VALUES(TRIM(p_nome),TRIM(p_email));
  SELECT LAST_INSERT_ID() AS aluno_inserido;
 WHEN 3 THEN
  IF p_nome IS NULL OR CHAR_LENGTH(TRIM(p_nome))=0 OR
     p_email IS NULL OR CHAR_LENGTH(TRIM(p_email))=0 THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Nome e email sao obrigatorios';
  END IF;
  SELECT id INTO v_id FROM alunos WHERE id=p_id FOR UPDATE;
  IF v_id IS NULL THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Aluno nao encontrado';
  END IF;
  UPDATE alunos SET nome=TRIM(p_nome),email=TRIM(p_email) WHERE id=p_id;
 WHEN 4 THEN
  DELETE FROM alunos WHERE id=p_id;
  IF ROW_COUNT()=0 THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Aluno nao encontrado';
  END IF;
 ELSE
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Acao invalida: use 1,2,3 ou 4';
 END CASE;
 COMMIT;
END$$
DELIMITER ;
