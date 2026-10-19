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
for name,size in [('SecurityRoomWide.png',(1983,793)),('SecurityWingLeft.png',(887,1774)),('SecurityWingRight.png',(887,1774))]:
    data=(ROOT/'src/B47ANCEDUI/42/media/ui/B47ANCEDUI'/name).read_bytes()
    assert struct.unpack('>II',data[16:24])==size,name
    assert data[25] == (6 if name=='SecurityRoomWide.png' else 2),name
assert manifest['ultrawide']['reference_resolution']==[5120,1440]
for i in range(1,9): assert (noise.DEST/f'Static{i}.png').read_bytes()==noise.frame(i)
assert len({noise.frame(i) for i in range(1,9)})==8
print('PASS artwork SHA256/PNG CRC and eight reproducible distinct noise frames')
