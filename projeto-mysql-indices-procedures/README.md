# Índices e procedures para manipulação de dados no MySQL

**Autor:** Giordani Martins Silva  
**Desafio DIO:** índices orientados a consultas e procedures com controle condicional de operações.

O projeto usa três bancos didáticos com dados fictícios: `company_indices`, `universidade_crud` e `ecommerce_crud`. Como o enunciado não forneceu os esquemas nem a procedure de referência da aula, foram criados modelos próprios que atendem aos requisitos.

## Parte 1 — Consultas e índices

As três perguntas estão implementadas em `sql/02_consultas.sql`:

1. **Qual departamento tem mais pessoas?** Uma CTE conta empregados por departamento e retorna todos os departamentos empatados no maior total.
2. **Quais departamentos existem em uma cidade?** A consulta usa a tabela de localidades e um parâmetro `@cidade`. Para listar todas as cidades, o script explica como retirar o filtro.
3. **Qual a relação de empregados por departamento?** A consulta lista os empregados e mantém também o departamento vazio com campos de empregado NULL.

Um departamento pode existir em mais de uma cidade, sem duplicar empregados na contagem da primeira pergunta: ela consulta diretamente a relação entre empregado e departamento.

### Critérios de escolha

O padrão de acesso adotado é uma hipótese didática baseada nas perguntas do desafio: consultas recorrentes por departamento e por cidade. Não foram fornecidas estatísticas reais de uso. Assim, as colunas relevantes são as chaves de relacionamento, o filtro de cidade e o nome exibido na listagem de empregados.

| Tabela | Índice mantido ou criado | Tipo | Justificativa |
| --- | --- | --- | --- |
| `departamentos` | `PRIMARY KEY(id)`, já existente | BTREE | Atende às junções por departamento; criar outro índice em id seria redundante |
| `empregados` | `idx_empregados_departamento_nome(departamento_id,nome)` | BTREE | O primeiro campo atende ao filtro e à junção por departamento; nome permite cobrir a listagem |
| `localidades_departamento` | `PRIMARY KEY(departamento_id,cidade)`, já existente | BTREE | Evita repetir o mesmo par e dá suporte à FK do departamento |
| `localidades_departamento` | `idx_localidades_cidade_departamento(cidade,departamento_id)` | BTREE | A cidade vem primeiro para permitir a busca por cidade; o departamento também está disponível no índice |

O arquivo `sql/03_indices.sql` cria apenas dois índices adicionais. Depois de criar o índice composto de empregados, remove o índice simples inicial `idx_empregados_departamento`, pois seu campo já é o prefixo esquerdo do novo índice. A chave estrangeira continua amparada pelo composto.

No InnoDB, o ID da chave primária já acompanha as entradas dos índices secundários. Não é necessário acrescentá-lo explicitamente ao índice de empregados para ler ID e nome. Não foram criados índices de salário nem um segundo índice de nome do departamento, pois essas colunas não são filtros nas consultas propostas.

**Por que BTREE?** É o tipo de índice convencional suportado pelo InnoDB, adequado às buscas por igualdade, aos prefixos de índices compostos e a percursos ordenados. O exemplo `USING HASH` do enunciado não foi aplicado: índices HASH convencionais não são suportados pelo InnoDB. O Adaptive Hash Index interno é um mecanismo distinto, não um índice HASH criado por esse comando.

Índices consomem espaço e precisam ser atualizados em operações de escrita. Contar todos os empregados continua exigindo percorrer dados ou índices; o índice não torna a agregação geral uma operação de tempo constante. Ordenação por contagem ainda pode exigir trabalho temporário e filesort.

### Verificação dos planos

`sql/04_explain.sql` pode ser executado antes e depois da criação dos índices. Ele analisa a agregação que sustenta o ranking, a consulta por cidade, a relação completa de empregados e uma consulta seletiva por departamento.

As evidências reais desta execução estão em `evidencias/explain_antes.txt` e `evidencias/explain_depois.txt`. Nessa base pequena:

- O filtro por cidade passou de varredura do índice primário (`type=index`) para acesso `ref` em `idx_localidades_cidade_departamento`.
- A consulta seletiva de ID e nome por departamento passou a usar `idx_empregados_departamento_nome` com `Using index`; o `Using filesort` dessa consulta seletiva deixou de aparecer.
- A relação completa também passou a usar o índice composto com `Using index`, mas sua ordenação global ainda exige trabalho adicional.
- A tabela `departamentos`, com quatro registros, continuou sendo varrida em algumas consultas, por escolha do otimizador.

`Using index` indica uma leitura coberta pelo índice. Esses resultados descrevem planos de execução; não constituem medição de ganho de tempo. O otimizador pode escolher planos diferentes com outros volumes, distribuições, estatísticas ou versões. Nenhum teste usa FORCE INDEX.

## Parte 2 — Procedures condicionais

| Controle `p_acao` | Ação | Parâmetros utilizados |
| --- | --- | --- |
| 1 | SELECT | ID para um registro; ID NULL para listar todos |
| 2 | INSERT | Nome e demais dados; ID ignorado, gerado por AUTO_INCREMENT |
| 3 | UPDATE | ID existente e todos os dados atualizáveis |
| 4 | DELETE | ID existente; demais dados ignorados |

O enunciado fornece uma numeração apenas como exemplo. Neste projeto, as duas procedures usam o mesmo mapeamento explícito acima.

- `universidade_crud.sp_manipular_aluno`: nome e e-mail do aluno.
- `ecommerce_crud.sp_manipular_produto`: nome, preço e estoque do produto.

