"""Testa views, acessos reais e triggers num MySQL de laboratorio vazio."""
import argparse
import json
from pathlib import Path
import secrets
import subprocess
import tempfile

p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--mysql', default='mysql')
p.add_argument('--config', default='mysql-local.ini')
p.add_argument('--host', default='127.0.0.1')
p.add_argument('--port', type=int, default=3306)
a=p.parse_args()
root=Path(__file__).resolve().parents[1]
admin=[a.mysql,'--defaults-extra-file='+str(Path(a.config).resolve()),'--batch','--skip-column-names','--default-character-set=utf8mb4']

def run(sql,cmd=admin,error=None):
 r=subprocess.run(cmd,input=sql,encoding='utf-8',capture_output=True)
 if error is None:
  if r.returncode: raise RuntimeError(r.stderr)
 else:
  assert r.returncode and ('ERROR '+str(error)+' ') in r.stderr, r.stderr
 return r.stdout.strip()

def eq(sql,wanted,cmd=admin):
 got=run(sql,cmd)
 assert got==wanted, repr((sql,got,wanted))

eq("SELECT COUNT(*) FROM information_schema.SCHEMATA WHERE SCHEMA_NAME IN ('empresa_views','ecommerce_gatilhos')",'0')
for f in ['01_empresa.sql','02_views.sql','04_ecommerce_triggers.sql']:
 run((root/'sql'/f).read_text())
 print('PASS: estrutura -',f)
eq('SELECT total_empregados FROM empresa_views.vw_empregados_departamento_localidade ORDER BY departamento_id,localidade','2\n1\n2\n0')
print('PASS: empregados por departamento/localidade, incluindo zero')
eq('SELECT COALESCE(gerente,\'SEM GERENTE\') FROM empresa_views.vw_departamentos_gerentes ORDER BY departamento_id','Ana\nCarla\nSEM GERENTE')
print('PASS: departamentos e gerentes, incluindo departamento sem gerente')
eq('SELECT projeto_id,total_empregados FROM empresa_views.vw_projetos_quantidade_empregados ORDER BY total_empregados DESC,projeto_id','1\t3\n2\t1\n3\t0')
print('PASS: projetos ordenados por numero de empregados, incluindo projeto vazio')
eq("SELECT projeto,departamento,COALESCE(gerente,'SEM GERENTE') FROM empresa_views.vw_projetos_departamentos_gerentes ORDER BY projeto_id",'Portal\tTecnologia\tAna\nAutomacao\tOperacoes\tCarla\nPesquisa Piloto\tPesquisa\tSEM GERENTE')
print('PASS: projetos, departamentos e gerentes')
eq('SELECT empregado_id,total_dependentes,eh_gerente FROM empresa_views.vw_empregados_dependentes_gerencia ORDER BY empregado_id','1\t2\t1\n2\t1\t0\n3\t1\t1')
print('PASS: dependentes e indicador de gerente sem duplicar empregados')
passwords=[secrets.token_urlsafe(28),secrets.token_urlsafe(28)]
permissions=(root/'sql/03_permissoes.sql').read_text().replace('SUBSTITUA_SENHA_GERENTE',passwords[0]).replace('SUBSTITUA_SENHA_EMPREGADO',passwords[1])
run(permissions)
with tempfile.TemporaryDirectory() as tmp:
 cmds=[]
 for user,password in zip(['gerente_dio','empregado_dio'],passwords):
  conf=Path(tmp)/(user+'.ini')
  conf.write_text('[client]\nuser='+user+'\npassword='+password+'\nhost='+a.host+'\nport='+str(a.port)+'\nprotocol=tcp\n')
  conf.chmod(0o600)
  cmds.append([a.mysql,'--defaults-extra-file='+str(conf),'--batch','--skip-column-names'])
 manager,employee=cmds
 for view in ['vw_empregados_departamento_localidade','vw_departamentos_gerentes','vw_projetos_quantidade_empregados','vw_projetos_departamentos_gerentes','vw_empregados_dependentes_gerencia','vw_dados_empregados','vw_empregados_publicos']:
  run('SELECT * FROM empresa_views.'+view,manager)
  if view!='vw_empregados_publicos': run('SELECT * FROM empresa_views.'+view,employee,error=1142)
 eq('SELECT COUNT(*) FROM empresa_views.vw_empregados_publicos','5',employee)
 for cmd in cmds:
  for table in ['empregados','departamentos','dependentes']:
   run('SELECT * FROM empresa_views.'+table,cmd,error=1142)
  run('UPDATE empresa_views.vw_empregados_publicos SET nome=\'Teste\' WHERE id=1',cmd,error=1142)
 print('PASS: gerente le as 7 views e empregado apenas a view publica')
 print('PASS: acessos indevidos e escrita negados nas duas contas')
 grants=run("SHOW GRANTS FOR 'gerente_dio'@'localhost'; SHOW GRANTS FOR 'empregado_dio'@'localhost';")
 (root/'evidencias/permissoes.txt').write_text(grants+'\n')

