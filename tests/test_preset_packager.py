"""Disposable offline data/plugin staging contracts; never reads user exports."""
from pathlib import Path
import importlib.util
import json
import hashlib
import tempfile
from unittest.mock import patch
import zlib
import sys
from lupa.lua51 import LuaRuntime

ROOT=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('preset_packager',ROOT/'scripts/preset_packager.py')
packager=importlib.util.module_from_spec(spec);spec.loader.exec_module(packager)
lua=LuaRuntime(unpack_returned_tuples=True);lua.globals().next=None
lua.globals().package.path=(ROOT/'src/B47ANCEDUI/42/media/lua/client').as_posix()+'/?.lua;'+lua.globals().package.path
lua.execute("UIFont={Small=1,Medium=2,Large=3};getText=function()return 'Preset One'end")
lua.execute("P=require 'B47ANCEDUI/StylePresets';K=require 'B47ANCEDUI/PresetPlugins'")
def data(color='#123456'):
    return lua.eval("function(hex)local b=P.set(P.new(),'default','*','all','titleText',hex);return K.encode('B47UI.Fixture','1.0.0',b)end")(color).encode()
def reject(raw):
    try:packager.parse(raw)
    except (ValueError,UnicodeError):return
    raise AssertionError('Accepted malformed preset export')
def hashes(root):
    return {p.relative_to(root).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in root.rglob('*') if p.is_file()}

raw=data();parsed=packager.parse(raw)
assert parsed['presets']['default']['values'][('*','all','titleText')]=='#123456'
reject(raw.replace(b'version=1.0.0',b'1.0.0',1));reject(raw.replace(b'id=B47UI.Fixture',b'id=../Bad',1))
reject(raw.replace(b'#123456',b'#123457'));reject(raw+b'extra\n');reject(b'x'*262401)
reject(raw.replace(b'b47ui-plugin=1',b'b47ui-plugin=2',1));reject(raw[:-1])
for bad in (b'not-a-color',b'#abcdef',b'NaN'):
    prefix,body=raw.split(b'schema=1\n',1);body=b'schema=1\n'+body.rsplit(b'checksum=',1)[0]
    body=body.replace(b'#123456',bad)
    reject(prefix+body+b'checksum='+packager.checksum(body).encode()+b'\n')
prefix,body=raw.split(b'schema=1\n',1);body=b'schema=1\n'+body.rsplit(b'checksum=',1)[0].rstrip(b'\n')
reject(prefix+body+b'checksum='+packager.checksum(body).encode()+b'\n')
aliases=lua.eval('B47ANCEDUI.Theme.colorAliases');expected=set(aliases.keys())|set('background hover selected border focus text muted accent accentHover disabled alternate danger warning success'.split())
assert packager.COLOR_PROPERTIES==expected,'Packager colour validation drift'

