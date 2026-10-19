# Validação executada

Data: 19/10/2026. Ambiente: MySQL Community Server 8.4.6, Linux, tabelas InnoDB e modo estrito padrão da instalação.

## Resultados reais

- Os scripts de estrutura, regras e dados foram executados com sucesso.
- Foram criadas 11 tabelas, uma view e 14 triggers.
- Foram persistidos cinco clientes, seis veículos, três equipes, cinco mecânicos, quatro participações, quatro serviços, quatro peças, seis OSs, seis itens de serviço, quatro itens de peça e quatro decisões.
- Todas as 14 consultas foram executadas e suas quantidades de linhas verificadas. Valores de atraso, cliente sem OS, ranking e serviço selecionado por HAVING também foram conferidos.
- Totais das OSs: 1001 = 280.00; 1002 = 500.00; 1003 = 450.00; 1004 = 0.00; 1005 = 120.00; 1006 = 750.00.
- Soma dos valores de OSs concluídas = 1030.00. Esse indicador não representa pagamentos recebidos.
- Fluxo completo de inclusão, orçamento, autorização, execução e conclusão executado em transação e desfeito com ROLLBACK.
- Teste com dois serviços e duas peças totalizou 790.00, sem duplicação por junções.
- Alteração temporária do proprietário do veículo não alterou o solicitante histórico da OS.
- Vinte e sete casos negativos compararam os dados antes e depois do erro e mantiveram as linhas inalteradas.
- Um caso adicional rejeitou sobreposição de participação de mecânico em equipe; o registro de preparação do teste foi removido ao final.
- O dicionário foi extraído dos metadados da instância executada.
- Os diagramas SVG foram renderizados e revisados visualmente; o XML do Draw.io foi verificado pelo gerador.

## Evidências

- `evidencias/testes.txt`: resultados do script de integração.
- `evidencias/consultas_resultados.txt`: as 14 perguntas com cabeçalhos e resultados reais.
- `evidencias/fluxo_rollback.txt`: orçamento de exemplo de 290.00, conclusão e confirmação de ausência da OS após rollback.
- `evidencias/inventario.txt`: tabelas, view e triggers instaladas.
- `evidencias/colunas.tsv` e `evidencias/chaves_estrangeiras.tsv`: metadados usados no dicionário.

## Limites dos testes

Não foram executados testes de carga, concorrência, desempenho ou restauração de backup. Os dados são fictícios e as consultas temporais usam 19/10/2026 como referência fixa. A estrutura Draw.io foi gerada e validada como XML; não se afirma que tenha sido editada na interface web do diagrams.net.
