(function(root) {
  "use strict";
  function shuffle(values, random = Math.random) {
    const result = [...values];
    for (let i = result.length - 1; i > 0; i--) {
      const j = Math.floor(random() * (i + 1));
      [result[i], result[j]] = [result[j], result[i]];
    }
    return result;
  }
  function createGame(deck) {
    if (!Array.isArray(deck) || deck.length === 0 || deck.length % 2) throw new Error("Baralho inválido");
    const counts = new Map();
    deck.forEach(value => counts.set(value, (counts.get(value) || 0) + 1));
    if ([...counts.values()].some(count => count !== 2)) throw new Error("Cada símbolo deve aparecer duas vezes");
    const state = { deck: [...deck], open: [], matched: new Set(), moves: 0, phase: "ready" };
    return {
      state,
      flip(index) {
        if (!Number.isInteger(index) || index < 0 || index >= state.deck.length ||
            state.phase === "locked" || state.phase === "won" ||
            state.matched.has(index) || state.open.includes(index)) return "ignored";
        state.phase = "playing";
        state.open.push(index);
        if (state.open.length === 1) return "first";
        state.moves++;
        const [a, b] = state.open;
        if (state.deck[a] !== state.deck[b]) {
          state.phase = "locked";
          return "mismatch";
        }
        state.matched.add(a); state.matched.add(b); state.open = [];
        if (state.matched.size === state.deck.length) { state.phase = "won"; return "won"; }
        return "match";
      },
      closeMismatch() {
        if (state.phase !== "locked") return;
        state.open = []; state.phase = "playing";
      }
    };
  }
  const api = { shuffle, createGame };
  if (typeof module !== "undefined" && module.exports) module.exports = api;
  else root.MemoryGame = api;
})(typeof globalThis !== "undefined" ? globalThis : this);
