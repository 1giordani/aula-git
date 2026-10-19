"""Teste real em MySQL de laboratorio sem o banco ecommerce_logico."""
import argparse
from pathlib import Path
import re
import subprocess

p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--mysql',default='mysql');p.add_argument('--config',default='mysql-local.ini')
a=p.parse_args();root=Path(__file__).resolve().parents[1]
base=[a.mysql,'--defaults-extra-file='+str(Path(a.config).resolve()),'--batch','--default-character-set=utf8mb4']
def run(sql,error=None,headers=False):
 r=subprocess.run(base+([] if headers else ['--skip-column-names']),input=sql,encoding='utf-8',capture_output=True)
 if error is None:
  if r.returncode:raise RuntimeError(r.stderr)
 else:assert r.returncode and ('ERROR '+str(error)+' ') in r.stderr,r.stderr
 return r.stdout.strip()
def q(sql,error=None):return run('USE ecommerce_logico;\n'+sql,error)
def eq(sql,expected):
 got=q(sql);assert got==expected,repr((sql,got,expected))
def read(name):return (root/'sql'/name).read_text()
def save(name,value):(root/'evidencias'/name).write_text(value+'\n')
tables=['cliente','forma_pagamento','vendedor','fornecedor','produto','oferta','fornecimento','estoque','produto_estoque','pedido','item_pedido','pagamento','entrega']
def snapshot():
 return q('\n'.join('SELECT * FROM '+t+' ORDER BY '+{'fornecimento':'id_fornecedor,id_produto','produto_estoque':'id_produto,id_estoque','item_pedido':'id_pedido,numero_item'}.get(t,'1')+';' for t in tables))
assert run("SELECT COUNT(*) FROM information_schema.SCHEMATA WHERE SCHEMA_NAME='ecommerce_logico'")=='0','Use servidor sem ecommerce_logico'
for f in ['01_estrutura.sql','02_regras.sql','03_dados.sql']:
 run(read(f));print('PASS: executado',f)
eq('SELECT COUNT(*) FROM vw_cliente_pf;SELECT COUNT(*) FROM vw_cliente_pj','3\n2')
eq('SELECT id_pedido,valor_total FROM vw_total_pedido ORDER BY id_pedido','1001\t320.00\n1002\t930.00\n1003\t290.00\n1004\t0.00\n1005\t95.00\n1006\t120.00')
eq("SELECT SUM(valor) FROM pagamento WHERE status='APROVADO'",'1410.00')
print('PASS: tres PF, duas PJ, totais de seis pedidos e pagamentos aprovados 1410.00')
expected_rows=[5,1,5,8,2,6,1,2,5,2,5,1,1,5,3,6]
results={};reports=[]
for mt in re.finditer(r'^-- Q(\d+): ([^\n]+)\n(.*?)(?=^-- Q\d+:|\Z)',read('04_consultas.sql'),re.M|re.S):
 n,title,sql=mt.groups();out=q(sql);results[int(n)]=out
 assert len(out.splitlines())==expected_rows[int(n)-1],(n,out)
 reports.append('Q'+n+' - '+title+'\n'+run('USE ecommerce_logico;\n'+sql,headers=True))
 print('PASS: Q'+n+' - '+str(len(out.splitlines()))+' linha(s) conferida(s)')
