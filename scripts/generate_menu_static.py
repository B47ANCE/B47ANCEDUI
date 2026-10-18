"""Reproducible original 64x48 noise textures; host tooling, never runtime code."""
from pathlib import Path
import random, struct, zlib
ROOT=Path(__file__).resolve().parents[1]
DEST=ROOT/'src/B47ANCEDUI/42/media/ui/B47ANCEDUI'
def chunk(kind,data):
    return struct.pack('>I',len(data))+kind+data+struct.pack('>I',zlib.crc32(kind+data)&0xffffffff)
def frame(index):
    rng=random.Random(47000+index)
    pixels=b''.join(b'\0'+bytes(rng.randrange(32,194) for _ in range(64)) for _ in range(48))
    return b'\x89PNG\r\n\x1a\n'+chunk(b'IHDR',struct.pack('>IIBBBBB',64,48,8,0,0,0,0))+chunk(b'IDAT',zlib.compress(pixels,9))+chunk(b'IEND',b'')
if __name__=='__main__':
    DEST.mkdir(parents=True,exist_ok=True)
    for i in range(1,9): (DEST/f'Static{i}.png').write_bytes(frame(i))
