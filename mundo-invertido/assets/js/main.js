"use strict";
const themeButton=document.getElementById("switch-theme");
const themeStatus=document.getElementById("theme-status");
const themeColor=document.querySelector('meta[name="theme-color"]');
function applyTheme(theme) {
  const selected=theme==="inverted"?"inverted":"normal";
  document.body.dataset.theme=selected;
  const inverted=selected==="inverted";
  themeButton.setAttribute("aria-pressed",String(inverted));
  themeButton.textContent=inverted?"Voltar ao mundo normal":"Inverter mundos";
  themeStatus.textContent=inverted?"Você está no Mundo Invertido.":"Você está no mundo normal.";
  themeColor.content=inverted?"#130e10":"#eee9df";
}
try{applyTheme(localStorage.getItem("giordani-mundo-theme"));}catch{applyTheme("normal");}
themeButton.addEventListener("click",()=>{
  const theme=Mundo.nextTheme(document.body.dataset.theme);
  applyTheme(theme);try{localStorage.setItem("giordani-mundo-theme",theme);}catch{}
});
const form=document.getElementById("club-form");
const fields=Object.fromEntries(["name","email","level","character"].map(key=>[key,document.getElementById(key)]));
const formStatus=document.getElementById("form-status");
document.getElementById("submit-form").disabled=false;
form.addEventListener("submit",event=>{
  event.preventDefault();
  const result=Mundo.validateForm(Object.fromEntries(Object.entries(fields).map(([key,input])=>[key,input.value])));
  Object.entries(fields).forEach(([key,input])=>{
    input.setAttribute("aria-invalid",String(Boolean(result.errors[key])));
    document.getElementById("error-"+key).textContent=result.errors[key]||"";
  });
  if(!result.valid){
    formStatus.textContent="Revise os campos indicados para continuar.";
    fields[Object.keys(result.errors)[0]].focus();return;
  }
  formStatus.textContent="Simulação concluída! "+result.values.name+", seu personagem de nível "+Number(result.values.level)+" passou pela validação. Nenhum cadastro foi enviado.";
  form.reset();
});
Object.entries(fields).forEach(([key,input])=>input.addEventListener("input",()=>{
  if(input.getAttribute("aria-invalid")==="true"){
    input.removeAttribute("aria-invalid");document.getElementById("error-"+key).textContent="";
  }
  formStatus.textContent="";
}));
