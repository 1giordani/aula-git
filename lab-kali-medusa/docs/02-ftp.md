# 02 — Dicionário em FTP

**Status: roteiro não executado em VM.**

Objetivo: observar como uma lista pequena de senhas é aplicada a uma conta do laboratório. A wordlist contém exemplos, incluindo uma credencial padrão de ambiente vulnerável; não representa uma descoberta.

## Ensaio proposto
Após confirmar que a porta 21 pertence à VM do escopo:
```bash
medusa -h 192.168.56.101 -u msfadmin -P wordlists/senhas-lab.txt -M ftp -t 1 -T 1 -f -O logs/ftp.log
```

- `-h`: alvo único; `-u`: conta.
- `-P`: arquivo de senhas; `-M`: módulo.
- `-t 1`: um login concorrente; `-T 1`: um host.
- `-f`: encerra o host no primeiro sucesso; `-O`: log.

São até três candidatos para uma conta, antes de considerar eventuais retransmissões da ferramenta. A concorrência reduzida não define um intervalo fixo entre tentativas. O parâmetro `-r` controla espera entre retentativas de conexão, não uma política de frequência de autenticação.

## Validação manual
Um resultado positivo deve ser verificado no mesmo serviço e na mesma conta:
```bash
ftp 192.168.56.101
```
Informe no prompt apenas a credencial didática identificada no laboratório. Após autenticar, use `pwd` e `quit`. Não é necessário baixar arquivos ou modificar o alvo.

Um retorno de sucesso do Medusa é um indício; registre o resultado da validação manual e separe erro de conexão de falha de autenticação. Não há credencial descoberta ou acesso validado nesta entrega.

## Prevenção
Remover credenciais padrão, reduzir exposição, desativar o serviço quando dispensável e limitar tentativas. FTP sem proteção de transporte pode expor credenciais; usar transporte seguro resolve esse problema, mas não elimina adivinhação de senhas. SFTP utiliza SSH e não é auditado com o módulo FTP.

Referência de sintaxe: [Kali — Medusa](https://www.kali.org/tools/medusa/).