assert len(results)==16
assert results[2]=='2\tParceiro Multi\t99000000000102\t2\tParceiro Multi'
assert results[5]=='1003\t1\t290.00\t100.00\t190.00\n1006\t3\t120.00\t60.00\t60.00'
assert results[7]=='1\tCliente Ana\t2'
assert results[12]=='5\tCliente Eva'
assert results[16].splitlines()[0]=='1001\t2\t2\t320.00\t320.00\t0.00'
save('consultas_resultados.txt','\n\n'.join(reports))
before=snapshot();out=run(read('05_fluxo_exemplo.sql'));assert snapshot()==before
assert '2001\tCONCLUIDO\t160.00\t160.00\t0.00' in out and out.splitlines()[-1]=='0'
save('fluxo_rollback.txt',out)
print('PASS: fluxo completo ate entrega e conclusao, seguido de rollback integral')
partial=q("START TRANSACTION; UPDATE pagamento SET status='APROVADO',data_pagamento='2026-10-12 12:00:00' WHERE id_pagamento=5; SELECT valor_aprovado,saldo_pendente FROM vw_saldo_pedido WHERE id_pedido=1003; ROLLBACK;")
assert partial=='290.00\t0.00';assert snapshot()==before
print('PASS: pagamento dividido quita exatamente 290.00 e rollback preserva tentativa pendente')
rastreio_sql="""START TRANSACTION;
INSERT INTO pedido(id_pedido,id_cliente,data_criacao,endereco_entrega_snapshot) VALUES(2002,1,'2026-10-19 10:00:00','Endereco Teste');
INSERT INTO item_pedido(id_pedido,numero_item,id_oferta,quantidade) VALUES(2002,1,1,1);
UPDATE pedido SET status='CONFIRMADO' WHERE id_pedido=2002;
INSERT INTO pagamento VALUES(98,2002,1,1,160,'APROVADO','2026-10-19 11:00:00');
UPDATE pedido SET status='EM_PROCESSAMENTO' WHERE id_pedido=2002;
INSERT INTO entrega(id_entrega,id_pedido) VALUES(98,2002);
UPDATE entrega SET status='POSTADA' WHERE id_entrega=98;
"""
q(rastreio_sql,error=3819);assert snapshot()==before
print('PASS: postagem sem rastreio rejeitada pelo CHECK; transacao temporaria revertida')
neg=[
('PF com dados PJ',"INSERT INTO cliente VALUES(99,'PF','Teste','teste@example.com','44444444444','Teste','99000000009999','Teste PJ')",3819),
('PF sem CPF',"INSERT INTO cliente VALUES(99,'PF','Teste','teste@example.com',NULL,'Teste',NULL,NULL)",3819),
('PJ com dados PF',"INSERT INTO cliente VALUES(99,'PJ','Teste','teste@example.com','44444444444','Teste','99000000009999','Teste PJ')",3819),
('PJ sem CNPJ',"INSERT INTO cliente VALUES(99,'PJ','Teste','teste@example.com',NULL,NULL,NULL,'Teste PJ')",3819),
('PF sem nome completo',"INSERT INTO cliente VALUES(99,'PF','Teste','teste@example.com','44444444444',NULL,NULL,NULL)",3819),
('PJ sem razao',"INSERT INTO cliente VALUES(99,'PJ','Teste','teste@example.com',NULL,NULL,'99000000009999',NULL)",3819),
('CPF duplicado',"INSERT INTO cliente VALUES(99,'PF','Teste','teste@example.com','11111111111','Teste',NULL,NULL)",1062),
('CNPJ duplicado',"INSERT INTO cliente VALUES(99,'PJ','Teste','teste@example.com',NULL,NULL,'99000000001001','Teste PJ')",1062),
('alteracao viola exclusividade',"UPDATE cliente SET cnpj='99000000009999' WHERE id_cliente=1",3819),
('pagador diferente do pedido',"INSERT INTO pagamento VALUES(99,1003,3,2,1,'APROVADO','2026-10-12 10:00:00')",1452),
('forma pertence a outro cliente',"INSERT INTO pagamento VALUES(99,1003,3,1,1,'APROVADO','2026-10-12 10:00:00')",1452),
('aprovacao acima do total',"INSERT INTO pagamento VALUES(99,1003,2,1,191,'APROVADO','2026-10-12 10:00:00')",1644),
('pagamento anterior ao pedido',"INSERT INTO pagamento VALUES(99,1003,2,1,1,'APROVADO','2026-10-09 10:00:00')",1644),
('aprovacao sem data',"INSERT INTO pagamento VALUES(99,1003,2,1,1,'APROVADO',NULL)",3819),
('valor de pagamento zero',"INSERT INTO pagamento VALUES(99,1003,2,1,0,'PENDENTE',NULL)",3819),
('editar aprovado','UPDATE pagamento SET valor=1 WHERE id_pagamento=1',1644),
('excluir historico pagamento','DELETE FROM pagamento WHERE id_pagamento=1',1644),
('processar sem quitacao',"UPDATE pedido SET status='EM_PROCESSAMENTO' WHERE id_pedido=1003",1644),
('concluir antes da entrega',"UPDATE pedido SET status='CONCLUIDO' WHERE id_pedido=1002",1644),
('cancelar sem estorno',"UPDATE pedido SET status='CANCELADO' WHERE id_pedido=1003",1644),
('reabrir concluido',"UPDATE pedido SET status='RASCUNHO' WHERE id_pedido=1001",1644),
('confirmar pedido vazio',"UPDATE pedido SET status='CONFIRMADO' WHERE id_pedido=1004",1644),
('editar frete confirmado','UPDATE pedido SET frete=999 WHERE id_pedido=1003',1644),
('alterar cliente do pedido','UPDATE pedido SET id_cliente=2 WHERE id_pedido=1003',1644),
('inserir item confirmado','INSERT INTO item_pedido(id_pedido,numero_item,id_oferta,quantidade) VALUES(1003,2,2,1)',1644),
('alterar item confirmado','UPDATE item_pedido SET quantidade=3 WHERE id_pedido=1003',1644),
('excluir item confirmado','DELETE FROM item_pedido WHERE id_pedido=1003',1644),
('oferta inativa','INSERT INTO item_pedido(id_pedido,numero_item,id_oferta,quantidade) VALUES(1004,1,6,1)',1644),
('quantidade zero','INSERT INTO item_pedido(id_pedido,numero_item,id_oferta,quantidade) VALUES(1004,1,2,0)',3819),
('reescrever produto da oferta','UPDATE oferta SET id_produto=2 WHERE id_oferta=1',1644),
('saldo fisico negativo','UPDATE produto_estoque SET quantidade_disponivel=-1 WHERE id_produto=1 AND id_estoque=1',3819),
('produto inexistente no fornecimento',"INSERT INTO fornecimento VALUES(1,999,'INV')",1452),
('entrega sem processamento','INSERT INTO entrega(id_entrega,id_pedido) VALUES(99,1003)',1644),
('duas entregas no pedido','INSERT INTO entrega(id_entrega,id_pedido) VALUES(99,1002)',1062),
('apagar rastreio postado','UPDATE entrega SET codigo_rastreio=NULL WHERE id_entrega=2',1644),
('excluir historico entrega','DELETE FROM entrega WHERE id_entrega=1',1644),
('retroceder entrega',"UPDATE entrega SET status='PREPARANDO' WHERE id_entrega=2",1644),
]
for label,sql,code in neg:
 old=snapshot();q(sql,error=code);assert snapshot()==old,label
 print('PASS: rejeitado sem alterar dados -',label)