As instruções ficam dentro de um `CASE p_acao`. Cada chamada inicia e encerra sua própria transação. Um `EXIT HANDLER FOR SQLEXCEPTION` executa ROLLBACK e RESIGNAL, preservando o erro para quem chamou.

As atualizações verificam a existência do registro com `SELECT ... FOR UPDATE`. Isso também permite atualizar um registro com valores idênticos sem confundir “nenhuma mudança” com “registro inexistente”. Exclusão de ID inexistente produz erro. Uma consulta de ID inexistente retorna resultado vazio.

A procedure de alunos exige nome e e-mail preenchidos; a restrição UNIQUE impede e-mails duplicados. Não se pretende validar a sintaxe completa de endereços de e-mail. A de produtos exige nome preenchido, preço positivo e estoque não negativo. Estoque zero é permitido. Ação nula ou fora de 1 a 4 é rejeitada.

**Chame as procedures sem uma transação externa aberta**, pois `START TRANSACTION` não implementa transações aninhadas e pode confirmar uma transação anterior da sessão. Os saltos em AUTO_INCREMENT após uma tentativa malsucedida são normais e não representam perda de registros.

### Chamadas prontas

O arquivo `sql/07_chamadas.sql` demonstra as quatro ações nos dois bancos. Exemplos:

```sql
CALL universidade_crud.sp_manipular_aluno(1,NULL,NULL,NULL);
CALL universidade_crud.sp_manipular_aluno(2,NULL,'Novo Aluno','novo@example.com');
SET @aluno_id=LAST_INSERT_ID();
CALL universidade_crud.sp_manipular_aluno(3,@aluno_id,'Aluno Atualizado','atualizado@example.com');
CALL universidade_crud.sp_manipular_aluno(4,@aluno_id,NULL,NULL);

CALL ecommerce_crud.sp_manipular_produto(2,NULL,'Mouse',80.00,30);
SET @produto_id=LAST_INSERT_ID();
CALL ecommerce_crud.sp_manipular_produto(3,@produto_id,'Mouse Atualizado',90.00,25);
CALL ecommerce_crud.sp_manipular_produto(1,@produto_id,NULL,NULL,NULL);
CALL ecommerce_crud.sp_manipular_produto(4,@produto_id,NULL,NULL,NULL);
```

Mantenha a mesma conexão para usar as variáveis de sessão e LAST_INSERT_ID(). O projeto não inclui uma aplicação web nem sistema de autenticação; seu foco é SQL e administração dos dados.

## Como executar

Requisitos: MySQL Server 8.0.16+ ou 8.4, MySQL Workbench ou cliente `mysql`, e uma conta de laboratório com privilégios para criar bancos, tabelas, índices e procedures. Para o teste automatizado, Python 3.

No Workbench, use um servidor sem os três bancos do projeto e execute:

1. `sql/01_company.sql`
2. `sql/02_consultas.sql`
3. `sql/04_explain.sql`, para observar o plano inicial.
4. `sql/03_indices.sql`
5. `sql/04_explain.sql` novamente e `sql/02_consultas.sql` para comparação.
6. `sql/05_universidade.sql`
7. `sql/06_ecommerce.sql`
8. `sql/07_chamadas.sql`

Os scripts de criação foram projetados para executar uma vez. Eles não removem bancos existentes e não reinicializam silenciosamente um ambiente já utilizado.

### Executar os testes automatizados

Em outro servidor de laboratório sem os três bancos, copie `mysql-local.example.ini` para `mysql-local.ini` e configure as credenciais. O arquivo com a senha é ignorado pelo Git.

```sh
python scripts/testar_projeto.py --config mysql-local.ini
```

Se o cliente MySQL não estiver no PATH, forneça `--mysql` com seu caminho completo. O script cria o cenário, compara as consultas antes/depois, captura os planos e testa as procedures. Não execute os SQLs manualmente antes de rodar o teste no mesmo servidor.

## Resultados esperados

- Tecnologia e Operações empatam no maior total, com três empregados cada.
- Belo Horizonte tem os departamentos Tecnologia e Financeiro.
- A relação completa inclui os sete empregados e uma linha referente ao departamento Pesquisa, sem empregado.
- As procedures incluem, consultam, atualizam e excluem registros, rejeitando entradas inválidas.

Os arquivos da pasta `evidencias/` registram o teste executado no MySQL 8.4.6. O escopo e as limitações estão em `evidencias/VALIDACAO.md`.

## Entrega na DIO

**Link para entregar:**

https://github.com/1giordani/aula-git/tree/projeto-mysql-indices-procedures/projeto-mysql-indices-procedures

**Descrição para copiar:**

> Projeto MySQL com consultas para identificar os departamentos com mais empregados, localizar departamentos por cidade e listar empregados por departamento. Inclui índices B-tree justificados no README e comparação de planos com EXPLAIN. Implementa também procedures para universidade e e-commerce, com controle condicional de consulta, inserção, atualização e exclusão, validação de dados e tratamento de erros. Os scripts foram testados no MySQL 8.4, com documentação e evidências disponíveis no GitHub.

## Referências oficiais

- [Índices compostos e prefixo esquerdo](https://dev.mysql.com/doc/refman/8.4/en/multiple-column-indexes.html)
- [CREATE INDEX e tipos suportados](https://dev.mysql.com/doc/refman/8.4/en/create-index.html)
- [EXPLAIN](https://dev.mysql.com/doc/refman/8.4/en/explain.html)
- [CREATE PROCEDURE](https://dev.mysql.com/doc/refman/8.4/en/create-procedure.html)
