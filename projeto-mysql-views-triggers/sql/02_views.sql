USE empresa_views;
-- 1. Lotacao real por par departamento/localidade; preserva pares vazios.
CREATE SQL SECURITY DEFINER VIEW vw_empregados_departamento_localidade AS
 SELECT d.id AS departamento_id,d.nome AS departamento,l.localidade,
 COUNT(e.id) AS total_empregados
 FROM departamentos d JOIN localidades_departamento l ON l.departamento_id=d.id
 LEFT JOIN empregados e ON e.departamento_id=l.departamento_id AND e.localidade=l.localidade
 GROUP BY d.id,d.nome,l.localidade;
-- 2. Departamentos e respectivos gerentes, inclusive departamento sem gerente.
CREATE SQL SECURITY DEFINER VIEW vw_departamentos_gerentes AS
 SELECT d.id AS departamento_id,d.nome AS departamento,
 e.id AS gerente_id,e.nome AS gerente
 FROM departamentos d LEFT JOIN empregados e ON e.id=d.gerente_id;
-- 3. Quantidade por projeto, inclusive projeto sem alocacoes.
CREATE SQL SECURITY DEFINER VIEW vw_projetos_quantidade_empregados AS
 SELECT p.id AS projeto_id,p.nome AS projeto,COUNT(a.empregado_id) AS total_empregados
 FROM projetos p LEFT JOIN alocacoes a ON a.projeto_id=p.id
 GROUP BY p.id,p.nome;
-- A ordenacao e garantida na consulta consumidora, em 05_consultas.sql.
-- 4. Projeto, departamento responsavel e gerente desse departamento.
CREATE SQL SECURITY DEFINER VIEW vw_projetos_departamentos_gerentes AS
 SELECT p.id AS projeto_id,p.nome AS projeto,d.nome AS departamento,e.nome AS gerente
 FROM projetos p JOIN departamentos d ON d.id=p.departamento_id
 LEFT JOIN empregados e ON e.id=d.gerente_id;
-- 5. Um registro por empregado com dependentes; EXISTS evita multiplicacao.
CREATE SQL SECURITY DEFINER VIEW vw_empregados_dependentes_gerencia AS
 SELECT e.id AS empregado_id,e.nome,
 (SELECT COUNT(*) FROM dependentes dep WHERE dep.empregado_id=e.id) AS total_dependentes,
 EXISTS(SELECT 1 FROM departamentos d WHERE d.gerente_id=e.id) AS eh_gerente
 FROM empregados e WHERE EXISTS(SELECT 1 FROM dependentes dep WHERE dep.empregado_id=e.id);
-- Views auxiliares para separar as permissoes das contas.
CREATE SQL SECURITY DEFINER VIEW vw_dados_empregados AS
 SELECT id,nome,departamento_id,localidade,salario FROM empregados;
CREATE SQL SECURITY DEFINER VIEW vw_empregados_publicos AS
 SELECT id,nome FROM empregados;
