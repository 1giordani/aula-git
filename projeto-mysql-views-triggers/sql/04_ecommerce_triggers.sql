CREATE DATABASE ecommerce_gatilhos CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE ecommerce_gatilhos;
CREATE TABLE usuarios (
 id INT PRIMARY KEY, nome VARCHAR(100) NOT NULL,email VARCHAR(150) NOT NULL UNIQUE,
 criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
CREATE TABLE usuarios_excluidos (
 arquivo_id INT PRIMARY KEY AUTO_INCREMENT,usuario_id INT NOT NULL,
 nome VARCHAR(100) NOT NULL,email VARCHAR(150) NOT NULL,
 criado_em TIMESTAMP NOT NULL,excluido_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 executado_por VARCHAR(300) NOT NULL
) ENGINE=InnoDB;
-- Sem FK do arquivo para usuarios: o historico deve sobreviver a exclusao.
CREATE TABLE pedidos (
 id INT PRIMARY KEY,usuario_id INT NULL,total DECIMAL(10,2) NOT NULL CHECK(total>0),
 FOREIGN KEY(usuario_id) REFERENCES usuarios(id) ON DELETE SET NULL
) ENGINE=InnoDB;
CREATE TABLE colaboradores (
 id INT PRIMARY KEY,nome VARCHAR(100) NOT NULL,
 salario_base DECIMAL(10,2) NOT NULL CHECK(salario_base>0)
) ENGINE=InnoDB;
CREATE TABLE historico_salarios (
 id INT PRIMARY KEY AUTO_INCREMENT,colaborador_id INT NOT NULL,
 salario_anterior DECIMAL(10,2) NOT NULL,salario_novo DECIMAL(10,2) NOT NULL,
 alterado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 executado_por VARCHAR(300) NOT NULL,
 FOREIGN KEY(colaborador_id) REFERENCES colaboradores(id)
) ENGINE=InnoDB;
DELIMITER $$
-- BEFORE DELETE e a sintaxe correta: nao existe BEFORE REMOVE no MySQL.
CREATE TRIGGER trg_usuarios_before_delete BEFORE DELETE ON usuarios FOR EACH ROW
BEGIN
 INSERT INTO usuarios_excluidos(usuario_id,nome,email,criado_em,executado_por)
 VALUES(OLD.id,OLD.nome,OLD.email,OLD.criado_em,USER());
END$$
-- Inclusao de colaborador: valida salario antes de gravar.
CREATE TRIGGER trg_colaboradores_before_insert BEFORE INSERT ON colaboradores FOR EACH ROW
BEGIN
 IF NEW.salario_base IS NULL OR NEW.salario_base<=0 THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Salario base deve ser positivo';
 END IF;
END$$
-- Atualizacao: valida e registra os valores antigo e novo apenas se mudarem.
CREATE TRIGGER trg_colaboradores_before_update BEFORE UPDATE ON colaboradores FOR EACH ROW
BEGIN
 IF NEW.salario_base IS NULL OR NEW.salario_base<=0 THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Salario base deve ser positivo';
 END IF;
 IF NOT(OLD.salario_base <=> NEW.salario_base) THEN
  INSERT INTO historico_salarios(colaborador_id,salario_anterior,salario_novo,executado_por)
  VALUES(OLD.id,OLD.salario_base,NEW.salario_base,USER());
 END IF;
END$$
DELIMITER ;
INSERT INTO usuarios(id,nome,email) VALUES
 (1,'Usuario Demonstracao','usuario@example.com'),(2,'Outra Conta','outra@example.com');
INSERT INTO pedidos VALUES(1,1,200.00);
INSERT INTO colaboradores VALUES(1,'Colaborador Demonstracao',3000.00);
