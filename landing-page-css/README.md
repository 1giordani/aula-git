# Landing Page — Trilha de CSS da DIO

Projeto educacional de **Giordani Martins Silva** para o desafio “Criando sua primeira Landing Page com HTML e CSS”.

## Sobre
Landing page que apresenta a Trilha de CSS da DIO, seus três módulos e uma seção sobre evolução profissional. O HTML de referência foi adaptado e recebeu uma folha de estilos própria. A página usa somente HTML e CSS, sem JavaScript, frameworks ou instalação de dependências.

## Recursos implementados
- HTML semântico com header, nav, main, section e footer.
- CSS externo com variáveis, seletores, box model, unidades relativas e absolutas.
- Tipografia em gradiente com background-clip e fallback de cor.
- Fundos com imagens, sobreposição em gradiente, bordas e sombras.
- Flexbox e Grid para alinhamento e distribuição dos elementos.
- Layout responsivo, imagens fluidas e tamanhos de fonte com clamp.
- Link de salto para conteúdo, textos alternativos e foco de teclado visível.
- Respeito à preferência de movimento reduzido.
- Botão de inscrição com link para a formação da DIO; não há cadastro ou coleta de dados nesta página.

## Arquivos
- `index.html`: estrutura e conteúdo.
- `assets/css/style.css`: toda a estilização.
- `ENTREGA-DIO.md`: descrição pronta para a submissão.

## Como executar
1. Baixe esta branch pelo botão **Code → Download ZIP** no GitHub.
2. Extraia o arquivo.
3. Abra `landing-page-css/index.html` no navegador.

Também pode usar a extensão Live Server do VS Code. Não é necessário Node.js ou npm.

**Conexão à internet:** as cinco imagens são carregadas do repositório oficial da DIO, fixadas no commit `ee6d62c5d85e84a9f57f57b3645be1926b844ece`. Assim, mudanças futuras da branch original não alteram os caminhos usados. A imagem de fundo woman-code.png da referência é grande (cerca de 23 MB), o que pode atrasar sua primeira carga. Uma evolução recomendada é armazenar versões WebP otimizadas localmente.

## Decisões de implementação
Mantive as seções e os textos centrais do desafio e personalizei a navegação, a apresentação dos módulos e os estados de interação. A implementação é uma adaptação própria baseada na estrutura oficial, não uma reprodução pixel a pixel do Figma. A fonte de sistema evita uma requisição adicional a serviços de fontes.

## Verificação
Revisão estática de referências locais, âncoras, estrutura HTML e folha CSS. A aparência em navegadores e os links externos devem ser conferidos ao abrir a página. Não há backend, testes de JavaScript ou formulário de inscrição.

## Referências e créditos
- [Repositório do desafio e origem dos textos/imagens](https://github.com/digitalinnovationone/trilha-css-desafio-01)
- [Protótipo Figma fornecido pela DIO](https://www.figma.com/file/3PiokoJj9IhGDnNiWAJbz7/DIO---Desafio-01?node-id=0%3A1)

As marcas, imagens e o conteúdo educacional de referência pertencem aos respectivos titulares. Uso neste projeto para fins de estudo.
