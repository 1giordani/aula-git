USE ecommerce_logico;
DELIMITER $$
CREATE TRIGGER trg_pedido_bi BEFORE INSERT ON pedido FOR EACH ROW
BEGIN
 IF NEW.status<>'RASCUNHO' THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Pedido deve iniciar em rascunho';
 END IF;
END$$
CREATE TRIGGER trg_pedido_bu BEFORE UPDATE ON pedido FOR EACH ROW
BEGIN
 DECLARE v_total DECIMAL(14,2);DECLARE v_pago DECIMAL(14,2);
 IF NEW.id_pedido<>OLD.id_pedido OR NEW.id_cliente<>OLD.id_cliente OR NEW.data_criacao<>OLD.data_criacao THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Identidade do pedido e imutavel';
 END IF;
 IF OLD.status<>'RASCUNHO' AND (NEW.frete<>OLD.frete OR NEW.desconto<>OLD.desconto
 OR NEW.endereco_entrega_snapshot<>OLD.endereco_entrega_snapshot) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Valores e endereco congelados apos confirmacao';
 END IF;
 IF NEW.status<>OLD.status AND NOT(
 (OLD.status='RASCUNHO' AND NEW.status IN('CONFIRMADO','CANCELADO')) OR
 (OLD.status='CONFIRMADO' AND NEW.status IN('EM_PROCESSAMENTO','CANCELADO')) OR
 (OLD.status='EM_PROCESSAMENTO' AND NEW.status IN('CONCLUIDO','CANCELADO'))) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Transicao de pedido invalida';
 END IF;
 SELECT COALESCE(SUM(subtotal),0)+NEW.frete-NEW.desconto INTO v_total FROM item_pedido WHERE id_pedido=OLD.id_pedido;
 SELECT COALESCE(SUM(valor),0) INTO v_pago FROM pagamento WHERE id_pedido=OLD.id_pedido AND status='APROVADO';
 IF NEW.status='CONFIRMADO' AND (v_total<0 OR NOT EXISTS(SELECT 1 FROM item_pedido WHERE id_pedido=OLD.id_pedido)) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Confirmacao exige itens e total nao negativo';
 END IF;
 IF NEW.status IN('EM_PROCESSAMENTO','CONCLUIDO') AND v_pago<>v_total THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Processamento exige quitacao';
 END IF;
 IF NEW.status='CONCLUIDO' AND NOT EXISTS(SELECT 1 FROM entrega WHERE id_pedido=OLD.id_pedido AND status='ENTREGUE') THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Conclusao exige entrega realizada';
 END IF;
 IF NEW.status='CANCELADO' AND v_pago>0 THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Cancelamento com pagamento exige estorno fora deste escopo';
 END IF;
END$$
CREATE TRIGGER trg_item_bi BEFORE INSERT ON item_pedido FOR EACH ROW
BEGIN
 DECLARE v_status VARCHAR(30);DECLARE v_preco DECIMAL(10,2);DECLARE v_ativo BOOLEAN;
 SELECT status INTO v_status FROM pedido WHERE id_pedido=NEW.id_pedido FOR UPDATE;
 IF v_status IS NULL OR v_status<>'RASCUNHO' THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Itens so podem mudar em rascunho';
 END IF;
 SELECT preco_atual,ativo INTO v_preco,v_ativo FROM oferta WHERE id_oferta=NEW.id_oferta;
 IF v_preco IS NULL OR NOT v_ativo THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Oferta inexistente ou inativa'; END IF;
 SET NEW.preco_unitario_praticado=v_preco;
END$$
CREATE TRIGGER trg_item_bu BEFORE UPDATE ON item_pedido FOR EACH ROW
BEGIN
 DECLARE v_status VARCHAR(30);DECLARE v_preco DECIMAL(10,2);DECLARE v_ativo BOOLEAN;
 SELECT status INTO v_status FROM pedido WHERE id_pedido=NEW.id_pedido FOR UPDATE;
 IF v_status IS NULL OR v_status<>'RASCUNHO' THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Itens so podem mudar em rascunho';
 END IF;
 IF NEW.id_pedido<>OLD.id_pedido OR NEW.numero_item<>OLD.numero_item OR NEW.id_oferta<>OLD.id_oferta THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Chaves do item sao imutaveis';
 END IF;
 SET NEW.preco_unitario_praticado=OLD.preco_unitario_praticado;
END$$
CREATE TRIGGER trg_item_bd BEFORE DELETE ON item_pedido FOR EACH ROW
BEGIN
 DECLARE v_status VARCHAR(30);DECLARE v_preco DECIMAL(10,2);DECLARE v_ativo BOOLEAN;
 SELECT status INTO v_status FROM pedido WHERE id_pedido=OLD.id_pedido FOR UPDATE;
 IF v_status IS NULL OR v_status<>'RASCUNHO' THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Itens so podem mudar em rascunho';
 END IF;
