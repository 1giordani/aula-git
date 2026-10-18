# Transações, procedures, backup e recovery com MySQL

**Autor:** Giordani Martins Silva  
**Desafio DIO:** controle transacional e recuperação de um banco e-commerce.

Projeto didático com clientes, produtos, pedidos, itens e auditoria de estoque. Todos os dados são fictícios. Como o enunciado não forneceu o banco da aula, foi criado um modelo próprio. O banco se chama `ecommerce` (sem hífen); `logistica` demonstra o backup de mais de um banco.

## O que o projeto demonstra

| Requisito | Implementação |
| --- | --- |
| Desabilitar autocommit | `sql/02_transacoes.sql`, restaura a configuração anterior ao terminar |
| Confirmar alterações | `START TRANSACTION` e `COMMIT` |
| Reverter alterações | `ROLLBACK` e `ROLLBACK TO SAVEPOINT` |
| Transação em procedure | `sp_registrar_pedido` |
| Tratamento de erro | `EXIT HANDLER FOR SQLEXCEPTION`, `ROLLBACK` e `RESIGNAL` |
| Controle de estoque | Atualização atômica condicionada à quantidade disponível |
| Recursos adicionais | Trigger de auditoria, view e evento desabilitado |
| Backup e recovery | `mysqldump` para exportar, cliente `mysql` para restaurar |
| Diferentes bancos | `ecommerce` e `logistica` |

O enunciado escreve “mysqdump”; o executável correto é **mysqldump**. Ele gera o backup. A importação é feita pelo cliente **mysql**.

## Pré-requisitos

- MySQL Server 8.0.16+ ou 8.4 e clientes `mysql` e `mysqldump`.
- MySQL Workbench para executar os arquivos SQL, se preferir interface gráfica.
- Python 3 para o script opcional que funciona em Windows e Linux.
- Conta com permissões para criar os bancos e os objetos deste laboratório e exportá-los. Use um ambiente de testes.

## 1. Criar os bancos e executar as transações

No MySQL Workbench, abra sua conexão e execute nesta ordem:

1. `sql/01_estrutura_dados.sql`
2. `sql/02_transacoes.sql`
3. `sql/03_procedure_recursos.sql`
4. `sql/04_demonstracao.sql`: execute os blocos separadamente; há um erro proposital.

Não repita o arquivo 01 sobre os bancos existentes: ele não apaga os dados nem reinicia o laboratório. Os resultados numéricos abaixo pressupõem uma única execução na ordem indicada.

Alternativa no terminal clássico do Windows (CMD) ou Bash:

```sh
mysql -u root -p < sql/01_estrutura_dados.sql
mysql -u root -p < sql/02_transacoes.sql
mysql -u root -p < sql/03_procedure_recursos.sql
```

O redirecionamento de entrada `<` não funciona dessa forma no PowerShell. Nele, use o Workbench para os SQLs e o script Python abaixo para backup/recovery.

### Resultados para conferir

| Etapa | Estoque do teclado |
| --- | ---: |
| Cadastro inicial | 20 |
| Acréscimo de 5 confirmado | 25 |
| Retirada de 10 desfeita | 25 |
| Acréscimo de 2 mantido e retirada de 3 desfeita via savepoint | 27 |
| Pedido de 2 unidades confirmado | 25 |
| Pedido de 3 unidades com erro simulado | 25 |

O pedido confirmado totaliza R$ 300,00. A falha simulada precisa manter inalterados pedidos, itens, estoque e auditoria. Testes adicionais: quantidade zero, estoque insuficiente, produto inexistente e cliente inexistente. Este último falha depois de alterar o estoque e comprova que o handler desfaz também essa alteração.

A procedure controla a própria transação. Chame-a numa sessão sem outra transação aberta, pois `START TRANSACTION` encerra implicitamente uma transação anterior no MySQL. Saltos nos IDs após rollback são normais: `AUTO_INCREMENT` não garante sequência sem lacunas.

Todas as tabelas usam InnoDB. A trigger participa da mesma transação do pedido. Não há DDL dentro das transações demonstrativas. O evento permanece desabilitado e só tem sua definição preservada no dump; não é necessário ativar o agendador para cumprir o desafio.

## 2. Gerar backups

