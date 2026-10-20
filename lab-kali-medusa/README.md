# Laboratório de estudo — Kali Linux e Medusa

Projeto de **Giordani Martins Silva** para o desafio da DIO sobre força bruta e medidas de prevenção.

## Modalidade e transparência
Esta entrega utiliza a **modalidade documental** expressamente permitida pelo desafio: estudos, roteiros, exemplos e simulação offline.

**Não foram instaladas VMs, executados ataques com Medusa ou obtidos acessos em FTP, SMB ou DVWA.** Não há capturas ou credenciais descobertas. Foram executados apenas os testes Python, a simulação offline e o planejamento dry-run do roteiro DVWA, sem requisições de rede.

As videoaulas não foram acessadas nesta implementação; sua conclusão fica registrada na plataforma DIO.

## Objetivos
Compreender dicionário e password spraying, planejar um laboratório isolado, diferenciar falha de autenticação de erro técnico e relacionar resultados a medidas de prevenção.

## Material entregue
| Arquivo | Conteúdo |
|---|---|
| [Ambiente](docs/01-ambiente.md) | VMs, rede, escopo e inventário restrito |
| [FTP](docs/02-ftp.md) | Medusa com wordlist e validação proposta |
| [SMB](docs/03-smb.md) | Enumeração limitada e uma rodada de spraying |
| [DVWA](docs/04-dvwa.md) | Sessão, nível Low, classificação e automação limitada |
| [Prevenção](docs/05-prevencao.md) | Controles, detecção e reflexão técnica |
| [Registro de execução](docs/registro-execucao.md) | Modelo não preenchido para evidências futuras |
| scripts/ | Simulador sem rede e roteiro DVWA com dry-run padrão |
| wordlists/ | Listas pequenas de exemplos didáticos |
| results/ | Saídas reais da simulação local, claramente identificadas |
| images/ | Instruções para capturas opcionais futuras |

## Escopo dos exemplos
Os comandos estão restritos ao endereço de exemplo **192.168.56.101**, reservado no roteiro para a VM vulnerável própria. Confirme o endereço no console da VM antes de reproduzir. As wordlists são artificiais; os usuários não foram enumerados nesta entrega.

Rede host-only e rede interna são modos diferentes. A primeira inclui o hospedeiro; a segunda conecta apenas as VMs. A documentação explica essa distinção e a ausência de conexão do alvo com redes externas.

## Executar a parte offline
Requer Python 3.9 ou superior, sem dependências adicionais. Na pasta do projeto:
```bash
python3 scripts/simulador_offline.py --mode dictionary
python3 scripts/simulador_offline.py --mode spray
python3 scripts/simulador_offline.py --mode dictionary --max-failures 2
python3 scripts/dvwa_lab.py
python3 -m unittest discover -s tests -v
```

O simulador compara credenciais fictícias em memória. Nenhum socket é aberto. O roteiro DVWA, sem --executar, apenas informa o planejamento.

## O que foi observado na simulação
- No cenário sem bloqueio, as duas contas fictícias são autenticadas em cinco tentativas.
- A ordem das contas/candidatos difere entre dicionário e spraying.
- Com limite de duas falhas, ana autentica; bruno fica bloqueado antes de alcançar o candidato correto. Há quatro tentativas efetivas e um evento de bloqueio sem autenticação.
- Esses resultados pertencem ao código simulado, não a servidores vulneráveis.

O conjunto foi validado por dez testes automatizados, incluindo respostas HTTP falsas, limitação de candidatos, parada em resposta inconclusiva e ausência de senhas/cookies no JSON de saída.

## Reprodução em VMs
Os documentos contêm comandos de referência para uso somente no laboratório próprio. A execução depende de ferramentas, serviços, módulos e versões compatíveis, e ainda não foi validada nessas VMs. Não são fornecidos scanners de sub-redes, listas de credenciais reais ou ciclos extensos de tentativas.

O roteiro DVWA faz requisições somente quando --executar é informado, exige cookie de sessão própria em Low, usa um alvo fixo e no máximo cinco candidatos. Essa função foi testada com transporte simulado, não com o DVWA real.

## Documentação de evidências
Uma evidência real deve indicar data, versão, alvo, comando e observação. Saídas esperadas não devem substituir evidências. Os arquivos results/ identificam expressamente a simulação. O modelo de execução permanece sem preenchimento.

Logs reais e capturas ficam ignorados por padrão; revise senhas, cookies e informações de terceiros antes de decidir publicá-los. Resultados positivos precisam de validação no serviço; erro de protocolo não comprova resistência à adivinhação.

## Decisões técnicas
- Biblioteca padrão Python para reduzir dependências.
- Separação entre estudo documental, simulação e operação opcional.
- Dry-run como comportamento inicial do exemplo web.
- Reconhecimento de marcadores do DVWA Low em vez de tratar HTTP 200 como sucesso.
- Nenhuma automação para contornar tokens, bloqueios ou ampliar o escopo.
- Roteiros e reflexões elaborados com apoio de IA a partir de fontes primárias.

## Referências
- [Kali — Medusa e opções](https://www.kali.org/tools/medusa/).
- [VirtualBox — rede virtual](https://docs.oracle.com/en/virtualization/virtualbox/7.2/user/networkingdetails.html).
- [Rapid7 — Metasploitable 2](https://docs.rapid7.com/metasploit/metasploitable-2/).
- [DVWA — repositório oficial](https://github.com/digininja/DVWA).
- [DVWA Low](https://github.com/digininja/DVWA/blob/master/vulnerabilities/brute/source/low.php) e [High](https://github.com/digininja/DVWA/blob/master/vulnerabilities/brute/source/high.php).
- [Nmap — técnicas de scan](https://nmap.org/book/man-port-scanning-techniques.html).
- [Samba — rpcclient](https://www.samba.org/samba/docs/current/man-html/rpcclient.1.html).
- [OWASP — autenticação](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html).

O site histórico do Medusa indicado no desafio não pôde ser recuperado na consulta; a sintaxe foi conferida na página do pacote no Kali. Este é material de estudo e não um relatório de pentest executado.
