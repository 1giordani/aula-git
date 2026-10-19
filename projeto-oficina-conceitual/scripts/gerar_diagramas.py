"""Gera os SVGs e o Draw.io editavel a partir de modelo.json; biblioteca padrao."""
from pathlib import Path
import html
import json
import xml.etree.ElementTree as ET

root=Path(__file__).resolve().parents[1]
m=json.loads((root/'modelo.json').read_text())
entities=m['entities'];relations=m['relations']
W,H=1600,1180
BG='#10141b';CARD='#1a2029';GOLD='#ebc17d';TEXT='#eae2d4';LINE='#a99576'
def h(s):return html.escape(str(s),quote=True)
def text(x,y,value,size=18,color=TEXT,anchor='start',weight='normal'):
 return f'<text x="{x}" y="{y}" font-size="{size}" fill="{color}" text-anchor="{anchor}" font-weight="{weight}">{h(value)}</text>'
def labelpos(points,start):
 a,b=(points[0],points[1]) if start else (points[-1],points[-2])
 dx,dy=b[0]-a[0],b[1]-a[1]
 if abs(dx)>=abs(dy):return a[0]+(36 if dx>0 else -36),a[1]-12
 return a[0]+33,a[1]+(28 if dy>0 else -18)

drawio=ET.Element('mxfile',host='app.diagrams.net',type='device')
covered=set();checked=0
for page in m['pages']:
 parts=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}" role="img" aria-labelledby="title desc">',
 f'<title id="title">{h(page["title"])}</title><desc id="desc">{h(page["subtitle"])}</desc>',
 '<g font-family="DejaVu Sans,Arial,sans-serif">',f'<rect width="{W}" height="{H}" fill="{BG}"/>',
 text(60,48,'OFICINA / '+page['id']+' — '+page['title'],28,GOLD,weight='bold'),
 text(60,84,page['subtitle'],17)]
 diagram=ET.SubElement(drawio,'diagram',id='pagina'+page['id'],name=page['title'])
 graph=ET.SubElement(diagram,'mxGraphModel',page='1',pageWidth=str(W),pageHeight=str(H),background=BG,grid='1',gridSize='10')
 eroot=ET.SubElement(graph,'root');ET.SubElement(eroot,'mxCell',id='0');ET.SubElement(eroot,'mxCell',id='1',parent='0')
 def vertex(ident,value,x,y,w,height,style):
  c=ET.SubElement(eroot,'mxCell',id=ident,value=value,style=style,vertex='1',parent='1')
  ET.SubElement(c,'mxGeometry',x=str(x),y=str(y),width=str(w),height=str(height),attrib={'as':'geometry'})
 vertex('heading',page['title'],50,15,1500,40,'text;html=1;fontColor='+GOLD+';fontSize=27;align=left;')
 vertex('subtitle',page['subtitle'],50,60,1500,40,'text;html=1;fontColor='+TEXT+';fontSize=17;align=left;')
 for i,points,lx,ly in page['edges']:
  
  if len(points)==2 and points[0][1]==points[1][1]: ly-=35
  rel=relations[i];assert rel['parent'] in page['nodes'] and rel['child'] in page['nodes']
  covered.add(i);checked+=1
  coords=' '.join(str(x)+','+str(y) for x,y in points)
  parts.append(f'<polyline points="{coords}" fill="none" stroke="{LINE}" stroke-width="2"/>')
  # Labels dos papeis de cada ponta e nome da relacao.
  for start,card in [(True,rel['parent_card']),(False,rel['child_card'])]:
   x,y=labelpos(points,start)
   parts.append(f'<rect x="{x-25}" y="{y-18}" width="50" height="24" rx="4" fill="{BG}"/>')
   parts.append(text(x,y,card,17,GOLD,'middle','bold'))
   vertex('card'+str(i)+str(start),card,x-28,y-20,56,28,'text;html=1;fontColor='+GOLD+';fontSize=17;fontStyle=1;fillColor='+BG+';')
  parts.append(f'<rect x="{lx-100}" y="{ly-20}" width="200" height="28" rx="5" fill="{BG}"/>')
  parts.append(text(lx,ly,rel['label'],16,TEXT,'middle'))
  sx,sy,sw,sh=page['nodes'][rel['parent']];tx,ty,tw,th=page['nodes'][rel['child']]
  style=f'edgeStyle=orthogonalEdgeStyle;rounded=0;html=1;endArrow=none;startArrow=none;strokeColor={LINE};fontColor={TEXT};fontSize=16;exitX={(points[0][0]-sx)/sw};exitY={(points[0][1]-sy)/sh};exitDx=0;exitDy=0;entryX={(points[-1][0]-tx)/tw};entryY={(points[-1][1]-ty)/th};entryDx=0;entryDy=0;'
  edge=ET.SubElement(eroot,'mxCell',id='edge'+str(i),value=rel['label'],style=style,edge='1',parent='1',source=rel['parent'],target=rel['child'])
  g=ET.SubElement(edge,'mxGeometry',relative='1',attrib={'as':'geometry'})
  if len(points)==2 and points[0][1]==points[1][1]:
   ET.SubElement(g,'mxPoint',x='0',y='-45',attrib={'as':'offset'})
  if len(points)>2:
   arr=ET.SubElement(g,'Array',attrib={'as':'points'})
   for x,y in points[1:-1]: ET.SubElement(arr,'mxPoint',x=str(x),y=str(y))
 for key,(x,y,w,height) in page['nodes'].items():
  e=entities[key]
  parts.append(f'<rect x="{x}" y="{y}" width="{w}" height="{height}" rx="10" fill="{CARD}" stroke="{LINE}" stroke-width="1.5"/>')
  parts.append(text(x+20,y+33,e['label'],19,GOLD,weight='bold'))
  parts.append(f'<line x1="{x}" y1="{y+50}" x2="{x+w}" y2="{y+50}" stroke="{LINE}"/>')
  for j,field in enumerate(e['fields']):parts.append(text(x+20,y+80+27*j,field,16))
  if e['notes']:parts.append(text(x+20,y+height-16,e['notes'],14,GOLD))
  fields='<br/>'.join(h(v) for v in e['fields'])
  value='<b>'+h(e['label'])+'</b><hr/>'+fields
  if e['notes']:value+='<br/><i>'+h(e['notes'])+'</i>'
  vertex(key,value,x,y,w,height,'rounded=1;whiteSpace=wrap;html=1;align=left;verticalAlign=top;spacing=15;fillColor='+CARD+';strokeColor='+LINE+';fontColor='+TEXT+';fontSize=16;')
 parts.extend([text(60,1122,page['footer'],17,GOLD),text(60,1155,'PK = chave primária   |   FK = chave estrangeira   |   UK = chave única   |   0..N = zero ou muitos   |   0..1 = opcional',16),text(1530,1155,'Giordani Martins Silva',15,TEXT,'end'),'</g></svg>'])
 vertex('footer',page['footer'],50,1095,1500,40,'text;html=1;align=left;fontSize=17;fontColor='+GOLD+';')
 vertex('legend','PK = chave primária | FK = chave estrangeira | UK = chave única | 0..N = zero ou muitos | 0..1 = opcional',50,1130,1500,40,'text;html=1;align=left;fontSize=16;fontColor='+TEXT+';')
 (root/'diagramas'/('diagrama_'+page['id']+'.svg')).write_text('\n'.join(parts))
assert covered==set(range(len(relations)))
assert all(any('PK' in f for f in e['fields']) for e in entities.values())
for rel in relations:
 for fk in rel['fk_fields']:
  assert any('FK' in field and fk in field for field in entities[rel['child']]['fields'])
assert set(entities)==set().union(*(set(p['nodes']) for p in m['pages']))
ET.indent(drawio)
ET.ElementTree(drawio).write(root/'diagramas/oficina_mecanica.drawio',encoding='utf-8',xml_declaration=True)
for svg in (root/'diagramas').glob('*.svg'):ET.parse(svg)
ET.parse(root/'diagramas/oficina_mecanica.drawio')
print(f'Gerados: 3 SVGs + Draw.io com 3 páginas; {len(entities)} entidades; {len(covered)} relacionamentos únicos ({checked} ocorrências nas páginas); PKs e FKs conferidas.')
