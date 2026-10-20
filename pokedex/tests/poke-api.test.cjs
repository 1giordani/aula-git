const test=require("node:test");
const assert=require("node:assert/strict");
const {pokemonId,normalize,filterIndex,createApi,mapLimit}=require("../assets/js/poke-api.js");
const raw={id:1,name:"bulbasaur",height:7,weight:69,types:[{slot:2,type:{name:"poison"}},{slot:1,type:{name:"grass"}}],sprites:{other:{"official-artwork":{front_default:"https://example.test/1.png"}}},abilities:[{ability:{name:"overgrow"}}],stats:[{stat:{name:"hp"},base_stat:45}]};
const ok=data=>({ok:true,status:200,json:async()=>data});
function memoryStorage(){const data=new Map();return{getItem:k=>data.get(k)||null,setItem:(k,v)=>data.set(k,v)};}
test("extrai ID de URL de Pokémon sem confundir recursos",()=>{
 assert.equal(pokemonId("https://pokeapi.co/api/v2/pokemon/25/"),25);
 assert.equal(pokemonId("https://pokeapi.co/api/v2/type/1/"),null);
});
test("normaliza tipos por slot e converte altura e peso",()=>{
 const p=normalize(raw);assert.deepEqual(p.types,["grass","poison"]);
 assert.equal(p.height,.7);assert.equal(p.weight,6.9);assert.equal(p.stats[0].value,45);
});
test("usa sprite alternativo quando arte oficial não existe",()=>{
 const p=normalize({...raw,sprites:{front_default:"fallback.png"}});assert.equal(p.image,"fallback.png");
 assert.equal(normalize({...raw,sprites:null}).image,null);
});
test("rejeita detalhe sem campos obrigatórios",()=>assert.throws(()=>normalize({id:"1",name:"x",types:[]})));
const index=[{id:25,name:"pikachu"},{id:1,name:"bulbasaur"},{id:4,name:"charmander"}];
test("busca ignora caixa e espaços e aceita ID com cerquilha e zeros",()=>{
 assert.equal(filterIndex(index," PIKA ")[0].id,25);
 assert.equal(filterIndex(index,"#001")[0].id,1);
 assert.deepEqual(filterIndex(index,"999"),[]);
});
test("filtro combina tipo e busca sem alterar o índice",()=>{
 assert.deepEqual(filterIndex(index,"",new Set([4,25])).map(p=>p.id),[4,25]);
 assert.deepEqual(filterIndex(index,"pika",new Set([4])),[]);
 assert.deepEqual(index.map(p=>p.id),[25,1,4]);
});
test("ordena por nome e aceita conjunto de tipo vazio",()=>{
 assert.deepEqual(filterIndex(index,"",null,"name").map(p=>p.id),[1,4,25]);
 assert.deepEqual(filterIndex(index,"",new Set()),[]);
});
test("deduplica requisições simultâneas e reutiliza cache em memória",async()=>{
 let calls=0;const api=createApi({fetchImpl:async()=>{calls++;return ok(raw);}});
 await Promise.all([api.pokemon(1),api.pokemon(1)]);await api.pokemon(1);assert.equal(calls,1);
});
test("cache persistente é reutilizado por outra instância",async()=>{
 const storage=memoryStorage();const api=createApi({storage,fetchImpl:async()=>ok(raw),now:()=>100});
 await api.pokemon(1);
 const cached=createApi({storage,fetchImpl:async()=>{throw Error("não deveria consultar");},now:()=>200});
 assert.equal((await cached.pokemon(1)).name,"bulbasaur");
});
test("cache expirado causa uma nova consulta",async()=>{
 const storage=memoryStorage();await createApi({storage,fetchImpl:async()=>ok(raw),now:()=>0}).pokemon(1);
 let calls=0;await createApi({storage,fetchImpl:async()=>{calls++;return ok(raw);},now:()=>8*86400000}).pokemon(1);
 assert.equal(calls,1);
});
test("falha HTTP permite tentar novamente",async()=>{
 let calls=0;const api=createApi({fetchImpl:async()=>++calls===1?{ok:false,status:503}:ok(raw)});
 await assert.rejects(api.pokemon(1),/503/);assert.equal((await api.pokemon(1)).id,1);assert.equal(calls,2);
});
test("armazenamento bloqueado não impede consultas",async()=>{
 const storage={getItem(){throw Error("bloqueado");},setItem(){throw Error("bloqueado");}};
 assert.equal((await createApi({storage,fetchImpl:async()=>ok(raw)}).pokemon(1)).id,1);
});
test("limita concorrência e mantém ordem dos resultados",async()=>{
 let active=0,peak=0;
 const result=await mapLimit([1,2,3,4,5,6],2,async n=>{
  active++;peak=Math.max(peak,active);await new Promise(resolve=>setTimeout(resolve,2));active--;return n*2;
 });
 assert.deepEqual(result,[2,4,6,8,10,12]);assert.equal(peak,2);
});
test("lista e tipo excluem Pokémon fora dos 151",async()=>{
 const api=createApi({fetchImpl:async url=>ok(url.includes("type/")?{pokemon:[{pokemon:{url:"https://pokeapi.co/api/v2/pokemon/1/"}},{pokemon:{url:"https://pokeapi.co/api/v2/pokemon/152/"}}]}:{results:[{name:"bulbasaur",url:"https://pokeapi.co/api/v2/pokemon/1/"},{name:"chikorita",url:"https://pokeapi.co/api/v2/pokemon/152/"}]})});
 assert.equal((await api.index()).length,1);assert.deepEqual([...(await api.type("grass"))],[1]);
});
test("consulta com timeout retorna erro compreensível",async()=>{
 const api=createApi({timeoutMs:2,fetchImpl:(_url,{signal})=>new Promise((_,reject)=>signal.addEventListener("abort",()=>{const e=Error();e.name="AbortError";reject(e);}))});
 await assert.rejects(api.pokemon(1),/demorou demais/);
});
