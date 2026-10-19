-- Esquema proprio com dados ficticios; executar uma vez em laboratorio.
CREATE DATABASE company_indices CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE company_indices;
CREATE TABLE departamentos (
 id INT PRIMARY KEY,nome VARCHAR(100) NOT NULL
) ENGINE=InnoDB;
CREATE TABLE localidades_departamento (
 departamento_id INT NOT NULL,cidade VARCHAR(100) NOT NULL,
 PRIMARY KEY(departamento_id,cidade),
 FOREIGN KEY(departamento_id) REFERENCES departamentos(id)
) ENGINE=InnoDB;
CREATE TABLE empregados (
 id INT PRIMARY KEY,nome VARCHAR(100) NOT NULL,departamento_id INT NOT NULL,
 salario DECIMAL(10,2) NOT NULL CHECK(salario>0),
 -- Indice inicial necessario a FK; sera substituido pelo composto.
 INDEX idx_empregados_departamento(departamento_id),
 FOREIGN KEY(departamento_id) REFERENCES departamentos(id)
) ENGINE=InnoDB;
INSERT INTO departamentos VALUES(1,'Tecnologia'),(2,'Operacoes'),(3,'Financeiro'),(4,'Pesquisa');
INSERT INTO localidades_departamento VALUES
 (1,'Belo Horizonte'),(1,'Nova Lima'),(2,'Joao Monlevade'),(3,'Belo Horizonte'),(4,'Itabira');
INSERT INTO empregados VALUES
 (1,'Ana',1,6000),(2,'Bruno',1,3500),(3,'Carla',1,5000),
 (4,'Diego',2,4000),(5,'Eva',2,4500),(6,'Fabio',2,3800),(7,'Gabriela',3,4200);
