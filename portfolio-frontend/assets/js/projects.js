(function(root){
  "use strict";
  const projects=[
  {
    "id": "css",
    "title": "Landing Page CSS",
    "category": "interfaces",
    "label": "Interfaces",
    "mark": "CSS",
    "design": "css",
    "tags": [
      "HTML",
      "CSS",
      "Responsividade"
    ],
    "description": "Página da trilha de CSS com gradientes, organização visual e adaptação para diferentes telas.",
    "branch": "projeto-landing-page-css",
    "folder": "landing-page-css",
    "url": "https://github.com/1giordani/aula-git/tree/projeto-landing-page-css/landing-page-css"
  },
  {
    "id": "pokedex",
    "title": "Pokédex de Kanto",
    "category": "aplicacoes",
    "label": "Aplicações",
    "mark": "API",
    "design": "api",
    "tags": [
      "JavaScript",
      "API REST",
      "Cache"
    ],
    "description": "Catálogo de Pokémon com busca, filtro por tipo, paginação e detalhes consumidos da PokéAPI.",
    "branch": "projeto-pokedex",
    "folder": "pokedex",
    "url": "https://github.com/1giordani/aula-git/tree/projeto-pokedex/pokedex"
  },
  {
    "id": "ralph",
    "title": "Detona Ralph",
    "category": "jogos",
    "label": "Jogos",
    "mark": "09",
    "design": "arcade",
    "tags": [
      "JavaScript",
      "DOM",
      "Eventos"
    ],
    "description": "Jogo de reflexos com nove janelas, pontuação, vidas, dificuldades e recorde local.",
    "branch": "projeto-detona-ralph",
    "folder": "detona-ralph",
    "url": "https://github.com/1giordani/aula-git/tree/projeto-detona-ralph/detona-ralph"
  },
  {
    "id": "memory",
    "title": "Memória Animal",
    "category": "jogos",
    "label": "Jogos",
    "mark": "↔",
    "design": "memory",
    "tags": [
      "JavaScript",
      "Arrays",
      "Estado"
    ],
    "description": "Jogo de pares com emojis, contador de jogadas, cronômetro e controle de cliques.",
    "branch": "projeto-jogo-memoria-emojis",
    "folder": "emoji-memory-game",
    "url": "https://github.com/1giordani/aula-git/tree/projeto-jogo-memoria-emojis/emoji-memory-game"
  },
  {
    "id": "piano",
    "title": "Piano Virtual",
    "category": "aplicacoes",
    "label": "Aplicações",
    "mark": "♪",
    "design": "piano",
    "tags": [
      "JavaScript",
      "Áudio",
      "Teclado"
    ],
    "description": "Instrumento virtual com 17 sons, controle de volume e interação por mouse, toque ou teclado.",
    "branch": "projeto-piano-virtual",
    "folder": "piano-virtual",
    "url": "https://github.com/1giordani/aula-git/tree/projeto-piano-virtual/piano-virtual"
  },
  {
    "id": "yugi",
    "title": "Yu-Gi-Oh! Jo-ken-po",
    "category": "jogos",
    "label": "Jogos",
    "mark": "VS",
    "design": "cards",
    "tags": [
      "JavaScript",
      "Lógica",
      "Cartas"
    ],
    "description": "Pedra, papel e tesoura com cartas, placar, histórico de rodadas e efeitos sonoros opcionais.",
    "branch": "projeto-yugioh-jokenpo",
    "folder": "yu-gi-oh-jokenpo",
    "url": "https://github.com/1giordani/aula-git/tree/projeto-yugioh-jokenpo/yu-gi-oh-jokenpo"
  },
  {
    "id": "mundo",
    "title": "Mundo Invertido",
    "category": "interfaces",
    "label": "Interfaces",
    "mark": "⇅",
    "design": "world",
    "tags": [
      "CSS",
      "Temas",
      "Formulário"
    ],
    "description": "Landing page temática com mudança de mundos, galeria e formulário demonstrativo validado.",
    "branch": "projeto-mundo-invertido",
    "folder": "mundo-invertido",
    "url": "https://github.com/1giordani/aula-git/tree/projeto-mundo-invertido/mundo-invertido"
  },
  {
    "id": "spider",
    "title": "Spider-Man Multiversos",
    "category": "interfaces",
    "label": "Interfaces",
    "mark": "3D",
    "design": "spider",
    "tags": [
      "CSS 3D",
      "Animações",
      "JavaScript"
    ],
    "description": "Carrossel com profundidade, três universos, seleção de filmes e galeria ampliável.",
    "branch": "projeto-spiderman-multiverso",
    "folder": "spider-man-multiverso",
    "url": "https://github.com/1giordani/aula-git/tree/projeto-spiderman-multiverso/spider-man-multiverso"
  }
];
  function normalize(value){return String(value??"").normalize("NFD").replace(/[\u0300-\u036f]/g,"").toLowerCase().trim();}
  function filterProjects(category="todos",query=""){
    const q=normalize(query);
    return projects.filter(p=>(category==="todos"||p.category===category)&&(!q||normalize([p.title,p.description,...p.tags].join(" ")).includes(q)));
  }
  const api={projects,filterProjects};
  if(typeof module!=="undefined"&&module.exports)module.exports=api;else root.Portfolio=api;
})(typeof globalThis!=="undefined"?globalThis:this);
