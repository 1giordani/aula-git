USE ecommerce;
DELIMITER $$
-- CODE 3: o handler reverte a operacao inteira e propaga o erro.
-- Chame esta procedure fora de uma transacao ja iniciada: ela e dona da transacao.
CREATE PROCEDURE sp_registrar_pedido(
 IN p_cliente_id INT, IN p_produto_id INT, IN p_quantidade INT,
 IN p_simular_erro BOOLEAN
)
BEGIN
 DECLARE v_preco DECIMAL(10,2);
 DECLARE v_pedido_id INT;
 DECLARE EXIT HANDLER FOR SQLEXCEPTION
 BEGIN
  ROLLBACK;
  RESIGNAL;
 END;
 START TRANSACTION;
 IF p_quantidade IS NULL OR p_quantidade <= 0 THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Quantidade deve ser positiva';
 END IF;
 -- UPDATE atomico: bloqueia a linha e impede venda acima do estoque.
 UPDATE produtos SET estoque=estoque-p_quantidade
 WHERE id=p_produto_id AND estoque>=p_quantidade;
 IF ROW_COUNT()=0 THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Produto inexistente ou estoque insuficiente';
 END IF;
 SELECT preco INTO v_preco FROM produtos WHERE id=p_produto_id;
 -- Cliente inexistente causa erro de FK DEPOIS da alteracao no estoque.
 INSERT INTO pedidos (cliente_id,total) VALUES (p_cliente_id,v_preco*p_quantidade);
 SET v_pedido_id=LAST_INSERT_ID();
 INSERT INTO itens_pedido VALUES (v_pedido_id,p_produto_id,p_quantidade,v_preco);
 IF COALESCE(p_simular_erro,FALSE) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Falha simulada: transacao revertida';
 END IF;
 COMMIT;
 SELECT v_pedido_id AS pedido_criado;
END$$
CREATE TRIGGER trg_auditar_estoque AFTER UPDATE ON produtos
FOR EACH ROW
BEGIN
 IF OLD.estoque <> NEW.estoque THEN
  INSERT INTO auditoria_estoque (produto_id,estoque_anterior,estoque_novo)
  VALUES (NEW.id,OLD.estoque,NEW.estoque);
 END IF;
END$$
-- Preservado no backup; desabilitado para nao excluir evidencias automaticamente.
CREATE EVENT ev_limpar_auditoria
 ON SCHEDULE EVERY 1 DAY
 DISABLE
 DO DELETE FROM auditoria_estoque WHERE alterado_em < CURRENT_TIMESTAMP - INTERVAL 90 DAY$$
DELIMITER ;
CREATE VIEW vw_resumo_pedidos AS
 SELECT p.id,c.nome AS cliente,p.criado_em,p.total
 FROM pedidos p JOIN clientes c ON c.id=p.cliente_id;
