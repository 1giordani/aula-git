# 04 — Automação no DVWA

**Status: planejamento e testes com respostas simuladas. Não houve autenticação real em DVWA.**

O login principal do DVWA e o exercício **Brute Force** são fluxos distintos. É necessário primeiro entrar no DVWA do laboratório e selecionar o nível **Low**, usando uma sessão própria. O roteiro testa apenas a página `/dvwa/vulnerabilities/brute/`, não o login principal.

No código oficial do nível Low, o exercício recebe username, password e Login por GET. HTTP 200 não significa sucesso: a classificação deve verificar o conteúdo. Níveis com token não são atendidos por este script.

## Planejamento sem rede (padrão)
Na raiz do projeto:
```bash
python3 scripts/dvwa_lab.py --wordlist wordlists/dvwa-senhas.txt
```
O resultado informa `kind: dry_run`, o número de tentativas planejadas e zero requisições. Essa execução foi validada localmente.

## Execução opcional na VM do laboratório
1. Acesse o DVWA da VM em 192.168.56.101; configure o banco se necessário.
2. Entre com a conta didática e selecione Low. As credenciais iniciais do DVWA oficial são admin/password, mas podem ter sido modificadas.
3. Obtenha o cookie da **sua própria sessão** no navegador local. Não publique o cookie.
4. No terminal do Kali, leia-o sem exibir os caracteres:
```bash
read -r -s -p "Cookie do seu DVWA local: " DVWA_COOKIE
export DVWA_COOKIE
python3 scripts/dvwa_lab.py --wordlist wordlists/dvwa-senhas.txt --usuario admin --executar
unset DVWA_COOKIE
```

O cookie deve conter PHPSESSID e security=low. O alvo é fixo no código. O script usa até cinco candidatos, intervalo de um segundo entre pedidos, timeout de cinco segundos, bloqueio de redirecionamentos e sem proxy de ambiente. Ele para no primeiro sucesso ou resposta inconclusiva.

**Não use o script em níveis Medium, High ou Impossible.** Um token encontrado, redirecionamento, erro HTTP ou conteúdo sem marcador esperado produz parada/inconclusão, não uma senha declarada inválida.

As mensagens reconhecidas são os marcadores do exercício Low consultado; se a instalação os traduzir ou alterar, a comparação precisará ser revisada. O script não tenta contornar tokens.

## Medusa e formulários
Um módulo de autenticação HTTP não implica suporte a qualquer formulário, cookie ou token. Consulte a lista de módulos e a ajuda da versão instalada antes de adaptar uma automação. Neste cenário foi usado Python para explicitar sessão, método, validação e condições de parada; FTP e SMB têm exemplos com Medusa.

## Evidência e dados
O JSON registra o índice do candidato e o resultado, sem gravar senha ou cookie. Como o exercício usa GET, a senha pode aparecer nos logs de acesso do DVWA. Logs e capturas devem ser revisados antes de publicação.

Referências:
- [DVWA — README e configuração](https://github.com/digininja/DVWA).
- [Código oficial Low](https://github.com/digininja/DVWA/blob/master/vulnerabilities/brute/source/low.php).
- [Código oficial High, com token](https://github.com/digininja/DVWA/blob/master/vulnerabilities/brute/source/high.php).
