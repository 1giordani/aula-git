"use strict";
document.body.classList.add("js-enabled");
const root=document.documentElement;
const themeButton=document.getElementById("theme-toggle");
function applyTheme(theme){
 const selected=theme==="light"?"light":"dark";root.dataset.theme=selected;
 const light=selected==="light";themeButton.setAttribute("aria-pressed",String(light));
 themeButton.setAttribute("aria-label",light?"Ativar tema escuro":"Ativar tema claro");
 document.querySelector('meta[name="theme-color"]').content=light?"#f3efe7":"#171717";
}
try{applyTheme(localStorage.getItem("giordani-portfolio-theme"));}catch{applyTheme("dark");}
themeButton.addEventListener("click",()=>{
 const next=root.dataset.theme==="dark"?"light":"dark";applyTheme(next);
 try{localStorage.setItem("giordani-portfolio-theme",next);}catch{}
});
const menu=document.getElementById("nav");
const menuToggle=document.getElementById("menu-toggle");
function closeMenu(){menu.classList.remove("open");menuToggle.setAttribute("aria-expanded","false");}
menuToggle.addEventListener("click",()=>{
 const open=menu.classList.toggle("open");menuToggle.setAttribute("aria-expanded",String(open));
});
menu.querySelectorAll("a").forEach(link=>link.addEventListener("click",closeMenu));
document.addEventListener("keydown",event=>{
 if(event.key==="Escape"&&menu.classList.contains("open")){closeMenu();menuToggle.focus();}
});
if("IntersectionObserver" in window){
 const observer=new IntersectionObserver(entries=>{
  entries.forEach(entry=>{
   if(!entry.isIntersecting)return;
   menu.querySelectorAll("a").forEach(link=>{
    if(link.getAttribute("href")==="#"+entry.target.id)link.setAttribute("aria-current","location");else link.removeAttribute("aria-current");
   });
  });
 },{rootMargin:"-15% 0px -65% 0px"});
 document.querySelectorAll("main section[id]").forEach(section=>observer.observe(section));
}
const search=document.getElementById("project-search");
const filterButtons=[...document.querySelectorAll("[data-filter]")];
const cards=[...document.querySelectorAll("[data-project]")];
let category="todos";
function render(){
 const found=Portfolio.filterProjects(category,search.value),ids=new Set(found.map(p=>p.id));
 cards.forEach(card=>{card.hidden=!ids.has(card.dataset.project);});
 filterButtons.forEach(button=>button.setAttribute("aria-pressed",String(button.dataset.filter===category)));
 document.getElementById("result-count").textContent=found.length+" "+(found.length===1?"projeto encontrado.":"projetos encontrados.");
 document.getElementById("empty-state").hidden=found.length>0;
}
filterButtons.forEach(button=>button.addEventListener("click",()=>{category=button.dataset.filter;render();}));
search.addEventListener("input",render);
render();
