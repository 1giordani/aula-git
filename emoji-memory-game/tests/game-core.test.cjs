const test = require("node:test");
const assert = require("node:assert/strict");
const { shuffle, createGame } = require("../src/scripts/game-core.js");
test("embaralhamento preserva todos os pares e não altera a entrada", () => {
  const deck=[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7], original=[...deck];
  const result=shuffle(deck, () => 0.25);
  assert.deepEqual(deck,original); assert.notDeepEqual(result,deck);
  assert.deepEqual([...result].sort(),[...deck].sort());
});
test("carta inicial abre sem contar uma jogada completa", () => {
  const g=createGame([0,0,1,1]); assert.equal(g.flip(0),"first");
  assert.equal(g.state.moves,0); assert.deepEqual(g.state.open,[0]);
});
test("clicar duas vezes na mesma carta não produz um par", () => {
  const g=createGame([0,0,1,1]); g.flip(0);
  assert.equal(g.flip(0),"ignored"); assert.equal(g.state.matched.size,0); assert.equal(g.state.moves,0);
});
test("par correto permanece encontrado e soma uma jogada", () => {
  const g=createGame([0,0,1,1]); g.flip(0);
  assert.equal(g.flip(1),"match"); assert.equal(g.state.moves,1);
  assert.equal(g.state.matched.size,2); assert.deepEqual(g.state.open,[]);
});
test("carta já encontrada não pode ser usada novamente", () => {
  const g=createGame([0,0,1,1]); g.flip(0); g.flip(1);
  assert.equal(g.flip(0),"ignored"); assert.equal(g.state.moves,1);
});
test("par diferente bloqueia uma terceira escolha até fechar", () => {
  const g=createGame([0,0,1,1]); g.flip(0);
  assert.equal(g.flip(2),"mismatch"); assert.equal(g.flip(3),"ignored");
  assert.deepEqual(g.state.open,[0,2]); assert.equal(g.state.moves,1);
  g.closeMismatch(); assert.deepEqual(g.state.open,[]); assert.equal(g.flip(3),"first");
});
test("vitória ocorre apenas quando todos os pares são encontrados", () => {
  const g=createGame([0,0,1,1]); g.flip(0); g.flip(1); g.flip(2);
  assert.equal(g.flip(3),"won"); assert.equal(g.state.phase,"won");
  assert.equal(g.state.moves,2); assert.equal(g.flip(0),"ignored");
});
test("nova partida não compartilha estado com a anterior", () => {
  const a=createGame([0,0,1,1]); a.flip(0); a.flip(2);
  const b=createGame([0,0,1,1]); assert.equal(b.state.moves,0);
  assert.equal(b.state.phase,"ready"); assert.deepEqual(b.state.open,[]);
});
test("índices inválidos não alteram o estado", () => {
  const g=createGame([0,0]); [-1,2,0.5,NaN,"0"].forEach(i=>assert.equal(g.flip(i),"ignored"));
  assert.equal(g.state.phase,"ready"); assert.deepEqual(g.state.open,[]);
});
test("baralhos vazios, ímpares ou sem pares são rejeitados", () => {
  [[],[0],[0,1],[0,0,0,0]].forEach(deck=>assert.throws(()=>createGame(deck)));
});
