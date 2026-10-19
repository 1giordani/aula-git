USE oficina_logica;
DELIMITER $$
CREATE TRIGGER trg_os_bi BEFORE INSERT ON ordem_servico FOR EACH ROW
BEGIN
 DECLARE v_cliente INT UNSIGNED;
 DECLARE v_equipe INT UNSIGNED;
 SELECT id_cliente_atual INTO v_cliente FROM veiculo WHERE id_veiculo=NEW.id_veiculo;
 SELECT id_equipe INTO v_equipe FROM equipe WHERE id_equipe=NEW.id_equipe FOR UPDATE;
 IF v_cliente IS NULL OR v_cliente<>NEW.id_cliente_solicitante THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Solicitante deve ser cliente atual do veiculo na abertura';
 END IF;
 IF NEW.status<>'EM_AVALIACAO' THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='OS deve iniciar em avaliacao';
 END IF;
 IF NOT EXISTS(SELECT 1 FROM composicao_equipe WHERE id_equipe=NEW.id_equipe
  AND data_inicio<=NEW.data_emissao AND (data_fim IS NULL OR data_fim>=NEW.data_emissao)) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Equipe precisa de mecanico ativo na emissao';
 END IF;
END$$
CREATE TRIGGER trg_os_bu BEFORE UPDATE ON ordem_servico FOR EACH ROW
BEGIN
 IF NEW.numero_os<>OLD.numero_os OR NEW.id_cliente_solicitante<>OLD.id_cliente_solicitante
  OR NEW.id_veiculo<>OLD.id_veiculo OR NEW.id_equipe<>OLD.id_equipe
  OR NEW.data_emissao<>OLD.data_emissao OR NEW.tipo_atendimento<>OLD.tipo_atendimento THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Identificacao, solicitante e equipe da OS sao imutaveis';
 END IF;
 IF NEW.status<>OLD.status AND NOT(
  (OLD.status='EM_AVALIACAO' AND NEW.status IN('AGUARDANDO_AUTORIZACAO','CANCELADA')) OR
  (OLD.status='AGUARDANDO_AUTORIZACAO' AND NEW.status IN('AUTORIZADA','CANCELADA')) OR
  (OLD.status='AUTORIZADA' AND NEW.status IN('EM_EXECUCAO','CANCELADA')) OR
  (OLD.status='EM_EXECUCAO' AND NEW.status IN('CONCLUIDA','CANCELADA'))
 ) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Transicao de status invalida';
 END IF;
 IF NEW.status='AGUARDANDO_AUTORIZACAO' AND NOT EXISTS(
  SELECT 1 FROM servico_os WHERE numero_os=NEW.numero_os) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Orcamento precisa de pelo menos um servico';
 END IF;
 IF NEW.status IN('AUTORIZADA','EM_EXECUCAO','CONCLUIDA') AND NOT EXISTS(
  SELECT 1 FROM autorizacao WHERE numero_os=NEW.numero_os AND decisao='AUTORIZADA') THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Execucao depende de autorizacao favoravel';
 END IF;
END$$
CREATE TRIGGER trg_autorizacao_bi BEFORE INSERT ON autorizacao FOR EACH ROW
BEGIN
 DECLARE v_status VARCHAR(30); DECLARE v_emissao DATE; DECLARE v_total DECIMAL(14,2);
 SELECT status,data_emissao INTO v_status,v_emissao FROM ordem_servico
 WHERE numero_os=NEW.numero_os FOR UPDATE;
 IF v_status IS NULL OR v_status<>'AGUARDANDO_AUTORIZACAO' THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Decisao exige OS aguardando autorizacao';
 END IF;
 SELECT valor_total INTO v_total FROM vw_total_os WHERE numero_os=NEW.numero_os;
 IF NEW.valor_orcado<>v_total OR NEW.data_decisao<v_emissao THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Valor ou data da decisao invalido';
 END IF;
