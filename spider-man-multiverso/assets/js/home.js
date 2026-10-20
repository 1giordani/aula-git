"use strict";
const carousel=document.getElementById("carousel");
const selectors=document.getElementById("selectors");
const status=document.getElementById("selection-status");
let current=0;
const cards=[],controls=[];
Spider.heroes.forEach((hero,index)=>{
  const link=document.createElement("a");link.className="universe-card";
  link.href="pages/universo.html?hero="+hero.id+"&film=1";link.style.setProperty("--angle",(index*120)+"deg");
  link.setAttribute("aria-label","Explorar universo de "+hero.name);
  const scene=document.createElement("img");scene.className="card-scene";scene.src=Spider.galleryPath(hero);scene.alt="";
  const character=document.createElement("img");character.className="card-character";character.src=Spider.source+"assets/images/"+hero.sprite;character.alt="Homem-Aranha do universo de "+hero.name;character.decoding="async";
  character.addEventListener("error",()=>{character.src=Spider.galleryPath(hero);character.style.objectFit="cover";},{once:true});
  const caption=document.createElement("div");caption.className="card-caption";
  const number=document.createElement("small");number.textContent="UNIVERSO "+hero.number;
  const title=document.createElement("h2");title.textContent=hero.name;
  const call=document.createElement("span");call.textContent="EXPLORAR UNIVERSO ↗";
  caption.append(number,title,call);link.append(scene,character,caption);carousel.append(link);cards.push(link);
  const button=document.createElement("button");button.type="button";button.textContent=hero.number;
  button.setAttribute("aria-label","Selecionar universo de "+hero.name);
  button.addEventListener("click",()=>select(index));selectors.append(button);controls.push(button);
});
function select(index,updateHash=true){
  current=Spider.wrapIndex(index,0);
  carousel.style.setProperty("--rotation",(-current*120)+"deg");
  cards.forEach((card,i)=>{
    const active=i===current;card.classList.toggle("active",active);
    card.tabIndex=active?0:-1;card.setAttribute("aria-hidden",String(!active));card.style.pointerEvents=active?"auto":"none";
    controls[i].setAttribute("aria-pressed",String(active));
  });
  const hero=Spider.heroes[current];status.textContent=hero.name+" · "+hero.films.length+" filmes · "+hero.label;
  if(updateHash){try{history.replaceState(null,"","#"+hero.id);}catch{}}
}
document.getElementById("previous").addEventListener("click",()=>select(Spider.wrapIndex(current,-1)));
document.getElementById("next").addEventListener("click",()=>select(Spider.wrapIndex(current,1)));
document.getElementById("carousel-controls").addEventListener("keydown",event=>{
  if(event.altKey||event.ctrlKey||event.metaKey)return;
  if(["ArrowLeft","ArrowRight","Home","End"].includes(event.key)){
    event.preventDefault();
    if(event.key==="Home")select(0);
    else if(event.key==="End")select(2);
    else select(Spider.wrapIndex(current,event.key==="ArrowLeft"?-1:1));
  }
});
function fromHash(){
  const index=Spider.heroes.findIndex(hero=>hero.id===location.hash.slice(1));
  select(index<0?0:index,false);
}
window.addEventListener("hashchange",fromHash);fromHash();
