const test=require("node:test");
const assert=require("node:assert/strict");
const {heroes,resolveSelection,wrapIndex,galleryPath,filmPath}=require("../assets/js/data.js");
const sourcePaths=new Set(require("./source-files.json"));
test("catálogo possui três universos únicos e oito filmes",()=>{
 assert.equal(heroes.length,3);assert.equal(new Set(heroes.map(h=>h.id)).size,3);
 assert.equal(heroes.reduce((total,h)=>total+h.films.length,0),8);
});
test("todas as oito rotas selecionam o universo e filme correspondentes",()=>{
 heroes.forEach(hero=>hero.films.forEach((film,i)=>{
  const result=resolveSelection(hero.id,String(i+1));
  assert.equal(result.hero.id,hero.id);assert.equal(result.film.title,film.title);assert.equal(result.index,i);
 }));
});
test("parâmetros ausentes ou inválidos têm fallback",()=>{
 assert.equal(resolveSelection("desconhecido","999").hero.id,"tobey");
 ["0","-1","1.5","abc",null,""].forEach(value=>assert.equal(resolveSelection("andrew",value).index,0));
 assert.equal(resolveSelection("andrew",3).index,0);
});
test("navegação circular não sai dos limites",()=>{
 assert.equal(wrapIndex(0,-1),2);assert.equal(wrapIndex(2,1),0);assert.equal(wrapIndex(1,9),1);
});
test("artes, galerias e vídeos apontam para arquivos presentes na referência",()=>{
 heroes.forEach(hero=>{
  assert.ok(sourcePaths.has("assets/images/"+hero.sprite));
  for(let n=1;n<=3;n++)assert.ok(sourcePaths.has(galleryPath(hero,n)));
  hero.films.forEach((film,i)=>{
   assert.ok(sourcePaths.has(filmPath(hero,i)));
   assert.ok(sourcePaths.has("assets/videos/"+film.video));
  });
 });
});
