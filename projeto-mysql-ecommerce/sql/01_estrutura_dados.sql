-- Ambiente didatico exclusivo; dados inteiramente ficticios.
-- Nao execute novamente para reiniciar um banco que ja contem seus dados.
CREATE DATABASE ecommerce CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
CREATE DATABASE logistica CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE ecommerce;
CREATE TABLE clientes (
 id INT PRIMARY KEY AUTO_INCREMENT,
 nome VARCHAR(100) NOT NULL,
 email VARCHAR(150) NOT NULL UNIQUE
) ENGINE=InnoDB;
CREATE TABLE produtos (
 id INT PRIMARY KEY AUTO_INCREMENT,
 nome VARCHAR(100) NOT NULL,
 preco DECIMAL(10,2) NOT NULL CHECK (preco > 0),
 estoque INT NOT NULL CHECK (estoque >= 0)
) ENGINE=InnoDB;
CREATE TABLE pedidos (
 id INT PRIMARY KEY AUTO_INCREMENT,
 cliente_id INT NOT NULL,
 criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 total DECIMAL(12,2) NOT NULL CHECK (total > 0),
 FOREIGN KEY (cliente_id) REFERENCES clientes(id)
) ENGINE=InnoDB;
CREATE TABLE itens_pedido (
 pedido_id INT NOT NULL,
 produto_id INT NOT NULL,
 quantidade INT NOT NULL CHECK (quantidade > 0),
 preco_unitario DECIMAL(10,2) NOT NULL CHECK (preco_unitario > 0),
 PRIMARY KEY (pedido_id, produto_id),
 FOREIGN KEY (pedido_id) REFERENCES pedidos(id),
 FOREIGN KEY (produto_id) REFERENCES produtos(id)
) ENGINE=InnoDB;
CREATE TABLE auditoria_estoque (
 id INT PRIMARY KEY AUTO_INCREMENT,
 produto_id INT NOT NULL,
 estoque_anterior INT NOT NULL,
 estoque_novo INT NOT NULL,
 alterado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY (produto_id) REFERENCES produtos(id)
) ENGINE=InnoDB;
INSERT INTO clientes (nome,email) VALUES
 ('Cliente Demonstracao','cliente@example.com'),('Cliente Teste','teste@example.com');
INSERT INTO produtos (nome,preco,estoque) VALUES ('Teclado',150.00,20),('Mouse',80.00,30);
USE logistica;
CREATE TABLE centros_distribuicao (
 id INT PRIMARY KEY AUTO_INCREMENT, nome VARCHAR(100) NOT NULL
) ENGINE=InnoDB;
INSERT INTO centros_distribuicao (nome) VALUES ('Centro Demonstracao');
