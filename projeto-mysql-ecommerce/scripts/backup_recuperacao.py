"""Backup logico com mysqldump e recovery com mysql; somente biblioteca padrao."""
import argparse
from pathlib import Path
import subprocess

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('acao', choices=['backup', 'restaurar'])
parser.add_argument('--config', default='mysql-local.ini')
parser.add_argument('--mysql', default='mysql')
parser.add_argument('--mysqldump', default='mysqldump')
parser.add_argument('--arquivo', default='backups/ecommerce.sql')
parser.add_argument('--multiplos', action='store_true')
parser.add_argument('--confirmar-restauracao', action='store_true')
a = parser.parse_args()
config = Path(a.config).resolve()
if not config.is_file():
    parser.error('Crie mysql-local.ini a partir do exemplo; nao publique sua senha.')
file = Path(a.arquivo).resolve()
if a.acao == 'backup':
    file.parent.mkdir(parents=True, exist_ok=True)
    temp = file.with_suffix(file.suffix + '.tmp')
    cmd = [a.mysqldump, '--defaults-extra-file=' + str(config),
           '--single-transaction', '--routines', '--events', '--triggers',
           '--no-tablespaces', '--set-gtid-purged=OFF',
           '--default-character-set=utf8mb4', '--databases', 'ecommerce']
    if a.multiplos:
        cmd.append('logistica')
    try:
        with temp.open('wb') as out:
            subprocess.run(cmd, stdout=out, check=True)
        temp.replace(file)
    except (OSError, subprocess.CalledProcessError):
        temp.unlink(missing_ok=True)
        raise
    print('Backup criado:', file)
else:
    if not a.confirmar_restauracao:
        parser.error('Recovery substitui tabelas nos bancos nomeados no dump. Use servidor de testes e --confirmar-restauracao.')
    with file.open('rb') as source:
        subprocess.run([a.mysql, '--defaults-extra-file=' + str(config),
                        '--default-character-set=utf8mb4'], stdin=source, check=True)
    print('Recovery concluido:', file)
