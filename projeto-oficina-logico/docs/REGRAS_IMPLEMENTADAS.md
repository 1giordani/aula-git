# Mapeamento das regras para o banco físico

O modelo é uma implementação do [esquema conceitual da oficina](https://github.com/1giordani/aula-git/tree/projeto-oficina-conceitual/projeto-oficina-conceitual) criado no desafio anterior.

| Regra | Implementação |
| --- | --- |
| Identificação das entidades | PKs simples e compostas, conforme `01_estrutura.sql` |
| Placa não repetida | UNIQUE em veiculo.placa |
| Vínculos entre entidades | FKs InnoDB, sem exclusões em cascata |
| Solicitante atual no momento da abertura | Trigger de inclusão da OS confere o cliente do veículo |
| Solicitante histórico preservado | Cliente solicitante, veículo, equipe, emissão e tipo não podem ser alterados na OS |
| Equipe com ao menos um mecânico ativo | Trigger de inclusão verifica participação válida na data de emissão |
| Mesma equipe avalia e executa | Um único id_equipe imutável na OS |
| Equipe não muda de composição com OS aberta | Triggers de inclusão, alteração e exclusão de composição |
| Períodos de um par equipe/mecânico não se sobrepõem | Triggers de inclusão/alteração verificam intervalos inclusivos |
| Previsão e conclusão consistentes | CHECKs de datas e de vínculo entre status e conclusão efetiva |
| Orçamento com ao menos um serviço | Trigger de mudança para aguardando autorização |
| Apenas o solicitante decide | FK composta `(numero_os,id_cliente)` para `(numero_os,id_cliente_solicitante)` |
| Valor e data da decisão | Trigger confere valor da view e data não anterior à emissão |
| Uma decisão final por OS | UNIQUE em autorizacao.numero_os; UPDATE e DELETE da decisão bloqueados |
| Execução exige aprovação | Trigger exige decisão favorável e uma transição de status válida |
| Orçamento congelado na submissão | Itens só podem mudar quando a OS está em avaliação |
| Preço de referência preservado | Trigger copia o preço na inclusão e mantém o preço histórico em atualizações de quantidade |
| Unidade de cobrança histórica | unidade_aplicada é copiada junto ao preço do serviço |
| Quantidades válidas | CHECKs de quantidade positiva e número inteiro em serviços de preço fixo; quantidade de peça é inteira |
| Subtotal e total | Colunas geradas e view de agregações independentes |

## Adaptações do conceitual

- `valor_total`, originalmente derivado na OS, foi implementado em `vw_total_os`; uma coluna gerada MySQL não pode agregar linhas de outras tabelas.
- A unidade do serviço foi adicionada ao item como cópia histórica, junto ao preço, para preservar a interpretação de sua quantidade.
- O par único `(numero_os,id_cliente_solicitante)` dá suporte à FK composta de autorização. Embora o número da OS já seja único, o índice composto expressa a regra de titularidade e atende à chave referenciada de forma explícita.
- Cada atendimento tem uma única decisão final. Revisão do escopo submetido exige nova OS, como no modelo conceitual adotado.
- A previsão pode ser atualizada, mas nunca para antes da emissão; não há histórico dessas alterações de prazo nesta versão.

## Status

Transições permitidas:

- EM_AVALIACAO → AGUARDANDO_AUTORIZACAO ou CANCELADA.
- AGUARDANDO_AUTORIZACAO → AUTORIZADA ou CANCELADA.
- AUTORIZADA → EM_EXECUCAO ou CANCELADA.
- EM_EXECUCAO → CONCLUIDA ou CANCELADA.
- CONCLUIDA e CANCELADA não podem voltar a outro estado.

A autorização é gravada antes de atualizar a OS para AUTORIZADA. A conclusão exige preencher data_efetiva_conclusao no mesmo UPDATE. Uma recusa não aprova execução: a massa demonstra seu encaminhamento explícito para CANCELADA.

## Limites

O projeto é didático e não implementa autenticação, perfis de acesso, pagamentos, estoque de peças, compras, faturamento fiscal ou agenda de capacidade. Nomes e preços de referência do catálogo podem mudar; os preços e unidades históricos dos itens permanecem intactos.

A validade das regras foi testada em operações sequenciais. Embora os gatilhos usem bloqueio da linha da OS para coordenar itens e submissão, não foi realizada uma avaliação de concorrência entre sessões. O projeto não pretende demonstrar isolamento completo de todos os cenários de produção.
