const test=require("node:test");
const assert=require("node:assert/strict");
const {projects,filterProjects}=require("../assets/js/projects.js");
test("catálogo possui oito projetos com identificadores e URLs únicos",()=>{
 assert.equal(projects.length,8);assert.equal(new Set(projects.map(p=>p.id)).size,8);
 assert.equal(new Set(projects.map(p=>p.url)).size,8);
 projects.forEach(p=>{const url=new URL(p.url);assert.equal(url.hostname,"github.com");assert.equal(url.pathname.split("/")[1],"1giordani");});
});
test("categorias isolam interfaces, jogos e aplicações",()=>{
 assert.equal(filterProjects("interfaces").length,3);
 assert.equal(filterProjects("jogos").length,3);
 assert.equal(filterProjects("aplicacoes").length,2);
});
test("busca desconsidera caixa, espaços e acentos",()=>{
 assert.equal(filterProjects("todos","  PIANO  ")[0].id,"piano");
 assert.equal(filterProjects("todos","audio")[0].id,"piano");
 assert.equal(filterProjects("todos","POKEDEX")[0].id,"pokedex");
});
test("busca e categoria são aplicadas em conjunto",()=>{
 assert.deepEqual(filterProjects("jogos","piano"),[]);
 assert.deepEqual(filterProjects("aplicacoes","cache").map(p=>p.id),["pokedex"]);
});
test("busca vazia preserva catálogo e ausência de resultados não o altera",()=>{
 const before=JSON.stringify(projects);assert.equal(filterProjects().length,8);
 assert.deepEqual(filterProjects("todos","inexistente"),[]);assert.equal(JSON.stringify(projects),before);
});
