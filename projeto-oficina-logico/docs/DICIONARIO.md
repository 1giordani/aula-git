# Dicionário físico do banco

Gerado a partir de `information_schema` do MySQL 8.4.6 após a execução dos scripts. O SQL em `sql/01_estrutura.sql` é a definição autoritativa.

## autorizacao

| Coluna | Tipo SQL | Aceita NULL | Chave no metadado | Complemento |
| --- | --- | --- | --- | --- |
| id_autorizacao | `int unsigned` | NO | PRI | — |
| numero_os | `int unsigned` | NO | UNI | — |
| id_cliente | `int unsigned` | NO | MUL | — |
| decisao | `enum('AUTORIZADA','RECUSADA')` | NO | — | — |
| data_decisao | `datetime` | NO | — | — |
| valor_orcado | `decimal(14,2)` | NO | — | — |

## cliente

| Coluna | Tipo SQL | Aceita NULL | Chave no metadado | Complemento |
| --- | --- | --- | --- | --- |
| id_cliente | `int unsigned` | NO | PRI | — |
| nome | `varchar(100)` | NO | — | — |
| telefone | `varchar(20)` | YES | — | — |
| email | `varchar(150)` | YES | — | — |
| endereco | `varchar(200)` | NO | — | — |

## composicao_equipe

| Coluna | Tipo SQL | Aceita NULL | Chave no metadado | Complemento |
| --- | --- | --- | --- | --- |
| id_equipe | `int unsigned` | NO | PRI | — |
| codigo_mecanico | `int unsigned` | NO | PRI | — |
| data_inicio | `date` | NO | PRI | — |
| data_fim | `date` | YES | — | — |

## equipe

| Coluna | Tipo SQL | Aceita NULL | Chave no metadado | Complemento |
| --- | --- | --- | --- | --- |
| id_equipe | `int unsigned` | NO | PRI | — |
| nome_equipe | `varchar(100)` | NO | — | — |

## mecanico

| Coluna | Tipo SQL | Aceita NULL | Chave no metadado | Complemento |
| --- | --- | --- | --- | --- |
| codigo_mecanico | `int unsigned` | NO | PRI | — |
| nome | `varchar(100)` | NO | — | — |
| endereco | `varchar(200)` | NO | — | — |
| especialidade | `varchar(100)` | NO | — | — |

## ordem_servico

| Coluna | Tipo SQL | Aceita NULL | Chave no metadado | Complemento |
| --- | --- | --- | --- | --- |
| numero_os | `int unsigned` | NO | PRI | — |
| id_cliente_solicitante | `int unsigned` | NO | MUL | — |
| id_veiculo | `int unsigned` | NO | MUL | — |
| id_equipe | `int unsigned` | NO | MUL | — |
| data_emissao | `date` | NO | — | — |
| data_prevista_conclusao | `date` | NO | — | — |
| data_efetiva_conclusao | `date` | YES | — | — |
| tipo_atendimento | `enum('REPARO','REVISAO')` | NO | — | — |
| status | `enum('EM_AVALIACAO','AGUARDANDO_AUTORIZACAO','AUTORIZADA','EM_EXECUCAO','CONCLUIDA','CANCELADA')` | NO | MUL | — |

## peca

| Coluna | Tipo SQL | Aceita NULL | Chave no metadado | Complemento |
| --- | --- | --- | --- | --- |
| id_peca | `int unsigned` | NO | PRI | — |
| descricao | `varchar(150)` | NO | — | — |
| valor_unitario_referencia | `decimal(10,2)` | NO | — | — |

## peca_os

| Coluna | Tipo SQL | Aceita NULL | Chave no metadado | Complemento |
| --- | --- | --- | --- | --- |
| numero_os | `int unsigned` | NO | PRI | — |
| id_peca | `int unsigned` | NO | PRI | — |
| quantidade | `int unsigned` | NO | — | — |
| valor_unitario_aplicado | `decimal(10,2)` | NO | — | — |
| subtotal | `decimal(14,2)` | YES | — | STORED GENERATED |

## servico

| Coluna | Tipo SQL | Aceita NULL | Chave no metadado | Complemento |
| --- | --- | --- | --- | --- |
| id_servico | `int unsigned` | NO | PRI | — |
| descricao | `varchar(150)` | NO | — | — |
| unidade_cobranca | `enum('HORA','SERVICO')` | NO | — | — |
| valor_unitario_referencia | `decimal(10,2)` | NO | — | — |

## servico_os

| Coluna | Tipo SQL | Aceita NULL | Chave no metadado | Complemento |
| --- | --- | --- | --- | --- |
| numero_os | `int unsigned` | NO | PRI | — |
| id_servico | `int unsigned` | NO | PRI | — |
| quantidade | `decimal(8,2)` | NO | — | — |
| unidade_aplicada | `enum('HORA','SERVICO')` | NO | — | — |
| valor_unitario_aplicado | `decimal(10,2)` | NO | — | — |
| subtotal | `decimal(14,2)` | YES | — | STORED GENERATED |

## veiculo

| Coluna | Tipo SQL | Aceita NULL | Chave no metadado | Complemento |
| --- | --- | --- | --- | --- |
| id_veiculo | `int unsigned` | NO | PRI | — |
| id_cliente_atual | `int unsigned` | NO | MUL | — |
| placa | `char(7)` | NO | UNI | — |
| marca | `varchar(50)` | NO | — | — |
| modelo | `varchar(80)` | NO | — | — |
| ano | `smallint unsigned` | NO | — | — |

## Chaves estrangeiras

Uma FK composta aparece em duas linhas com o mesmo nome de constraint.

| Tabela | Constraint | Coluna | Referência |
| --- | --- | --- | --- |
| autorizacao | autorizacao_ibfk_1 | numero_os | ordem_servico.numero_os |
| autorizacao | autorizacao_ibfk_1 | id_cliente | ordem_servico.id_cliente_solicitante |
| autorizacao | autorizacao_ibfk_2 | id_cliente | cliente.id_cliente |
| composicao_equipe | composicao_equipe_ibfk_1 | id_equipe | equipe.id_equipe |
| composicao_equipe | composicao_equipe_ibfk_2 | codigo_mecanico | mecanico.codigo_mecanico |
| ordem_servico | ordem_servico_ibfk_1 | id_cliente_solicitante | cliente.id_cliente |
| ordem_servico | ordem_servico_ibfk_2 | id_veiculo | veiculo.id_veiculo |
| ordem_servico | ordem_servico_ibfk_3 | id_equipe | equipe.id_equipe |
| peca_os | peca_os_ibfk_1 | numero_os | ordem_servico.numero_os |
| peca_os | peca_os_ibfk_2 | id_peca | peca.id_peca |
| servico_os | servico_os_ibfk_1 | numero_os | ordem_servico.numero_os |
| servico_os | servico_os_ibfk_2 | id_servico | servico.id_servico |
| veiculo | fk_veiculo_cliente | id_cliente_atual | cliente.id_cliente |

## Total derivado e subtotais

`servico_os.subtotal` e `peca_os.subtotal` são colunas geradas armazenadas. `vw_total_os` inclui os dados da OS e acrescenta total_servicos, total_pecas e valor_total, usando agregações separadas para evitar multiplicação de linhas. O total não é uma coluna física de ordem_servico.
