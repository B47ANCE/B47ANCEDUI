"""Optional offline preset exporter companion. Never launches Steam or uploads.

Run once for a .b47ui.txt export, or keep --watch running for one-button in-game
exports. Only validated data enters generated mods; no Lua/code is executed.
"""
from pathlib import Path
import argparse
import hashlib
import json
import os
import re
import struct
import tempfile
import time
import uuid
import zlib

IDENTIFIER = re.compile(r'[A-Za-z][A-Za-z0-9_.-]{0,63}')
COLOR_PROPERTIES = set('background hover selected border focus text muted accent accentHover disabled alternate danger warning success windowBackground panelBackground raisedBackground rowBackground overlayBackground pressed selectedText disabledText disabledBorder focusOuter focusInner titleBackground titleText statusBackground track trackBorder thumb thumbHover thumbBorder scrollTrack scrollThumb scrollThumbHover scrollArrow check checkBackground checkBorder icon iconDisabled progressTrack progressFill progressBorder menuText menuHover menuUnderline tooltipBackground tooltipText tooltipBorder inputText inputPlaceholder'.split())
NUMBERS = {'opacity':(20,100),'radius':(0,8),'borderWidth':(0,3),'trackThickness':(1,12),'thumbWidth':(4,32),'thumbHeight':(8,48)}


def require(condition, message):
    if not condition:
        raise ValueError(message)


def identifier(value):
    return isinstance(value,str) and IDENTIFIER.fullmatch(value) is not None


def checksum(data):
    return f'{zlib.adler32(data):08X}'


def unhex(value):
    require(re.fullmatch(r'(?:[0-9A-Fa-f]{2})+',value) is not None,'Invalid encoded value')
    return bytes.fromhex(value).decode('utf-8')


def parse(data):
    require(len(data)<=262400 and b'\r' not in data,'Oversized or noncanonical export')
    text=data.decode('utf-8')
    lines=[line+'\n' for line in text.split('\n')[:-1]]
    require(text.endswith('\n'),'Incomplete export')
    require(all(line.endswith('\n') and len(line.encode('utf-8'))<=513 for line in lines),'Invalid record bounds')
    require(len(lines)<=4100 and len(lines)>=8,'Invalid record count')
    require(lines[0]=='b47ui-plugin=1\n','Unsupported plugin format')
    pack_id=lines[1].removeprefix('id=').removesuffix('\n')
    version=lines[2].removeprefix('version=').removesuffix('\n')
    require(lines[1]=='id='+pack_id+'\n' and identifier(pack_id),'Invalid pack ID')
    require(lines[2]=='version='+version+'\n','Invalid version header')
    require(re.fullmatch(r'(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)',version) is not None and len(version)<=32,'Invalid pack version')
    require(pack_id.split('.')[0].upper() not in {'CON','PRN','AUX','NUL','COM1','LPT1'},'Reserved folder name')
    payload=''.join(lines[3:]).encode('utf-8')
    body,last=payload.rsplit(b'checksum=',1)
    require(body.endswith(b'\n') and last==checksum(body).encode()+b'\n','Export checksum mismatch')
    require(len(payload)<=262144,'Oversized preset payload')
    records=body.decode('utf-8').split('\n')[:-1]
    require(records[0]=='schema=1' and len(records)==len(set(records)),'Invalid preset records')
    presets={};bindings={};active=None;generation=None;values=0;seen=set()
    for line in records[1:]:
        parts=line.split('|')
        if line.startswith('generation='):
            require(generation is None and re.fullmatch(r'generation=[0-9]+',line),'Duplicate/invalid generation')
            generation=int(line[11:]);require(1<=generation<=1_000_000_000,'Invalid generation')
        elif line.startswith('active='):
            require(active is None,'Duplicate active');active=line[7:]
        elif parts[0]=='preset' and len(parts)==3:
            key,name=parts[1],unhex(parts[2])
            require(identifier(key) and key not in presets and 1<=len(name.encode('utf-8'))<=48 and not re.search(r'[\x00-\x1f\x7f]',name),'Invalid preset')
            presets[key]={'name':name,'values':{}}
        elif parts[0]=='value' and len(parts)==6:
            _,key,scope,family,property_id,value=parts;scope=unhex(scope)
            require(key in presets and (scope=='*' or identifier(scope)) and identifier(family) and identifier(property_id),'Invalid value target')
            address=(key,scope,family,property_id);require(address not in seen,'Duplicate value');seen.add(address)
            if property_id in COLOR_PROPERTIES:
                require(re.fullmatch(r'#[0-9A-F]{6}',value) is not None,'Invalid/noncanonical colour')
            elif property_id in NUMBERS:
                lo,hi=NUMBERS[property_id];require(re.fullmatch(r'[0-9]+',value) is not None and lo<=int(value)<=hi,'Invalid number')
            else:
                require(0<len(value.encode('utf-8'))<=64 and not re.search(r'[|\r\n\x00]',value),'Invalid future property')
            presets[key]['values'][address[1:]]=value;values+=1
        elif parts[0]=='bind' and len(parts)==3:
            scope=unhex(parts[1]);require(identifier(scope) and scope not in bindings,'Invalid binding');bindings[scope]=parts[2]
        else:
            raise ValueError('Unrecognized preset record')
    require(generation is not None and active in presets and 'default' in presets and 1<=len(presets)<=16 and values<=3072 and len(bindings)<=32,'Invalid preset library')
    require(all(key in presets for key in bindings.values()),'Missing bound preset')
    return {'id':pack_id,'version':version,'presets':presets,'data':data}