with tempfile.TemporaryDirectory(prefix='b47ui-packager-test-') as directory:
    base=Path(directory).resolve();workshop=base/'Workshop';export=base/'B47UI.Fixture.b47ui.txt';export.write_bytes(raw)
    root=packager.stage(export,workshop);assert root.is_relative_to(workshop)
    receipt=json.loads((root/'.b47ui-export.json').read_text());assert receipt['version']=='1.0.0'
    common=root/'Contents/mods/B47UI.Fixture/common/media/B47ANCEDUI/style-pack.txt'
    packager.parse(common.read_bytes());assert lua.eval('K.parse')(common.read_text())[0] is not None
    assert 'require=B47ANCEDUI\n' in (root/'Contents/mods/B47UI.Fixture/42/mod.info').read_text()
    assert all(p.suffix not in {'.lua','.jar','.class'} for p in (root/'Contents').rglob('*') if p.is_file())
    png=(root/'preview.png').read_bytes();assert png[:8]==b'\x89PNG\r\n\x1a\n';assert int.from_bytes(png[16:20],'big')==256 and int.from_bytes(png[20:24],'big')==256
    at=8
    while at<len(png):
        size=int.from_bytes(png[at:at+4],'big');chunk=png[at+4:at+8+size]
        assert zlib.crc32(chunk)==int.from_bytes(png[at+8+size:at+12+size],'big');at+=size+12
    before=hashes(root);packager.stage(export,workshop);assert hashes(root)==before,'Idempotent staging changed package'
    metadata=b'version=1\nid=123456789\ntitle=Owner title\nvisibility=public\ntags=Custom\n'
    (root/'workshop.txt').write_bytes(metadata);export.write_bytes(data('#654321'))
    stable=hashes(root);original_write=packager.atomic_write
    def fail_preparation(path,content):
        if path.name=='preview.png':raise OSError('preparation failure')
        return original_write(path,content)
    with patch.object(packager,'atomic_write',side_effect=fail_preparation):
        try:packager.stage(export,workshop)
        except OSError:pass
        else:raise AssertionError('Failure injection did not fail')
    assert hashes(root)==stable,'Preparation failure changed live package'
    rename=Path.rename;failed=[False]
    def fail_install(self,target):
        if Path(target)==root and self.parent.name=='transactions' and not failed[0]:
            failed[0]=True;raise OSError('install failure')
        return rename(self,target)
    with patch.object(Path,'rename',fail_install):
        try:packager.stage(export,workshop)
        except OSError:pass
        else:raise AssertionError('Install failure injection did not fail')
    assert hashes(root)==stable,'Install failure did not roll back live package'
    packager.stage(export,workshop)
    assert (root/'workshop.txt').read_bytes()==metadata,'Update reset Workshop identity/visibility'
    assert (root/'VERSION').read_text().strip()=='1.0.1'
    assert packager.parse(common.read_bytes())['version']=='1.0.1'
    assert list((base/'B47ANCEDUI-PresetPackages/history/B47UI.Fixture').iterdir()),'Previous package not retained'
    assert [p.name for p in workshop.iterdir()]==['B47UI.Fixture'],'Helper internals leaked into native staging list'
    # Data-only readiness rejects unexpected executables without deleting them.
    extra=root/'Contents/mods/B47UI.Fixture/42/media/lua/client/extra.lua';extra.parent.mkdir(parents=True);extra.write_text('error("never executed")')
    damaged=hashes(root)
    try:packager.stage(export,workshop)
    except ValueError:pass
    else:raise AssertionError('Unexpected runtime code accepted')
    assert hashes(root)==damaged and extra.exists()
    receipt_path=root/'.b47ui-export.json';original_receipt=receipt_path.read_bytes()
    edited=json.loads(original_receipt);edited['files'][extra.relative_to(root).as_posix()]=hashlib.sha256(extra.read_bytes()).hexdigest()
    receipt_path.write_text(json.dumps(edited))
    try:packager.stage(export,workshop)
    except ValueError:pass
    else:raise AssertionError('Edited receipt authorized executable content')
    receipt_path.write_bytes(original_receipt)
    extra.unlink()  # Remove only this disposable malicious fixture.
    # Recover a known interrupted directory swap before accepting another update.
    cache=base/'B47ANCEDUI-PresetPackages';backup=cache/'history/B47UI.Fixture/interrupted';backup.parent.mkdir(parents=True,exist_ok=True);root.rename(backup)
    (cache/'B47UI.Fixture.pending.json').write_text(json.dumps({'id':'B47UI.Fixture','phase':'prepared','backup':'history/B47UI.Fixture/interrupted'}))
    packager.stage(export,workshop);assert root.exists() and (root/'workshop.txt').read_bytes()==metadata
    unowned=workshop/'B47UI.Other';unowned.mkdir();(unowned/'keep.txt').write_text('preserve')
    other=base/'other.txt';other.write_bytes(raw.replace(b'id=B47UI.Fixture',b'id=B47UI.Other',1))
    try:packager.stage(other,workshop)
    except ValueError:pass
    else:raise AssertionError('Unowned Workshop directory overwritten')
    assert (unowned/'keep.txt').read_text()=='preserve'
print('PASS OFFLINE cross-Lua preset format, malformed/future/case/checksum rejection, data-only packaging, PNG CRC, versioned updates, identity preservation, rollback/recovery, idempotence and owned-folder guards')
