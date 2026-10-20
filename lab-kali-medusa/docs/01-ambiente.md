# 01 — Ambiente e escopo

Este é um roteiro de reprodução. As VMs não foram criadas ou executadas nesta entrega.

## Topologia proposta
| Componente | Endereço de exemplo | Função |
|---|---|---|
| Host VirtualBox | 192.168.56.1 | Hospedeiro da rede host-only |
| Kali Linux | 192.168.56.10/24 | Estação de auditoria |
| Metasploitable 2 / DVWA | 192.168.56.101/24 | Único alvo do exercício |

Os endereços são exemplos de configuração, não máquinas descobertas. Confirme a identidade da VM no console antes de qualquer teste.

**Host-only não é o mesmo modo que rede interna.** Host-only permite comunicação entre host e VMs. Rede interna permite comunicação entre VMs da mesma rede virtual, sem incluir o host. Não use bridge para estas máquinas vulneráveis. Verifique que o host não encaminha tráfego dessa rede para outras redes.

## Preparação
1. Obtenha Kali e Metasploitable pelas fontes oficiais.
2. Crie as duas VMs no VirtualBox e faça snapshots antes dos testes.
3. Configure ambas no mesmo adaptador host-only; alternativamente, ambas na mesma rede interna.
4. Desative adaptadores extras no alvo. Para instalar ferramentas no Kali, use a conectividade de atualização separadamente e remova-a antes do exercício.
5. Use IPs sem conflito com o DHCP e sem gateway externo nesse segmento.
6. No console de cada VM, confira o endereço. No alvo antigo, pode ser necessário usar ifconfig em vez de ip.

No Kali, durante a preparação:
```bash
sudo apt update
sudo apt install medusa nmap smbclient python3
```

Depois de isolar as VMs:
```bash
ip -br addr
ip route
ping -c 2 192.168.56.101
mkdir -p logs
medusa -V
medusa -d
medusa -M ftp -q
medusa -M smbnt -q
nmap --version
smbclient --version
```

O nome dos módulos e sua compatibilidade devem ser conferidos na instalação utilizada. Não trate ausência de módulo ou erro de protocolo como senha incorreta.

## Inventário restrito
```bash
nmap -sT -sV --version-light -Pn -n -p 21,80,139,445 -oN logs/servicos.txt 192.168.56.101
```
O comando inspeciona quatro portas de um único IP. Não execute varredura de sub-redes nem use alvos que não sejam a VM do laboratório.

Preencha no relatório: versões, portas realmente abertas, data, endereço da VM e configuração da rede. Os serviços não estão confirmados nesta entrega.

## Referências
- [VirtualBox — rede virtual](https://docs.oracle.com/en/virtualization/virtualbox/7.2/user/networkingdetails.html).
- [Kali — Medusa](https://www.kali.org/tools/medusa/).
- [Rapid7 — Metasploitable 2](https://docs.rapid7.com/metasploit/metasploitable-2/).
- [Nmap — técnicas de scan](https://nmap.org/book/man-port-scanning-techniques.html).
