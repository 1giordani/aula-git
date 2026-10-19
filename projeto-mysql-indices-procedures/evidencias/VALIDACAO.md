# Validação executada

Data: 19/10/2026. MySQL Community Server 8.4.6, Linux, tabelas InnoDB, servidor temporário de laboratório.

A execução de `scripts/testar_projeto.py` terminou com TODOS OS TESTES PASSARAM. Os resultados não foram simulados.

## Verificações

- Os três resultados das consultas permaneceram idênticos antes e depois da criação dos índices.
- O departamento de maior tamanho retorna todos os empates (Tecnologia e Operações, três empregados cada).
- O filtro por Belo Horizonte encontra Tecnologia e Financeiro.
- O departamento Pesquisa continua presente na relação, mesmo sem empregado.
- Dois índices BTREE foram criados e o índice simples redundante de empregados foi removido.
- Os planos foram capturados antes e depois, sem FORCE INDEX.
- As quatro ações foram chamadas nas procedures de universidade e e-commerce.
- Os valores resultantes de inserção, atualização e consulta foram conferidos.
- Atualização com valores idênticos foi aceita; estoque zero também.
- Foram verificados 22 casos negativos, incluindo ações nulas/inválidas, nome/e-mail obrigatório, e-mail duplicado, IDs inexistentes, preços inválidos e estoques inválidos.
- Cada erro esperado preservou as linhas das tabelas em comparação ao estado anterior. Os contadores internos de AUTO_INCREMENT não entram nessa comparação.
- Exclusões foram confirmadas e a consulta posterior do ID excluído retornou vazio.

## Arquivos de evidência

- `testes.txt`: saída do teste automatizado.
- `consultas.txt`: resultados das três consultas, sem cabeçalhos, na ordem de `sql/02_consultas.sql`.
- `indices.txt`: tabela, nome, ordem, coluna e tipo dos índices.
- `explain_antes.txt` e `explain_depois.txt`: planos das quatro consultas de diagnóstico de `sql/04_explain.sql`, sem cabeçalhos, na ordem do arquivo.
- `chamadas_crud.txt`: resultados das chamadas SQL de demonstração.

Para ler EXPLAIN, a sequência de colunas é: id, select_type, table, partitions, type, possible_keys, key, key_len, ref, rows, filtered e Extra. O texto NULL indica ausência de valor.

O primeiro diagnóstico analisa a agregação que sustenta o ranking; não é o plano completo da CTE que filtra o maior total. Não foram executados benchmark de latência, teste de carga ou teste de concorrência. A amostra tem sete empregados; os planos podem mudar com outros dados e estatísticas. Os procedimentos usam modelos próprios, pois os arquivos da aula não foram fornecidos.