END$$
CREATE TRIGGER trg_autorizacao_bu BEFORE UPDATE ON autorizacao FOR EACH ROW
BEGIN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Decisao historica nao pode ser alterada';
END$$
CREATE TRIGGER trg_autorizacao_bd BEFORE DELETE ON autorizacao FOR EACH ROW
BEGIN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Decisao historica nao pode ser excluida';
END$$
CREATE TRIGGER trg_servico_os_bi BEFORE INSERT ON servico_os FOR EACH ROW
BEGIN
 DECLARE v_status VARCHAR(30);
 DECLARE v_preco DECIMAL(10,2);
 DECLARE v_unidade VARCHAR(10);
 SELECT status INTO v_status FROM ordem_servico WHERE numero_os=NEW.numero_os FOR UPDATE;
 IF v_status IS NULL OR v_status<>'EM_AVALIACAO' THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Itens so podem mudar durante avaliacao';
 END IF;
 SELECT valor_unitario_referencia,unidade_cobranca INTO v_preco,v_unidade FROM servico WHERE id_servico=NEW.id_servico;
 SET NEW.unidade_aplicada=v_unidade;
 IF v_preco IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Referencia inexistente'; END IF;
 SET NEW.valor_unitario_aplicado=v_preco;
END$$
CREATE TRIGGER trg_servico_os_bu BEFORE UPDATE ON servico_os FOR EACH ROW
BEGIN
 DECLARE v_status VARCHAR(30);
 DECLARE v_preco DECIMAL(10,2);
 DECLARE v_unidade VARCHAR(10);
 SELECT status INTO v_status FROM ordem_servico WHERE numero_os=NEW.numero_os FOR UPDATE;
 IF v_status IS NULL OR v_status<>'EM_AVALIACAO' THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Itens so podem mudar durante avaliacao';
 END IF;
 IF NEW.numero_os<>OLD.numero_os OR NEW.id_servico<>OLD.id_servico THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Chave do item e imutavel'; END IF;
 SET NEW.valor_unitario_aplicado=OLD.valor_unitario_aplicado;
 SET NEW.unidade_aplicada=OLD.unidade_aplicada;
END$$
CREATE TRIGGER trg_servico_os_bd BEFORE DELETE ON servico_os FOR EACH ROW
BEGIN
 DECLARE v_status VARCHAR(30);
 DECLARE v_preco DECIMAL(10,2);
 DECLARE v_unidade VARCHAR(10);
 SELECT status INTO v_status FROM ordem_servico WHERE numero_os=OLD.numero_os FOR UPDATE;
 IF v_status IS NULL OR v_status<>'EM_AVALIACAO' THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Itens so podem mudar durante avaliacao';
 END IF;
END$$
CREATE TRIGGER trg_peca_os_bi BEFORE INSERT ON peca_os FOR EACH ROW
BEGIN
 DECLARE v_status VARCHAR(30);
 DECLARE v_preco DECIMAL(10,2);
 DECLARE v_unidade VARCHAR(10);
 SELECT status INTO v_status FROM ordem_servico WHERE numero_os=NEW.numero_os FOR UPDATE;
 IF v_status IS NULL OR v_status<>'EM_AVALIACAO' THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Itens so podem mudar durante avaliacao';
 END IF;
 SELECT valor_unitario_referencia INTO v_preco FROM peca WHERE id_peca=NEW.id_peca;
 IF v_preco IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Referencia inexistente'; END IF;
 SET NEW.valor_unitario_aplicado=v_preco;
