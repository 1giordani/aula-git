(function(root){
  "use strict";
  const source="https://raw.githubusercontent.com/micheleambrosio/spider-man-multiverses-dio/7654422bc2a0cab81eb07c5c49530fa05e5a8d2b/";
  const heroes=[
    {id:"tobey",name:"Tobey Maguire",label:"A responsabilidade de ser um herói",number:"01",sprite:"spider-man-01.png",slug:"spiderman-tobey",films:[
      {title:"Homem-Aranha",year:2002,video:"spiderman-2002-trailer.mp4"},
      {title:"Homem-Aranha 2",year:2004,video:"spiderman2-2004-trailer.mp4"},
      {title:"Homem-Aranha 3",year:2007,video:"spiderman3-2007-trailer.mp4"}]},
    {id:"tom",name:"Tom Holland",label:"Um novo olhar sobre o seu amigo da vizinhança",number:"02",sprite:"spider-man-02.png",slug:"spiderman-tom",films:[
      {title:"Homem-Aranha: De Volta ao Lar",year:2017,video:"spiderman-2017-trailer.mp4"},
      {title:"Homem-Aranha: Longe de Casa",year:2019,video:"spiderman2-2019-trailer.mp4"},
      {title:"Homem-Aranha: Sem Volta para Casa",year:2021,video:"spiderman3-2021-trailer.mp4"}]},
    {id:"andrew",name:"Andrew Garfield",label:"Uma aventura espetacular por outro universo",number:"03",sprite:"spider-man-03.png",slug:"spiderman-andrew",films:[
      {title:"O Espetacular Homem-Aranha",year:2012,video:"amazing-spiderman-2014-trailer.mp4"},
      {title:"O Espetacular Homem-Aranha 2: A Ameaça de Electro",year:2014,video:"amazing-spiderman2-2014-trailer.mp4"}]}
  ];
  function resolveSelection(heroId,filmNumber=1){
    const hero=heroes.find(item=>item.id===heroId)||heroes[0];
    const n=Number(filmNumber);
    const index=Number.isInteger(n)&&n>=1&&n<=hero.films.length?n-1:0;
    return {hero,film:hero.films[index],index};
  }
  function wrapIndex(index,step=1){return ((index+step)%heroes.length+heroes.length)%heroes.length;}
  function galleryPath(hero,index=1){return "assets/images/"+hero.slug+"/movie-01/gallery/image-0"+index+".png";}
  function filmPath(hero,index){return "assets/images/"+hero.slug+"/movie-0"+(index+1)+"/logo.png";}
  const api={heroes,source,resolveSelection,wrapIndex,galleryPath,filmPath};
  if(typeof module!=="undefined"&&module.exports)module.exports=api;else root.Spider=api;
})(typeof globalThis!=="undefined"?globalThis:this);
