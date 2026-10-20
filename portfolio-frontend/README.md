# Giordani Silva — Portfólio Front-end

Portfólio educacional de **Giordani Martins Silva**, desenvolvido para o desafio [Construindo seu Portfólio Front-end do Zero](https://github.com/elidianaandrade/dio-lab-portfolio), da Elidiana Andrade / DIO.

## Objetivo
Reunir projetos de estudos de front-end, apresentar as tecnologias praticadas e registrar decisões de implementação. A identidade visual usa fundo escuro, texto em tons quentes, destaques dourados e uma opção de tema claro.

A apresentação identifica o trabalho como portfólio de estudos, sem atribuir experiência profissional, certificações, depoimentos ou percentuais de domínio não informados.

## Funcionalidades
- Seções de início, projetos, sobre e contato pelo perfil público do GitHub.
- Oito projetos com links para seus códigos e documentação.
- Filtros de interfaces, jogos e aplicações.
- Busca por título, descrição ou tecnologia, ignorando caixa e acentos.
- Contagem de resultados e mensagem de busca vazia.
- Alternância de tema com preferência salva no navegador.
- Menu responsivo e indicação da seção atual.
- HTML semântico, foco visível, link de salto e movimento reduzido.
- Sem dependências de fontes, imagens, ícones ou frameworks externos.

## Projetos incluídos
| Projeto | Categoria |
|---|---|
| Landing Page CSS | Interfaces |
| Pokédex de Kanto | Aplicações |
| Detona Ralph | Jogos |
| Memória Animal | Jogos |
| Piano Virtual | Aplicações |
| Yu-Gi-Oh! Jo-ken-po | Jogos |
| Mundo Invertido | Interfaces |
| Spider-Man Multiversos | Interfaces |

Os oito links foram verificados no GitHub durante a preparação. Eles abrem o código, não uma versão hospedada dos projetos. Consulte o README de cada um para executar e verificar suas limitações.

## Tecnologias e decisões
**HTML5, CSS3 e JavaScript puro.**

- HTML estático para manter os oito projetos legíveis mesmo se o JavaScript estiver desativado.
- Catálogo em `assets/js/projects.js`, separado das interações.
- Grid para o catálogo e Flexbox para navegação e controles.
- Variáveis CSS para compartilhar a identidade entre os temas.
- Monograma e capas ilustrativas em CSS, sem usar capturas de tela como se tivessem sido verificadas.
- Fontes do sistema para reduzir requisições e funcionar offline.
- localStorage apenas para o tema; não há coleta própria de dados ou formulário de contato.
- Links externos com noopener/noreferrer e aviso acessível sobre nova aba.
- Sem barras de habilidades ou números de experiência inventados.

O conteúdo foi adaptado ao contexto de estudos de Giordani. A construção foi assistida por IA, com referências didáticas creditadas neste README e nos projetos listados.

## Executar
Baixe esta branch em **Code → Download ZIP**, extraia e abra `portfolio-frontend/index.html`.

Opcionalmente, dentro da pasta do projeto:
```bash
python -m http.server 8000
```
Abra `http://localhost:8000`.

Não precisa de npm ou instalação de dependências para visualizar. A página funciona offline; os links do GitHub exigem internet. Em arquivo local, a persistência do tema depende do navegador.

## Personalizar
- Texto pessoal: `index.html`.
- Cores, tipografia e capas: `assets/css/style.css`.
- Dados e filtros: `assets/js/projects.js`.
- Menu e tema: `assets/js/main.js`.

Ao adicionar um projeto, inclua os dados no catálogo e um article correspondente no HTML com o mesmo data-project. Isso mantém o conteúdo disponível sem JavaScript.

## Testes e verificação
Com Node.js 18 ou superior:
```bash
npm test
```
Não precisa executar npm install. Os cinco testes verificam integridade do catálogo, categorias, busca com acentos, filtros combinados e preservação dos dados.

Também foram verificados a sintaxe dos scripts, IDs, âncoras, links locais e a existência dos oito destinos do GitHub. A aparência e as interações ainda precisam ser conferidas em um navegador real.

## Publicação
O código está publicado em uma branch própria do repositório público aula-git. Não foi realizado deploy do site.

Para hospedar, use um serviço de sites estáticos com `portfolio-frontend` como diretório de publicação, ou copie o conteúdo dessa pasta para a raiz de um repositório dedicado e configure a hospedagem escolhida. O projeto não precisa de etapa de build.

## Estrutura
```text
index.html
assets/favicon.svg
assets/css/style.css
assets/js/projects.js
assets/js/main.js
tests/projects.test.cjs
package.json
ENTREGA-DIO.md
```

## Referências
- [Elidiana Andrade — dio-lab-portfolio](https://github.com/elidianaandrade/dio-lab-portfolio).
- [Figma fornecido no desafio](https://www.figma.com/file/NkndT2SbyHJZWLEsaM8Xn3/DIO-Lab-Portf%C3%B3lio).
- Os projetos listados mantêm seus próprios créditos e referências.

Esta é uma implementação própria inspirada no objetivo do desafio, sem reprodução pixel a pixel do protótipo. As videoaulas não foram acessadas nesta implementação; a conclusão das aulas e a submissão são registradas na plataforma DIO.
