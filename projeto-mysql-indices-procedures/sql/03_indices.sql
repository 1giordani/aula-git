USE company_indices;
-- Tipo: BTREE, suportado pelo InnoDB. Nao usamos HASH (exemplo do enunciado).
-- Perguntas 1 e 3: o prefixo departamento_id atende juncao e agrupamento.
-- nome cobre a listagem; a PK id ja integra os indices secundarios no InnoDB.
CREATE INDEX idx_empregados_departamento_nome USING BTREE
 ON empregados(departamento_id,nome);
-- O novo indice preserva o suporte a FK. Remove o simples redundante APOS cria-lo.
ALTER TABLE empregados DROP INDEX idx_empregados_departamento;
-- Pergunta 2: PK existente (departamento_id,cidade) nao comeca por cidade.
-- Indice invertido permite pesquisar pela cidade e obter o departamento no indice.
CREATE INDEX idx_localidades_cidade_departamento USING BTREE
 ON localidades_departamento(cidade,departamento_id);
-- departamentos: a PRIMARY KEY(id) existente atende as juncoes. Sem duplicacao.
-- Nao indexamos salario: nao participa das consultas solicitadas.
-- COUNT geral ainda precisa percorrer dados/indice; nao prometemos tempo constante.
ANALYZE TABLE departamentos,localidades_departamento,empregados;
