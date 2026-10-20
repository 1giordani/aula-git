(function(root) {
  "use strict";
  const BASE="https://pokeapi.co/api/v2/";
  function pokemonId(url) {
    const match=String(url).match(/\/pokemon\/(\d+)\/?$/);
    return match?Number(match[1]):null;
  }
  function normalize(data) {
    if(!Number.isInteger(data.id)||typeof data.name!=="string"||!Array.isArray(data.types))throw Error("Resposta inválida da API.");
    return {
      id:data.id,name:data.name,
      types:[...data.types].sort((a,b)=>a.slot-b.slot).map(slot=>slot.type.name),
      image:data.sprites?.other?.["official-artwork"]?.front_default||data.sprites?.front_default||null,
      height:data.height/10,weight:data.weight/10,
      abilities:(data.abilities||[]).map(a=>a.ability.name),
      stats:(data.stats||[]).map(s=>({name:s.stat.name,value:s.base_stat}))
    };
  }
  function filterIndex(index,query="",typeIds=null,order="number") {
    const q=query.trim().toLowerCase().replace(/^#/,"");
    return index.filter(p=>(!q||(/^\d+$/.test(q)?p.id===Number(q):p.name.includes(q)))&&(!typeIds||typeIds.has(p.id)))
      .sort(order==="name"?(a,b)=>a.name.localeCompare(b.name):(a,b)=>a.id-b.id);
  }
  function createApi({fetchImpl,storage=null,timeoutMs=12000,now=Date.now}={}) {
    const fetcher=fetchImpl||root.fetch.bind(root);
    const memory=new Map(),pending=new Map();
    async function request(path) {
      if(memory.has(path))return memory.get(path);
      const key="giordani-pokedex-v1:"+path;
      try {
        const cached=JSON.parse(storage?.getItem(key)||"null");
        if(cached&&cached.expires>now()&&cached.data&&typeof cached.data==="object") {memory.set(path,cached.data);return cached.data;}
      } catch { /* Cache bloqueado ou inválido: consulta a API. */ }
      if(pending.has(path))return pending.get(path);
      const task=(async()=>{
        const controller=new AbortController();
        const timer=setTimeout(()=>controller.abort(),timeoutMs);
        try {
          const response=await fetcher(BASE+path,{signal:controller.signal});
          if(!response.ok)throw Error("A API retornou erro "+response.status+". Tente novamente.");
          const data=await response.json();
          memory.set(path,data);
          try {storage?.setItem(key,JSON.stringify({expires:now()+7*86400000,data}));}catch{}
          return data;
        } catch(error) {
          if(error.name==="AbortError")throw Error("A consulta demorou demais. Tente novamente.");
          throw error;
        } finally {clearTimeout(timer);}
      })();
      pending.set(path,task);
      try{return await task;}finally{pending.delete(path);}
    }
    return {
      async index() {
        const data=await request("pokemon?limit=151&offset=0");
        if(!Array.isArray(data.results))throw Error("Lista inválida da API.");
        return data.results.map(p=>({id:pokemonId(p.url),name:p.name})).filter(p=>p.id>=1&&p.id<=151);
      },
      async pokemon(id) {return normalize(await request("pokemon/"+id+"/"));},
      async type(name) {
        const data=await request("type/"+encodeURIComponent(name)+"/");
        if(!Array.isArray(data.pokemon))throw Error("Tipo inválido da API.");
        return new Set(data.pokemon.map(p=>pokemonId(p.pokemon.url)).filter(id=>id>=1&&id<=151));
      }
    };
  }
  async function mapLimit(items,limit,mapper) {
    const output=new Array(items.length);let next=0;
    async function worker(){while(next<items.length){const i=next++;output[i]=await mapper(items[i],i);}}
    await Promise.all(Array.from({length:Math.min(limit,items.length)},worker));
    return output;
  }
  const api={pokemonId,normalize,filterIndex,createApi,mapLimit};
  if(typeof module!=="undefined"&&module.exports)module.exports=api;else root.Pokedex=api;
})(typeof globalThis!=="undefined"?globalThis:this);
