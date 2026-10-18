-- Modelo proprio, dados ficticios. Execute uma vez em laboratorio vazio.
CREATE DATABASE empresa_views CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE empresa_views;
CREATE TABLE departamentos (
 id INT PRIMARY KEY, nome VARCHAR(80) NOT NULL, gerente_id INT NULL
) ENGINE=InnoDB;
CREATE TABLE localidades_departamento (
 departamento_id INT NOT NULL, localidade VARCHAR(80) NOT NULL,
 PRIMARY KEY(departamento_id,localidade),
 FOREIGN KEY(departamento_id) REFERENCES departamentos(id)
) ENGINE=InnoDB;
CREATE TABLE empregados (
 id INT PRIMARY KEY, nome VARCHAR(100) NOT NULL,
 departamento_id INT NOT NULL, localidade VARCHAR(80) NOT NULL,
 salario DECIMAL(10,2) NOT NULL CHECK(salario>0),
 FOREIGN KEY(departamento_id,localidade)
 REFERENCES localidades_departamento(departamento_id,localidade)
) ENGINE=InnoDB;
ALTER TABLE departamentos ADD CONSTRAINT fk_gerente
 FOREIGN KEY(gerente_id) REFERENCES empregados(id);
CREATE TABLE projetos (
 id INT PRIMARY KEY, nome VARCHAR(100) NOT NULL, departamento_id INT NOT NULL,
 FOREIGN KEY(departamento_id) REFERENCES departamentos(id)
) ENGINE=InnoDB;
CREATE TABLE alocacoes (
 empregado_id INT NOT NULL, projeto_id INT NOT NULL,
 PRIMARY KEY(empregado_id,projeto_id),
 FOREIGN KEY(empregado_id) REFERENCES empregados(id),
 FOREIGN KEY(projeto_id) REFERENCES projetos(id)
) ENGINE=InnoDB;
CREATE TABLE dependentes (
 id INT PRIMARY KEY, empregado_id INT NOT NULL, nome VARCHAR(100) NOT NULL,
 FOREIGN KEY(empregado_id) REFERENCES empregados(id)
) ENGINE=InnoDB;
INSERT INTO departamentos VALUES (1,'Tecnologia',NULL),(2,'Operacoes',NULL),(3,'Pesquisa',NULL);
INSERT INTO localidades_departamento VALUES
 (1,'Belo Horizonte'),(1,'Nova Lima'),(2,'Joao Monlevade'),(3,'Itabira');
INSERT INTO empregados VALUES
 (1,'Ana',1,'Belo Horizonte',6000),(2,'Bruno',1,'Belo Horizonte',3500),
 (3,'Carla',2,'Joao Monlevade',6500),(4,'Diego',2,'Joao Monlevade',3200),
 (5,'Eva',1,'Nova Lima',4000);
UPDATE departamentos SET gerente_id=1 WHERE id=1;
UPDATE departamentos SET gerente_id=3 WHERE id=2;
INSERT INTO projetos VALUES (1,'Portal',1),(2,'Automacao',2),(3,'Pesquisa Piloto',3);
INSERT INTO alocacoes VALUES (1,1),(2,1),(4,1),(2,2);
INSERT INTO dependentes VALUES (1,1,'Dependente A'),(2,1,'Dependente B'),
 (3,2,'Dependente C'),(4,3,'Dependente D');
