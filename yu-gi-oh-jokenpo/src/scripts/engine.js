"use strict";
const ui = Object.fromEntries(["player-score","opponent-score","round","draws","player-card","opponent-card","player-name","opponent-name","status","next","hand","preview","reset","sound","history"].map(id=>[id,document.getElementById(id)]));
let duel, handButtons=[], soundEnabled=false;
const images="src/assets/icons/";
const audio={win:new Audio("src/assets/audios/win.wav"),lose:new Audio("src/assets/audios/lose.wav")};
Object.values(audio).forEach(item=>item.volume=0.25);
const labels={win:"Você venceu a rodada",lose:"O computador venceu a rodada",draw:"Empate"};
function updateScore() {
  ui["player-score"].textContent=duel.state.player;
  ui["opponent-score"].textContent=duel.state.opponent;
  ui.round.textContent=duel.state.round;
  ui.draws.textContent=duel.state.draws;
}
function updateHistory() {
  ui.history.replaceChildren();
  duel.state.history.slice(-5).reverse().forEach(entry=>{
    const item=document.createElement("li");
    item.textContent="Rodada "+entry.round+": "+YugiGame.cards[entry.player].name+" × "+YugiGame.cards[entry.opponent].name+" — "+labels[entry.result]+".";
    ui.history.append(item);
  });
}
function showCard(side,id) {
  const card=YugiGame.cards[id];
  ui[side+"-card"].src=images+card.image;
  ui[side+"-card"].alt=card.name+" — "+card.type;
  ui[side+"-name"].textContent=card.name+" · "+card.type;
}
function selectCard(id,button) {
  if(duel.state.phase!=="choosing") return;
  const result=duel.play(id,YugiGame.draw());
  if(!result) return;
  handButtons.forEach(item=>{item.disabled=true;});
  button.classList.add("selected");
  showCard("player",id); showCard("opponent",result.opponent);
  ui.status.dataset.result=result.result;
  ui.status.textContent=labels[result.result]+"!";
  ui.preview.textContent="As cartas da rodada foram reveladas.";
  updateScore(); updateHistory();
  if(soundEnabled && audio[result.result]) {
    const effect=audio[result.result]; effect.currentTime=0;
    effect.play().catch(()=>{ /* Áudio bloqueado não interrompe o duelo. */ });
  }
  if(duel.state.phase==="finished") {
    ui.status.textContent+=(duel.state.winner==="player" ? " Você conquistou cinco vitórias e venceu o duelo!" : " O computador conquistou cinco vitórias. Tente um novo duelo!");
    ui.next.disabled=true; ui.reset.focus();
  } else { ui.next.disabled=false; ui.next.focus(); }
}
function deal() {
  ["player","opponent"].forEach(side=>{
    ui[side+"-card"].src=images+"card-back.png";
    ui[side+"-card"].alt=side==="player" ? "Sua carta ainda não foi escolhida" : "Carta do computador ainda oculta";
  });
  ui["player-name"].textContent="Faça sua escolha";
  ui["opponent-name"].textContent="Carta oculta";
  ui.status.dataset.result="";
  ui.status.textContent="Sua vez! Escolha uma carta abaixo para duelar.";
  ui.preview.textContent="Use o mouse, toque ou Tab e Enter para jogar.";
  ui.next.disabled=true; ui.hand.replaceChildren();
  handButtons=YugiGame.hand().map((id,index)=>{
    const card=YugiGame.cards[id];
    const button=document.createElement("button"); button.type="button"; button.className="card";
    button.setAttribute("aria-label","Carta "+(index+1)+": "+card.name+", "+card.type);
    const img=document.createElement("img"); img.src=images+card.image; img.alt=""; img.draggable=false;
    const type=document.createElement("span"); type.textContent=card.icon+" "+card.type;
    button.append(img,type);
    function preview() { if(duel.state.phase==="choosing") ui.preview.textContent=card.name+" · "+card.type+" — vence "+YugiGame.cards[card.beats].name+"."; }
    button.addEventListener("mouseenter",preview); button.addEventListener("focus",preview);
    button.addEventListener("click",()=>selectCard(id,button));
    ui.hand.append(button); return button;
  });
}
function reset() {
  Object.values(audio).forEach(item=>{item.pause(); item.currentTime=0;});
  duel=YugiGame.createDuel(); deal(); updateScore();
  const item=document.createElement("li"); item.textContent="Nenhuma rodada disputada."; ui.history.replaceChildren(item);
}
ui.next.addEventListener("click",()=>{
  if(!duel.next()) return;
  deal(); updateScore(); handButtons[0].focus();
});
ui.reset.addEventListener("click",reset);
ui.sound.addEventListener("click",()=>{
  soundEnabled=!soundEnabled;
  ui.sound.setAttribute("aria-pressed",String(soundEnabled));
  ui.sound.textContent="Som: "+(soundEnabled?"ligado":"desligado");
  if(!soundEnabled) Object.values(audio).forEach(item=>item.pause());
});
reset();
