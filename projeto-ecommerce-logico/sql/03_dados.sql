USE ecommerce_logico;
-- Dados de demonstracao, sem referencia a pessoas ou empresas reais.
INSERT INTO cliente VALUES
(1,'PF','Cliente Ana','ana@example.com','11111111111','Ana Demonstracao',NULL,NULL),
(2,'PJ','Empresa Alfa','alfa@example.com',NULL,NULL,'99000000001001','Alfa Demonstracao Ltda'),
(3,'PF','Cliente Bruno','bruno@example.com','22222222222','Bruno Demonstracao',NULL,NULL),
(4,'PJ','Empresa Beta','beta@example.com',NULL,NULL,'99000000001002','Beta Demonstracao Ltda'),
(5,'PF','Cliente Eva','eva@example.com','33333333333','Eva Demonstracao',NULL,NULL);
INSERT INTO forma_pagamento VALUES
(1,1,'CARTAO','Cartao demonstrativo','token-ficticio-1'),(2,1,'PIX','PIX Ana',NULL),
(3,2,'BOLETO','Boleto Alfa',NULL),(4,4,'CARTAO','Cartao Beta','token-ficticio-4'),
(5,3,'PIX','PIX Bruno',NULL),(6,5,'PIX','PIX Eva',NULL);
INSERT INTO vendedor VALUES
(1,'Loja Plataforma','99000000000101','PLATAFORMA'),
(2,'Parceiro Multi','99000000000102','TERCEIRO'),
(3,'Loja Digital','99000000000103','TERCEIRO');
INSERT INTO fornecedor VALUES
(1,'Fabricante Demonstracao','99000000000201'),
(2,'Parceiro Multi','99000000000102'),
(3,'Distribuidora Demonstracao','99000000000203');
INSERT INTO produto VALUES
(1,'Teclado','Perifericos'),(2,'Mouse','Perifericos'),(3,'Monitor','Video'),
(4,'Cabo USB','Acessorios'),(5,'Webcam','Video');
INSERT INTO oferta VALUES
(1,1,1,150,TRUE),(2,2,1,80,TRUE),(3,3,2,900,TRUE),
(4,4,3,30,TRUE),(5,1,2,140,TRUE),(6,5,3,200,FALSE);
INSERT INTO fornecimento VALUES(1,1,'FAB-T'),(1,2,'FAB-M'),(2,1,'PAR-T'),(2,3,'PAR-V'),(3,4,'DIS-C');
INSERT INTO estoque VALUES(1,'Belo Horizonte'),(2,'Joao Monlevade'),(3,'Nova Lima');
INSERT INTO produto_estoque VALUES(1,1,20),(1,2,10),(2,1,30),(3,2,5),(4,1,100);
INSERT INTO pedido(id_pedido,id_cliente,data_criacao,endereco_entrega_snapshot,frete,desconto) VALUES
(1001,1,'2026-10-01 09:00:00','Rua Exemplo 1',20,10),
(1002,2,'2026-10-05 09:00:00','Rua Exemplo 2',30,0),
(1003,1,'2026-10-10 09:00:00','Rua Exemplo 1',10,0),
(1004,3,'2026-10-18 09:00:00','Rua Exemplo 3',0,0),
(1005,4,'2026-10-07 09:00:00','Rua Exemplo 4',5,0),
(1006,3,'2026-10-12 09:00:00','Rua Exemplo 3',0,20);
INSERT INTO item_pedido(id_pedido,numero_item,id_oferta,quantidade) VALUES
(1001,1,1,1),(1001,2,2,2),(1002,1,3,1),(1003,1,5,2),
(1005,1,4,3),(1006,1,4,2),(1006,2,2,1);
UPDATE pedido SET status='CONFIRMADO' WHERE id_pedido IN(1001,1002,1003,1005,1006);
INSERT INTO pagamento VALUES
(1,1001,1,1,200,'APROVADO','2026-10-02 10:00:00'),
(2,1001,2,1,120,'APROVADO','2026-10-02 10:05:00'),
(3,1002,3,2,930,'APROVADO','2026-10-06 10:00:00'),
(4,1003,2,1,100,'APROVADO','2026-10-11 10:00:00'),
(5,1003,1,1,190,'PENDENTE',NULL),
(6,1005,4,4,95,'RECUSADO',NULL),
(7,1006,5,3,60,'APROVADO','2026-10-13 10:00:00');
UPDATE pedido SET status='EM_PROCESSAMENTO' WHERE id_pedido IN(1001,1002);
INSERT INTO entrega(id_entrega,id_pedido) VALUES(1,1001),(2,1002);
UPDATE entrega SET status='POSTADA',transportadora='Transportadora Exemplo',codigo_rastreio='EX001' WHERE id_entrega=1;
UPDATE entrega SET status='EM_TRANSITO' WHERE id_entrega=1;
UPDATE entrega SET status='ENTREGUE' WHERE id_entrega=1;
UPDATE pedido SET status='CONCLUIDO' WHERE id_pedido=1001;
UPDATE entrega SET status='POSTADA',transportadora='Transportadora Exemplo',codigo_rastreio='EX002' WHERE id_entrega=2;
UPDATE entrega SET status='EM_TRANSITO' WHERE id_entrega=2;
UPDATE pedido SET status='CANCELADO' WHERE id_pedido=1005;
-- Novo preco de catalogo nao reescreve o valor praticado em compras anteriores.
UPDATE oferta SET preco_atual=160 WHERE id_oferta=1;
