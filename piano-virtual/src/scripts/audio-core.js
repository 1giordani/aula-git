(function(root){
  "use strict";
  const keys=["a","w","s","e","d","f","t","g","y","h","u","j","k","o","l","p",";"];
  function normalizeKey(key) {
    const value=typeof key==="string"?key.toLowerCase():"";
    return keys.includes(value)?value:null;
  }
  function createPlayer(factory) {
    const voices=new Map(); let volume=0.5, muted=false;
    function effectiveVolume(){return muted?0:volume;}
    function updateVolumes(){voices.forEach(audio=>{audio.volume=effectiveVolume();});}
    return {
      async play(rawKey) {
        const key=normalizeKey(rawKey); if(key===null)return false;
        try {
          if(!voices.has(key))voices.set(key,factory("src/tunes/"+key+".wav"));
          const audio=voices.get(key);
          audio.volume=effectiveVolume(); audio.currentTime=0;
          await audio.play(); return true;
        } catch {return false;}
      },
      setVolume(value) {
        const number=Number(value);
        if(!Number.isFinite(number))return volume;
        volume=Math.max(0,Math.min(1,number));updateVolumes();return volume;
      },
      setMuted(value){muted=Boolean(value);updateVolumes();return muted;},
      stopAll(){voices.forEach(audio=>{audio.pause();audio.currentTime=0;});}
    };
  }
  const api={keys,normalizeKey,createPlayer};
  if(typeof module!=="undefined"&&module.exports)module.exports=api;
  else root.Piano=api;
})(typeof globalThis!=="undefined"?globalThis:this);
