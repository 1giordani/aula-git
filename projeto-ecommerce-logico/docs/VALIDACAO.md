# Validação executada

Data: 19/10/2026. Ambiente: MySQL Community Server 8.4.6, Linux, InnoDB e modo SQL estrito padrão.

## Verificações e resultados

- Estrutura, gatilhos e massa executados com sucesso: 13 tabelas, quatro views e 12 triggers.
- Clientes persistidos: três PF e dois PJ. As projeções retornaram esses totais.
- Massa com seis pedidos, sete itens, sete registros de pagamento e duas entregas.
- As 16 consultas executaram sem erro, com quantidades de linhas conferidas. Também foram verificados valores de saldo, empresa com dois papéis, cliente com múltiplas formas e cliente sem pedidos.
- Totais dos pedidos: 1001 = 320.00; 1002 = 930.00; 1003 = 290.00; 1004 = 0.00; 1005 = 95.00; 1006 = 120.00.
- Soma de pagamentos aprovados = 1410.00, sem incluir a tentativa pendente de 190.00 nem a recusa de 95.00.
- Fluxo de pedido até quitação, entrega e conclusão executado e revertido com ROLLBACK, sem alterar a massa.
- Aprovação temporária do pagamento pendente quitou exatamente 290.00; ROLLBACK preservou a tentativa pendente original.
- Postagem sem rastreio foi rejeitada diretamente pelo CHECK; a transação de preparação do teste foi integralmente revertida.
- Trinta e sete casos negativos compararam todas as tabelas antes e depois do erro, preservando as linhas. Mais um caso rejeitou total negativo na confirmação e removeu os dados de preparação do teste. Somados ao caso de postagem sem rastreio, foram 39 cenários negativos.
- Casos negativos incluem CPF/PJ misturados ou incompletos, documentos duplicados, cliente ou forma incompatível com pedido, pagamento acima do total, falta de data, alteração de preço/itens históricos, quantidades inválidas e transições indevidas.
- O dicionário foi extraído dos metadados da instância executada.
- SVGs foram renderizados e revisados visualmente; o XML do arquivo Draw.io foi verificado pelo gerador.

## Evidências

- `evidencias/testes.txt`: resultados do teste real.
- `evidencias/consultas_resultados.txt`: perguntas, cabeçalhos e resultados das 16 consultas.
- `evidencias/fluxo_rollback.txt`: pedido de exemplo de 160.00 concluído e ausência após rollback.
- `evidencias/inventario.txt`: tabelas, views e triggers instaladas.
- `evidencias/colunas.tsv` e `evidencias/chaves_estrangeiras.tsv`: metadados de colunas e referências.

## Limites

Não foram realizados testes de concorrência, carga, desempenho ou backup. Os dados e referências de pagamento são fictícios. A validação de CPF/CNPJ verifica exclusividade, obrigatoriedade, tamanho e unicidade, não autenticidade ou dígitos verificadores. O arquivo Draw.io foi gerado como XML editável, sem alegação de edição na interface web do diagrams.net.
