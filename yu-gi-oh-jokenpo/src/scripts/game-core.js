(function(root) {
  "use strict";
  const cards = [
    { id:0, name:"Exodia", type:"Pedra", icon:"✊", image:"exodia.png", beats:2 },
    { id:1, name:"Dragão Branco", type:"Papel", icon:"✋", image:"dragon.png", beats:0 },
    { id:2, name:"Mago Negro", type:"Tesoura", icon:"✌", image:"magician.png", beats:1 }
  ];
  function outcome(player, opponent) {
    if (![player,opponent].every(id => Number.isInteger(id) && id >= 0 && id < cards.length)) throw new Error("Carta inválida");
    if (player === opponent) return "draw";
    return cards[player].beats === opponent ? "win" : "lose";
  }
  function draw(random = Math.random) { return Math.floor(random() * cards.length); }
  function hand(random = Math.random) {
    const result = [0,1,2,draw(random),draw(random)];
    for (let i=result.length-1;i>0;i--) {
      const j=Math.floor(random()*(i+1)); [result[i],result[j]]=[result[j],result[i]];
    }
    return result;
  }
  function createDuel(target=5) {
    if (!Number.isInteger(target) || target < 1) throw new Error("Meta inválida");
    const state={ player:0, opponent:0, draws:0, round:1, phase:"choosing", history:[], winner:null };
    return {
      state,
      play(player,opponent) {
        if (state.phase !== "choosing") return null;
        const result=outcome(player,opponent);
        if(result==="win") state.player++;
        else if(result==="lose") state.opponent++;
        else state.draws++;
        const entry={round:state.round,player,opponent,result};
        state.history.push(entry);
        state.phase="result";
        if(state.player===target || state.opponent===target) {
          state.phase="finished";
          state.winner=state.player===target ? "player" : "opponent";
        }
        return entry;
      },
      next() {
        if(state.phase!=="result") return false;
        state.round++; state.phase="choosing"; return true;
      }
    };
  }
  const api={cards,outcome,draw,hand,createDuel};
  if(typeof module!=="undefined" && module.exports) module.exports=api;
  else root.YugiGame=api;
})(typeof globalThis!=="undefined" ? globalThis : this);
