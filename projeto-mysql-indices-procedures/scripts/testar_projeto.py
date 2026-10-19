"""Teste de integracao em MySQL vazio: consultas, indices e CRUD condicional."""
import argparse
from pathlib import Path
import subprocess

p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--mysql',default='mysql')
p.add_argument('--config',default='mysql-local.ini')
a=p.parse_args()
root=Path(__file__).resolve().parents[1]
cmd=[a.mysql,'--defaults-extra-file='+str(Path(a.config).resolve()),'--batch','--skip-column-names','--default-character-set=utf8mb4']

def run(sql,error=None):
 r=subprocess.run(cmd,input=sql,encoding='utf-8',capture_output=True)
 if error is None:
  if r.returncode: raise RuntimeError(r.stderr)
 else:
  assert r.returncode and ('ERROR '+str(error)+' ') in r.stderr,r.stderr
 return r.stdout.strip()

def eq(sql,expected):
 result=run(sql)
 assert result==expected,repr((sql,result,expected))

def file(name): return (root/'sql'/name).read_text()
def save(name,text): (root/'evidencias'/name).write_text(text+'\n')
def state():
 return run('SELECT * FROM universidade_crud.alunos ORDER BY id; SELECT * FROM ecommerce_crud.produtos ORDER BY id;')

