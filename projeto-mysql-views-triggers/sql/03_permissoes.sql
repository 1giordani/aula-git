-- Execute como administrador; troque os dois marcadores de senha antes.
-- Nao use IF NOT EXISTS: evita reaproveitar contas com privilegios anteriores.
CREATE USER 'gerente_dio'@'localhost' IDENTIFIED BY 'SUBSTITUA_SENHA_GERENTE';
CREATE USER 'empregado_dio'@'localhost' IDENTIFIED BY 'SUBSTITUA_SENHA_EMPREGADO';
GRANT SELECT ON empresa_views.vw_empregados_departamento_localidade TO 'gerente_dio'@'localhost';
GRANT SELECT ON empresa_views.vw_departamentos_gerentes TO 'gerente_dio'@'localhost';
GRANT SELECT ON empresa_views.vw_projetos_quantidade_empregados TO 'gerente_dio'@'localhost';
GRANT SELECT ON empresa_views.vw_projetos_departamentos_gerentes TO 'gerente_dio'@'localhost';
GRANT SELECT ON empresa_views.vw_empregados_dependentes_gerencia TO 'gerente_dio'@'localhost';
GRANT SELECT ON empresa_views.vw_dados_empregados TO 'gerente_dio'@'localhost';
GRANT SELECT ON empresa_views.vw_empregados_publicos TO 'gerente_dio'@'localhost';
-- Empregado ve apenas nomes e IDs; nenhuma view revela departamento ou gerencia.
GRANT SELECT ON empresa_views.vw_empregados_publicos TO 'empregado_dio'@'localhost';
SHOW GRANTS FOR 'gerente_dio'@'localhost';
SHOW GRANTS FOR 'empregado_dio'@'localhost';
-- Nao se concede acesso direto as tabelas, escrita ou GRANT OPTION.
-- SQL SECURITY DEFINER permite ler a view sem conceder a tabela base.
