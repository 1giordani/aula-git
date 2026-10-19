USE company_indices;
-- Execute ANTES e DEPOIS de 03_indices.sql. Sem FORCE INDEX.
EXPLAIN FORMAT=TRADITIONAL
SELECT d.id,d.nome,COUNT(e.id) AS total_empregados
FROM departamentos d LEFT JOIN empregados e ON e.departamento_id=d.id
GROUP BY d.id,d.nome ORDER BY total_empregados DESC,d.id;
EXPLAIN FORMAT=TRADITIONAL
SELECT l.cidade,d.id,d.nome
FROM localidades_departamento l JOIN departamentos d ON d.id=l.departamento_id
WHERE l.cidade='Belo Horizonte' ORDER BY d.id;
EXPLAIN FORMAT=TRADITIONAL
SELECT d.id,d.nome,e.id,e.nome
FROM departamentos d LEFT JOIN empregados e ON e.departamento_id=d.id
ORDER BY d.id,e.nome,e.id;
-- Consulta seletiva da mesma relacao; demonstra o prefixo esquerdo do composto.
EXPLAIN FORMAT=TRADITIONAL
SELECT id,nome FROM empregados WHERE departamento_id=1 ORDER BY nome,id;
-- Inspecione key, possible_keys, type e Extra; varredura pode ser escolhida
-- em bases pequenas. EXPLAIN estima um plano; nao e benchmark de tempo.