Abra um terminal na pasta do projeto. Os comandos abaixo usam `--result-file` para evitar problemas de codificação no redirecionamento do PowerShell. Se os executáveis não estiverem no PATH, use o caminho da pasta `bin` da instalação do MySQL.

Backup de um banco, com procedures, eventos, triggers e views:

```sh
mysqldump -u root -p --single-transaction --routines --events --triggers --no-tablespaces --set-gtid-purged=OFF --default-character-set=utf8mb4 --databases ecommerce --result-file=backups/ecommerce.sql
```

Backup de dois bancos:

```sh
mysqldump -u root -p --single-transaction --routines --events --triggers --no-tablespaces --set-gtid-purged=OFF --default-character-set=utf8mb4 --databases ecommerce logistica --result-file=backups/ecommerce_logistica.sql
```

`--single-transaction` fornece um snapshot consistente para as tabelas InnoDB deste laboratório. Não altere a estrutura das tabelas durante a exportação. Os dumps preservam os bancos indicados e seus objetos; não constituem um backup das contas/permissões do servidor nem recovery por ponto no tempo com binlogs.

## 3. Restaurar e verificar

Use um servidor MySQL de testes separado. Os arquivos contêm `CREATE DATABASE`, `USE` e substituição de tabelas dos bancos nomeados no dump. Passar outro nome de banco ao cliente não renomeia esses comandos.

No CMD ou Bash, apontando para o servidor de testes:

```sh
mysql -h 127.0.0.1 -P 3307 -u root -p < backups/ecommerce_logistica.sql
mysql -h 127.0.0.1 -P 3307 -u root -p < sql/05_verificar_recuperacao.sql
```

A porta 3307 é apenas um exemplo: use a porta real do servidor de recuperação. Não é preciso excluir os bancos originais para testar. Use versão compatível e conta com as permissões necessárias; os dumps reais preservam DEFINER dos objetos. Em outro servidor, crie a conta correspondente ou adapte os definers com cuidado.

No Workbench, outra opção é **Server → Data Import → Import from Self-Contained File**, selecionar o dump e iniciar a importação no servidor de testes. Depois execute `sql/05_verificar_recuperacao.sql` nessa conexão e compare dados e objetos com a origem.

### Opção para PowerShell e Linux: script Python

Copie `mysql-local.example.ini` para `mysql-local.ini` e coloque suas credenciais locais. Esse arquivo é ignorado pelo Git. Para recovery, use outra configuração, apontando para o servidor de testes.

```sh
python scripts/backup_recuperacao.py backup
python scripts/backup_recuperacao.py backup --multiplos --arquivo backups/ecommerce_logistica.sql
python scripts/backup_recuperacao.py restaurar --config mysql-recovery.ini --arquivo backups/ecommerce_logistica.sql --confirmar-restauracao
```

Não publique arquivos com senhas. Se criar `mysql-recovery.ini`, mantenha-o fora do repositório (a regra `.gitignore` cobre `mysql-*.ini`, exceto o exemplo).

## 4. Entrega na DIO

Projeto disponível em uma pasta própria na branch `projeto-mysql-transacoes-backup-recovery` do repositório de estudos do autor.

**Link para entregar na plataforma:**

https://github.com/1giordani/aula-git/tree/projeto-mysql-transacoes-backup-recovery/projeto-mysql-ecommerce

Cole esse endereço no campo de entrega da DIO. A pasta inclui os scripts, os backups reais e as evidências de validação.

**Descrição para a plataforma:**

> Implementação de transações no MySQL em um banco e-commerce, com COMMIT, ROLLBACK e SAVEPOINT. Inclui procedure para registro de pedidos com tratamento de exceções e reversão automática, controle de estoque, trigger de auditoria, view e evento. O projeto apresenta backup com mysqldump e recuperação de um ou vários bancos, preservando procedures, eventos e triggers, além de scripts e evidências de validação.

## Referências oficiais

- [Transações](https://dev.mysql.com/doc/refman/8.4/en/commit.html)
- [Tratamento de exceções](https://dev.mysql.com/doc/refman/8.4/en/declare-handler.html)
- [Restrições de stored programs](https://dev.mysql.com/doc/refman/8.4/en/stored-program-restrictions.html)
- [mysqldump](https://dev.mysql.com/doc/refman/8.4/en/mysqldump.html)

Consulte `evidencias/VALIDACAO.md` para o ambiente e os resultados efetivamente verificados.
