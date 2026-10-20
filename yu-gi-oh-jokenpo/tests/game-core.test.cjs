const test=require("node:test");
const assert=require("node:assert/strict");
const {cards,outcome,draw,hand,createDuel}=require("../src/scripts/game-core.js");
const expected=[["draw","lose","win"],["win","draw","lose"],["lose","win","draw"]];
for(let p=0;p<3;p++)for(let o=0;o<3;o++)test(cards[p].name+" versus "+cards[o].name,()=>assert.equal(outcome(p,o),expected[p][o]));
test("baralho contém cinco cartas e permite os três tipos",()=>{
 const result=hand(()=>0.4); assert.equal(result.length,5);
 [0,1,2].forEach(id=>assert.ok(result.includes(id))); assert.ok(result.every(id=>id>=0&&id<3));
});
test("sorteio cobre as extremidades sem sair do baralho",()=>{
 assert.equal(draw(()=>0),0); assert.equal(draw(()=>0.99999),2);
});
test("somente uma escolha é contabilizada por rodada",()=>{
 const g=createDuel(); g.play(0,2);
 assert.equal(g.play(0,2),null); assert.equal(g.state.player,1); assert.equal(g.state.history.length,1);
 assert.equal(g.next(),true); assert.equal(g.state.round,2); assert.equal(g.next(),false);
});
test("empates não somam vitórias",()=>{
 const g=createDuel(); g.play(1,1);
 assert.equal(g.state.draws,1); assert.equal(g.state.player,0); assert.equal(g.state.opponent,0);
});
test("quinta vitória encerra o duelo do jogador e bloqueia novas rodadas",()=>{
 const g=createDuel();
 for(let i=0;i<5;i++){g.play(0,2);if(i<4)g.next();}
 assert.equal(g.state.phase,"finished"); assert.equal(g.state.winner,"player");
 assert.equal(g.next(),false); assert.equal(g.play(0,2),null); assert.equal(g.state.player,5);
});
test("computador também vence ao conquistar cinco pontos",()=>{
 const g=createDuel();
 for(let i=0;i<5;i++){g.play(0,1);if(i<4)g.next();}
 assert.equal(g.state.winner,"opponent"); assert.equal(g.state.opponent,5);
});
test("novo duelo começa sem resultados da partida anterior",()=>{
 const a=createDuel();a.play(0,2);const b=createDuel();
 assert.equal(b.state.player,0);assert.equal(b.state.round,1);assert.deepEqual(b.state.history,[]);
});
test("cartas inválidas e metas inválidas são rejeitadas sem pontuar",()=>{
 [-1,3,0.5,"0"].forEach(id=>assert.throws(()=>outcome(id,1)));
 [0,-1,0.5].forEach(target=>assert.throws(()=>createDuel(target)));
 const g=createDuel(); assert.throws(()=>g.play(9,0)); assert.equal(g.state.history.length,0);assert.equal(g.state.player,0);
});
