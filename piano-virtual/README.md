# Piano Virtual — JavaScript

Projeto educacional de **Giordani Martins Silva** para o desafio da DIO, baseado em [Felipe Aguiar — js-music-keyboard-virtual](https://github.com/felipeAguiarCode/js-music-keyboard-virtual).

## Objetivo
Construir um piano virtual com HTML5, CSS3 e JavaScript puro, aplicando manipulação do DOM, eventos, reprodução de áudio, funções e gerenciamento de estado.

A implementação mantém o mapeamento e as 17 amostras WAV do projeto de referência. A interface foi personalizada, com suporte a ponteiros, teclado, controle de volume e reprodução independente de notas diferentes.

## Como tocar
- Clique nas teclas ou toque na tela.
- Use as letras exibidas no piano: **A W S E D F T G Y H U J K O L P ;**.
- Maiúsculas e minúsculas funcionam. O ponto e vírgula depende do layout do seu teclado; a tecla na tela é sempre uma alternativa.
- Teclas diferentes podem tocar juntas; repetir a mesma nota reinicia sua amostra.
- Arraste o controle **Volume**, use **Silenciar/Ativar som** ou desmarque **Mostrar letras**.
- Use Tab para focar uma tecla e Enter/Espaço para tocar.
- Em telas pequenas, deslize a área do piano horizontalmente.
- Ao sair da janela ou ocultar a página, os sons são interrompidos.

Os atalhos ficam inativos quando um campo de entrada está em foco, permitindo ajustar o volume pelo teclado. As notas são amostras gravadas com duração fixa: segurar uma tecla não cria sustentação infinita.

## Recursos
- 17 teclas com sons locais, sem dependências externas.
- Volume inicial de 50%, aplicado desde a primeira nota.
- Uma voz por tecla para permitir polifonia entre notas diferentes.
- Feedback visual para teclas pressionadas.
- Suporte a mouse, toque e teclado.
- Controle de volume, mute e exibição de letras.
- Layout responsivo e foco visível.
- Tratamento de falhas na reprodução do áudio.
- Núcleo de áudio separado da interface e testes automatizados.

## Executar
Baixe esta branch em **Code → Download ZIP**, extraia e abra `piano-virtual/index.html`.

Não é necessário instalar dependências ou estar conectado à internet. O navegador pode exigir interação do usuário antes de liberar áudio; clique em uma tecla para começar.

Opcionalmente, dentro da pasta do projeto:
```bash
python -m http.server 8000
```
Abra `http://localhost:8000`.

## Testes
Com Node.js 18 ou superior:
```bash
npm test
```
Não precisa executar npm install. Os 11 testes utilizam vozes de áudio simuladas para verificar mapeamento, volume, mute, reprodução independente, reinício de nota, interrupção e falhas. Eles não validam a qualidade sonora, o hardware de áudio ou a aparência no navegador.

Também foram conferidos a sintaxe dos scripts e os caminhos locais do HTML. A conferência visual e auditiva em navegador real ainda é necessária.

## Estrutura
```text
index.html
src/styles/main.css
src/scripts/audio-core.js
src/scripts/engine.js
src/tunes/  (17 arquivos WAV)
tests/audio-core.test.cjs
package.json
ENTREGA-DIO.md
```

## Créditos
- Referência didática, mapeamento das teclas e amostras WAV: [Felipe Aguiar / DIO](https://github.com/felipeAguiarCode/js-music-keyboard-virtual).
- Interface e organização desta versão adaptadas para o portfólio de Giordani Martins Silva.
- Projeto de estudo; os arquivos de referência pertencem aos respectivos autores.

## Limitações
Não há gravação, exportação, pedal de sustentação ou integração MIDI. A latência e a quantidade de toques simultâneos dependem do navegador, dispositivo e teclado físico. Nenhum dado pessoal é coletado ou transmitido.
