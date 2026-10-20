const test=require("node:test");
const assert=require("node:assert/strict");
const {keys,normalizeKey,createPlayer}=require("../src/scripts/audio-core.js");
function fixture(fail=false){
 const voices=[];
 const player=createPlayer(src=>{
  const audio={src,volume:1,currentTime:99,plays:0,pauses:0,
   play(){this.plays++;return fail?Promise.reject(new Error("bloqueado")):Promise.resolve();},
   pause(){this.pauses++;}};
  voices.push(audio);return audio;
 });
 return {player,voices};
}
test("mapa contém dezessete teclas únicas",()=>{assert.equal(keys.length,17);assert.equal(new Set(keys).size,17);assert.ok(keys.includes(";"));});
test("normaliza letras maiúsculas e rejeita entradas desconhecidas",()=>{
 assert.equal(normalizeKey("A"),"a");assert.equal(normalizeKey(";"),";");
 ["q","Enter","",null,5].forEach(k=>assert.equal(normalizeKey(k),null));
});
test("nota válida toca amostra local desde o início e com volume inicial",async()=>{
 const {player,voices}=fixture();assert.equal(await player.play("a"),true);
 assert.equal(voices[0].src,"src/tunes/a.wav");assert.equal(voices[0].currentTime,0);
 assert.equal(voices[0].volume,.5);assert.equal(voices[0].plays,1);
});
test("cada tecla do mapa possui um caminho de áudio distinto",async()=>{
 const {player,voices}=fixture();for(const key of keys)await player.play(key);
 assert.equal(new Set(voices.map(v=>v.src)).size,17);
});
test("notas diferentes usam vozes independentes e não são pausadas",async()=>{
 const {player,voices}=fixture();await player.play("a");await player.play("w");
 assert.equal(voices.length,2);assert.equal(voices[0].pauses,0);assert.equal(voices[1].pauses,0);
});
test("repetir a nota reutiliza a voz e reinicia sua reprodução",async()=>{
 const {player,voices}=fixture();await player.play("a");voices[0].currentTime=1;
 await player.play("A");assert.equal(voices.length,1);assert.equal(voices[0].plays,2);assert.equal(voices[0].currentTime,0);
});
test("volume é limitado entre zero e um e muda vozes atuais e futuras",async()=>{
 const {player,voices}=fixture();await player.play("a");
 player.setVolume(.8);assert.equal(voices[0].volume,.8);
 await player.play("s");assert.equal(voices[1].volume,.8);
 assert.equal(player.setVolume(2),1);assert.equal(player.setVolume(-1),0);
 assert.equal(player.setVolume(NaN),0);
});
test("silenciar preserva o volume escolhido para reativação",async()=>{
 const {player,voices}=fixture();player.setVolume(.7);await player.play("a");player.setMuted(true);
 assert.equal(voices[0].volume,0);await player.play("s");assert.equal(voices[1].volume,0);
 player.setMuted(false);assert.ok(voices.every(v=>v.volume===.7));
});
test("parar todas as notas pausa e zera as vozes",async()=>{
 const {player,voices}=fixture();await player.play("a");await player.play("s");
 player.stopAll();assert.ok(voices.every(v=>v.pauses===1&&v.currentTime===0));
});
test("tecla inexistente não cria áudio",async()=>{
 const {player,voices}=fixture();assert.equal(await player.play("q"),false);assert.equal(voices.length,0);
});
test("falha de reprodução retorna falso sem rejeição não tratada",async()=>{
 const {player}=fixture(true);assert.equal(await player.play("a"),false);
});
