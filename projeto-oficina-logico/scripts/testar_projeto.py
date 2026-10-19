"""Testa criacao, dados, consultas e regras em servidor MySQL de laboratorio vazio."""
import argparse
from pathlib import Path
import re
import subprocess

p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--mysql',default='mysql')
p.add_argument('--config',default='mysql-local.ini')
a=p.parse_args()
root=Path(__file__).resolve().parents[1]
base=[a.mysql,'--defaults-extra-file='+str(Path(a.config).resolve()),'--batch','--default-character-set=utf8mb4']

def run(sql,error=None,headers=False):
 cmd=base if headers else base+['--skip-column-names']
 r=subprocess.run(cmd,input=sql,encoding='utf-8',capture_output=True)
 if error is None:
  if r.returncode: raise RuntimeError(r.stderr)
 else:
  assert r.returncode and ('ERROR '+str(error)+' ') in r.stderr,r.stderr
 return r.stdout.strip()

def q(sql,error=None):return run('USE oficina_logica;\n'+sql,error=error)
def eq(sql,wanted):
 got=q(sql)
 assert got==wanted,repr((sql,got,wanted))
def read(name):return (root/'sql'/name).read_text()
def save(name,value):(root/'evidencias'/name).write_text(value+'\n')
tables=['cliente','veiculo','equipe','mecanico','composicao_equipe','ordem_servico','servico','peca','servico_os','peca_os','autorizacao']
def snapshot():
 return q('\n'.join('SELECT * FROM '+table+' ORDER BY '+{'composicao_equipe':'id_equipe,codigo_mecanico,data_inicio','servico_os':'numero_os,id_servico','peca_os':'numero_os,id_peca'}.get(table,'1')+';' for table in tables))

assert run("SELECT COUNT(*) FROM information_schema.SCHEMATA WHERE SCHEMA_NAME='oficina_logica'")=='0','Use servidor sem oficina_logica'
for f in ['01_estrutura.sql','02_regras.sql','03_dados.sql']:
 run(read(f));print('PASS: executado',f)
eq('SELECT COUNT(*) FROM ordem_servico','6')
eq('SELECT numero_os,valor_total FROM vw_total_os ORDER BY numero_os','1001\t280.00\n1002\t500.00\n1003\t450.00\n1004\t0.00\n1005\t120.00\n1006\t750.00')
eq("SELECT SUM(valor_total) FROM vw_total_os WHERE status='CONCLUIDA'",'1030.00')
print('PASS: seis totais calculados, OS sem itens e valor de OSs concluidas')
expected_rows=[5,1,6,6,2,3,6,1,2,3,2,1,5,1]
results={};reports=[]
for match in re.finditer(r'^-- Q(\d+): ([^\n]+)\n(.*?)(?=^-- Q\d+:|\Z)',read('04_consultas.sql'),re.M|re.S):
 number,title,sql=match.groups();prefix="USE oficina_logica; SET @data_referencia='2026-10-19';\n"
 output=run(prefix+sql);results[int(number)]=output
 assert len(output.splitlines())==expected_rows[int(number)-1],(number,output)
 reports.append('Q'+number+' - '+title+'\n'+run(prefix+sql,headers=True))
 assert int(number)==len(results)
 print('PASS: Q'+number+' - '+str(len(output.splitlines()))+' linha(s) conferida(s)')