# BEFORE DELETE: arquivo transacional e preservacao dos pedidos.
run('START TRANSACTION; DELETE FROM ecommerce_gatilhos.usuarios WHERE id=1; ROLLBACK;')
eq('SELECT COUNT(*) FROM ecommerce_gatilhos.usuarios WHERE id=1','1')
eq('SELECT COUNT(*) FROM ecommerce_gatilhos.usuarios_excluidos','0')
eq('SELECT usuario_id FROM ecommerce_gatilhos.pedidos WHERE id=1','1')
print('PASS: rollback da exclusao restaura usuario e pedido e desfaz arquivo')
run('DELETE FROM ecommerce_gatilhos.usuarios WHERE id=1')
eq('SELECT COUNT(*) FROM ecommerce_gatilhos.usuarios WHERE id=1','0')
eq('SELECT usuario_id,nome,email FROM ecommerce_gatilhos.usuarios_excluidos','1\tUsuario Demonstracao\tusuario@example.com')
eq('SELECT COUNT(*) FROM ecommerce_gatilhos.pedidos WHERE id=1 AND usuario_id IS NULL','1')
print('PASS: BEFORE DELETE arquiva OLD, remove conta e preserva pedido')
# BEFORE INSERT e BEFORE UPDATE.
run("INSERT INTO ecommerce_gatilhos.colaboradores VALUES(2,'Novo Colaborador',2500)")
run('START TRANSACTION; UPDATE ecommerce_gatilhos.colaboradores SET salario_base=3100 WHERE id=1; ROLLBACK;')
eq('SELECT COUNT(*) FROM ecommerce_gatilhos.historico_salarios','0')
eq('SELECT salario_base FROM ecommerce_gatilhos.colaboradores WHERE id=1','3000.00')
run('UPDATE ecommerce_gatilhos.colaboradores SET salario_base=3300 WHERE id=1')
eq('SELECT salario_anterior,salario_novo FROM ecommerce_gatilhos.historico_salarios','3000.00\t3300.00')
run("UPDATE ecommerce_gatilhos.colaboradores SET nome='Nome Atualizado' WHERE id=1")
run('UPDATE ecommerce_gatilhos.colaboradores SET salario_base=3300 WHERE id=1')
eq('SELECT COUNT(*) FROM ecommerce_gatilhos.historico_salarios','1')
for value in ['0','-10','NULL']:
 run("INSERT INTO ecommerce_gatilhos.colaboradores VALUES(9,'Invalido',"+value+')',error=1644)
 run('UPDATE ecommerce_gatilhos.colaboradores SET salario_base='+value+' WHERE id=1',error=1644)
eq('SELECT salario_base FROM ecommerce_gatilhos.colaboradores WHERE id=1','3300.00')
eq('SELECT COUNT(*) FROM ecommerce_gatilhos.historico_salarios','1')
print('PASS: BEFORE INSERT permite salario valido e rejeita zero, negativo e NULL')
print('PASS: BEFORE UPDATE valida, audita alteracao e ignora salario inalterado')
print('PASS: rollback salarial desfaz historico; operacoes invalidas preservam estado')
views=run((root/'sql/05_consultas.sql').read_text())
(root/'evidencias/resultados_views.txt').write_text(views+'\n')
triggers=run("SELECT TRIGGER_NAME,ACTION_TIMING,EVENT_MANIPULATION FROM information_schema.TRIGGERS WHERE TRIGGER_SCHEMA='ecommerce_gatilhos' ORDER BY TRIGGER_NAME")
(root/'evidencias/triggers.txt').write_text(triggers+'\n')
print('TODOS OS TESTES PASSARAM - MySQL '+run('SELECT VERSION()'))
