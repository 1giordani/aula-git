# 05 — Prevenção, detecção e reflexão

## Conceitos
| Estratégia | Característica | Exemplo didático |
|---|---|---|
| Força bruta exaustiva | Explora combinações de um espaço definido | Todas as combinações de um PIN curto |
| Dicionário | Usa candidatos de uma lista | Três senhas para uma conta FTP |
| Password spraying | Aplica uma senha a várias contas por rodada | Uma senha para três contas SMB |
| Credential stuffing | Reutiliza pares usuário/senha obtidos de outra origem | Conceito estudado, não implementado |

O material usa wordlists pequenas; não demonstra busca exaustiva de senhas longas.

## Medidas recomendadas
| Controle | Finalidade | Limite |
|---|---|---|
| Senhas fortes, únicas e remoção de padrões | Reduzir candidatos previsíveis e reutilização | Não substitui proteção do fluxo |
| MFA onde o fluxo suporta | Reduzir risco de comprometimento por senha | Não é uma opção nativa universal para FTP/SMB |
| Limitação por conta e monitoramento de origem | Conter automação e correlacionar abuso | Limitar apenas por IP é insuficiente |
| Atraso progressivo e bloqueio temporário | Reduzir repetição | Bloqueio rígido pode causar negação de serviço |
| Mensagens de erro uniformes | Reduzir enumeração | Não resolve adivinhação sozinho |
| Restrição de acesso e remoção de serviços legados | Reduzir superfície | Requer inventário e manutenção |
| Transporte seguro | Proteger credenciais em trânsito | TLS não impede tentativa de senhas |
| Registros e alertas | Identificar padrões e investigar | Não registrar segredos em logs públicos |

Use políticas compatíveis com cada serviço; não copie configurações genéricas sem validar seu efeito.

## Comparação mensurável proposta
Registrar antes e depois: número de tentativas, falhas, sucessos validados, bloqueios, período e condições da política. Repetir o mesmo conjunto de teste após a mitigação. Um erro de protocolo não conta como uma defesa de senha comprovada.

A simulação offline incluída ilustra um caso em que duas falhas anteriores bloqueiam uma credencial correta que aparece depois. Isso demonstra o compromisso entre reduzir tentativas e manter disponibilidade. Não é medição de FTP, Samba ou DVWA.

## Reflexão de estudo
- A ordem das tentativas muda o padrão observado; quantidade total não conta toda a história.
- Um sucesso indicado por ferramenta precisa de validação no serviço.
- HTTP 200 pode representar uma página de login ou de erro.
- Sessões, tokens, protocolo e política de bloqueio fazem parte do contexto do teste.
- Evidência útil identifica ambiente, comando, tempo e resultado; uma saída esperada não é evidência real.

Referência de prevenção: [OWASP — Authentication Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html).
