"""Prepare reviewable first-publication draft only. No VDF, login, upload or restart."""
from pathlib import Path
import json,hashlib,subprocess,sys
from build import ROOT,MOD,source_files,verify,verify_source_commit
LABEL='MP testing build - dedicated multiplayer NOT TESTED'
def prepare():
    assert not (ROOT/'WORKSHOP_ID.txt').exists(),'Use the assigned existing-item workflow'
    assert not subprocess.check_output(['git','status','--porcelain'],cwd=ROOT).strip(),'Commit source first'
    version=(ROOT/'VERSION').read_text().strip();archive=ROOT/f'dist/current/{MOD}-{version}.zip'
    receipt=json.loads(archive.with_name(archive.name+'.provenance.json').read_text())
    head=subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip()
    assert verify(archive,source_files())==receipt['package_sha256']
    verify_source_commit(receipt)
    description=(ROOT/'workshop/description.bbcode').read_text(encoding='utf-8')
    note=(ROOT/'docs/WORKSHOP_CHANGELOG.md').read_text(encoding='utf-8')
    assert LABEL in description and LABEL in note and '\\n' not in description+note
    assert f'Version {version}' in note
    stage=ROOT/f'dist/workshop-draft-{version}-{head[:12]}'
    assert not stage.exists(),'Preserve existing staging/evidence'
    expected=source_files();content=stage/'Contents'
    for directory in receipt['directory_entries']:(content/'mods'/directory).mkdir(parents=True,exist_ok=True)
    for name,data in expected.items():
        p=content/'mods'/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(data)
    actual={p.relative_to(content/'mods').as_posix():p.read_bytes() for p in (content/'mods').rglob('*') if p.is_file()}
    assert actual==expected,'Staging parity failed'
    (stage/'description.bbcode').write_text(description,encoding='utf-8',newline='\n')
    (stage/'changenote.txt').write_text(note,encoding='utf-8',newline='\n')
    receipt.update(validation_commit=head,workshop_id=None,creation_authorized=False,upload='BLOCKED: new Workshop item requires explicit authorization',artwork='No default substituted; UI excluded from fallback branding',description_sha256=hashlib.sha256(description.encode()).hexdigest(),changenote_sha256=hashlib.sha256(note.encode()).hexdigest())
    (stage/'release-manifest.json').write_text(json.dumps(receipt,indent=2)+'\n')
    print('DRAFT PARITY PASS',len(expected),'files;',stage)
    print('NO submission VDF generated. New public Workshop item authorization required. No upload performed.')
if __name__=='__main__':prepare()
