"use strict";
const player=Piano.createPlayer(src=>new Audio(src));
const buttons=[...document.querySelectorAll(".key")];
const byKey=new Map(buttons.map(button=>[button.dataset.key,button]));
const held=new Set();
const pointerKeys=new Map();
const keyboard=document.querySelector("#keyboard");
const volume=document.querySelector("#volume");
const output=document.querySelector("#volume-value");
const showKeys=document.querySelector("#show-keys");
const mute=document.querySelector("#mute");
const status=document.querySelector("#last-key");
let muted=false;
function updateHighlight(key){
  const button=byKey.get(key);
  if(button)button.classList.toggle("active",held.has(key)||[...pointerKeys.values()].includes(key));
}
async function play(key) {
  status.textContent=muted?"Som silenciado":"Tocando: "+key.toUpperCase();
  const success=await player.play(key);
  if(!success)status.textContent="Não foi possível tocar. Clique novamente e confira o áudio do navegador.";
}
buttons.forEach(button=>{
  const key=button.dataset.key;
  button.addEventListener("pointerdown",event=>{
    if(event.button!==0)return;
    pointerKeys.set(event.pointerId,key);
    button.setPointerCapture(event.pointerId);
    updateHighlight(key);play(key);
  });
  function release(event) {
    pointerKeys.delete(event.pointerId);updateHighlight(key);
  }
  button.addEventListener("pointerup",release);
  button.addEventListener("pointercancel",release);
  button.addEventListener("lostpointercapture",release);
  // Enter/Espaço e tecnologias assistivas disparam click sem pointerdown.
  button.addEventListener("click",event=>{
    if(event.detail!==0)return;
    play(key);button.classList.add("active");
    setTimeout(()=>updateHighlight(key),150);
  });
});
function typingInControl(target){return target instanceof Element && (target.closest("input,textarea,select") || target.isContentEditable);}
document.addEventListener("keydown",event=>{
  if(event.repeat||event.ctrlKey||event.metaKey||event.altKey||typingInControl(event.target))return;
  const key=Piano.normalizeKey(event.key);if(key===null||held.has(key))return;
  event.preventDefault();held.add(key);updateHighlight(key);play(key);
});
document.addEventListener("keyup",event=>{
  const key=Piano.normalizeKey(event.key);if(key===null)return;
  held.delete(key);updateHighlight(key);
});
function stopAll(){
  held.clear();pointerKeys.clear();player.stopAll();
  buttons.forEach(button=>button.classList.remove("active"));
  status.textContent=muted?"Som silenciado":"Pronto para tocar";
}
window.addEventListener("blur",stopAll);
document.addEventListener("visibilitychange",()=>{if(document.hidden)stopAll();});
volume.addEventListener("input",()=>{
  const value=player.setVolume(volume.value);
  output.textContent=Math.round(value*100)+"%";
  volume.setAttribute("aria-valuetext",Math.round(value*100)+" por cento");
});
showKeys.addEventListener("change",()=>keyboard.classList.toggle("hide-labels",!showKeys.checked));
mute.addEventListener("click",()=>{
  muted=player.setMuted(!muted);
  mute.setAttribute("aria-pressed",String(muted));
  mute.textContent=muted?"Ativar som":"Silenciar";
  status.textContent=muted?"Som silenciado":"Pronto para tocar";
});
