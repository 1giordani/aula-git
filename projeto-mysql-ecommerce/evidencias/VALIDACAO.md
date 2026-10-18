# Validação executada

Data: 18/10/2026. Ambiente: MySQL Community Server 8.4.6, Linux, tabelas InnoDB. Foram usadas duas instâncias temporárias separadas: origem e recuperação. Os dumps foram efetivamente produzidos pelo executável `mysqldump` 8.4.6, e não escritos manualmente.

## Resultados

- Criação dos dois bancos e de todos os objetos: aprovada.
- Script com COMMIT, ROLLBACK e SAVEPOINT: executado sem erros; estoque final 27.
- Pedido válido de duas unidades: estoque 25 e pedido de R$ 300,00.
- Falha simulada após as inserções: rollback integral, sem mudanças persistidas em estoque, pedidos, itens e auditoria.
- Estoque insuficiente: erro e estado preservado.
- Cliente inexistente: erro de chave estrangeira após a atualização do estoque, integralmente revertida.
- Quantidade zero ou nula: erro e estado preservado.
- Produto inexistente: erro e estado preservado.
- Backup de `ecommerce`: gerado com sucesso em `backups/ecommerce.sql`.
- Backup de `ecommerce` e `logistica`: gerado com sucesso em `backups/ecommerce_logistica.sql`.
- Recovery do backup de dois bancos: executado em uma segunda instância MySQL.
- Comparação da saída de `sql/05_verificar_recuperacao.sql` entre origem e recuperação: idêntica, incluindo as linhas das tabelas, a consulta à view e a presença da procedure, trigger e evento desabilitado.

## Evidências incluídas

- `testes_transacoes.txt`: saída do teste de integração.
- `teste_recuperacao.txt`: resultado da comparação após recovery.
- `origem.txt` e `recuperado.txt`: consultas executadas nos dois servidores.

A restauração do backup de um único banco não foi executada separadamente. A concorrência entre clientes não foi testada. O evento não foi executado, pois está desabilitado por projeto. A submissão na plataforma DIO será realizada pelo autor usando o link do projeto.

## Reproduzir os testes

Em outro servidor de laboratório, sem os bancos `ecommerce` e `logistica` existentes:

```sh
python scripts/testar_transacoes.py --config mysql-local.ini
```

Esse comando cria o cenário, executa as transações e verifica os erros esperados. Depois siga os comandos de backup/recovery do README e compare as consultas nos servidores de origem e destino. Não rode o teste sobre um banco de produção.
