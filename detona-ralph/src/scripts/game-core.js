/* Regras independentes do DOM: testáveis com o Node.js. */
(function (root) {
  "use strict";
  function createGame() {
    const state = { phase: "idle", score: 0, lives: 3, remainingMs: 60000, deadline: 0, target: null };
    function finish() { state.phase = "finished"; state.target = null; }
    return {
      state,
      start(now) {
        Object.assign(state, { phase: "playing", score: 0, lives: 3, remainingMs: 60000, deadline: now + 60000, target: null });
      },
      tick(now) {
        if (state.phase !== "playing") return;
        state.remainingMs = Math.max(0, state.deadline - now);
        if (state.remainingMs === 0) finish();
      },
      setTarget(index) {
        if (state.phase === "playing" && Number.isInteger(index) && index >= 0 && index < 9) state.target = index;
      },
      hit(index, now) {
        this.tick(now);
        if (state.phase !== "playing" || !Number.isInteger(index) || index < 0 || index > 8) return "ignored";
        if (state.target === index) {
          state.score += 1; state.target = null; return "hit";
        }
        state.lives -= 1;
        if (state.lives === 0) finish();
        return "miss";
      },
      pause(now) {
        this.tick(now);
        if (state.phase === "playing") state.phase = "paused";
      },
      resume(now) {
        if (state.phase !== "paused") return;
        state.deadline = now + state.remainingMs;
        state.phase = "playing";
      }
    };
  }
  if (typeof module !== "undefined" && module.exports) module.exports = { createGame };
  else root.RalphGame = { createGame };
})(typeof globalThis !== "undefined" ? globalThis : this);
