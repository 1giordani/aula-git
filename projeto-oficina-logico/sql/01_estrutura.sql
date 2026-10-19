-- MySQL 8.0.16+ / 8.4. Execute uma vez em servidor de laboratorio.
CREATE DATABASE oficina_logica CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE oficina_logica;
CREATE TABLE cliente (
 id_cliente INT UNSIGNED PRIMARY KEY,nome VARCHAR(100) NOT NULL,
 telefone VARCHAR(20),email VARCHAR(150),endereco VARCHAR(200) NOT NULL
) ENGINE=InnoDB;
CREATE TABLE veiculo (
 id_veiculo INT UNSIGNED PRIMARY KEY,id_cliente_atual INT UNSIGNED NOT NULL,
 placa CHAR(7) NOT NULL,marca VARCHAR(50) NOT NULL,modelo VARCHAR(80) NOT NULL,
 ano SMALLINT UNSIGNED NOT NULL,
 CONSTRAINT uk_veiculo_placa UNIQUE(placa),
 CONSTRAINT ck_veiculo_ano CHECK(ano BETWEEN 1900 AND 2100),
 CONSTRAINT fk_veiculo_cliente FOREIGN KEY(id_cliente_atual) REFERENCES cliente(id_cliente)
) ENGINE=InnoDB;
CREATE TABLE equipe (
 id_equipe INT UNSIGNED PRIMARY KEY,nome_equipe VARCHAR(100) NOT NULL
) ENGINE=InnoDB;
CREATE TABLE mecanico (
 codigo_mecanico INT UNSIGNED PRIMARY KEY,nome VARCHAR(100) NOT NULL,
 endereco VARCHAR(200) NOT NULL,especialidade VARCHAR(100) NOT NULL
) ENGINE=InnoDB;
CREATE TABLE composicao_equipe (
 id_equipe INT UNSIGNED NOT NULL,codigo_mecanico INT UNSIGNED NOT NULL,
 data_inicio DATE NOT NULL,data_fim DATE NULL,
 PRIMARY KEY(id_equipe,codigo_mecanico,data_inicio),
 CONSTRAINT ck_composicao_datas CHECK(data_fim IS NULL OR data_fim>=data_inicio),
 FOREIGN KEY(id_equipe) REFERENCES equipe(id_equipe),
 FOREIGN KEY(codigo_mecanico) REFERENCES mecanico(codigo_mecanico)
) ENGINE=InnoDB;
CREATE TABLE ordem_servico (
 numero_os INT UNSIGNED PRIMARY KEY,
 id_cliente_solicitante INT UNSIGNED NOT NULL,
 id_veiculo INT UNSIGNED NOT NULL,id_equipe INT UNSIGNED NOT NULL,
 data_emissao DATE NOT NULL,data_prevista_conclusao DATE NOT NULL,
 data_efetiva_conclusao DATE NULL,
 tipo_atendimento ENUM('REPARO','REVISAO') NOT NULL,
 status ENUM('EM_AVALIACAO','AGUARDANDO_AUTORIZACAO','AUTORIZADA','EM_EXECUCAO','CONCLUIDA','CANCELADA') NOT NULL DEFAULT 'EM_AVALIACAO',
 -- Total da OS e derivado na view, pois coluna gerada nao pode somar outras tabelas.
 CONSTRAINT uk_os_cliente UNIQUE(numero_os,id_cliente_solicitante),
 CONSTRAINT ck_os_previsao CHECK(data_prevista_conclusao>=data_emissao),
 CONSTRAINT ck_os_conclusao CHECK(
  (status='CONCLUIDA' AND data_efetiva_conclusao IS NOT NULL AND data_efetiva_conclusao>=data_emissao)
  OR (status<>'CONCLUIDA' AND data_efetiva_conclusao IS NULL)),
 FOREIGN KEY(id_cliente_solicitante) REFERENCES cliente(id_cliente),
 FOREIGN KEY(id_veiculo) REFERENCES veiculo(id_veiculo),
 FOREIGN KEY(id_equipe) REFERENCES equipe(id_equipe),
 INDEX idx_os_status_previsao(status,data_prevista_conclusao)
) ENGINE=InnoDB;
CREATE TABLE servico (
 id_servico INT UNSIGNED PRIMARY KEY,descricao VARCHAR(150) NOT NULL,
 unidade_cobranca ENUM('HORA','SERVICO') NOT NULL,
 valor_unitario_referencia DECIMAL(10,2) NOT NULL,
 CHECK(valor_unitario_referencia>=0)
) ENGINE=InnoDB;
CREATE TABLE peca (
 id_peca INT UNSIGNED PRIMARY KEY,descricao VARCHAR(150) NOT NULL,
 valor_unitario_referencia DECIMAL(10,2) NOT NULL,
 CHECK(valor_unitario_referencia>=0)
) ENGINE=InnoDB;
CREATE TABLE servico_os (
 numero_os INT UNSIGNED NOT NULL,id_servico INT UNSIGNED NOT NULL,
 quantidade DECIMAL(8,2) NOT NULL,
 unidade_aplicada ENUM('HORA','SERVICO') NOT NULL DEFAULT 'SERVICO',
 valor_unitario_aplicado DECIMAL(10,2) NOT NULL DEFAULT 0,
 subtotal DECIMAL(14,2) GENERATED ALWAYS AS (ROUND(quantidade*valor_unitario_aplicado,2)) STORED,
 PRIMARY KEY(numero_os,id_servico),
 CHECK(quantidade>0),CHECK(valor_unitario_aplicado>=0),
 CHECK(unidade_aplicada='HORA' OR quantidade=FLOOR(quantidade)),
 FOREIGN KEY(numero_os) REFERENCES ordem_servico(numero_os),
 FOREIGN KEY(id_servico) REFERENCES servico(id_servico)
) ENGINE=InnoDB;
CREATE TABLE peca_os (
 numero_os INT UNSIGNED NOT NULL,id_peca INT UNSIGNED NOT NULL,
 quantidade INT UNSIGNED NOT NULL,
 valor_unitario_aplicado DECIMAL(10,2) NOT NULL DEFAULT 0,
 subtotal DECIMAL(14,2) GENERATED ALWAYS AS (quantidade*valor_unitario_aplicado) STORED,
 PRIMARY KEY(numero_os,id_peca),CHECK(quantidade>0),CHECK(valor_unitario_aplicado>=0),
 FOREIGN KEY(numero_os) REFERENCES ordem_servico(numero_os),
 FOREIGN KEY(id_peca) REFERENCES peca(id_peca)
) ENGINE=InnoDB;
CREATE TABLE autorizacao (
 id_autorizacao INT UNSIGNED PRIMARY KEY,numero_os INT UNSIGNED NOT NULL,
 id_cliente INT UNSIGNED NOT NULL,
 decisao ENUM('AUTORIZADA','RECUSADA') NOT NULL,
 data_decisao DATETIME NOT NULL,valor_orcado DECIMAL(14,2) NOT NULL,
 UNIQUE(numero_os),CHECK(valor_orcado>=0),
 -- FK composta impede decisao de cliente diferente do solicitante historico.
 FOREIGN KEY(numero_os,id_cliente) REFERENCES ordem_servico(numero_os,id_cliente_solicitante),
 FOREIGN KEY(id_cliente) REFERENCES cliente(id_cliente)
) ENGINE=InnoDB;
CREATE VIEW vw_total_os AS
SELECT os.*,
 COALESCE(s.total_servicos,0) AS total_servicos,
 COALESCE(p.total_pecas,0) AS total_pecas,
 CAST(COALESCE(s.total_servicos,0)+COALESCE(p.total_pecas,0) AS DECIMAL(14,2)) AS valor_total
FROM ordem_servico os
LEFT JOIN (SELECT numero_os,SUM(subtotal) total_servicos FROM servico_os GROUP BY numero_os) s USING(numero_os)
LEFT JOIN (SELECT numero_os,SUM(subtotal) total_pecas FROM peca_os GROUP BY numero_os) p USING(numero_os);
-- Cada grupo e agregado ANTES da juncao; evita multiplicar totais de servicos e pecas.