END$$
CREATE TRIGGER trg_oferta_bu BEFORE UPDATE ON oferta FOR EACH ROW
BEGIN
 IF (NEW.id_oferta<>OLD.id_oferta OR NEW.id_produto<>OLD.id_produto OR NEW.id_vendedor<>OLD.id_vendedor)
 AND EXISTS(SELECT 1 FROM item_pedido WHERE id_oferta=OLD.id_oferta) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Oferta usada em pedido preserva produto e vendedor';
 END IF;
END$$
CREATE TRIGGER trg_pagamento_bi BEFORE INSERT ON pagamento FOR EACH ROW
BEGIN
 DECLARE v_status VARCHAR(30);DECLARE v_criacao DATETIME;
 DECLARE v_total DECIMAL(14,2);DECLARE v_pago DECIMAL(14,2);
 SELECT status,data_criacao INTO v_status,v_criacao FROM pedido WHERE id_pedido=NEW.id_pedido FOR UPDATE;
 IF v_status IS NULL OR v_status NOT IN('CONFIRMADO','EM_PROCESSAMENTO') THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Pagamento exige pedido confirmado ou em processamento';
 END IF;
 IF NEW.status='APROVADO' THEN
  SELECT valor_total INTO v_total FROM vw_total_pedido WHERE id_pedido=NEW.id_pedido;
  SELECT COALESCE(SUM(valor),0) INTO v_pago FROM pagamento WHERE id_pedido=NEW.id_pedido AND status='APROVADO';
  IF v_pago+NEW.valor>v_total OR NEW.data_pagamento<v_criacao THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Valor aprovado excede total ou data anterior ao pedido';
  END IF;
 END IF;
END$$
CREATE TRIGGER trg_pagamento_bu BEFORE UPDATE ON pagamento FOR EACH ROW
BEGIN
 DECLARE v_status VARCHAR(30);DECLARE v_criacao DATETIME;
 DECLARE v_total DECIMAL(14,2);DECLARE v_pago DECIMAL(14,2);
 IF OLD.status<>'PENDENTE' OR NEW.id_pagamento<>OLD.id_pagamento OR NEW.id_pedido<>OLD.id_pedido
 OR NEW.id_forma<>OLD.id_forma OR NEW.id_cliente<>OLD.id_cliente OR NEW.valor<>OLD.valor THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Pagamento finalizado ou identidade imutavel';
 END IF;
 SELECT status,data_criacao INTO v_status,v_criacao FROM pedido WHERE id_pedido=NEW.id_pedido FOR UPDATE;
 IF v_status IS NULL OR v_status NOT IN('CONFIRMADO','EM_PROCESSAMENTO') THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Pagamento exige pedido confirmado ou em processamento';
 END IF;
 IF NEW.status='APROVADO' THEN
  SELECT valor_total INTO v_total FROM vw_total_pedido WHERE id_pedido=NEW.id_pedido;
  SELECT COALESCE(SUM(valor),0) INTO v_pago FROM pagamento WHERE id_pedido=NEW.id_pedido AND status='APROVADO' AND id_pagamento<>OLD.id_pagamento;
  IF v_pago+NEW.valor>v_total OR NEW.data_pagamento<v_criacao THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Valor aprovado excede total ou data anterior ao pedido';
  END IF;
 END IF;
END$$
CREATE TRIGGER trg_pagamento_bd BEFORE DELETE ON pagamento FOR EACH ROW
BEGIN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Historico de pagamentos nao pode ser excluido';
END$$
CREATE TRIGGER trg_entrega_bi BEFORE INSERT ON entrega FOR EACH ROW
BEGIN
 DECLARE v_status VARCHAR(30);
 SELECT status INTO v_status FROM pedido WHERE id_pedido=NEW.id_pedido FOR UPDATE;
 IF v_status IS NULL OR v_status<>'EM_PROCESSAMENTO' OR NEW.status<>'PREPARANDO' THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Entrega inicia em preparacao para pedido em processamento';
 END IF;
END$$
CREATE TRIGGER trg_entrega_bu BEFORE UPDATE ON entrega FOR EACH ROW
BEGIN
 IF NEW.id_entrega<>OLD.id_entrega OR NEW.id_pedido<>OLD.id_pedido THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Identidade da entrega e imutavel';
 END IF;
 IF OLD.status NOT IN('PREPARANDO') AND (NOT(NEW.transportadora<=>OLD.transportadora) OR NOT(NEW.codigo_rastreio<=>OLD.codigo_rastreio)) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Rastreio historico nao pode mudar apos postagem';
 END IF;
 IF NEW.status<>OLD.status AND NOT(
 (OLD.status='PREPARANDO' AND NEW.status IN('POSTADA','CANCELADA')) OR
 (OLD.status='POSTADA' AND NEW.status IN('EM_TRANSITO','CANCELADA')) OR
 (OLD.status='EM_TRANSITO' AND NEW.status IN('ENTREGUE','CANCELADA'))) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Transicao de entrega invalida';
 END IF;
END$$
CREATE TRIGGER trg_entrega_bd BEFORE DELETE ON entrega FOR EACH ROW
BEGIN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Historico de entregas nao pode ser excluido';
END$$
DELIMITER ;
