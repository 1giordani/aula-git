# Regras de negócio

## 1. Clientes, veículos e histórico

- Cada veículo pertence a um cliente atual; um cliente pode possuir zero ou muitos veículos. A placa é única nesta versão, destinada a veículos com placa registrada.
- Cada OS tem exatamente um veículo, um cliente solicitante e uma equipe responsável.
- O solicitante é o cliente atual do veículo no momento de abertura. Essa regra entre caminhos é adicional às FKs e deverá ser implementada explicitamente numa futura base física.
- A OS preserva o solicitante histórico. Mudança de proprietário do veículo não altera as OSs anteriores.
- O mesmo veículo pode ter várias OSs ao longo do tempo. Não há uma equipe fixa vinculada diretamente ao veículo.

## 2. Equipes e mecânicos

- Cada mecânico tem código único, nome, endereço e especialidade. A narrativa usa especialidade no singular; o modelo também registra uma por mecânico.
- COMPOSIÇÃO DA EQUIPE resolve a relação N:N, com PK `(id_equipe, codigo_mecanico, data_inicio)` e data de saída opcional. Isso permite registrar diferentes períodos de participação do mesmo mecânico na mesma equipe.
- Períodos do mesmo par equipe/mecânico não podem se sobrepor. Data final, quando informada, deve ser posterior ou igual à inicial.
- Equipe recém-criada pode não ter integrantes. Para receber uma OS, deve ter ao menos um participante ativo.
- A mesma equipe avalia e executa a OS: existe somente um `id_equipe` na OS, não campos separados para equipe avaliadora e executora.
- Nesta versão, a equipe e sua composição são preservadas da avaliação até a conclusão ou cancelamento da OS. Um ajuste excepcional de equipe durante esse período não está modelado.
- Um mecânico pode participar de mais de uma equipe em períodos sobrepostos, mas o controle de agenda e capacidade não está no escopo. Essa é uma escolha autoral, não uma exigência da narrativa.

## 3. OS e datas

- `numero_os` é o identificador da ordem.
- Emissão e previsão de conclusão são obrigatórias. A previsão representa a data de entrega prometida durante a abertura/avaliação.
- A previsão não pode ser anterior à emissão. A conclusão efetiva é opcional enquanto os trabalhos não terminaram.
- Uma OS concluída deve ter data efetiva de conclusão, não anterior à emissão. O modelo permite atraso: a conclusão efetiva pode ser posterior à prevista.
- Os status autorais são em avaliação, aguardando autorização, autorizada, em execução, concluída e cancelada.
- A OS pode ter zero itens durante a avaliação inicial. Para aguardar autorização, precisa de pelo menos um serviço; nenhuma peça é obrigatória.
- A OS em execução ou concluída precisa de autorização favorável previamente registrada pelo seu solicitante. Não se pode executar uma OS recusada ou cancelada.

## 4. Serviços e referência de mão de obra

- SERVIÇO / MÃO DE OBRA representa a tabela de referência da narrativa: identifica o serviço, sua descrição, unidade de cobrança e valor unitário atual.
- Um serviço pode estar em várias OSs e uma OS pode conter vários serviços. SERVIÇO DA OS resolve o N:N com PK `(numero_os, id_servico)`.
- A unidade é hora ou serviço; a quantidade representa horas de trabalho ou quantidade de execuções, respectivamente.
- Quantidade deve ser positiva e o preço unitário não negativo. Serviços cobrados por execução usam quantidade inteira; horas podem ser fracionadas.
- O valor unitário aplicado é copiado da referência no orçamento e mantido no item. Atualização posterior da referência não modifica a OS.
- Não se prevê negociação fora da referência nesta versão. Caso seja necessária, exigirá uma nova regra explícita.

## 5. Peças e cálculo

- PEÇA identifica o material e seu valor unitário de referência atual.
- PEÇA DA OS resolve a relação N:N com PK `(numero_os, id_peca)`.
- Quantidade de peças é inteira e positiva; valor aplicado é não negativo e copiado da referência na montagem do orçamento.
- Repetições do mesmo serviço ou da mesma peça na mesma OS são acumuladas no mesmo item. Não se pretende distinguir, por exemplo, duas etapas separadas do mesmo serviço.
- Cada subtotal é derivado de quantidade × valor unitário aplicado.
- Valor total da OS = soma dos subtotais de serviços + soma dos subtotais de peças. Não há descontos, taxas nem tributos no cálculo desta versão.
- Total pode ser recalculado enquanto a OS está em avaliação. Preços e quantidades ficam congelados quando o orçamento é submetido para decisão, preservando o escopo avaliado pelo cliente.

## 6. Autorização e preservação do orçamento

- Uma OS ainda sem decisão tem zero registros de autorização; após a decisão, tem exatamente um.
- AUTORIZAÇÃO registra uma decisão final: autorizada ou recusada, sua data, cliente e valor orçado.
- `numero_os` é único em AUTORIZAÇÃO. O cliente informado precisa ser o solicitante da OS; a FK isoladamente não garante essa igualdade entre entidades.
- O valor orçado da decisão deve coincidir com o total apresentado na OS. A decisão não pode ocorrer antes da emissão.
- Decisão favorável permite avançar para execução; decisão recusada leva ao cancelamento.
- A decisão e o orçamento submetido não são sobrescritos. Revisões de escopo ou valores exigem uma nova OS e nova decisão nesta versão simplificada.
- Uma OS autorizada ou em execução ainda pode ser cancelada; a autorização histórica permanece registrada, mas não permite continuar os trabalhos depois do cancelamento.

## Cardinalidades

Cada registro da entidade filha abaixo possui exatamente um registro pai da entidade indicada à esquerda. A última coluna representa a quantidade possível de filhos por pai.

| Pai | Filha | Cardinalidade por pai |
| --- | --- | --- |
| Cliente | Veículo | 0..N |
| Cliente | OS | 0..N |
| Veículo | OS | 0..N |
| Equipe | OS | 0..N |
| OS | Autorização | 0..1 |
| Cliente | Autorização | 0..N |
| Equipe | Composição da equipe | 0..N; pelo menos um ativo para receber OS |
| Mecânico | Composição da equipe | 0..N |
| OS | Serviço da OS | 0..N; pelo menos um ao submeter orçamento |
| Serviço / mão de obra | Serviço da OS | 0..N |
| OS | Peça da OS | 0..N |
| Peça | Peça da OS | 0..N |

As cardinalidades estáticas não substituem regras de estado, datas, totalização e autorização. Essas condições estão descritas acima para orientar uma implementação futura.
