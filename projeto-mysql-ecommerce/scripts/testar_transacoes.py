"""Teste de integracao em servidor de laboratorio SEM ecommerce/logistica existentes."""
import argparse
from pathlib import Path
import subprocess

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--mysql', default='mysql')
p.add_argument('--config', default='mysql-local.ini')
a = p.parse_args()
root = Path(__file__).resolve().parents[1]
cmd = [a.mysql, '--defaults-extra-file=' + str(Path(a.config).resolve()), '--batch', '--skip-column-names', '--default-character-set=utf8mb4']

def run(sql, ok=True):
    r = subprocess.run(cmd, input=sql, encoding='utf-8', capture_output=True)
    if ok and r.returncode:
        raise RuntimeError(r.stderr)
    if not ok:
        assert r.returncode != 0, 'Era esperado um erro SQL'
        assert 'ERROR' in r.stderr
    return r.stdout.strip()

def snapshot():
    return run('''SELECT estoque FROM ecommerce.produtos ORDER BY id;
    SELECT COUNT(*),COALESCE(SUM(total),0) FROM ecommerce.pedidos;
    SELECT COUNT(*),COALESCE(SUM(quantidade),0) FROM ecommerce.itens_pedido;
    SELECT COUNT(*) FROM ecommerce.auditoria_estoque;''')

assert run("SELECT COUNT(*) FROM information_schema.SCHEMATA WHERE SCHEMA_NAME IN ('ecommerce','logistica')") == '0', 'Use servidor vazio: os bancos ja existem.'
for filename in ['01_estrutura_dados.sql','02_transacoes.sql','03_procedure_recursos.sql']:
    run((root/'sql'/filename).read_text(encoding='utf-8'))
    print('PASS:', filename)
assert run('SELECT estoque FROM ecommerce.produtos WHERE id=1') == '27'
run('CALL ecommerce.sp_registrar_pedido(1,1,2,FALSE)')
assert run('SELECT estoque FROM ecommerce.produtos WHERE id=1') == '25'
assert run('SELECT COUNT(*),SUM(total) FROM ecommerce.pedidos') == '1\t300.00'
print('PASS: pedido confirmado, estoque 25 e total 300.00')
for label, args in [
    ('falha simulada apos inserts','1,1,3,TRUE'),
    ('estoque insuficiente','1,1,999,FALSE'),
    ('cliente inexistente apos UPDATE','999,1,1,FALSE'),
    ('quantidade zero','1,1,0,FALSE'),
    ('quantidade nula','1,1,NULL,FALSE'),
    ('produto inexistente','1,999,1,FALSE'),
]:
    before = snapshot()
    run('CALL ecommerce.sp_registrar_pedido(' + args + ')', ok=False)
    assert snapshot() == before, label
    print('PASS: rollback preserva estoque, pedidos, itens e auditoria -', label)
assert run("SELECT COUNT(*) FROM information_schema.ROUTINES WHERE ROUTINE_SCHEMA='ecommerce'") == '1'
assert run("SELECT COUNT(*) FROM information_schema.TRIGGERS WHERE TRIGGER_SCHEMA='ecommerce'") == '1'
assert run("SELECT STATUS FROM information_schema.EVENTS WHERE EVENT_SCHEMA='ecommerce'") == 'DISABLED'
print('PASS: procedure, trigger e evento desabilitado presentes')
print('TODOS OS TESTES PASSARAM')
