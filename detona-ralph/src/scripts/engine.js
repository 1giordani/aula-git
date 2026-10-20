"use strict";
const game = RalphGame.createGame();
const squares = [...document.querySelectorAll(".square")];
const view = {
  time: document.querySelector("#time-left"),
  score: document.querySelector("#score"),
  lives: document.querySelector("#lives"),
  best: document.querySelector("#best"),
  start: document.querySelector("#start"),
  pause: document.querySelector("#pause"),
  sound: document.querySelector("#sound"),
  difficulty: document.querySelector("#difficulty"),
  status: document.querySelector("#status")
};
const storageKey = "giordani-detona-ralph-best";
let best = 0;
try {
  const saved = Number(localStorage.getItem(storageKey));
  if (Number.isSafeInteger(saved) && saved > 0) best = saved;
} catch { /* O jogo funciona mesmo se o navegador bloquear armazenamento. */ }
let soundEnabled = false;
let timer = null;
let nextMove = 0;
let lastTarget = -1;
let velocity = 700;
let recorded = false;
const hitAudio = new Audio("src/audios/hit.m4a");
hitAudio.volume = 0.25;

function message(text) { view.status.textContent = text; }
function clearTimer() { if (timer !== null) clearInterval(timer); timer = null; }
function saveRecord() {
  if (game.state.score <= best) return;
  best = game.state.score;
  try { localStorage.setItem(storageKey, String(best)); } catch { /* Recorde permanece nesta sessão. */ }
}
function render() {
  const s = game.state;
  view.time.textContent = Math.ceil(s.remainingMs / 1000);
  view.score.textContent = s.score;
  view.lives.textContent = s.lives;
  view.best.textContent = best;
  view.pause.disabled = s.phase !== "playing" && s.phase !== "paused";
  view.pause.textContent = s.phase === "paused" ? "Continuar" : "Pausar";
  view.difficulty.disabled = s.phase === "playing" || s.phase === "paused";
  squares.forEach((square, i) => {
    const active = s.phase === "playing" && s.target === i;
    square.classList.toggle("enemy", active);
    square.disabled = s.phase !== "playing";
    square.setAttribute("aria-label", "Janela " + (i + 1) + (active ? ": Ralph apareceu" : ": vazia"));
  });
  if (s.phase === "finished" && !recorded) {
    recorded = true;
    clearTimer();
    saveRecord();
    view.best.textContent = best;
    message((s.lives === 0 ? "As vidas acabaram! " : "Tempo encerrado! ") + "Você fez " + s.score + " ponto(s). Clique em jogar novamente.");
    view.start.textContent = "Jogar novamente";
    view.start.focus();
  }
}
function moveTarget() {
  // Evita repetir a mesma janela em dois movimentos consecutivos.
  let index = Math.floor(Math.random() * 8);
  if (index >= lastTarget) index += 1;
  if (lastTarget < 0) index = Math.floor(Math.random() * 9);
  lastTarget = index;
  game.setTarget(index);
}
function update() {
  const now = performance.now();
  game.tick(now);
  if (game.state.phase === "playing" && now >= nextMove) {
    moveTarget();
    nextMove = now + velocity;
  }
  render();
}
function runTimer() { clearTimer(); timer = setInterval(update, 50); }
function start() {
  clearTimer();
  velocity = Number(view.difficulty.value);
  if (![1000, 700, 450].includes(velocity)) velocity = 700;
  recorded = false;
  lastTarget = -1;
  const now = performance.now();
  game.start(now);
  moveTarget();
  nextMove = now + velocity;
  view.start.textContent = "Reiniciar partida";
  message("Valendo! Acerte o Ralph e evite as janelas vazias.");
  render();
  runTimer();
}
function pause() {
  if (game.state.phase !== "playing") return;
  game.pause(performance.now());
  clearTimer();
  if (game.state.phase === "paused") message("Jogo pausado. Clique em continuar quando estiver pronto.");
  render();
}
function resume() {
  if (game.state.phase !== "paused") return;
  const now = performance.now();
  game.resume(now);
  nextMove = now + velocity;
  message("Valendo novamente!");
  render();
  runTimer();
}
function hit(index) {
  const result = game.hit(index, performance.now());
  if (result === "hit" && soundEnabled) {
    hitAudio.currentTime = 0;
    hitAudio.play().catch(() => { /* Ausência de áudio não interrompe a partida. */ });
  }
  if (result === "miss" && game.state.phase !== "finished") message("Janela vazia! Você perdeu uma vida.");
  render();
}
squares.forEach((square, i) => square.addEventListener("click", () => hit(i)));
view.start.addEventListener("click", start);
view.pause.addEventListener("click", () => game.state.phase === "paused" ? resume() : pause());
view.sound.addEventListener("click", () => {
  soundEnabled = !soundEnabled;
  view.sound.setAttribute("aria-pressed", String(soundEnabled));
  view.sound.textContent = "Som: " + (soundEnabled ? "ligado" : "desligado");
});
document.addEventListener("keydown", event => {
  if (event.repeat || event.ctrlKey || event.altKey || event.metaKey) return;
  if (["SELECT", "INPUT", "TEXTAREA"].includes(event.target.tagName)) return;
  if (/^[1-9]$/.test(event.key) && game.state.phase === "playing") {
    event.preventDefault();
    hit(Number(event.key) - 1);
  }
});
document.addEventListener("visibilitychange", () => { if (document.hidden) pause(); });
render();
