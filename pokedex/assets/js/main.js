"use strict";
const typeNames={"normal":"Normal","fire":"Fogo","water":"Água","electric":"Elétrico","grass":"Planta","ice":"Gelo","fighting":"Lutador","poison":"Veneno","ground":"Terra","flying":"Voador","psychic":"Psíquico","bug":"Inseto","rock":"Pedra","ghost":"Fantasma","dragon":"Dragão","dark":"Sombrio","steel":"Aço","fairy":"Fada"};
const statNames={hp:"HP",attack:"Ataque",defense:"Defesa","special-attack":"Atq. especial","special-defense":"Def. especial",speed:"Velocidade"};
let storage=null;try{storage=localStorage;}catch{}
const api=Pokedex.createApi({storage});
const ui=Object.fromEntries(["filters","search","type","order","clear","status","pokemon-list","load-more","retry","details","detail-content","close-details"].map(id=>[id,document.getElementById(id)]));
const controls=[ui.search,ui.type,ui.order,ui.clear,ui.filters.querySelector('button[type="submit"]')];
let index=[],filtered=[],loaded=0,revision=0,busy=false,debounce=null,retryAction=null;
const pageSize=12;
function element(tag,className,text){
  const node=document.createElement(tag);if(className)node.className=className;
  if(text!==undefined)node.textContent=text;return node;
}
function number(id){return "#"+String(id).padStart(3,"0");}
function setBusy(value){
  busy=value;ui["pokemon-list"].setAttribute("aria-busy",String(value));
  ui["load-more"].disabled=value;ui.retry.disabled=value;
}
function showError(error,action){
  ui.status.textContent="Não foi possível carregar. "+(error.message||"Verifique sua conexão.");
  retryAction=action;ui.retry.hidden=false;ui["load-more"].hidden=true;
}
function image(pokemon,className){
  if(!pokemon.image)return element("div","no-image","Imagem indisponível");
  const img=element("img",className);img.src=pokemon.image;img.alt=pokemon.name;
  img.loading="lazy";img.width=180;img.height=180;
  img.addEventListener("error",()=>img.replaceWith(element("div","no-image","Imagem indisponível")),{once:true});
  return img;
}
function badges(pokemon){
  const wrap=element("div","types");
  pokemon.types.forEach(type=>wrap.append(element("span","type type-"+type,typeNames[type]||type)));
  return wrap;
}
function card(pokemon){
  const button=element("button","pokemon-card");button.type="button";
  button.setAttribute("aria-label","Ver detalhes de "+pokemon.name);
  const top=element("div","card-top");top.append(element("span","",number(pokemon.id)),element("span","","KANTO"));
  button.append(top,image(pokemon,"card-image"),element("h3","",pokemon.name),badges(pokemon),element("span","card-hint","VER DETALHES ↗"));
  button.addEventListener("click",()=>details(pokemon));return button;
}
function details(pokemon){
  const content=ui["detail-content"];content.replaceChildren();
  content.append(image(pokemon,"detail-image"),element("p","detail-id",number(pokemon.id)));
  const name=element("h2","",pokemon.name);name.id="detail-name";content.append(name,badges(pokemon));
  const measures=element("div","measurements");
  measures.append(element("span","","Altura: "+pokemon.height.toLocaleString("pt-BR")+" m"),element("span","","Peso: "+pokemon.weight.toLocaleString("pt-BR")+" kg"));
  content.append(measures,element("p","abilities","Habilidades: "+pokemon.abilities.join(", ").replaceAll("-"," ")));
  const stats=element("div","stats");stats.setAttribute("aria-label","Atributos base");
  pokemon.stats.forEach(stat=>{
    const row=element("div","stat");
    const meter=element("meter");meter.min=0;meter.max=255;meter.value=stat.value;
    meter.setAttribute("aria-label",(statNames[stat.name]||stat.name)+": "+stat.value+" de 255");
    row.append(element("span","",statNames[stat.name]||stat.name),element("strong","",stat.value),meter);stats.append(row);
  });
  content.append(stats);ui.details.showModal();
}
async function loadPage(token=revision){
  if(busy||token!==revision)return;
  const page=filtered.slice(loaded,loaded+pageSize);if(!page.length)return;
  setBusy(true);ui.retry.hidden=true;ui.status.textContent="Carregando Pokémon…";
  try{
    const result=await Pokedex.mapLimit(page,4,p=>api.pokemon(p.id));
    if(token!==revision)return;
    const fragment=document.createDocumentFragment();
    result.forEach(p=>{fragment.append(card(p));});
    ui["pokemon-list"].append(fragment);loaded+=result.length;
    ui.status.textContent="Exibindo "+loaded+" de "+filtered.length+" Pokémon encontrados.";
    ui["load-more"].hidden=loaded>=filtered.length;
  }catch(error){if(token===revision)showError(error,()=>loadPage(revision));}
  finally{if(token===revision)setBusy(false);}
}
async function applyFilters(){
  clearTimeout(debounce);
  const token=++revision;
  setBusy(true);ui.retry.hidden=true;ui["load-more"].hidden=true;
  ui["pokemon-list"].replaceChildren();loaded=0;
  const query=ui.search.value,type=ui.type.value,order=ui.order.value;
  ui.status.textContent="Consultando filtros…";
  try{
    const ids=type?await api.type(type):null;
    if(token!==revision)return;
    filtered=Pokedex.filterIndex(index,query,ids,order);
    setBusy(false);
    if(!filtered.length){ui.status.textContent="Nenhum Pokémon encontrado. Tente outro nome, número ou tipo.";return;}
    await loadPage(token);
  }catch(error){if(token===revision){setBusy(false);showError(error,applyFilters);}}
}
async function initialize(){
  const token=++revision;
  controls.forEach(control=>control.disabled=true);
  setBusy(true);ui.retry.hidden=true;ui.status.textContent="Carregando catálogo de Kanto…";
  try{
    index=await api.index();if(token!==revision)return;
    controls.forEach(control=>control.disabled=false);setBusy(false);await applyFilters();
  }catch(error){if(token===revision){setBusy(false);showError(error,initialize);}}
}
ui.filters.addEventListener("submit",event=>{event.preventDefault();applyFilters();});
ui.search.addEventListener("input",()=>{clearTimeout(debounce);debounce=setTimeout(applyFilters,300);});
ui.type.addEventListener("change",applyFilters);
ui.order.addEventListener("change",applyFilters);
ui.clear.addEventListener("click",()=>{ui.search.value="";ui.type.value="";ui.order.value="number";applyFilters();});
ui["load-more"].addEventListener("click",()=>loadPage());
ui.retry.addEventListener("click",()=>{if(retryAction)retryAction();});
ui["close-details"].addEventListener("click",()=>ui.details.close());
ui.details.addEventListener("click",event=>{if(event.target===ui.details){const r=ui.details.getBoundingClientRect();if(event.clientX<r.left||event.clientX>r.right||event.clientY<r.top||event.clientY>r.bottom)ui.details.close();}});
initialize();
