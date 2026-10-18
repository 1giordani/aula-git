# Views, controle de acesso e triggers no MySQL

**Autor:** Giordani Martins Silva  
**Desafio DIO:** personalização de acessos com views e automação com gatilhos.

Projeto desenvolvido com dois bancos didáticos e dados fictícios: `empresa_views`, para empregados, departamentos e projetos; e `ecommerce_gatilhos`, para exclusão de contas e controle do salário base de colaboradores. O enunciado não trouxe o esquema nem os trechos CODE 1 a 4 da aula; os modelos deste projeto são próprios.

## Parte 1 — As cinco views solicitadas

| Cenário | View | Detalhe |
| --- | --- | --- |
| Empregados por departamento e localidade | `vw_empregados_departamento_localidade` | Conta a lotação efetiva em cada par, incluindo localidades sem empregados |
| Departamentos e seus gerentes | `vw_departamentos_gerentes` | Mantém departamentos sem gerente, com valor NULL |
| Projetos com mais empregados | `vw_projetos_quantidade_empregados` | Conta alocações e mantém projetos sem empregados |
| Projetos, departamentos e gerentes | `vw_projetos_departamentos_gerentes` | Usa o gerente do departamento responsável pelo projeto |
| Empregados com dependentes e indicação de gerência | `vw_empregados_dependentes_gerencia` | Um registro por empregado, quantidade de dependentes e indicador 1/0 |

Uma view armazena a definição da consulta e pode receber permissões próprias. Neste projeto, os dados permanecem nas tabelas base. A consulta abaixo garante a ordenação decrescente do ranking:

```sql
SELECT * FROM empresa_views.vw_projetos_quantidade_empregados
ORDER BY total_empregados DESC, projeto_id;
```

O arquivo `sql/05_consultas.sql` reúne as consultas das cinco views. A tabela de alocações tem chave composta que impede repetir um empregado no mesmo projeto. `EXISTS` evita duplicar empregados com vários dependentes na quinta view.

### Contas e permissões

| Recurso | `gerente_dio` | `empregado_dio` |
| --- | --- | --- |
| Cinco views do desafio | SELECT | Negado |
| `vw_dados_empregados`, com departamento, localidade e salário | SELECT | Negado |
| `vw_empregados_publicos`, somente ID e nome | SELECT | SELECT |
| Tabelas base | Negado | Negado |
| INSERT, UPDATE e DELETE | Negado | Negado |
| Conceder privilégios a terceiros | Negado | Negado |

As views usam `SQL SECURITY DEFINER` para permitir as consultas autorizadas sem conceder acesso às tabelas subjacentes. O usuário que cria as views precisa continuar existindo e ter privilégios sobre essas tabelas. O empregado não recebe acesso às views que revelam departamentos, gerentes, salários ou dependentes.

O perfil empregado pode consultar os nomes e IDs de todos os empregados; não foi implementado filtro por linha para exibir somente o próprio cadastro. Não há concessão de privilégios sobre o banco de e-commerce às duas contas de consulta.

## Parte 2 — Gatilhos

| Gatilho | Momento | Comportamento |
| --- | --- | --- |
| `trg_usuarios_before_delete` | BEFORE DELETE | Copia os dados OLD para `usuarios_excluidos` antes da remoção |
| `trg_colaboradores_before_insert` | BEFORE INSERT | Rejeita salário base nulo, zero ou negativo |
| `trg_colaboradores_before_update` | BEFORE UPDATE | Valida o novo salário e registra valor anterior, valor novo, momento e conta que executou a mudança |

A sintaxe MySQL é `BEFORE DELETE`; não existe `BEFORE REMOVE`. Os pedidos usam `ON DELETE SET NULL`: sobrevivem à exclusão da conta, sem apontar para uma conta inexistente. O arquivo de usuários excluídos não tem chave estrangeira para a tabela de usuários, pois precisa sobreviver à remoção. Nenhuma senha é armazenada nesse histórico.

O salário precisa ser positivo; essa é uma regra demonstrativa do projeto, sem piso salarial ou percentual automático de reajuste. Alterar apenas o nome ou repetir o salário atual não gera histórico salarial. Todas as tabelas são InnoDB: o arquivamento e os registros de auditoria são revertidos se a transação for desfeita. O arquivamento de usuários é didático; políticas de retenção e anonimização de produção não fazem parte do escopo.

