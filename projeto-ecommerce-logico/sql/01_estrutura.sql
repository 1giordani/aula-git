-- MySQL 8.0.16+ / 8.4. Executar uma vez em laboratorio vazio.
CREATE DATABASE ecommerce_logico CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE ecommerce_logico;
-- Mapeamento EER: tabela unica para a especializacao total e exclusiva PF/PJ.
CREATE TABLE cliente (
 id_cliente INT UNSIGNED PRIMARY KEY,tipo_cliente ENUM('PF','PJ') NOT NULL,
 nome_exibicao VARCHAR(100) NOT NULL,email VARCHAR(150) NOT NULL UNIQUE,
 cpf CHAR(11) NULL,nome_completo VARCHAR(150) NULL,
 cnpj CHAR(14) NULL,razao_social VARCHAR(150) NULL,
 UNIQUE(cpf),UNIQUE(cnpj),CHECK(CHAR_LENGTH(TRIM(nome_exibicao))>0),
 CONSTRAINT ck_cliente_pf_pj CHECK(
 (tipo_cliente='PF' AND cpf IS NOT NULL AND CHAR_LENGTH(cpf)=11
 AND nome_completo IS NOT NULL AND CHAR_LENGTH(TRIM(nome_completo))>0
 AND cnpj IS NULL AND razao_social IS NULL)
 OR
 (tipo_cliente='PJ' AND cnpj IS NOT NULL AND CHAR_LENGTH(cnpj)=14
 AND razao_social IS NOT NULL AND CHAR_LENGTH(TRIM(razao_social))>0
 AND cpf IS NULL AND nome_completo IS NULL))
) ENGINE=InnoDB;
CREATE VIEW vw_cliente_pf AS SELECT id_cliente,cpf,nome_completo FROM cliente WHERE tipo_cliente='PF';
CREATE VIEW vw_cliente_pj AS SELECT id_cliente,cnpj,razao_social FROM cliente WHERE tipo_cliente='PJ';
CREATE TABLE forma_pagamento (
 id_forma INT UNSIGNED PRIMARY KEY,id_cliente INT UNSIGNED NOT NULL,
 tipo ENUM('CARTAO','PIX','BOLETO') NOT NULL,apelido VARCHAR(80) NOT NULL,
 referencia_provedor VARCHAR(100) NULL,
 UNIQUE(id_forma,id_cliente),FOREIGN KEY(id_cliente) REFERENCES cliente(id_cliente)
) ENGINE=InnoDB;
CREATE TABLE vendedor (
 id_vendedor INT UNSIGNED PRIMARY KEY,nome VARCHAR(120) NOT NULL,
 cnpj CHAR(14) NOT NULL UNIQUE,tipo ENUM('PLATAFORMA','TERCEIRO') NOT NULL,
 CHECK(CHAR_LENGTH(cnpj)=14)
) ENGINE=InnoDB;
CREATE TABLE fornecedor (
 id_fornecedor INT UNSIGNED PRIMARY KEY,razao_social VARCHAR(120) NOT NULL,
 cnpj CHAR(14) NOT NULL UNIQUE,CHECK(CHAR_LENGTH(cnpj)=14)
) ENGINE=InnoDB;
CREATE TABLE produto (
 id_produto INT UNSIGNED PRIMARY KEY,descricao VARCHAR(120) NOT NULL,categoria VARCHAR(80) NOT NULL
) ENGINE=InnoDB;
CREATE TABLE oferta (
 id_oferta INT UNSIGNED PRIMARY KEY,id_produto INT UNSIGNED NOT NULL,id_vendedor INT UNSIGNED NOT NULL,
 preco_atual DECIMAL(10,2) NOT NULL,ativo BOOLEAN NOT NULL DEFAULT TRUE,
 UNIQUE(id_produto,id_vendedor),CHECK(preco_atual>0),CHECK(ativo IN(0,1)),
 FOREIGN KEY(id_produto) REFERENCES produto(id_produto),
 FOREIGN KEY(id_vendedor) REFERENCES vendedor(id_vendedor)
) ENGINE=InnoDB;
CREATE TABLE fornecimento (
 id_fornecedor INT UNSIGNED NOT NULL,id_produto INT UNSIGNED NOT NULL,
 referencia_fornecedor VARCHAR(80) NULL,PRIMARY KEY(id_fornecedor,id_produto),
 FOREIGN KEY(id_fornecedor) REFERENCES fornecedor(id_fornecedor),
 FOREIGN KEY(id_produto) REFERENCES produto(id_produto)
) ENGINE=InnoDB;
CREATE TABLE estoque (
 id_estoque INT UNSIGNED PRIMARY KEY,localizacao VARCHAR(120) NOT NULL
) ENGINE=InnoDB;
CREATE TABLE produto_estoque (
 id_produto INT UNSIGNED NOT NULL,id_estoque INT UNSIGNED NOT NULL,
 quantidade_disponivel INT NOT NULL,PRIMARY KEY(id_produto,id_estoque),
 CHECK(quantidade_disponivel>=0),
 FOREIGN KEY(id_produto) REFERENCES produto(id_produto),
 FOREIGN KEY(id_estoque) REFERENCES estoque(id_estoque)
) ENGINE=InnoDB;
CREATE TABLE pedido (
 id_pedido INT UNSIGNED PRIMARY KEY,id_cliente INT UNSIGNED NOT NULL,
 data_criacao DATETIME NOT NULL,
 status ENUM('RASCUNHO','CONFIRMADO','EM_PROCESSAMENTO','CONCLUIDO','CANCELADO') NOT NULL DEFAULT 'RASCUNHO',
 endereco_entrega_snapshot VARCHAR(250) NOT NULL,
 frete DECIMAL(10,2) NOT NULL DEFAULT 0,desconto DECIMAL(10,2) NOT NULL DEFAULT 0,
 CHECK(frete>=0),CHECK(desconto>=0),UNIQUE(id_pedido,id_cliente),
 FOREIGN KEY(id_cliente) REFERENCES cliente(id_cliente)
) ENGINE=InnoDB;
CREATE TABLE item_pedido (
 id_pedido INT UNSIGNED NOT NULL,numero_item SMALLINT UNSIGNED NOT NULL,
 id_oferta INT UNSIGNED NOT NULL,quantidade INT NOT NULL,
 preco_unitario_praticado DECIMAL(10,2) NOT NULL DEFAULT 0,
 subtotal DECIMAL(14,2) GENERATED ALWAYS AS(quantidade*preco_unitario_praticado) STORED,
 PRIMARY KEY(id_pedido,numero_item),CHECK(quantidade>0),CHECK(preco_unitario_praticado>0),
 FOREIGN KEY(id_pedido) REFERENCES pedido(id_pedido),FOREIGN KEY(id_oferta) REFERENCES oferta(id_oferta)
) ENGINE=InnoDB;
CREATE TABLE pagamento (
 id_pagamento INT UNSIGNED PRIMARY KEY,id_pedido INT UNSIGNED NOT NULL,
 id_forma INT UNSIGNED NOT NULL,id_cliente INT UNSIGNED NOT NULL,
 valor DECIMAL(14,2) NOT NULL,
 status ENUM('PENDENTE','APROVADO','RECUSADO','CANCELADO') NOT NULL,
 data_pagamento DATETIME NULL,CHECK(valor>0),
 CHECK((status='APROVADO' AND data_pagamento IS NOT NULL) OR (status<>'APROVADO' AND data_pagamento IS NULL)),
 FOREIGN KEY(id_pedido,id_cliente) REFERENCES pedido(id_pedido,id_cliente),
 FOREIGN KEY(id_forma,id_cliente) REFERENCES forma_pagamento(id_forma,id_cliente)
) ENGINE=InnoDB;
CREATE TABLE entrega (
 id_entrega INT UNSIGNED PRIMARY KEY,id_pedido INT UNSIGNED NOT NULL UNIQUE,
 status ENUM('PREPARANDO','POSTADA','EM_TRANSITO','ENTREGUE','CANCELADA') NOT NULL DEFAULT 'PREPARANDO',
 transportadora VARCHAR(80) NULL,codigo_rastreio VARCHAR(80) NULL,
 UNIQUE(transportadora,codigo_rastreio),
 CHECK(status IN('PREPARANDO','CANCELADA') OR
 (transportadora IS NOT NULL AND CHAR_LENGTH(TRIM(transportadora))>0
 AND codigo_rastreio IS NOT NULL AND CHAR_LENGTH(TRIM(codigo_rastreio))>0)),
 FOREIGN KEY(id_pedido) REFERENCES pedido(id_pedido)
) ENGINE=InnoDB;
CREATE VIEW vw_total_pedido AS
SELECT p.*,COALESCE(i.valor_produtos,0) AS valor_produtos,
 CAST(COALESCE(i.valor_produtos,0)+p.frete-p.desconto AS DECIMAL(14,2)) AS valor_total
FROM pedido p LEFT JOIN(
 SELECT id_pedido,SUM(subtotal) valor_produtos FROM item_pedido GROUP BY id_pedido
) i USING(id_pedido);
CREATE VIEW vw_saldo_pedido AS
SELECT t.*,COALESCE(a.valor_aprovado,0) AS valor_aprovado,
 CAST(GREATEST(t.valor_total-COALESCE(a.valor_aprovado,0),0) AS DECIMAL(14,2)) AS saldo_pendente
FROM vw_total_pedido t LEFT JOIN(
 SELECT id_pedido,SUM(valor) AS valor_aprovado FROM pagamento WHERE status='APROVADO' GROUP BY id_pedido
) a USING(id_pedido);
