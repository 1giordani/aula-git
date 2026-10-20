"use strict";
const symbols = [
  { emoji:"🐱", name:"gato" }, { emoji:"🦝", name:"guaxinim" },
  { emoji:"🦊", name:"raposa" }, { emoji:"🐶", name:"cachorro" },
  { emoji:"🐵", name:"macaco" }, { emoji:"🦁", name:"leão" },
  { emoji:"🐯", name:"tigre" }, { emoji:"🐮", name:"vaca" }
];
const board = document.querySelector("#board");
const moves = document.querySelector("#moves");
const pairs = document.querySelector("#pairs");
const time = document.querySelector("#time");
const bestView = document.querySelector("#best");
const status = document.querySelector("#status");
const reset = document.querySelector("#reset");
const recordKey = "giordani-memory-best-moves";
let game, buttons = [], timer = null, mismatchTimer = null, startedAt = null, elapsed = 0, best = null;
try {
  const saved = Number(localStorage.getItem(recordKey));
  if (Number.isSafeInteger(saved) && saved >= 8) best = saved;
} catch { /* Armazenamento indisponível não impede o jogo. */ }

function formatTime(milliseconds) {
  const seconds = Math.floor(milliseconds / 1000);
  return String(Math.floor(seconds / 60)).padStart(2,"0") + ":" + String(seconds % 60).padStart(2,"0");
}
function updateClock() {
  if (startedAt !== null) elapsed = performance.now() - startedAt;
  time.textContent = formatTime(elapsed);
}
function stopTimers() {
  clearInterval(timer); clearTimeout(mismatchTimer);
  timer = null; mismatchTimer = null;
}
function render() {
  const s = game.state;
  moves.textContent = s.moves;
  pairs.textContent = s.matched.size / 2;
  bestView.textContent = best === null ? "—" : best;
  board.setAttribute("aria-busy", String(s.phase === "locked"));
  buttons.forEach((button, i) => {
    const found = s.matched.has(i);
    const visible = found || s.open.includes(i);
    const symbol = symbols[s.deck[i]];
    button.classList.toggle("open", visible);
    button.classList.toggle("matched", found);
    button.querySelector(".card-front").textContent = visible ? symbol.emoji : "";
    button.disabled = found;
    button.setAttribute("aria-disabled", String(found || s.phase === "locked" || visible));
    button.setAttribute("aria-label", "Carta " + (i + 1) + ": " + (visible ? symbol.name + (found ? ", par encontrado" : ", aberta") : "virada para baixo"));
  });
}
function finish() {
  updateClock(); clearInterval(timer); timer = null;
  const newRecord = best === null || game.state.moves < best;
  if (newRecord) {
    best = game.state.moves;
    try { localStorage.setItem(recordKey,String(best)); } catch { /* Mantém recorde desta sessão. */ }
  }
  status.textContent = "Você venceu em " + game.state.moves + " jogadas e " + formatTime(elapsed) + "!" + (newRecord ? " Novo recorde!" : "") + " Que tal outra partida?";
  reset.textContent = "↻ Jogar novamente";
  reset.focus();
}
function choose(index) {
  const result = game.flip(index);
  if (result === "ignored") return;
  if (startedAt === null) {
    startedAt = performance.now();
    timer = setInterval(updateClock, 250);
  }
  if (result === "first") status.textContent = "Agora encontre a outra carta deste par.";
  if (result === "match") status.textContent = "Par encontrado! Continue assim.";
  if (result === "mismatch") {
    status.textContent = "Não foi desta vez. Observe as cartas e tente novamente.";
    mismatchTimer = setTimeout(() => {
      game.closeMismatch(); mismatchTimer = null; render();
      status.textContent = "Escolha mais duas cartas.";
    }, 850);
  }
  if (result === "won") finish();
  render();
}
function newGame() {
  stopTimers(); startedAt = null; elapsed = 0;
  game = MemoryGame.createGame(MemoryGame.shuffle([...symbols.keys(), ...symbols.keys()]));
  board.replaceChildren();
  buttons = game.state.deck.map((_, index) => {
    const button = document.createElement("button");
    button.type = "button"; button.className = "card";
    const inner = document.createElement("span"); inner.className = "card-inner"; inner.setAttribute("aria-hidden","true");
    const back = document.createElement("span"); back.className = "card-back"; back.textContent = "?";
    const front = document.createElement("span"); front.className = "card-front";
    inner.append(back,front); button.append(inner);
    button.addEventListener("click", () => choose(index));
    board.append(button); return button;
  });
  time.textContent = "00:00"; reset.textContent = "↻ Nova partida";
  status.textContent = "Vire uma carta para começar. O relógio inicia na primeira escolha.";
  render();
}
reset.addEventListener("click",newGame);
newGame();
