"""Stage an existing-item MP test update. Never logs in, uploads or touches Steam."""
from pathlib import Path
import json,hashlib,re,subprocess
from build import ROOT,MOD,source_files,verify,verify_source_commit,assigned_workshop_id
LABEL='MP testing build - dedicated multiplayer NOT TESTED'

def submission(fields):
    assert fields['appid']=='108600' and re.fullmatch(r'[1-9][0-9]{0,19}',fields['publishedfileid'])
    assert int(fields['publishedfileid'])<2**64 and fields['visibility']=='0'
    assert 0<len(fields['description'].encode('utf-8'))<8000
    assert 0<len(fields['title'].encode('utf-8'))<129
    assert LABEL in fields['description'] and LABEL in fields['changenote']
    assert not re.search(r'\b(?:TODO|TBD|PLACEHOLDER)\b',fields['description']+fields['changenote'])
    assert '\\n' not in fields['description']+fields['changenote'] and '\x00' not in ''.join(fields.values())
    def escape(value):return value.replace('\\','\\\\').replace('"','\\"').replace('\r\n','\n').replace('\r','\n')
    text='"workshopitem"\n{\n'+''.join(f'    "{key}" "{escape(value)}"\n' for key,value in fields.items())+'}\n'
    tokens=[json.loads(t,strict=False) for t in re.findall(r'"(?:\\.|[^"\\])*"',text,re.S)]
    assert dict(zip(tokens[1::2],tokens[2::2]))==fields,'VDF round trip failed'
    return text

def prepare():
    item=assigned_workshop_id();assert item,'Existing item required; creation is not supported'
    assert not subprocess.check_output(['git','status','--porcelain'],cwd=ROOT).strip(),'Commit source first'
    version=(ROOT/'VERSION').read_text().strip();archive=ROOT/f'dist/current/{MOD}-{version}.zip'
    receipt=json.loads(archive.with_name(archive.name+'.provenance.json').read_text())
    head=verify_source_commit(receipt)
    expected=source_files();assert verify(archive,expected)==receipt['package_sha256']
    assert receipt['workshop_id']==item and receipt['project_version']==version
    description=(ROOT/'workshop/description.bbcode').read_text(encoding='utf-8')
    note=(ROOT/'docs/WORKSHOP_CHANGELOG.md').read_text(encoding='utf-8')
    assert f'Version {version}' in note and 'https://github.com/B47ANCE/B47ANCEDUI' in description
    stage=ROOT/f'dist/workshop-update-{version}-{head[:12]}'
    assert not stage.exists(),'Preserve prior stage/provenance'
    content=stage/'Contents'
    fields=dict(appid='108600',publishedfileid=item,contentfolder=str(content),visibility='0',title="B47ANCE'd UI",description=description,changenote=note)
    text=submission(fields)
    for directory in receipt['directory_entries']:(content/'mods'/directory).mkdir(parents=True,exist_ok=True)
    for name,data in expected.items():
        path=content/'mods'/name;path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(data)
    actual={p.relative_to(content/'mods').as_posix():p.read_bytes() for p in (content/'mods').rglob('*') if p.is_file()}
    assert actual==expected,'Source/staging mismatch'
    (stage/'description.bbcode').write_text(description,encoding='utf-8',newline='\n')
    (stage/'changenote.txt').write_text(note,encoding='utf-8',newline='\n')
    vdf=stage/'submission.vdf';vdf.write_text(text,encoding='utf-8-sig',newline='\n')
    receipt.update(validation_commit=head,creation_authorized=False,visibility=0,
        description_sha256=hashlib.sha256(description.encode()).hexdigest(),changenote_sha256=hashlib.sha256(note.encode()).hexdigest(),
        submission_sha256=hashlib.sha256(vdf.read_bytes()).hexdigest(),upload='NOT PERFORMED',steam_desktop_restart='NOT PERFORMED')
    (stage/'release-manifest.json').write_text(json.dumps(receipt,indent=2)+'\n')
    print('PASS existing-item stage:',item,version,len(actual),'files; no upload/restart:',stage)
    return stage
if __name__=='__main__':prepare()
