#!/usr/bin/env python3
"""Simulação didática sem rede, sem Medusa e sem autenticação real."""
import argparse
import json

ACCOUNTS = {"ana": "lab123", "bruno": "SenhaDidatica!"}
CANDIDATES = ["123456", "lab123", "SenhaDidatica!"]

def simulate(mode="dictionary", max_failures=None):
    if mode not in {"dictionary", "spray"}:
        raise ValueError("Modo inválido")
    if max_failures is not None and (not isinstance(max_failures, int) or max_failures < 1):
        raise ValueError("Limite inválido")
    users = list(ACCOUNTS)
    pairs = ([(u, p) for u in users for p in CANDIDATES] if mode == "dictionary"
             else [(u, p) for p in CANDIDATES for u in users])
    failures = dict.fromkeys(users, 0)
    authenticated, blocked, events = set(), set(), []
    for user, password in pairs:
        if user in authenticated or user in blocked:
            continue
        if max_failures is not None and failures[user] >= max_failures:
            blocked.add(user)
            events.append({"user": user, "result": "blocked", "authentication_attempt": False})
            continue
        success = ACCOUNTS[user] == password
        events.append({"user": user, "candidate_index": CANDIDATES.index(password) + 1,
                       "result": "success" if success else "failure", "authentication_attempt": True})
        if success:
            authenticated.add(user)
        else:
            failures[user] += 1
    return {"kind": "offline_simulation", "mode": mode, "max_failures": max_failures,
            "network_requests": 0, "attempts": sum(e["authentication_attempt"] for e in events),
            "authenticated": sorted(authenticated), "blocked": sorted(blocked), "events": events}

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--mode", choices=["dictionary", "spray"], default="dictionary")
    parser.add_argument("--max-failures", type=int)
    args = parser.parse_args()
    print(json.dumps(simulate(args.mode, args.max_failures), ensure_ascii=False, indent=2))

if __name__ == "__main__":
    main()
