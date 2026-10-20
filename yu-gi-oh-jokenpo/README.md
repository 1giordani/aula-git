# Yu-Gi-Oh! — Jo-ken-po Edition

Projeto educacional de **Giordani Martins Silva** para o desafio da DIO, baseado em [digitalinnovationone/js-yugioh-assets](https://github.com/digitalinnovationone/js-yugioh-assets).

## Sobre
Jogo de pedra, papel e tesoura com cartas do universo Yu-Gi-Oh! Desenvolvido com HTML, CSS e JavaScript puro para praticar gerenciamento de estado, funções, organização de código, eventos e manipulação do DOM.

O repositório indicado no desafio fornece os recursos visuais e sonoros, mas seus arquivos index.html e engine.js estão vazios na versão consultada. Esta implementação constrói a interface e a lógica a partir desses recursos e do objetivo Jo-ken-po descrito no README de referência. É uma adaptação própria; não foi possível conferir o passo a passo da aula em vídeo.

## Regras
| Carta | Tipo | Vence |
|---|---|---|
| Exodia | Pedra | Mago Negro |
| Dragão Branco | Papel | Exodia |
| Mago Negro | Tesoura | Dragão Branco |

- Você recebe cinco cartas por rodada. A mão contém pelo menos uma carta de cada tipo.
- Clique em uma carta para jogar. O computador sorteia um dos três tipos com a mesma chance para cada um.
- A fileira superior de cinco cartas viradas representa visualmente a mão oculta; o sorteio do computador é independente dessa fileira.
- Cartas iguais empatam e não dão pontos.
- A primeira pessoa a alcançar **cinco vitórias** vence o duelo.
- Clique em **Próxima rodada** para uma nova mão ou em **Novo duelo** para zerar o placar e o histórico.
- Passe o mouse ou dê foco com Tab em uma carta para ver seu nome, tipo e vantagem. Enter/Espaço selecionam a carta.
- O som começa desligado e pode ser ativado pelo botão da página.

## Recursos
- Três tipos de cartas e comparação completa das nove combinações.
- Placar, contador de rodadas, empates e histórico das últimas cinco rodadas.
- Uma única escolha por rodada e bloqueio após o fim do duelo.
- Sons de vitória/derrota opcionais.
- Interface responsiva, botões semânticos, foco visível e mensagens anunciadas.
- Regras separadas do DOM e testes automatizados.
- Recursos utilizados armazenados localmente: sem dependência de links externos para jogar.

## Como executar
Baixe esta branch em **Code → Download ZIP**, extraia e abra `yu-gi-oh-jokenpo/index.html` no navegador.

Não é necessário instalar dependências, ter conta ou estar conectado à internet.
Opcionalmente, dentro da pasta do projeto:
```bash
python -m http.server 8000
```
Abra `http://localhost:8000`.

## Testes
Requer Node.js 18 ou superior apenas para executar os testes:
```bash
npm test
```
Não precisa executar npm install. Os testes verificam todas as combinações de cartas, sorteio, composição da mão, pontuação, empates, bloqueio de escolha, vitória de ambos os lados e reinício do estado.

Também foram verificadas a sintaxe dos scripts e as referências locais do HTML. A aparência e a reprodução de áudio ainda precisam ser conferidas em um navegador real.

## Estrutura
```text
index.html
src/styles/main.css
src/scripts/game-core.js
src/scripts/engine.js
src/assets/icons/
src/assets/audios/
tests/game-core.test.cjs
package.json
ENTREGA-DIO.md
```

## Créditos
- Referência didática e arquivos de cartas/sons: [Digital Innovation One — js-yugioh-assets](https://github.com/digitalinnovationone/js-yugioh-assets).
- Yu-Gi-Oh!, personagens e demais elementos pertencem aos respectivos titulares. Uso educacional, sem afiliação oficial.
- Interface e lógica desta versão adaptadas para o portfólio de Giordani Martins Silva.

## Limitações
O placar existe apenas durante a sessão da página; recarregar reinicia o duelo. O jogo é local contra o computador, sem multiplayer, ranking online ou coleta de dados. A música e o vídeo do pacote original não foram incluídos; são utilizados apenas as três cartas, o verso e os efeitos de resultado.
