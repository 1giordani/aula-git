# Mundo Invertido — Landing Page

Projeto educacional de **Giordani Martins Silva**, inspirado no desafio [Semana Front-end Mundo Invertido da DIO](https://github.com/digitalinnovationone/semana-frontend-mundo-invertido).

## Sobre
Landing page temática inspirada em Stranger Things, construída com HTML5, CSS3 e JavaScript puro. Aplica estrutura semântica, navegação por âncoras, variáveis de tema, Flexbox, Grid, media queries, manipulação do DOM e validação de formulário.

O código de referência fornece a estrutura e os recursos; esta versão implementa uma folha de estilos própria e interações adaptadas. Não é uma reprodução pixel a pixel do Figma e o vídeo da aula não foi assistido.

## Recursos
- Alternância entre mundo normal e Mundo Invertido.
- Cores, personagens e ilustração que mudam conforme o tema.
- Preferência de tema salva no navegador, com fallback quando o armazenamento está bloqueado.
- Seções sobre o Mundo Invertido, trailer, galeria e clube de D&D.
- Imagens locais e carregamento adiado nas seções inferiores.
- Formulário de demonstração com mensagens por campo, foco no primeiro erro e confirmação clara.
- Layout responsivo, navegação por teclado, link de salto e respeito a movimento reduzido.

## Formulário: demonstração
Use dados fictícios. Os campos são validados apenas nesta página:
- Nome: de 2 a 80 caracteres.
- E-mail: formato básico válido e até 254 caracteres.
- Nível: inteiro de 1 a 20.
- Personagem: descrição de 20 a 600 caracteres.

**Não há inscrição real, envio de dados ou gravação dos campos.** Somente o tema é salvo no localStorage. A confirmação informa que a simulação foi concluída, sem alegar cadastro externo.

A integração com Firebase citada no material de referência não está configurada nesta versão. Para uma inscrição real seria necessário implementar backend, configurar acesso, regras e tratamento dos dados; este projeto entrega o fluxo demonstrativo.

## Executar
Baixe esta branch pelo botão **Code → Download ZIP**, extraia e abra `mundo-invertido/index.html`.

Opcionalmente, dentro da pasta do projeto:
```bash
python -m http.server 8000
```
Abra `http://localhost:8000`.

Não precisa instalar dependências. As imagens, o CSS e os scripts são locais. O trailer depende de conexão com o YouTube; pode não tocar quando a página é aberta como arquivo local, sendo recomendado o servidor HTTP acima.

## Testes
Com Node.js 18 ou superior:
```bash
npm test
```
Não precisa executar npm install. Os sete testes verificam limites de campos, níveis, e-mails e normalização dos dados. A sintaxe dos scripts, âncoras e referências locais também foram verificadas.

Os testes não substituem a conferência visual em navegador real nem verificam a disponibilidade do vídeo externo.

## Estrutura
```text
index.html
assets/css/styles.css
assets/js/core.js
assets/js/main.js
assets/images/
tests/form.test.cjs
package.json
ENTREGA-DIO.md
```

## Decisões e limitações
- O mundo normal usa tons claros e o invertido usa tons escuros. Não há luzes piscantes.
- A arte central gira ao inverter o tema; o texto continua na orientação normal para preservar a leitura.
- As músicas da referência não foram incluídas e não há áudio automático.
- O trailer usa o domínio de incorporação youtube-nocookie.com, sem autoplay. Seu carregamento ainda depende de um serviço externo.
- A opção de tema pode não persistir em alguns navegadores ao abrir o arquivo diretamente.
- O projeto não possui autenticação, banco de dados ou cadastro real.

## Referências e créditos
- [Código e recursos de origem — DIO](https://github.com/digitalinnovationone/semana-frontend-mundo-invertido).
- [Figma fornecido no desafio](https://www.figma.com/file/I3Q42CcVUziRN3iMfTrbfb/Stranger-Things?type=design&mode=design).
- Imagens e identidade temática pertencem aos respectivos titulares. Stranger Things não é uma criação deste projeto; uso para fins educacionais, sem vínculo oficial.
- Interface e interações desta versão adaptadas para o portfólio de Giordani Martins Silva.