assert len(results)==14
assert results[2]=='1002\tEM_EXECUCAO\t2026-10-15\t4'
assert results[8]=='5\tCliente Eva'
assert results[12]=='1006\t2026-10-10\t2026-10-11\t1'
assert results[14]=='2\tDiagnostico por hora\t4.00\t600.00'
assert results[13].splitlines()[0]=='4\tCliente Diego\t750.00\t1'
save('consultas_resultados.txt','\n\n'.join(reports))
before=snapshot();flow=run(read('05_fluxo_exemplo.sql'));assert snapshot()==before
assert '290.00' in flow and 'CONCLUIDA' in flow and flow.splitlines()[-1]=='0'
save('fluxo_rollback.txt',flow)
print('PASS: fluxo completo ate conclusao e rollback sem alterar a massa')
# Dois servicos e duas pecas: verifica independencia das agregacoes.
antidouble=q("""START TRANSACTION;
INSERT INTO ordem_servico(numero_os,id_cliente_solicitante,id_veiculo,id_equipe,data_emissao,data_prevista_conclusao,tipo_atendimento)
VALUES(2002,1,1,1,'2026-10-19','2026-10-20','REPARO');
INSERT INTO servico_os(numero_os,id_servico,quantidade) VALUES(2002,1,1),(2002,2,2);
INSERT INTO peca_os(numero_os,id_peca,quantidade) VALUES(2002,1,2),(2002,3,4);
SELECT total_servicos,total_pecas,valor_total FROM vw_total_os WHERE numero_os=2002;
ROLLBACK;""")
assert antidouble=='430.00\t360.00\t790.00';assert snapshot()==before
print('PASS: total 790.00 com dois servicos e duas pecas, sem produto cartesiano')
q('START TRANSACTION; UPDATE veiculo SET id_cliente_atual=5 WHERE id_veiculo=1; SELECT 1; ROLLBACK;')
eq('SELECT id_cliente_solicitante FROM ordem_servico WHERE numero_os=1001','1')
print('PASS: solicitante historico preservado na alteracao de proprietario')
neg=[
('placa duplicada',"INSERT INTO veiculo VALUES(99,1,'AAA1A01','Teste','Teste',2020)",1062),
('cliente inexistente',"INSERT INTO veiculo VALUES(99,999,'ZZZ9Z99','Teste','Teste',2020)",1452),
('solicitante incorreto',"INSERT INTO ordem_servico(numero_os,id_cliente_solicitante,id_veiculo,id_equipe,data_emissao,data_prevista_conclusao,tipo_atendimento) VALUES(9999,2,1,1,'2026-10-19','2026-10-20','REPARO')",1644),
('equipe sem integrante',"INSERT INTO ordem_servico(numero_os,id_cliente_solicitante,id_veiculo,id_equipe,data_emissao,data_prevista_conclusao,tipo_atendimento) VALUES(9999,1,1,3,'2026-10-19','2026-10-20','REPARO')",1644),
('previsao anterior a emissao',"INSERT INTO ordem_servico(numero_os,id_cliente_solicitante,id_veiculo,id_equipe,data_emissao,data_prevista_conclusao,tipo_atendimento) VALUES(9999,1,1,1,'2026-10-19','2026-10-18','REPARO')",3819),
('troca de equipe','UPDATE ordem_servico SET id_equipe=2 WHERE numero_os=1003',1644),
('sem autorizacao',"UPDATE ordem_servico SET status='AUTORIZADA' WHERE numero_os=1003",1644),
('pular estado',"UPDATE ordem_servico SET status='EM_EXECUCAO' WHERE numero_os=1004",1644),
('orcamento sem servico',"UPDATE ordem_servico SET status='AGUARDANDO_AUTORIZACAO' WHERE numero_os=1004",1644),
('item congelado INSERT','INSERT INTO servico_os(numero_os,id_servico,quantidade) VALUES(1003,1,1)',1644),
('item congelado UPDATE','UPDATE servico_os SET quantidade=2 WHERE numero_os=1003',1644),
('item congelado DELETE','DELETE FROM peca_os WHERE numero_os=1003',1644),
('autorizacao outro cliente',"INSERT INTO autorizacao VALUES(99,1003,2,'AUTORIZADA','2026-10-11 10:00:00',450)",1452),
('valor divergente',"INSERT INTO autorizacao VALUES(99,1003,1,'AUTORIZADA','2026-10-11 10:00:00',1)",1644),
('decisao antes da emissao',"INSERT INTO autorizacao VALUES(99,1003,1,'AUTORIZADA','2026-10-09 10:00:00',450)",1644),
('decisao fora do estado',"INSERT INTO autorizacao VALUES(99,1004,3,'AUTORIZADA','2026-10-19 10:00:00',0)",1644),
('alterar decisao',"UPDATE autorizacao SET decisao='RECUSADA' WHERE numero_os=1001",1644),
('excluir decisao','DELETE FROM autorizacao WHERE numero_os=1001',1644),
('reabrir cancelada',"UPDATE ordem_servico SET status='EM_AVALIACAO' WHERE numero_os=1005",1644),
('conclusao sem data',"UPDATE ordem_servico SET status='CONCLUIDA' WHERE numero_os=1002",3819),
('alterar composicao','UPDATE composicao_equipe SET data_fim=\'2026-12-31\' WHERE id_equipe=1 AND codigo_mecanico=1',1644),
('excluir composicao','DELETE FROM composicao_equipe WHERE id_equipe=1 AND codigo_mecanico=1',1644),
('incluir composicao',"INSERT INTO composicao_equipe VALUES(1,5,'2026-10-19',NULL)",1644),
('servico quantidade zero','INSERT INTO servico_os(numero_os,id_servico,quantidade) VALUES(1004,1,0)',3819),
('servico fixo fracionado','INSERT INTO servico_os(numero_os,id_servico,quantidade) VALUES(1004,1,0.5)',3819),
('peca quantidade zero','INSERT INTO peca_os(numero_os,id_peca,quantidade) VALUES(1004,1,0)',3819),
('referencia inexistente','INSERT INTO servico_os(numero_os,id_servico,quantidade) VALUES(1004,999,1)',1644),
]
for label,sql,code in neg:
 before=snapshot();q(sql,error=code);assert snapshot()==before,label
 print('PASS: rejeitado sem alterar dados -',label)
q("INSERT INTO composicao_equipe VALUES(3,5,'2026-01-01','2026-06-30')")
q("INSERT INTO composicao_equipe VALUES(3,5,'2026-05-01','2026-08-01')",error=1644)
q('DELETE FROM composicao_equipe WHERE id_equipe=3')
print('PASS: sobreposicao de participacao rejeitada; massa restaurada')
save('inventario.txt',run("SELECT TABLE_NAME,TABLE_TYPE FROM information_schema.TABLES WHERE TABLE_SCHEMA='oficina_logica' ORDER BY TABLE_NAME; SELECT TRIGGER_NAME FROM information_schema.TRIGGERS WHERE TRIGGER_SCHEMA='oficina_logica' ORDER BY TRIGGER_NAME;",headers=True))
print('TODOS OS TESTES PASSARAM - MySQL '+run('SELECT VERSION()'))