eq("SELECT COUNT(*) FROM information_schema.SCHEMATA WHERE SCHEMA_NAME IN ('company_indices','universidade_crud','ecommerce_crud')",'0')
run(file('01_company.sql'))
before=run(file('02_consultas.sql'))
save('consultas.txt',before)
save('explain_antes.txt',run(file('04_explain.sql')))
run(file('03_indices.sql'))
after=run(file('02_consultas.sql'))
assert before==after,'Indices nao devem alterar resultados'
save('explain_depois.txt',run(file('04_explain.sql')))
indexes=run("SELECT TABLE_NAME,INDEX_NAME,SEQ_IN_INDEX,COLUMN_NAME,INDEX_TYPE FROM information_schema.STATISTICS WHERE TABLE_SCHEMA='company_indices' ORDER BY TABLE_NAME,INDEX_NAME,SEQ_IN_INDEX")
save('indices.txt',indexes)
assert 'idx_empregados_departamento_nome' in indexes
assert 'idx_localidades_cidade_departamento' in indexes
assert '\tidx_empregados_departamento\t' not in indexes
assert 'HASH' not in indexes
print('PASS: consultas identicas antes e depois dos indices')
print('PASS: dois indices BTREE criados e indice simples redundante removido')
eq('''WITH contagens AS (SELECT d.id,COUNT(e.id) n FROM company_indices.departamentos d LEFT JOIN company_indices.empregados e ON e.departamento_id=d.id GROUP BY d.id)
SELECT id,n FROM contagens WHERE n=(SELECT MAX(n) FROM contagens) ORDER BY id''','1\t3\n2\t3')
eq("SELECT d.id FROM company_indices.localidades_departamento l JOIN company_indices.departamentos d ON d.id=l.departamento_id WHERE l.cidade='Belo Horizonte' ORDER BY d.id",'1\n3')
eq('SELECT COUNT(*) FROM company_indices.departamentos d LEFT JOIN company_indices.empregados e ON e.departamento_id=d.id','8')
eq('SELECT COUNT(e.id) FROM company_indices.departamentos d LEFT JOIN company_indices.empregados e ON e.departamento_id=d.id WHERE d.id=4','0')
print('PASS: empates no maior departamento, filtro por cidade e departamento vazio')
run(file('05_universidade.sql'))
run(file('06_ecommerce.sql'))
# O arquivo de chamadas exercita SELECT/INSERT/UPDATE/DELETE e limpa os novos registros.
save('chamadas_crud.txt',run(file('07_chamadas.sql')))
eq('SELECT COUNT(*) FROM universidade_crud.alunos','1')
eq('SELECT COUNT(*) FROM ecommerce_crud.produtos','1')
print('PASS: chamadas dos quatro controles nos dois bancos')
# Ler, inserir e atualizar sem depender de uma sequencia de AUTO_INCREMENT.
run("CALL universidade_crud.sp_manipular_aluno(2,NULL,'Teste Aluno','teste@example.com')")
uid=run("SELECT id FROM universidade_crud.alunos WHERE email='teste@example.com'")
run(f"CALL universidade_crud.sp_manipular_aluno(3,{uid},'Teste Atualizado','teste2@example.com')")
eq(f"CALL universidade_crud.sp_manipular_aluno(1,{uid},NULL,NULL)",uid+'\tTeste Atualizado\tteste2@example.com')
# Atualizacao identica deve ser valida, pois a existencia e verificada com bloqueio.
run(f"CALL universidade_crud.sp_manipular_aluno(3,{uid},'Teste Atualizado','teste2@example.com')")
run("CALL ecommerce_crud.sp_manipular_produto(2,NULL,'Produto Teste',10,0)")
pid=run("SELECT id FROM ecommerce_crud.produtos WHERE nome='Produto Teste'")
run(f"CALL ecommerce_crud.sp_manipular_produto(3,{pid},'Produto Atualizado',12.50,5)")
eq(f"CALL ecommerce_crud.sp_manipular_produto(1,{pid},NULL,NULL,NULL)",pid+'\tProduto Atualizado\t12.50\t5')
run(f"CALL ecommerce_crud.sp_manipular_produto(3,{pid},'Produto Atualizado',12.50,5)")
print('PASS: valores persistidos, SELECT por ID, estoque zero e UPDATE identico')
invalid=[
 ('acao invalida aluno','CALL universidade_crud.sp_manipular_aluno(9,NULL,NULL,NULL)',1644),
 ('acao nula aluno','CALL universidade_crud.sp_manipular_aluno(NULL,NULL,NULL,NULL)',1644),
 ('acao invalida produto','CALL ecommerce_crud.sp_manipular_produto(9,NULL,NULL,NULL,NULL)',1644),
 ('acao nula produto','CALL ecommerce_crud.sp_manipular_produto(NULL,NULL,NULL,NULL,NULL)',1644),
 ('aluno sem nome',"CALL universidade_crud.sp_manipular_aluno(2,NULL,' ','x@example.com')",1644),
 ('aluno sem email',"CALL universidade_crud.sp_manipular_aluno(2,NULL,'Teste',NULL)",1644),
 ('email duplicado INSERT',"CALL universidade_crud.sp_manipular_aluno(2,NULL,'Duplicado','aluno@example.com')",1062),
 ('email duplicado UPDATE',f"CALL universidade_crud.sp_manipular_aluno(3,{uid},'Duplicado','aluno@example.com')",1062),
 ('aluno inexistente UPDATE',"CALL universidade_crud.sp_manipular_aluno(3,999,'Teste','x@example.com')",1644),
 ('aluno inexistente DELETE','CALL universidade_crud.sp_manipular_aluno(4,999,NULL,NULL)',1644),
 ('produto inexistente UPDATE',"CALL ecommerce_crud.sp_manipular_produto(3,999,'Teste',10,1)",1644),
 ('produto inexistente DELETE','CALL ecommerce_crud.sp_manipular_produto(4,999,NULL,NULL,NULL)',1644),
]
for price,stock in [('0','1'),('-1','1'),('NULL','1'),('10','-1'),('10','NULL')]:
 invalid.append(('produto invalido INSERT '+price+'/'+stock,f"CALL ecommerce_crud.sp_manipular_produto(2,NULL,'Invalido',{price},{stock})",1644))
 invalid.append(('produto invalido UPDATE '+price+'/'+stock,f"CALL ecommerce_crud.sp_manipular_produto(3,{pid},'Invalido',{price},{stock})",1644))
for label,sql,error in invalid:
 before=state();run(sql,error=error);assert state()==before,label
 print('PASS: erro esperado e dados preservados -',label)
run(f'CALL universidade_crud.sp_manipular_aluno(4,{uid},NULL,NULL)')
run(f'CALL ecommerce_crud.sp_manipular_produto(4,{pid},NULL,NULL,NULL)')
eq(f'CALL universidade_crud.sp_manipular_aluno(1,{uid},NULL,NULL)','')
eq(f'CALL ecommerce_crud.sp_manipular_produto(1,{pid},NULL,NULL,NULL)','')
print('PASS: DELETE efetivo e SELECT de ID inexistente retorna vazio')
print('TODOS OS TESTES PASSARAM - MySQL '+run('SELECT VERSION()'))
