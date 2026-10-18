# Validação executada

Data: 18/10/2026. MySQL Community Server 8.4.6, tabelas InnoDB, servidor temporário de laboratório.

O arquivo `testes.txt` registra uma execução real de `scripts/testar_projeto.py`, sem erros. Foram criados os dois bancos, sete views (cinco exigidas e duas auxiliares), duas contas de acesso e três triggers.

## Casos verificados

- Contagens por departamento/localidade, incluindo par com zero empregados.
- Departamento sem gerente, representado por NULL.
- Ranking de projetos com 3, 1 e 0 empregados, ordenado na consulta.
- Relação entre projeto, departamento responsável e gerente.
- Dependentes e gerência com um único registro por empregado, mesmo com vários dependentes.
- Login efetivo como gerente: leitura das sete views.
- Login efetivo como empregado: leitura da view pública e bloqueio das outras seis.
- Bloqueio de leitura direta das tabelas de empregados, departamentos e dependentes nas duas contas.
- Bloqueio de UPDATE na view pública nas duas contas.
- BEFORE DELETE: arquivamento dos dados OLD e preservação do pedido com usuario_id NULL.
- ROLLBACK da exclusão: restaura usuário e referência do pedido e desfaz o arquivo.
- BEFORE INSERT: aceita salário positivo e rejeita zero, negativo e NULL.
- BEFORE UPDATE: registra 3000.00 → 3300.00 e rejeita salários inválidos.
- Alteração apenas do nome ou repetição do mesmo salário não produz histórico adicional.
- ROLLBACK da alteração salarial desfaz o salário e o registro de histórico.

## Arquivos

- `testes.txt`: resultados dos testes.
- `resultados_views.txt`: dados retornados pelas cinco views, sem cabeçalhos, na ordem do arquivo SQL de consultas.
- `permissoes.txt`: SHOW GRANTS das duas contas, sem senhas.
- `triggers.txt`: nome, momento e operação dos três gatilhos instalados.

Não foram realizados testes de carga, concorrência, conexão remota ou integração com uma aplicação. O projeto usa esquemas próprios porque o material da aula não foi fornecido. As evidências contêm apenas dados fictícios; senhas temporárias não estão no repositório.
