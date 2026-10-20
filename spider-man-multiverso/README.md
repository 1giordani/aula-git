# Spider-Man — Multiversos

Projeto educacional de **Giordani Martins Silva**, inspirado no desafio [Spider-Man Multiverses da DIO, por Michele Ambrosio](https://github.com/micheleambrosio/spider-man-multiverses-dio).

## Objetivo
Praticar efeitos CSS, animações, posicionamento e composição visual através de um site sobre três universos do Homem-Aranha. A interface foi adaptada a partir dos recursos da referência, sem frameworks.

## Recursos
- Carrossel 3D com perspective, transform-style e rotateY.
- Camadas de cenário, personagem e texto com translateZ, sobreposição, filtros e sombras.
- Efeitos de hover e foco.
- Três universos: Tobey Maguire, Tom Holland e Andrew Garfield.
- Seleção de oito filmes por uma página interna reutilizável.
- Navegação por URLs com parâmetros, permitindo abrir cada filme diretamente.
- Galeria do universo com ampliação em dialog nativo.
- Player de vídeos de referência, aberto apenas por solicitação e sem autoplay.
- Layout responsivo, controles por teclado e suporte a prefers-reduced-motion.

## Como executar
Baixe esta branch em **Code → Download ZIP**, extraia e abra `spider-man-multiverso/index.html`.

Para desenvolvimento, execute dentro dessa pasta:
```bash
python -m http.server 8000
```
Acesse `http://localhost:8000`.

Não há instalação de dependências. **É necessário acesso à internet para os recortes dos personagens, logos, parte da galeria e vídeos.**

## Navegação
Na página inicial, use os botões 01, 02 e 03 ou as setas. Quando um controle estiver em foco, ← e → trocam de universo; Home e End selecionam as extremidades. O card ativo abre a página interna.

Na página interna, escolha outro universo ou outro filme. Clique em uma imagem para ampliar. Escape fecha os diálogos. O vídeo possui controles nativos e é interrompido ao fechar a janela.

Exemplos de rotas:
- `pages/universo.html?hero=tobey&film=1`
- `pages/universo.html?hero=tom&film=3`
- `pages/universo.html?hero=andrew&film=2`

## Organização e decisões
Os dados ficam em `assets/js/data.js`; a página de filmes usa uma única estrutura para as oito rotas. Parâmetros inválidos recebem uma seleção padrão válida.

A referência contém datas e sinopses repetidas em páginas de filmes diferentes. Esta adaptação usa títulos e anos correspondentes às oito produções, sem copiar as sinopses repetidas. A galeria é identificada como galeria do universo, pois algumas imagens de referência são compartilhadas entre filmes.

O conteúdo é uma adaptação própria, não uma reprodução pixel a pixel do Figma; a aula em vídeo não foi assistida.

## Recursos locais e remotos
O ícone e uma imagem de cada universo estão incluídos localmente. As demais mídias são carregadas do repositório original no commit `7654422bc2a0cab81eb07c5c49530fa05e5a8d2b`, evitando depender de alterações futuras da branch main.

Os recortes e vídeos originais são grandes e podem demorar a carregar. Recortes indisponíveis usam uma imagem local alternativa. Os vídeos são recursos do material didático; seu conteúdo audiovisual não foi conferido nesta implementação.

## Testes
Com Node.js 18 ou superior:
```bash
npm test
```
Não precisa executar npm install. Os cinco testes verificam integridade do catálogo, oito rotas, parâmetros inválidos, navegação circular e caminhos das mídias na referência consultada.

Também foram conferidos a sintaxe dos scripts e os caminhos locais do HTML. Não houve conferência visual em navegador real; os testes não garantem disponibilidade futura das mídias remotas.

## Estrutura
```text
index.html
pages/universo.html
assets/css/style.css
assets/js/data.js
assets/js/home.js
assets/js/universe.js
assets/images/
tests/
package.json
ENTREGA-DIO.md
```

## Créditos
- [Código e recursos originais — Michele Ambrosio / DIO](https://github.com/micheleambrosio/spider-man-multiverses-dio).
- [Figma fornecido no desafio](https://www.figma.com/file/GjvdE0uob68X6pEHqw2pY8/Multiverse-Spider-Man?type=design&node-id=1-17&mode=design).
- Spider-Man, personagens, imagens e vídeos pertencem aos respectivos titulares. Uso educacional, sem vínculo oficial.
- Interface e interações desta versão adaptadas para o portfólio de Giordani Martins Silva.

## Limitações
A aplicação não possui backend, cadastro, streaming próprio ou coleta de dados pessoais. Ao carregar as mídias, o navegador consulta o serviço de arquivos do GitHub. O site não é hospedado por este repositório automaticamente: baixe e abra o HTML para visualizar.
