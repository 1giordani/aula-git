USE oficina_logica;
-- Exemplo independente: transacao concluida com ROLLBACK para nao alterar a massa.
START TRANSACTION;
INSERT INTO ordem_servico(numero_os,id_cliente_solicitante,id_veiculo,id_equipe,data_emissao,data_prevista_conclusao,tipo_atendimento)
VALUES(2001,1,1,1,'2026-10-19','2026-10-23','REPARO');
INSERT INTO servico_os(numero_os,id_servico,quantidade) VALUES(2001,1,1);
INSERT INTO peca_os(numero_os,id_peca,quantidade) VALUES(2001,1,2);
-- A referencia atual de servico 1 ja e 130; total esperado = 130 + 160 = 290.
SELECT numero_os,total_servicos,total_pecas,valor_total FROM vw_total_os WHERE numero_os=2001;
UPDATE ordem_servico SET status='AGUARDANDO_AUTORIZACAO' WHERE numero_os=2001;
INSERT INTO autorizacao VALUES(99,2001,1,'AUTORIZADA','2026-10-19 15:00:00',290);
UPDATE ordem_servico SET status='AUTORIZADA' WHERE numero_os=2001;
UPDATE ordem_servico SET status='EM_EXECUCAO' WHERE numero_os=2001;
UPDATE ordem_servico SET status='CONCLUIDA',data_efetiva_conclusao='2026-10-21' WHERE numero_os=2001;
SELECT numero_os,status,valor_total FROM vw_total_os WHERE numero_os=2001;
ROLLBACK;
-- Deve retornar 0; os itens e a autorizacao tambem sao desfeitos.
SELECT COUNT(*) AS os_exemplo_persistida FROM ordem_servico WHERE numero_os=2001;