## Executar no computador

Requisitos: MySQL Server 8.0.16+ ou 8.4, MySQL Workbench ou cliente `mysql` e uma conta administrativa para criar bancos, views, triggers, usuários e permissões. Python 3 é opcional para os testes automatizados. Use um servidor de laboratório.

No Workbench, execute uma vez e nesta ordem:

1. `sql/01_empresa.sql`
2. `sql/02_views.sql`
3. `sql/03_permissoes.sql`, **substituindo os dois marcadores de senha** antes de executar.
4. `sql/04_ecommerce_triggers.sql`
5. `sql/05_consultas.sql`
6. `sql/06_demonstrar_triggers.sql`, para observar as mudanças e os rollbacks.

Os arquivos não apagam bancos nem contas anteriores. Se os bancos ou as contas já existirem, use outro servidor de laboratório. As contas são criadas para `localhost`; conexões a um servidor remoto exigem configuração de host apropriada pelo administrador.

Crie no Workbench conexões separadas com `gerente_dio` e `empregado_dio` para comparar os acessos. Na conexão de empregado:

```sql
-- Permitido:
SELECT * FROM empresa_views.vw_empregados_publicos;
-- Negado (execute separado):
SELECT * FROM empresa_views.vw_departamentos_gerentes;
-- Negado:
SELECT * FROM empresa_views.empregados;
```

### Testes automatizados

Use um servidor **sem os dois bancos e sem as contas de teste**. O script cria todo o cenário; não execute primeiro os arquivos SQL nesse mesmo servidor.

Copie `mysql-local.example.ini` para `mysql-local.ini` e configure a conta administrativa. O arquivo com a senha é ignorado pelo Git. Em seguida:

```sh
python scripts/testar_projeto.py --config mysql-local.ini --host 127.0.0.1 --port 3306
```

Se necessário, forneça `--mysql` com o caminho completo do executável. `--host` e `--port` indicam onde as contas gerente e empregado se conectarão e devem apontar para o mesmo servidor da configuração administrativa. O script gera senhas aleatórias para as duas contas, usa arquivos temporários restritos, apaga esses arquivos ao finalizar e não publica as senhas nas evidências. As contas permanecem no servidor de laboratório após o teste; o administrador pode removê-las ao encerrar o laboratório.

## Resultados esperados

- Empregados por departamento/localidade: Tecnologia/Belo Horizonte = 2; Tecnologia/Nova Lima = 1; Operações/João Monlevade = 2; Pesquisa/Itabira = 0.
- Gerentes: Ana em Tecnologia, Carla em Operações, nenhum em Pesquisa.
- Ranking de projetos: Portal = 3; Automação = 1; Pesquisa Piloto = 0.
- Dependentes: Ana = 2 e gerente; Bruno = 1 e não gerente; Carla = 1 e gerente.
- Exclusão do usuário 1: conta removida, dados arquivados e pedido mantido com referência NULL.
- Atualização salarial: R$ 3.000,00 → R$ 3.300,00 gera um registro de histórico.
- Quantidades salariais inválidas são rejeitadas; rollback desfaz também os registros produzidos pelos gatilhos.

As evidências de execução estão em `evidencias/`. Consulte `evidencias/VALIDACAO.md` para o ambiente e o escopo dos testes realizados.

## Entrega na DIO

**Link do projeto:**

https://github.com/1giordani/aula-git/tree/projeto-mysql-views-triggers/projeto-mysql-views-triggers

**Descrição para copiar na plataforma:**

> Projeto MySQL com cinco views para consultas de empregados, departamentos, localidades, projetos, gerentes e dependentes. Implementa permissões distintas para gerente e empregado, com acesso controlado às views. Inclui triggers BEFORE DELETE para arquivamento de contas excluídas, BEFORE INSERT para validação salarial e BEFORE UPDATE para validação e histórico de alterações do salário base. Os scripts foram testados no MySQL 8.4, incluindo consultas, acessos permitidos e negados, auditoria e rollback, com documentação e evidências no GitHub.

## Documentação oficial

- [CREATE VIEW e SQL SECURITY](https://dev.mysql.com/doc/refman/8.4/en/create-view.html)
- [GRANT](https://dev.mysql.com/doc/refman/8.4/en/grant.html)
- [Sintaxe e exemplos de triggers](https://dev.mysql.com/doc/refman/8.4/en/trigger-syntax.html)
