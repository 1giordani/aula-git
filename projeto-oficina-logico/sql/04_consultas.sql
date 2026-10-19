USE oficina_logica;
SET @data_referencia='2026-10-19'; -- Data fixa para resultados reproduziveis.

-- Q01: Quais mecanicos estao cadastrados e quais sao suas especialidades?
SELECT codigo_mecanico,nome,especialidade FROM mecanico ORDER BY nome;

-- Q02: Quais OSs abertas estao atrasadas na data de referencia?
SELECT numero_os,status,data_prevista_conclusao,
 DATEDIFF(@data_referencia,data_prevista_conclusao) AS dias_atraso
FROM ordem_servico
WHERE status NOT IN('CONCLUIDA','CANCELADA') AND data_prevista_conclusao<@data_referencia
ORDER BY dias_atraso DESC,numero_os;

-- Q03: Quanto custa cada servico aplicado a uma OS?
SELECT i.numero_os,s.descricao,i.quantidade,i.unidade_aplicada,i.valor_unitario_aplicado,
 ROUND(i.quantidade*i.valor_unitario_aplicado,2) AS subtotal_calculado
FROM servico_os i JOIN servico s USING(id_servico)
ORDER BY i.numero_os,i.id_servico;

-- Q04: Qual o valor de servicos, pecas e total de cada OS, do maior para o menor?
SELECT numero_os,total_servicos,total_pecas,valor_total,status
FROM vw_total_os ORDER BY valor_total DESC,numero_os;

-- Q05: Quais clientes solicitaram pelo menos duas OSs?
SELECT c.id_cliente,c.nome,COUNT(os.numero_os) AS quantidade_os
FROM cliente c JOIN ordem_servico os ON os.id_cliente_solicitante=c.id_cliente
GROUP BY c.id_cliente,c.nome HAVING COUNT(os.numero_os)>=2
ORDER BY quantidade_os DESC,c.id_cliente;

-- Q06: Quantas OSs e qual o valor das ordens de cada equipe, incluindo equipes sem OS?
-- O valor inclui todos os status, inclusive canceladas; nao e receita recebida.
SELECT e.id_equipe,e.nome_equipe,COUNT(t.numero_os) AS quantidade_os,
 COALESCE(SUM(t.valor_total),0) AS valor_das_ordens
FROM equipe e LEFT JOIN vw_total_os t ON t.id_equipe=e.id_equipe
GROUP BY e.id_equipe,e.nome_equipe ORDER BY valor_das_ordens DESC,e.id_equipe;

-- Q07: Qual a visao completa de cada atendimento e sua decisao de autorizacao?
SELECT os.numero_os,c.nome AS cliente,v.placa,e.nome_equipe,os.tipo_atendimento,
 os.status,COALESCE(a.decisao,'SEM DECISAO') AS decisao,t.valor_total
FROM ordem_servico os
JOIN cliente c ON c.id_cliente=os.id_cliente_solicitante
JOIN veiculo v ON v.id_veiculo=os.id_veiculo
JOIN equipe e ON e.id_equipe=os.id_equipe
JOIN vw_total_os t ON t.numero_os=os.numero_os
LEFT JOIN autorizacao a ON a.numero_os=os.numero_os
ORDER BY os.numero_os;

-- Q08: Quais clientes ainda nao possuem nenhuma OS?
SELECT c.id_cliente,c.nome FROM cliente c
WHERE NOT EXISTS(SELECT 1 FROM ordem_servico os WHERE os.id_cliente_solicitante=c.id_cliente)
ORDER BY c.id_cliente;

-- Q09: Quais pecas foram usadas em OSs concluidas e qual seu valor acumulado?
SELECT p.id_peca,p.descricao,SUM(i.quantidade) AS unidades,
 SUM(i.subtotal) AS valor_aplicado
FROM peca p JOIN peca_os i USING(id_peca)
JOIN ordem_servico os ON os.numero_os=i.numero_os
WHERE os.status='CONCLUIDA'
GROUP BY p.id_peca,p.descricao ORDER BY unidades DESC,p.id_peca;

-- Q10: Quais mecanicos integram cada equipe na data de referencia?
SELECT e.id_equipe,e.nome_equipe,COUNT(m.codigo_mecanico) AS mecanicos_ativos,
 COALESCE(GROUP_CONCAT(m.nome ORDER BY m.nome SEPARATOR ', '),'SEM INTEGRANTES') AS integrantes
FROM equipe e LEFT JOIN composicao_equipe ce ON ce.id_equipe=e.id_equipe
 AND ce.data_inicio<=@data_referencia AND (ce.data_fim IS NULL OR ce.data_fim>=@data_referencia)
LEFT JOIN mecanico m ON m.codigo_mecanico=ce.codigo_mecanico
GROUP BY e.id_equipe,e.nome_equipe ORDER BY e.id_equipe;

-- Q11: Quais itens mantiveram preco historico diferente da referencia atual?
SELECT i.numero_os,s.descricao,i.valor_unitario_aplicado,s.valor_unitario_referencia,
 s.valor_unitario_referencia-i.valor_unitario_aplicado AS diferenca_unitaria
FROM servico_os i JOIN servico s USING(id_servico)
WHERE i.valor_unitario_aplicado<>s.valor_unitario_referencia
ORDER BY i.numero_os,i.id_servico;

-- Q12: Quais OSs concluidas ultrapassaram a previsao, e em quantos dias?
SELECT numero_os,data_prevista_conclusao,data_efetiva_conclusao,
 DATEDIFF(data_efetiva_conclusao,data_prevista_conclusao) AS dias_atraso
FROM ordem_servico WHERE status='CONCLUIDA'
 AND data_efetiva_conclusao>data_prevista_conclusao
ORDER BY dias_atraso DESC,numero_os;

-- Q13: Qual o ranking dos clientes pelo valor de OSs nao canceladas, incluindo quem nao tem OS?
WITH valores AS (
 SELECT c.id_cliente,c.nome,COALESCE(SUM(t.valor_total),0) AS valor_ordens
 FROM cliente c LEFT JOIN vw_total_os t ON t.id_cliente_solicitante=c.id_cliente
 AND t.status<>'CANCELADA'
 GROUP BY c.id_cliente,c.nome
)
SELECT id_cliente,nome,valor_ordens,DENSE_RANK() OVER(ORDER BY valor_ordens DESC) AS posicao
FROM valores ORDER BY posicao,id_cliente;

-- Q14: Quais servicos somam pelo menos R$300 em OSs autorizadas, em execucao ou concluidas?
SELECT s.id_servico,s.descricao,SUM(i.quantidade) AS quantidade,SUM(i.subtotal) AS valor
FROM servico s JOIN servico_os i USING(id_servico)
JOIN ordem_servico os ON os.numero_os=i.numero_os
WHERE os.status IN('AUTORIZADA','EM_EXECUCAO','CONCLUIDA')
GROUP BY s.id_servico,s.descricao HAVING SUM(i.subtotal)>=300
ORDER BY valor DESC,s.id_servico;
