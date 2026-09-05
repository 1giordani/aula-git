# Comandos essenciais do Git

| Comando | Finalidade |
|---|---|
| `git init` | Inicia um repositório Git na pasta atual. |
| `git clone URL` | Baixa uma cópia de um repositório remoto. |
| `git status` | Mostra arquivos modificados e preparados. |
| `git add arquivo` | Prepara um arquivo para o próximo commit. |
| `git add .` | Prepara todas as alterações da pasta atual. |
| `git commit -m "mensagem"` | Registra as alterações no histórico. |
| `git branch` | Lista as branches locais. |
| `git switch -c nova-branch` | Cria uma branch e muda para ela. |
| `git merge nome-da-branch` | Mescla a branch indicada na branch atual. |
| `git pull` | Busca e integra alterações do repositório remoto. |
| `git push` | Envia commits locais ao repositório remoto. |
| `git log --oneline` | Exibe o histórico resumido de commits. |

## Exemplo de rotina

```bash
git status
git add .
git commit -m "docs: atualiza material da aula"
git push
```

Antes de executar um comando que altera o histórico, confira a branch atual com `git status`.