q('INSERT INTO item_pedido(id_pedido,numero_item,id_oferta,quantidade) VALUES(1004,1,2,1)')
q('UPDATE pedido SET desconto=90 WHERE id_pedido=1004')
old=snapshot();q("UPDATE pedido SET status='CONFIRMADO' WHERE id_pedido=1004",error=1644);assert snapshot()==old
q('UPDATE pedido SET desconto=0 WHERE id_pedido=1004');q('DELETE FROM item_pedido WHERE id_pedido=1004')
assert snapshot()==before
print('PASS: total negativo rejeitado ao confirmar; preparacao do teste removida')
# Metadados reais usados no dicionario, nao uma copia manual do DDL.
save('colunas.tsv',run("SELECT TABLE_NAME,COLUMN_NAME,COLUMN_TYPE,IS_NULLABLE,COLUMN_KEY,EXTRA FROM information_schema.COLUMNS WHERE TABLE_SCHEMA='ecommerce_logico' AND TABLE_NAME NOT LIKE 'vw_%' ORDER BY TABLE_NAME,ORDINAL_POSITION",headers=True))
save('chaves_estrangeiras.tsv',run("SELECT TABLE_NAME,CONSTRAINT_NAME,COLUMN_NAME,REFERENCED_TABLE_NAME,REFERENCED_COLUMN_NAME FROM information_schema.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA='ecommerce_logico' AND REFERENCED_TABLE_NAME IS NOT NULL ORDER BY TABLE_NAME,CONSTRAINT_NAME,ORDINAL_POSITION",headers=True))
save('inventario.txt',run("SELECT TABLE_NAME,TABLE_TYPE FROM information_schema.TABLES WHERE TABLE_SCHEMA='ecommerce_logico' ORDER BY TABLE_NAME; SELECT TRIGGER_NAME FROM information_schema.TRIGGERS WHERE TRIGGER_SCHEMA='ecommerce_logico' ORDER BY TRIGGER_NAME;",headers=True))
print('TODOS OS TESTES PASSARAM - MySQL '+run('SELECT VERSION()'))
