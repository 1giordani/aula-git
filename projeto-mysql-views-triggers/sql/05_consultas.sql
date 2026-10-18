USE empresa_views;
SELECT * FROM vw_empregados_departamento_localidade ORDER BY departamento_id,localidade;
SELECT * FROM vw_departamentos_gerentes ORDER BY departamento_id;
SELECT * FROM vw_projetos_quantidade_empregados ORDER BY total_empregados DESC,projeto_id;
SELECT * FROM vw_projetos_departamentos_gerentes ORDER BY projeto_id;
SELECT * FROM vw_empregados_dependentes_gerencia ORDER BY empregado_id;
-- Empregado: conectar com empregado_dio e consultar apenas esta view.
-- SELECT * FROM empresa_views.vw_empregados_publicos;
-- Exemplos NEGADOS para empregado_dio (execute individualmente):
-- SELECT * FROM empresa_views.vw_departamentos_gerentes;
-- SELECT * FROM empresa_views.empregados;
