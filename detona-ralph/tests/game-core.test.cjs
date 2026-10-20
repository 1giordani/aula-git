const test = require("node:test");
const assert = require("node:assert/strict");
const { createGame } = require("../src/scripts/game-core.js");
test("partida inicia com 60 segundos, três vidas e placar zerado", () => {
  const game = createGame(); game.start(5000);
  assert.equal(game.state.deadline, 65000); assert.equal(game.state.lives, 3);
  assert.equal(game.state.score, 0); assert.equal(game.state.phase, "playing");
});
test("acerto pontua uma vez e remove o alvo", () => {
  const game=createGame(); game.start(0); game.setTarget(4);
  assert.equal(game.hit(4,100), "hit"); assert.equal(game.state.score,1);
  assert.equal(game.state.target,null);
  assert.equal(game.hit(4,101), "miss"); assert.equal(game.state.score,1); assert.equal(game.state.lives,2);
});
test("três erros encerram a partida e cliques posteriores são ignorados", () => {
  const game=createGame(); game.start(0); game.setTarget(4);
  game.hit(0,1); game.hit(0,2); game.hit(0,3);
  assert.equal(game.state.phase,"finished"); assert.equal(game.state.lives,0);
  assert.equal(game.hit(4,4),"ignored"); assert.equal(game.state.score,0);
});
test("relógio usa tempo decorrido mesmo com atualização atrasada", () => {
  const game=createGame(); game.start(1000); game.tick(16500);
  assert.equal(game.state.remainingMs,44500);
  game.tick(90000); assert.equal(game.state.remainingMs,0); assert.equal(game.state.phase,"finished");
});
test("não aceita acerto após o prazo mesmo antes do próximo tick", () => {
  const game=createGame(); game.start(0); game.setTarget(3);
  assert.equal(game.hit(3,60000),"ignored"); assert.equal(game.state.score,0);
});
test("pausa conserva o tempo e continuar redefine o prazo", () => {
  const game=createGame(); game.start(0); game.setTarget(2); game.pause(10000);
  game.tick(50000); assert.equal(game.state.remainingMs,50000);
  assert.equal(game.hit(2,50000),"ignored"); game.resume(80000);
  assert.equal(game.state.deadline,130000); assert.equal(game.hit(2,80001),"hit");
});
test("reiniciar limpa o resultado, vidas e alvo de uma partida anterior", () => {
  const game=createGame(); game.start(0); game.setTarget(1); game.hit(1,10); game.hit(2,20);
  game.start(90000); assert.equal(game.state.score,0); assert.equal(game.state.lives,3);
  assert.equal(game.state.target,null); assert.equal(game.state.remainingMs,60000);
});
test("entradas inválidas e alvos fora do tabuleiro são ignorados", () => {
  const game=createGame(); assert.equal(game.hit(1,0),"ignored");
  game.start(0); game.setTarget(9); assert.equal(game.state.target,null);
  assert.equal(game.hit(-1,10),"ignored"); assert.equal(game.hit(0.5,10),"ignored");
  assert.equal(game.state.lives,3);
});
