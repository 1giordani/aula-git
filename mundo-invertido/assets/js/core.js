(function(root){
  "use strict";
  function validateForm(input){
    const values={
      name:String(input.name||"").trim(),
      email:String(input.email||"").trim(),
      level:String(input.level??"").trim(),
      character:String(input.character||"").trim()
    };
    const errors={};
    if(values.name.length<2||values.name.length>80)errors.name="Informe um nome entre 2 e 80 caracteres.";
    if(values.email.length>254||!/^\S+@[^\s@]+\.[^\s@]+$/.test(values.email)||values.email.split("@").length!==2)errors.email="Informe um e-mail válido para a demonstração.";
    if(!/^\d+$/.test(values.level)||Number(values.level)<1||Number(values.level)>20)errors.level="Escolha um nível inteiro de 1 a 20.";
    if(values.character.length<20||values.character.length>600)errors.character="Descreva seu personagem com 20 a 600 caracteres.";
    return {valid:Object.keys(errors).length===0,values,errors};
  }
  function nextTheme(current){return current==="inverted"?"normal":"inverted";}
  const api={validateForm,nextTheme};
  if(typeof module!=="undefined"&&module.exports)module.exports=api;
  else root.Mundo=api;
})(typeof globalThis!=="undefined"?globalThis:this);
