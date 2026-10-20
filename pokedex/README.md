# Pokédex — Explore Kanto

Projeto educacional de **Giordani Martins Silva** para o desafio da DIO, baseado em [digitalinnovationone/js-developer-pokedex](https://github.com/digitalinnovationone/js-developer-pokedex).

## Objetivo
Consumir uma API REST com JavaScript e apresentar os 151 Pokémon da primeira geração em uma interface responsiva, aplicando HTML semântico, CSS, funções, arrays, Promises, async/await, fetch e manipulação do DOM.

## Funcionalidades
- Catálogo dos 151 Pokémon de Kanto, como no projeto de referência.
- Carregamento de 12 registros por página.
- Busca parcial por nome ou exata por número, com ou sem # e zeros iniciais.
- Filtro por tipo sobre o catálogo inteiro, inclusive Pokémon ainda não exibidos.
- Ordenação por número ou nome.
- Detalhes em modal: imagem, tipos, altura, peso, habilidades e atributos base.
- Estados de carregamento, erro e lista vazia, com botão para tentar novamente.
- Cache em memória e localStorage por sete dias; falhas de armazenamento não impedem uso.
- Deduplicação de consultas, até quatro consultas de detalhes simultâneas e timeout de 12 segundos por requisição.
- Proteção contra respostas antigas sobrescreverem filtros mais recentes.
- Imagens com carregamento adiado e texto alternativo quando indisponíveis.
- Layout responsivo e controles acessíveis por teclado.

## Executar
Baixe esta branch em **Code → Download ZIP**, extraia e abra `pokedex/index.html` em um navegador moderno.

Para desenvolvimento, é recomendado executar um servidor local dentro da pasta `pokedex`:
```bash
python -m http.server 8000
```
Abra `http://localhost:8000`.

Não precisa instalar dependências. A aplicação depende de conexão à internet para consultar dados e carregar imagens na primeira utilização.

## API e unidades
A aplicação usa a [PokéAPI v2](https://pokeapi.co/docs/v2/):
- `GET /pokemon?limit=151&offset=0`: índice de nomes e números.
- `GET /pokemon/{id}/`: detalhes.
- `GET /type/{name}/`: composição dos tipos.

Os valores de altura e peso são convertidos respectivamente de decímetros para metros e de hectogramas para quilogramas. Os atributos exibidos são atributos base, não os valores calculados para um nível específico. Os nomes de Pokémon e habilidades são fornecidos pela API; rótulos de tipos e atributos são apresentados em português.

O filtro usa os tipos atuais da API para os 151 Pokémon, incluindo alterações posteriores à primeira geração. Tipos sem representantes nesse recorte mostram uma lista vazia.

## Testes
Com Node.js 18 ou superior:
```bash
npm test
```
Não precisa executar npm install. Os 15 testes utilizam respostas simuladas para validar conversões, filtros, ordenação, cache, deduplicação, erros, timeout e concorrência.

Também foram verificadas a sintaxe dos scripts e as referências locais do HTML. Os testes não comprovam disponibilidade da API ao vivo nem substituem a conferência visual em navegador real.

## Estrutura
```text
index.html
assets/css/style.css
assets/js/poke-api.js
assets/js/main.js
tests/poke-api.test.cjs
package.json
ENTREGA-DIO.md
```

## Decisões de implementação
O índice é carregado antes dos detalhes para permitir busca global com poucas requisições. A lista de cada tipo é cruzada com os números de Kanto. O modal reutiliza os detalhes já recebidos. O cache segue a recomendação de uso responsável da PokéAPI e pode ser removido limpando os dados do site no navegador.

Os dados externos são inseridos com textContent e criação de elementos, sem interpolar conteúdo da API em HTML.

## Créditos
- Referência didática: [DIO — js-developer-pokedex](https://github.com/digitalinnovationone/js-developer-pokedex).
- Dados e imagens: [PokéAPI](https://pokeapi.co/), com sprites apontados pela própria API.
- Pokémon pertence aos respectivos titulares. Este é um projeto educacional sem afiliação oficial.

## Limitações e privacidade
A consulta depende da disponibilidade da API e do serviço de imagens. O cache cobre somente recursos já consultados; a aplicação não é uma PWA e não garante uso offline. O navegador pode bloquear armazenamento ao abrir arquivos locais; nesse caso o cache continua em memória durante a sessão.

Não há cadastro ou coleta própria de dados pessoais. O navegador realiza requisições aos serviços externos de dados e imagens.
