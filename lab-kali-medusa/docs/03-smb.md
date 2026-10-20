# 03 — Enumeração e password spraying em SMB

**Status: roteiro não executado em VM.**

Spraying testa uma senha em várias contas antes de considerar outra senha. Dicionário costuma percorrer várias senhas para uma conta. Uma lista de usuários com uma lista de senhas não comprova, por si só, a ordem de spraying.

## Enumeração limitada
Na VM vulnerável, uma consulta anônima poderá ou não ser permitida:
```bash
rpcclient -U "" -N 192.168.56.101 -c "enumdomusers"
```
Se for negada, registre a restrição. Não invente usuários enumerados. Compare somente contas de teste confirmadas com `wordlists/usuarios-lab.txt`, que é uma lista de exemplos.

Metasploitable 2 contém serviços antigos. Clientes atuais podem recusar seus protocolos. Registre a incompatibilidade separadamente; não altere globalmente as proteções do computador para fazer o exemplo funcionar.

## Uma rodada de spraying
Confira `medusa -M smbnt -q` e, se o módulo e o protocolo forem compatíveis, aplique **uma única senha didática** às contas do arquivo:
```bash
medusa -h 192.168.56.101 -U wordlists/usuarios-lab.txt -p 'Lab#2026' -M smbnt -n 445 -t 1 -T 1 -O logs/smb-rodada-01.log
```

Este comando representa uma rodada com até três contas e uma senha. Não há laço automático de novas rodadas. Confira a política de bloqueio antes de qualquer repetição. O objetivo é observar controles e eventos, não contorná-los.

## Validação
Se houver um resultado positivo, confira a credencial de teste no cliente SMB, informando a senha pelo prompt:
```bash
smbclient -L //192.168.56.101 -U msfadmin
```
Substitua o usuário apenas por uma conta efetivamente testada. Observe se a sessão é autenticada ou mapeada para guest: listar um compartilhamento público não comprova acesso com a conta alegada.

## Detecção
Compare tentativas por conta e por origem. Spraying pode produzir poucas falhas por usuário, mas falhas distribuídas entre vários usuários. Registre os eventos de autenticação disponíveis no alvo; não pressuponha IDs de eventos Windows em um alvo Linux/Samba.

Referências: [Medusa no Kali](https://www.kali.org/tools/medusa/) e [rpcclient — Samba](https://www.samba.org/samba/docs/current/man-html/rpcclient.1.html).
