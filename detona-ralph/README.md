# Detona Ralph — JavaScript Game

Projeto educacional de **Giordani Martins Silva**, desenvolvido para o desafio da DIO a partir de [digitalinnovationone/jsgame-detona-ralph](https://github.com/digitalinnovationone/jsgame-detona-ralph).

## Objetivo
Praticar HTML, CSS e JavaScript criando um jogo de reflexos com um tabuleiro de nove janelas. O Ralph muda de posição e o jogador deve acertá-lo antes que apareça em outra janela.

## Como jogar
1. Abra `index.html` no navegador e escolha a dificuldade.
2. Clique em **Iniciar jogo**.
3. Clique/toque na janela do Ralph ou use as teclas **1 a 9**, na ordem das janelas, da esquerda para a direita e de cima para baixo.
4. Cada acerto soma **1 ponto**. Clicar em uma janela vazia remove **1 vida**.
5. A partida termina ao completar **60 segundos** ou perder as **3 vidas**.
6. Use **Pausar/Continuar** ou **Reiniciar partida**. Trocar de aba pausa automaticamente.
7. O som é opcional e começa desligado.

Deixar o Ralph escapar não remove vida. Clicar novamente em uma janela após um acerto conta como clique em janela vazia.

## Melhorias em relação à referência
- Início explícito, reinício e pausa sem acumular temporizadores.
- Sistema de vidas funcional.
- Três dificuldades: fácil (1000 ms), normal (700 ms) e difícil (450 ms).
- Contagem por tempo decorrido, evitando depender somente da quantidade de ticks.
- Recorde local salvo no navegador, compartilhado entre as dificuldades.
- Controle de som e tratamento de falhas na reprodução.
- Layout responsivo e botões acessíveis por teclado.
- Regras separadas do DOM e testes automatizados.

## Tecnologias e conceitos
HTML5 semântico; CSS3 com variáveis, Grid, Flexbox e media queries; JavaScript puro com manipulação do DOM, eventos, números aleatórios, funções, objetos, temporizadores, Audio e localStorage.

## Executar localmente
Baixe esta branch com **Code → Download ZIP**, extraia e abra `detona-ralph/index.html`.
Não precisa de instalação, framework ou conexão à internet: imagens, áudio e scripts estão no projeto.

Opcionalmente, execute a partir desta pasta:
```bash
python -m http.server 8000
```
Depois acesse `http://localhost:8000`. Um servidor local é recomendado para comportamento consistente do recorde; em páginas abertas como arquivo, o armazenamento depende do navegador.

## Testes
É necessário Node.js 18 ou superior apenas para executar os testes:
```bash
npm test
```
Nenhuma dependência precisa ser instalada. Os testes verificam pontuação, vidas, expiração, pausa, reinício e entradas inválidas. Eles validam as regras; não substituem a conferência visual ou a reprodução de áudio em um navegador real.

## Estrutura
```text
index.html
src/
  styles/main.css
  scripts/game-core.js
  scripts/engine.js
  images/
  audios/hit.m4a
tests/game-core.test.cjs
package.json
ENTREGA-DIO.md
```

## Créditos
Referência didática, imagens e efeito sonoro: [projeto original da DIO](https://github.com/digitalinnovationone/jsgame-detona-ralph), árvore `8d11faae5a7727e6d3a7df3eaf5a2184bca63900`.
As regras e a apresentação desta versão foram adaptadas. Detona Ralph e os personagens pertencem aos respectivos titulares; este é um exercício educacional sem vínculo oficial com os detentores da marca.

## Limitações
O recorde fica somente neste navegador e pode ser perdido ao limpar os dados. Se o armazenamento estiver bloqueado, o jogo continua funcionando e mantém o recorde somente durante a sessão. Não há ranking online, conta ou coleta de dados.
