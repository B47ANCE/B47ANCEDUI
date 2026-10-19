"""Verify original image identity, PNG integrity and reproducible noise frames."""
from pathlib import Path
import hashlib,importlib.util,json,struct,zlib
ROOT=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('noise',ROOT/'scripts/generate_menu_static.py')
noise=importlib.util.module_from_spec(spec);spec.loader.exec_module(noise)
manifest=json.loads((ROOT/'docs/MENU_ARTWORK.json').read_text())
for relative,expected in manifest['assets'].items():
    data=(ROOT/relative).read_bytes()
    assert hashlib.sha256(data).hexdigest()==expected,relative
    assert data[:8]==b'\x89PNG\r\n\x1a\n'
    offset=8
    while offset<len(data):
        size=struct.unpack('>I',data[offset:offset+4])[0]
        block=data[offset+4:offset+8+size]
        assert zlib.crc32(block)&0xffffffff==struct.unpack('>I',data[offset+8+size:offset+12+size])[0]
        offset+=size+12
    assert offset==len(data)
data=(ROOT/'src/B47ANCEDUI/42/media/ui/B47ANCEDUI/SecurityRoomPanorama.png').read_bytes()
width,height=struct.unpack('>II',data[16:24])
assert (width,height)==(2172,724) and data[24:26]==bytes([8,6]) and data[28]==0
compressed=b'';offset=8
while offset<len(data):
    size=struct.unpack('>I',data[offset:offset+4])[0]
    if data[offset+4:offset+8]==b'IDAT': compressed+=data[offset+8:offset+8+size]
    offset+=size+12
raw=zlib.decompress(compressed);stride=width*4;prior=bytearray(stride);rows=[]
def paeth(a,b,c):
    p=a+b-c;pa,pb,pc=abs(p-a),abs(p-b),abs(p-c)
    return a if pa<=pb and pa<=pc else b if pb<=pc else c
for y in range(height):
    kind=raw[y*(stride+1)];row=bytearray(raw[y*(stride+1)+1:(y+1)*(stride+1)])
    assert kind in range(5)
    for x in range(stride):
        left=row[x-4] if x>=4 else 0;above=prior[x];corner=prior[x-4] if x>=4 else 0
        predictor=(0,left,above,(left+above)//2,paeth(left,above,corner))[kind]
        row[x]=(row[x]+predictor)&255
    rows.append(row);prior=row
for x,y in [(1180,240),(1420,240),(1180,400),(1420,400)]:
    assert rows[y][x*4+3]==0,'CRT glass must be actual transparency, not painted checkerboard'
holes=[(1105,188,1272,298),(1335,187,1500,298),(1106,340,1272,450),(1335,340,1500,450)]
for y in range(28,height-32):
    for x in range(width):
        if rows[y][x*4+3]==0:
            assert any(x0<=x<x1 and y0<=y<y1 for x0,y0,x1,y1 in holes),'Unexpected transparent hole in visible scenery'
assert manifest['ultrawide']['reference_resolution']==[5120,1440]
for i in range(1,9): assert (noise.DEST/f'Static{i}.png').read_bytes()==noise.frame(i)
assert len({noise.frame(i) for i in range(1,9)})==8
print('PASS artwork SHA256/PNG CRC and eight reproducible distinct noise frames')
