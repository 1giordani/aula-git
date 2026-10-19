# Revisão do esquema

Data: 19/10/2026.

## Verificações realizadas

- Correspondência dos itens da narrativa com entidades, atributos e relacionamentos, conforme tabela do README.
- Identificação das 11 entidades e dos 12 relacionamentos únicos. O vínculo equipe/OS é repetido em dois recortes para facilitar a leitura, sem representar uma segunda relação.
- Presença de PK nas entidades e coerência das FKs indicadas com os relacionamentos.
- Identificação de chaves compostas nos serviços, peças e participações de mecânicos.
- Uma única equipe na OS, responsável por avaliar e executar.
- Autorização explícita do solicitante e regra de bloqueio da execução sem decisão favorável.
- Inclusão de número, emissão, status, previsão de conclusão, conclusão efetiva e valor da OS.
- Preservação dos valores aplicados nos itens e totalização de serviços e peças.
- Geração dos três SVGs e do arquivo Draw.io com três páginas a partir da mesma fonte JSON.
- Leitura XML para conferir integridade estrutural dos arquivos.
- Renderização dos três SVGs e revisão visual para verificar legibilidade, cardinalidades e distribuição dos elementos.

## Limites

O projeto é um esquema conceitual. Não foi executado em um SGBD nem se afirma que regras condicionais tenham sido verificadas como constraints SQL.

O Draw.io foi gerado como XML não comprimido com elementos editáveis. Sua estrutura foi conferida; não se afirma que tenha sido aberto e editado na interface web. As imagens SVG foram efetivamente renderizadas para inspeção visual.

A revisão usa a narrativa enviada pelo usuário. Não foi necessária a análise do vídeo para identificar os requisitos aqui atendidos.
