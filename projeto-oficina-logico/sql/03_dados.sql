USE oficina_logica;
-- Dados inteiramente ficticios; datas fixas permitem reproduzir os resultados.
INSERT INTO cliente VALUES
(1,'Cliente Ana','31900000001','ana@example.com','Rua Exemplo 1'),
(2,'Cliente Bruno','31900000002','bruno@example.com','Rua Exemplo 2'),
(3,'Cliente Carla','31900000003','carla@example.com','Rua Exemplo 3'),
(4,'Cliente Diego','31900000004','diego@example.com','Rua Exemplo 4'),
(5,'Cliente Eva','31900000005','eva@example.com','Rua Exemplo 5');
INSERT INTO veiculo VALUES
(1,1,'AAA1A01','Toyota','Corolla',2020),(2,2,'AAA1A02','Chevrolet','Onix',2021),
(3,1,'AAA1A03','Honda','Civic',2019),(4,3,'AAA1A04','Volkswagen','Gol',2018),
(5,4,'AAA1A05','Fiat','Uno',2017),(6,5,'AAA1A06','Fiat','Argo',2022);
INSERT INTO equipe VALUES(1,'Equipe Freios'),(2,'Equipe Revisao'),(3,'Equipe em Formacao');
INSERT INTO mecanico VALUES
(1,'Mecanico A','Rua Oficina 1','Freios'),(2,'Mecanico B','Rua Oficina 2','Mecanica geral'),
(3,'Mecanica C','Rua Oficina 3','Injecao'),(4,'Mecanico D','Rua Oficina 4','Lubrificacao'),
(5,'Mecanica E','Rua Oficina 5','Eletrica');
INSERT INTO composicao_equipe VALUES
(1,1,'2026-01-01',NULL),(1,2,'2026-01-01',NULL),
(2,3,'2026-01-01',NULL),(2,4,'2026-01-01',NULL);
INSERT INTO servico VALUES
(1,'Troca de pastilhas','SERVICO',120),(2,'Diagnostico por hora','HORA',150),
(3,'Revisao periodica','SERVICO',250),(4,'Balanceamento','SERVICO',60);
INSERT INTO peca VALUES(1,'Pastilha',80),(2,'Filtro especial',200),(3,'Oleo - unidade',50),(4,'Lampada',20);
INSERT INTO ordem_servico(numero_os,id_cliente_solicitante,id_veiculo,id_equipe,data_emissao,data_prevista_conclusao,tipo_atendimento) VALUES
(1001,1,1,1,'2026-10-01','2026-10-05','REPARO'),
(1002,2,2,2,'2026-10-08','2026-10-15','REPARO'),
(1003,1,3,1,'2026-10-10','2026-10-22','REVISAO'),
(1004,3,4,2,'2026-10-18','2026-10-25','REVISAO'),
(1005,2,2,1,'2026-10-07','2026-10-08','REPARO'),
(1006,4,5,2,'2026-10-04','2026-10-10','REVISAO');
-- Os gatilhos copiam preco e unidade da referencia no momento da inclusao.
INSERT INTO servico_os(numero_os,id_servico,quantidade) VALUES
(1001,1,1),(1002,2,2),(1003,3,1),(1005,1,1),(1006,3,1),(1006,2,2);
INSERT INTO peca_os(numero_os,id_peca,quantidade) VALUES
(1001,1,2),(1002,2,1),(1003,3,4),(1006,3,4);
UPDATE ordem_servico SET status='AGUARDANDO_AUTORIZACAO' WHERE numero_os IN(1001,1002,1003,1005,1006);
INSERT INTO autorizacao VALUES
(1,1001,1,'AUTORIZADA','2026-10-02 10:00:00',280),
(2,1002,2,'AUTORIZADA','2026-10-09 10:00:00',500),
(3,1005,2,'RECUSADA','2026-10-07 10:00:00',120),
(4,1006,4,'AUTORIZADA','2026-10-05 10:00:00',750);
UPDATE ordem_servico SET status='AUTORIZADA' WHERE numero_os IN(1001,1002,1006);
UPDATE ordem_servico SET status='EM_EXECUCAO' WHERE numero_os IN(1001,1002,1006);
UPDATE ordem_servico SET status='CONCLUIDA',data_efetiva_conclusao='2026-10-04' WHERE numero_os=1001;
UPDATE ordem_servico SET status='CONCLUIDA',data_efetiva_conclusao='2026-10-11' WHERE numero_os=1006;
UPDATE ordem_servico SET status='CANCELADA' WHERE numero_os=1005;
-- Comprova que preco atual do catalogo nao altera valor historico de itens.
UPDATE servico SET valor_unitario_referencia=130 WHERE id_servico=1;
