"use strict";
const params=new URLSearchParams(location.search);
const {hero,film,index}=Spider.resolveSelection(params.get("hero"),params.get("film"));
document.title=film.title+" | "+hero.name+" — Multiversos";
document.getElementById("universe-name").textContent="UNIVERSO "+hero.number+" / "+hero.name.toUpperCase();
document.getElementById("film-title").textContent=film.title;
document.getElementById("film-year").textContent=film.year+" · FILME "+String(index+1).padStart(2,"0");
document.getElementById("universe-description").textContent=hero.label+". Explore uma das versões de Peter Parker que compõem este multiverso.";
const fallback="../"+Spider.galleryPath(hero);
const character=document.getElementById("film-character");
character.src=Spider.source+"assets/images/"+hero.sprite;character.alt="Homem-Aranha interpretado por "+hero.name;
character.addEventListener("error",()=>{character.src=fallback;},{once:true});
const logo=document.getElementById("film-logo");logo.src=Spider.source+Spider.filmPath(hero,index);logo.alt="Arte do título "+film.title;
logo.addEventListener("error",()=>{logo.hidden=true;},{once:true});
Spider.heroes.forEach(item=>{
 const link=document.createElement("a");link.href="?hero="+item.id+"&film=1";link.textContent=item.name;
 if(item.id===hero.id)link.setAttribute("aria-current","page");
 document.getElementById("hero-nav").append(link);
});
hero.films.forEach((movie,i)=>{
 const link=document.createElement("a");link.href="?hero="+hero.id+"&film="+(i+1);link.textContent=String(i+1).padStart(2,"0");
 link.setAttribute("aria-label",movie.title);if(i===index)link.setAttribute("aria-current","page");
 document.getElementById("film-nav").append(link);
});
const lightbox=document.getElementById("lightbox");
const large=document.getElementById("lightbox-image");
for(let i=1;i<=3;i++){
 const button=document.createElement("button");button.type="button";button.setAttribute("aria-label","Ampliar imagem "+i+" do universo de "+hero.name);
 const image=document.createElement("img");image.src=i===1?fallback:Spider.source+Spider.galleryPath(hero,i);
 image.alt="Cena do universo de "+hero.name+" — imagem "+i;image.loading="lazy";image.width=400;image.height=250;
 if(i!==1)image.addEventListener("error",()=>{image.src=fallback;},{once:true});
 button.append(image);button.addEventListener("click",()=>{large.src=image.src;large.alt=image.alt;lightbox.showModal();});
 document.getElementById("gallery").append(button);
}
document.getElementById("close-lightbox").addEventListener("click",()=>lightbox.close());
const videoDialog=document.getElementById("video-dialog");
const video=document.getElementById("video");
document.getElementById("open-video").addEventListener("click",()=>{
 document.getElementById("video-title").textContent="Vídeo de referência · "+film.title;
 video.src=Spider.source+"assets/videos/"+film.video;videoDialog.showModal();
});
video.addEventListener("error",()=>{videoDialog.querySelector("p").textContent="O vídeo não pôde ser carregado. Verifique a conexão ou consulte o repositório de referência.";});
document.getElementById("close-video").addEventListener("click",()=>videoDialog.close());
videoDialog.addEventListener("close",()=>{video.pause();video.removeAttribute("src");video.load();});
[lightbox,videoDialog].forEach(dialog=>dialog.addEventListener("click",event=>{
 if(event.target!==dialog)return;
 const r=dialog.getBoundingClientRect();if(event.clientX<r.left||event.clientX>r.right||event.clientY<r.top||event.clientY>r.bottom)dialog.close();
}));