END$$
CREATE TRIGGER trg_peca_os_bu BEFORE UPDATE ON peca_os FOR EACH ROW
BEGIN
 DECLARE v_status VARCHAR(30);
 DECLARE v_preco DECIMAL(10,2);
 DECLARE v_unidade VARCHAR(10);
 SELECT status INTO v_status FROM ordem_servico WHERE numero_os=NEW.numero_os FOR UPDATE;
 IF v_status IS NULL OR v_status<>'EM_AVALIACAO' THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Itens so podem mudar durante avaliacao';
 END IF;
 IF NEW.numero_os<>OLD.numero_os OR NEW.id_peca<>OLD.id_peca THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Chave do item e imutavel'; END IF;
 SET NEW.valor_unitario_aplicado=OLD.valor_unitario_aplicado;
END$$
CREATE TRIGGER trg_peca_os_bd BEFORE DELETE ON peca_os FOR EACH ROW
BEGIN
 DECLARE v_status VARCHAR(30);
 DECLARE v_preco DECIMAL(10,2);
 DECLARE v_unidade VARCHAR(10);
 SELECT status INTO v_status FROM ordem_servico WHERE numero_os=OLD.numero_os FOR UPDATE;
 IF v_status IS NULL OR v_status<>'EM_AVALIACAO' THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Itens so podem mudar durante avaliacao';
 END IF;
END$$
CREATE TRIGGER trg_composicao_bi BEFORE INSERT ON composicao_equipe FOR EACH ROW
BEGIN
 DECLARE v_id INT UNSIGNED;
 SELECT id_equipe INTO v_id FROM equipe WHERE id_equipe=NEW.id_equipe FOR UPDATE;
 IF EXISTS(SELECT 1 FROM ordem_servico WHERE id_equipe=NEW.id_equipe AND status NOT IN('CONCLUIDA','CANCELADA')) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Composicao da equipe bloqueada enquanto houver OS aberta';
 END IF;
 IF EXISTS(SELECT 1 FROM composicao_equipe WHERE id_equipe=NEW.id_equipe AND codigo_mecanico=NEW.codigo_mecanico
 AND data_inicio<=COALESCE(NEW.data_fim,'9999-12-31') AND COALESCE(data_fim,'9999-12-31')>=NEW.data_inicio) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Periodos de participacao nao podem sobrepor';
 END IF;
END$$
CREATE TRIGGER trg_composicao_bu BEFORE UPDATE ON composicao_equipe FOR EACH ROW
BEGIN
 DECLARE v_id INT UNSIGNED;
 SELECT id_equipe INTO v_id FROM equipe WHERE id_equipe=NEW.id_equipe FOR UPDATE;
 IF EXISTS(SELECT 1 FROM ordem_servico WHERE id_equipe=NEW.id_equipe AND status NOT IN('CONCLUIDA','CANCELADA')) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Composicao da equipe bloqueada enquanto houver OS aberta';
 END IF;
 IF NEW.id_equipe<>OLD.id_equipe OR NEW.codigo_mecanico<>OLD.codigo_mecanico OR NEW.data_inicio<>OLD.data_inicio THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Chave da participacao e imutavel'; END IF;
 IF EXISTS(SELECT 1 FROM composicao_equipe WHERE id_equipe=NEW.id_equipe AND codigo_mecanico=NEW.codigo_mecanico
 AND data_inicio<=COALESCE(NEW.data_fim,'9999-12-31') AND COALESCE(data_fim,'9999-12-31')>=NEW.data_inicio AND data_inicio<>OLD.data_inicio) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Periodos de participacao nao podem sobrepor';
 END IF;
END$$
CREATE TRIGGER trg_composicao_bd BEFORE DELETE ON composicao_equipe FOR EACH ROW
BEGIN
 DECLARE v_id INT UNSIGNED;
 SELECT id_equipe INTO v_id FROM equipe WHERE id_equipe=OLD.id_equipe FOR UPDATE;
 IF EXISTS(SELECT 1 FROM ordem_servico WHERE id_equipe=OLD.id_equipe AND status NOT IN('CONCLUIDA','CANCELADA')) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Composicao da equipe bloqueada enquanto houver OS aberta';
 END IF;
END$$
DELIMITER ;
