"""Temporary malformed archive fixtures. No live files/packages/deployment."""
import importlib.util,tempfile,zipfile,warnings,struct
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('ui_build',ROOT/'scripts/build.py');module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
expected={'B47ANCEDUI/42/mod.info':b'fixture'}
valid={**dict.fromkeys(module.DIRECTORIES,b''),**expected}
with tempfile.TemporaryDirectory() as tmp:
    def archive(name,entries):
        p=Path(tmp)/name
        with zipfile.ZipFile(p,'w') as z:
            with warnings.catch_warnings():
                warnings.simplefilter('ignore',UserWarning)
                for key,value in entries:z.writestr(key,value)
        return p
    module.verify(archive('good.zip',list(valid.items())),expected)
    cases=[list(valid.items())+[('../escape',b'bad')],list(valid.items())+[('B47ANCEDUI/extra.lua',b'bad')],list(valid.items())+[('B47ANCEDUI/42/MOD.INFO',b'bad')],list(valid.items())+list(expected.items()),[(k,b'changed' if k in expected else v) for k,v in valid.items()],[(k,v) for k,v in valid.items() if k not in expected]]
    for i,entries in enumerate(cases):
        try:module.verify(archive(f'bad{i}.zip',entries),expected)
        except (AssertionError,zipfile.BadZipFile):pass
        else:raise AssertionError('Unsafe/drifting archive accepted')
    corrupt=archive('crc.zip',list(valid.items()))
    with zipfile.ZipFile(corrupt) as z: entry=z.getinfo('B47ANCEDUI/42/mod.info')
    data=bytearray(corrupt.read_bytes());start=entry.header_offset
    filename_length,extra_length=struct.unpack_from('<HH',data,start+26)
    data[start+30+filename_length+extra_length]^=1;corrupt.write_bytes(data)
    try:module.verify(corrupt,expected)
    except (AssertionError,zipfile.BadZipFile):pass
    else:raise AssertionError('CRC-corrupt archive accepted')
print('PASS temporary archive traversal/case/duplicate/extra/changed/missing/CRC rejection; no game evidence')
