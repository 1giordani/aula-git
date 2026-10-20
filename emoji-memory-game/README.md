# Memória Animal — Jogo da Memória com Emojis

Projeto de **Giordani Martins Silva** para o desafio da DIO, inspirado em [digitalinnovationone/js-emoji-memory-game](https://github.com/digitalinnovationone/js-emoji-memory-game).

## Objetivo
Criar um jogo da memória com HTML, CSS e JavaScript puro, praticando arrays, funções, manipulação do DOM, eventos, condições e temporizadores. A versão mantém o tabuleiro de 16 cartas com oito pares de animais da referência e personaliza a interface.

## Como jogar
- Vire duas cartas. Cada dupla escolhida conta como uma jogada.
- Cartas iguais ficam abertas; cartas diferentes fecham após 850 milissegundos.
- Enquanto um par diferente está aberto, não é possível escolher uma terceira carta.
- Encontre os oito pares com o menor número de jogadas.
- O cronômetro começa na primeira escolha e para na vitória. Ele continua contando se a aba ficar em segundo plano.
- **Nova partida** zera as estatísticas e embaralha novamente, inclusive durante a espera de um par diferente.
- No teclado, use Tab para navegar e Enter/Espaço para virar uma carta.

## Recursos e melhorias
- Embaralhamento Fisher–Yates.
- Bloqueio de cliques repetidos na mesma carta, em cartas encontradas ou durante comparação.
- Contador de jogadas e pares, cronômetro e mensagem de vitória.
- Recorde do menor número de jogadas salvo com localStorage.
- Reinício sem recarregar a página e com cancelamento dos temporizadores anteriores.
- Layout responsivo, botões semânticos, foco visível e nomes acessíveis que não revelam cartas escondidas.
- Respeito à preferência de movimento reduzido.
- Regras separadas da interface, com testes automatizados.

## Executar
1. Baixe esta branch em **Code → Download ZIP** e extraia.
2. Abra `emoji-memory-game/index.html` no navegador.

Não precisa de npm, bibliotecas ou conexão à internet para jogar. Os emojis são renderizados pelo sistema e podem ter aparência diferente conforme o dispositivo.

Opcionalmente, dentro da pasta do projeto:
```bash
python -m http.server 8000
```
Abra `http://localhost:8000`. O servidor local é recomendado para armazenamento consistente do recorde.

## Testes
Com Node.js 18 ou superior:
```bash
npm test
```
Não é necessário instalar dependências. Os dez testes verificam embaralhamento, pares, cliques duplicados, bloqueio durante comparação, vitória, isolamento entre partidas e entradas inválidas.

Também foram conferidos a sintaxe dos scripts e os caminhos locais do HTML. Os testes cobrem as regras, não a aparência em navegador real.

## Estrutura
```text
index.html
src/styles/main.css
src/scripts/game-core.js
src/scripts/engine.js
tests/game-core.test.cjs
package.json
ENTREGA-DIO.md
```

## Recorde e privacidade
O recorde fica somente neste navegador; não existe conta, ranking online ou transmissão de dados. Se o armazenamento for bloqueado, a partida continua e o recorde permanece apenas na sessão. Abrir como arquivo local pode ter comportamento de armazenamento diferente entre navegadores.

## Créditos
Referência didática: [DIO — js-emoji-memory-game](https://github.com/digitalinnovationone/js-emoji-memory-game).
A interface e a organização das regras foram adaptadas para este exercício educacional. Não há dependências externas de imagens, fontes ou scripts.
