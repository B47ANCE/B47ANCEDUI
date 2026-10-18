"""Explicit deterministic package and integrity checks. Never uploads or deploys."""
from pathlib import Path,PurePosixPath
import hashlib,json,subprocess,sys,zipfile,argparse,re
ROOT=Path(__file__).resolve().parents[1]
MOD='B47ANCEDUI'
DIRECTORIES=[f'{MOD}/common/',f'{MOD}/common/media/AnimSets/',f'{MOD}/common/media/actiongroups/',f'{MOD}/42/media/AnimSets/',f'{MOD}/42/media/actiongroups/']

def assigned_workshop_id(root=ROOT):
    path=root/'WORKSHOP_ID.txt'
    if not path.exists():return None
    item=path.read_text(encoding='utf-8').strip()
    assert re.fullmatch(r'[1-9][0-9]{0,19}',item) and int(item)<2**64,'Invalid existing Workshop identity'
    return item
def source_files():
    source=ROOT/'src'/MOD
    names=json.loads((ROOT/'scripts/production-files.json').read_text())
    result={}
    for name in names:
        p=PurePosixPath(name)
        assert not p.is_absolute() and '..' not in p.parts and '\\' not in name and ':' not in name,name
        result[f'{MOD}/{name}']=(source/name).read_bytes()
    assert len(names)==len(result)==len({n.casefold() for n in result})
    assert set(names)=={p.relative_to(source).as_posix() for p in source.rglob('*') if p.is_file()}
    return result
def verify(archive,expected):
    with zipfile.ZipFile(archive) as z:
        assert z.testzip() is None,'ZIP data/CRC failure'
        names=z.namelist()
        assert len(names)==len(set(names))==len({n.casefold() for n in names}),'Duplicate/case-colliding member'
        for name in names:
            p=PurePosixPath(name)
            assert not p.is_absolute() and '..' not in p.parts and '\\' not in name and ':' not in name and p.parts[0]==MOD,'Unsafe ZIP path'
        assert set(names)==set(expected)|set(DIRECTORIES),'Unexpected/missing member'
        for name,data in expected.items():assert z.read(name)==data, name
    return hashlib.sha256(archive.read_bytes()).hexdigest()
def verify_source_commit(receipt):
    head=subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip()
    source=receipt['source_commit']
    subprocess.run(['git','merge-base','--is-ancestor',source,head],cwd=ROOT,check=True)
    # Preserve a package created before a metadata-only validation correction.
    # Its original source commit/receipt remain immutable; reject any runtime/version drift.
    assert not subprocess.check_output(['git','diff','--name-only',source,head,'--','src','VERSION','scripts/production-files.json'],cwd=ROOT).strip(),'Packaged source differs from current revision'
    return head
def build():
    assert not subprocess.check_output(['git','status','--porcelain'],cwd=ROOT).strip(),'Commit/review source before packaging'
    subprocess.run([sys.executable,'-B',str(ROOT/'tests/run_tests.py')],check=True)
    version=(ROOT/'VERSION').read_text().strip();expected=source_files()
    out=ROOT/'dist/current';out.mkdir(parents=True,exist_ok=True)
    archive=out/f'{MOD}-{version}.zip'
    assert not archive.exists(),'Preserve existing package/provenance; no automatic replacement'
    with zipfile.ZipFile(archive,'x',zipfile.ZIP_DEFLATED) as z:
        for name,data in sorted({**dict.fromkeys(DIRECTORIES,b''),**expected}.items()):
            info=zipfile.ZipInfo(name,date_time=(1980,1,1,0,0,0));info.compress_type=zipfile.ZIP_DEFLATED
            info.external_attr=((0o40755 if name.endswith('/') else 0o100644)<<16)|(0x10 if name.endswith('/') else 0)
            z.writestr(info,data)
    digest=verify(archive,expected)
    receipt={'project_version':version,'source_commit':subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),'source_dirty':False,'mod_id':MOD,'workshop_id':assigned_workshop_id(),'appid':108600,'target_game':'42.21.0','package_sha256':digest,'files':{n:hashlib.sha256(d).hexdigest() for n,d in expected.items()},'directory_entries':DIRECTORIES,'native_sp':'NOT TESTED','dedicated_g7':'BLOCKED / NOT TESTED','stable_g8':'BLOCKED','upload':'NOT PERFORMED'}
    archive.with_name(archive.name+'.provenance.json').write_text(json.dumps(receipt,indent=2)+'\n')
    subprocess.run([sys.executable,'-B',str(ROOT/'scripts/check_versions.py'),'--release'],check=True)
    print('PACKAGE INTEGRITY PASS',archive.name,digest,'-- version/package checks only; stable G8 BLOCKED')
if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--verify',action='store_true');args=parser.parse_args()
    if args.verify:
        version=(ROOT/'VERSION').read_text().strip();archive=ROOT/f'dist/current/{MOD}-{version}.zip'
        receipt=json.loads(archive.with_name(archive.name+'.provenance.json').read_text())
        assert verify(archive,source_files())==receipt['package_sha256']
        verify_source_commit(receipt)
        print('PASS source/package/hash/commit integrity; no runtime claim')
    else:build()
