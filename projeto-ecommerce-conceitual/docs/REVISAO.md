# Revisão do modelo e dos arquivos

Data: 19/10/2026.

## Verificações realizadas

- Conferência dos três refinamentos com as instruções escritas da DIO.
- Cobertura das 15 entidades e dos 15 relacionamentos nos três recortes.
- Correspondência das FKs indicadas em cada entidade filha com seus relacionamentos.
- Presença de PK em todas as entidades e identificação das chaves compostas das associações.
- Consistência da regra total + XOR entre PF e PJ.
- Distinção entre forma de pagamento cadastrada e pagamento de um pedido.
- Declaração da regra de titularidade entre cliente do pedido e cliente da forma de pagamento.
- Identificação de entrega com status e rastreio condicional à postagem.
- Geração dos três SVGs e do Draw.io de três páginas a partir da mesma fonte JSON.
- Leitura XML dos quatro arquivos para conferir sua integridade estrutural.
- Renderização dos SVGs em imagens e revisão visual de legibilidade, cardinalidades e posicionamento.

## Limites

Esta é uma entrega conceitual. Não foi criado ou executado um banco MySQL para este projeto. As restrições de negócio descritas não foram testadas como constraints de um SGBD. Os símbolos de PK/FK e os domínios indicam a intenção de mapeamento, sem substituir implementação transacional futura.

O arquivo Draw.io foi gerado em XML não comprimido, com entidades, relações e rótulos editáveis. Sua estrutura XML foi verificada; não se afirma que foi aberto e editado na interface web do diagrams.net. As imagens SVG foram efetivamente renderizadas para inspeção visual.
