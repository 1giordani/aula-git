USE company_indices;
-- Pergunta 1: departamento com mais pessoas; retorna TODOS os empates.
WITH contagens AS (
 SELECT d.id,d.nome,COUNT(e.id) AS total_empregados
 FROM departamentos d LEFT JOIN empregados e ON e.departamento_id=d.id
 GROUP BY d.id,d.nome
)
SELECT id,nome,total_empregados FROM contagens
WHERE total_empregados=(SELECT MAX(total_empregados) FROM contagens)
ORDER BY id;
-- Pergunta 2: departamentos de uma cidade; altere o parametro abaixo.
SET @cidade='Belo Horizonte';
SELECT l.cidade,d.id AS departamento_id,d.nome AS departamento
FROM localidades_departamento l JOIN departamentos d ON d.id=l.departamento_id
WHERE l.cidade=@cidade ORDER BY d.id;
-- Para listar todas as cidades, retire o WHERE e ordene por l.cidade,d.id.
-- Pergunta 3: empregados por departamento, incluindo departamento vazio.
SELECT d.id AS departamento_id,d.nome AS departamento,e.id AS empregado_id,e.nome AS empregado
FROM departamentos d LEFT JOIN empregados e ON e.departamento_id=d.id
ORDER BY d.id,e.nome,e.id;