def preview_png(pack):
    """Original palette swatches, not claimed native screenshots or branding."""
    colors=['#121515','#242A29','#B0B0B0','#E8EDEB']
    for preset in pack['presets'].values():
        colors.extend(value for (_,_,prop),value in preset['values'].items() if prop in COLOR_PROPERTIES and value not in colors)
    colors=colors[:12];rgb=[bytes.fromhex(c[1:]) for c in colors]
    rows=[]
    for y in range(256):
        row=bytearray()
        for x in range(256):
            index=min(len(rgb)-1,x*len(rgb)//256)
            row.extend(rgb[index] if 20<=y<236 else rgb[0])
        rows.append(b'\0'+row)
    def chunk(kind,data):
        return struct.pack('>I',len(data))+kind+data+struct.pack('>I',zlib.crc32(kind+data))
    return b'\x89PNG\r\n\x1a\n'+chunk(b'IHDR',struct.pack('>IIBBBBB',256,256,8,2,0,0,0))+chunk(b'IDAT',zlib.compress(b''.join(rows),9))+chunk(b'IEND',b'')


def owned_path(root,relative):
    require(not Path(relative).is_absolute() and '..' not in Path(relative).parts,'Unsafe owned path')
    target=(root/relative).resolve()
    require(target.is_relative_to(root.resolve()),'Symlink/path escaped selected folder')
    return target


def atomic_write(path,data):
    path.parent.mkdir(parents=True,exist_ok=True)
    temporary=None
    try:
        with tempfile.NamedTemporaryFile(dir=path.parent,prefix='.b47ui-',delete=False) as handle:
            temporary=Path(handle.name);handle.write(data)
        os.replace(temporary,path)
    except BaseException:
        if temporary is not None:temporary.unlink(missing_ok=True)
        raise


def verify_owned(root,pack_id):
    receipt_path=owned_path(root,'.b47ui-export.json')
    require(receipt_path.is_file(),'Refusing to overwrite an unowned Workshop folder')
    receipt=json.loads(receipt_path.read_text(encoding='utf-8'))
    require(receipt.get('schema')==1 and receipt.get('id')==pack_id,'Invalid folder ownership')
    prefix=f'Contents/mods/{pack_id}'
    fixed={f'{prefix}/42/mod.info',f'{prefix}/common/media/B47ANCEDUI/style-pack.txt',f'{prefix}/42/poster.png',f'{prefix}/common/poster.png','preview.png','VERSION'}
    require(isinstance(receipt.get('files'),dict) and set(receipt['files'])==fixed,'Invalid data-only file inventory')
    expected={name for name in fixed if name.startswith('Contents/')}
    actual=set()
    for path in (root/'Contents').rglob('*'):
        require(not path.is_symlink(),'Unexpected symlink in plugin content')
        if path.is_file():actual.add(path.relative_to(root).as_posix())
    require(actual==expected,'Unexpected/missing files in data-only plugin content')
    for name,digest in receipt['files'].items():
        path=owned_path(root,name)
        require(path.is_file() and not path.is_symlink() and hashlib.sha256(path.read_bytes()).hexdigest()==digest,'Generated file changed locally: '+name)
    return receipt


def stage(export,workshop_dir):
    export=export.resolve();raw=export.read_bytes();pack=parse(raw)
    workshop_dir=workshop_dir.resolve()
    require(workshop_dir.name.casefold()=='workshop','Select the Zomboid Workshop staging directory')
    workshop_dir.mkdir(parents=True,exist_ok=True)
    root=owned_path(workshop_dir,pack['id'])
    # Transactions/history stay outside Workshop so native enumeration sees
    # only actual plugin items, never helper scratch/history directories.
    cache=owned_path(workshop_dir.parent,'B47ANCEDUI-PresetPackages')
    owner=owned_path(cache,'.b47ui-helper.json')
    cache.mkdir(parents=True,exist_ok=True)
    if owner.exists():require(owner.read_text()=='{"schema":1}\n','Unowned helper directory')
    else:
        require(not any(cache.iterdir()),'Unowned helper directory')
        atomic_write(owner,b'{"schema":1}\n')
    pending=owned_path(cache,pack['id']+'.pending.json')
    if pending.exists() and not root.exists():
        recovery=json.loads(pending.read_text())
        require(recovery.get('id')==pack['id'] and recovery.get('phase') in {'prepared','complete'},'Invalid pending transaction')
        backup=owned_path(cache,recovery['backup'])
        if backup.exists():
            verify_owned(backup,pack['id']);backup.rename(root)
    previous=verify_owned(root,pack['id']) if root.exists() else None
    source_hash=hashlib.sha256(raw).hexdigest()
    if previous and previous.get('export_sha256')==source_hash:
        pass  # Already hash/inventory-verified, including unexpected payload.
    else:
        version=pack['version']
        if previous:
            a,b,c=previous['version'].split('.');version=f'{a}.{b}.{int(c)+1}'
        require(len(version)<=32,'Plugin version limit reached')
        data=raw.replace(('version='+pack['version']+'\n').encode(),('version='+version+'\n').encode(),1)
        title=next(iter(pack['presets'].values()))['name']
        prefix=f'Contents/mods/{pack["id"]}'
        info=f'name={title}\nid={pack["id"]}\nmodversion={version}\nversionMin=42.21.0\nrequire=B47ANCEDUI\nposter=poster.png\ndescription=UI preset data pack. Adds choices to B47ANCE\'d UI; never activates automatically.\n'
        image=preview_png(pack)
        files={f'{prefix}/42/mod.info':info.encode(),f'{prefix}/common/media/B47ANCEDUI/style-pack.txt':data,
               f'{prefix}/42/poster.png':image,f'{prefix}/common/poster.png':image,'preview.png':image,'VERSION':(version+'\n').encode()}
        transaction=uuid.uuid4().hex
        staged=owned_path(cache,'transactions/'+transaction)
        for name,content in files.items():atomic_write(owned_path(staged,name),content)
        for name in ('42','common'):
            for empty in ('media/AnimSets','media/actiongroups'):
                owned_path(staged,f'{prefix}/{name}/{empty}').mkdir(parents=True,exist_ok=True)
        metadata=owned_path(root,'workshop.txt')
        if metadata.exists():
            require(not metadata.is_symlink(),'Workshop metadata symlink')
            metadata_data=metadata.read_bytes()
        else:
            metadata_text=f'version=1\nid=\ntitle={title}\ndescription=UI preset pack. Requires B47ANCE\'d UI. Enable this pack, then choose a preset in Options > Interface > UI Style Presets.\ntags=Interface\nvisibility=private\n'
            metadata_data=metadata_text.encode()
        atomic_write(owned_path(staged,'workshop.txt'),metadata_data)
        receipt={'schema':1,'id':pack['id'],'version':version,'export_sha256':source_hash,
                 'files':{name:hashlib.sha256(content).hexdigest() for name,content in files.items()},'publication':'NOT PERFORMED'}
        atomic_write(owned_path(staged,'.b47ui-export.json'),(json.dumps(receipt,indent=2)+'\n').encode())
        verify_owned(staged,pack['id'])
        backup_relative='history/'+pack['id']+'/'+transaction
        backup=owned_path(cache,backup_relative)
        journal={'id':pack['id'],'phase':'prepared','backup':backup_relative}
        atomic_write(pending,(json.dumps(journal)+'\n').encode())
        if previous:
            backup.parent.mkdir(parents=True,exist_ok=True);root.rename(backup)
        try:
            staged.rename(root)
        except OSError:
            if previous and not root.exists():backup.rename(root)
            raise
        journal['phase']='complete';atomic_write(pending,(json.dumps(journal)+'\n').encode())
        verify_owned(root,pack['id'])
    status=f'b47ui-stage=1\nid={pack["id"]}\nexport={checksum(raw)}\nstatus=ready\n'
    atomic_write(owned_path(export.parent,pack['id']+'.status.txt'),status.encode())
    return root


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('export',nargs='?',type=Path)
    parser.add_argument('--zomboid-dir',type=Path,help='The game data folder shown by PZ, containing Lua/ and Workshop/')
    parser.add_argument('--workshop-dir',type=Path)
    parser.add_argument('--watch',action='store_true')
    args=parser.parse_args()
    workshop=args.workshop_dir or (args.zomboid_dir/'Workshop' if args.zomboid_dir else None)
    parser.error('Select --zomboid-dir or --workshop-dir') if workshop is None else None
    if args.watch:
        require(args.zomboid_dir is not None,'Watch requires --zomboid-dir')
        exports=(args.zomboid_dir/'Lua/B47ANCEDUI/exports').resolve();seen={};errors={}
        print('Watching UI preset exports. Press Ctrl+C to stop. No Steam upload or game launch.')
        while True:
            for path in sorted(exports.glob('B47UI.*.b47ui.txt')):
                try:
                    require(path.resolve().is_relative_to(exports),'Export symlink escaped selected data folder')
                    raw=path.read_bytes();digest=hashlib.sha256(raw).hexdigest()
                    if seen.get(path)==digest:continue
                    request=path.with_name(path.name.removesuffix('.b47ui.txt')+'.request.txt')
                    require(request.resolve().is_relative_to(exports),'Request symlink escaped selected data folder')
                    expected=f'b47ui-export=1\nid={path.name.removesuffix(".b47ui.txt")}\nexport={checksum(raw)}\n'
                    if not request.is_file() or request.read_text(encoding='utf-8')!=expected:continue
                    print('Ready:',stage(path,workshop));seen[path]=digest
                except (ValueError,OSError,UnicodeError,KeyError) as exc:
                    # Retry partial writes; do not publish, delete exports or
                    # suppress native/file failures as successful staging.
                    message=str(exc)
                    if errors.get(path)!=message:print('Export not staged:',path.name,message);errors[path]=message
            time.sleep(1)
    else:
        parser.error('Select a .b47ui.txt export') if args.export is None else None
        print('Ready:',stage(args.export,workshop))


if __name__=='__main__':
    try:main()
    except KeyboardInterrupt:pass
