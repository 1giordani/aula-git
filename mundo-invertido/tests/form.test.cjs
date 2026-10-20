const test=require("node:test");
const assert=require("node:assert/strict");
const {validateForm}=require("../assets/js/core.js");
const valid={name:"Guardião de Hawkins",email:"aventureiro@example.com",level:"1",character:"Um mago corajoso que protege seus amigos em Hawkins."};
test("aceita personagem válido e remove espaços externos",()=>{
 const r=validateForm({...valid,name:"  Guardião  ",email:" aventureiro@example.com "});
 assert.equal(r.valid,true);assert.equal(r.values.name,"Guardião");assert.equal(r.values.email,"aventureiro@example.com");
});
test("níveis um e vinte são aceitos e outros valores rejeitados",()=>{
 ["1","20"].forEach(level=>assert.equal(validateForm({...valid,level}).valid,true));
 ["0","21","1.5","-1","abc",""].forEach(level=>assert.ok(validateForm({...valid,level}).errors.level));
});
test("campos vazios geram erros em todos os campos",()=>{
 const r=validateForm({});assert.equal(r.valid,false);assert.deepEqual(Object.keys(r.errors),["name","email","level","character"]);
});
test("e-mails incompletos, com espaços ou múltiplos arrobas são rejeitados",()=>{
 ["a@","sem-arroba.com","a @example.com","a@@example.com","a@example","@example.com"].forEach(email=>assert.ok(validateForm({...valid,email}).errors.email));
});
test("nome respeita limites de tamanho",()=>{
 assert.ok(validateForm({...valid,name:"A"}).errors.name);assert.ok(validateForm({...valid,name:"a".repeat(81)}).errors.name);
 assert.equal(validateForm({...valid,name:"a".repeat(80)}).valid,true);
});
test("descrição respeita os limites vinte e seiscentos",()=>{
 [20,600].forEach(n=>assert.equal(validateForm({...valid,character:"a".repeat(n)}).valid,true));
 [19,601].forEach(n=>assert.ok(validateForm({...valid,character:"a".repeat(n)}).errors.character));
});
test("entrada não é modificada durante a validação",()=>{
 const input={...valid};validateForm(input);assert.deepEqual(input,valid);
});
