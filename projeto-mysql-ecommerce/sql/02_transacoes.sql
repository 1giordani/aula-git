USE ecommerce;
-- CODE 1: desabilitar autocommit nesta sessao.
SET @autocommit_anterior = @@SESSION.autocommit;
SET SESSION autocommit = 0;
-- CODE 2: confirmar uma modificacao.
START TRANSACTION;
SELECT id,nome,estoque FROM produtos WHERE id=1 FOR UPDATE;
UPDATE produtos SET estoque=estoque+5 WHERE id=1;
COMMIT;
SELECT 'COMMIT: estoque esperado 25' AS resultado,estoque FROM produtos WHERE id=1;
-- Reverter toda a transacao.
START TRANSACTION;
UPDATE produtos SET estoque=estoque-10 WHERE id=1;
ROLLBACK;
SELECT 'ROLLBACK: estoque esperado 25' AS resultado,estoque FROM produtos WHERE id=1;
-- Reverter somente a alteracao posterior ao SAVEPOINT.
START TRANSACTION;
UPDATE produtos SET estoque=estoque+2 WHERE id=1;
SAVEPOINT ajuste_valido;
UPDATE produtos SET estoque=estoque-3 WHERE id=1;
ROLLBACK TO SAVEPOINT ajuste_valido;
RELEASE SAVEPOINT ajuste_valido;
COMMIT;
SELECT 'SAVEPOINT: estoque esperado 27' AS resultado,estoque FROM produtos WHERE id=1;
SET SESSION autocommit = @autocommit_anterior;
