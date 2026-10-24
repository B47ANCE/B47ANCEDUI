"""Read-only installed UI source discovery; no Lua execution or runtime proof."""
import argparse
from collections import Counter
from hashlib import sha256
import json
from pathlib import Path
import re
import sys

DERIVE = re.compile(r"""(?m)^[ \t]*([A-Za-z_]\w*)\s*=\s*([A-Za-z_]\w*)\s*[:.]derive\s*\(\s*["']([^"']+)["']""")
PREFIXES = ('ISUI/', 'OptionScreens/', 'DebugUIs/', 'PZAPI/ui/',
            'Entity/ISUI/', 'RadioCom/ISUIRadio/', 'RadioCom/RadioWindowModules/', 'XpSystem/ISUI/')
COMPONENTS = {'ISButton', 'ISPanel', 'ISPanelJoypad', 'ISTabPanel', 'ISComboBox',
              'ISTickBox', 'ISTextEntryBox', 'ISSliderPanel', 'ISVolumeControl', 'ISMegaVolumeControl'}
GEOMETRY = {'ISInventoryPage', 'ISCharacterInfoWindow', 'ISVehicleMechanics',
            'ISEquippedItem', 'ISMiniMapOuter', 'ISHotbar', 'ISChat'}

def discover(game, date, version, build):
    base = game / 'media/lua/client'
    if not base.is_dir() or base.is_symlink():
        raise ValueError('Expected a real installed media/lua/client source directory')
    files, excluded, declarations = {}, [], []
    for path in sorted(base.rglob('*.lua')):
        if path.is_symlink() or any(p.is_symlink() or getattr(p, 'is_junction', lambda: False)() for p in path.parents if p.is_relative_to(base)):
            raise ValueError('Linked source not followed: ' + path.name)
        rel = path.relative_to(base).as_posix()
        if rel.startswith('pzopt/'):
            excluded.append('media/lua/client/' + rel)
            continue
        raw = path.read_bytes()
        text = raw.decode('utf-8-sig', errors='replace')
        defs = [{'name':m[1], 'base':m[2], 'type_name':m[3],
                 'line':text.count('\n',0,m.start())+1} for m in DERIVE.finditer(text)]
        files[rel] = (raw, defs)
        declarations += defs
    ui = {'ISUIElement'}
    while True:
        found = {d['name'] for d in declarations if d['base'] in ui}
        if found <= ui: break
        ui |= found
    entries = []
    for rel, (raw, defs) in files.items():
        ui_defs = [d for d in defs if d['name'] in ui]
        if not ui_defs and not rel.startswith(PREFIXES):
            continue
        names = {d['name'] for d in ui_defs}
        if 'MainOptions' in names: scope = 'partial_options_adapter'
        elif 'MainScreen' in names: scope = 'partial_main_menu_adapter'
        elif 'ISModalDialog' in names: scope = 'selected_frontend_quit_only'
        elif names & COMPONENTS: scope = 'conditional_component_adoption'
        elif names & GEOMETRY: scope = 'geometry_only_not_live_skin'
        elif ui_defs: scope = 'no_global_adoption'
        else: scope = 'support_or_alternate_ui_candidate'
        entries.append({'path':'media/lua/client/'+rel, 'sha256':sha256(raw).hexdigest(),
                        'bytes':len(raw), 'ui_declarations':ui_defs, 'coverage_boundary':scope})
    fingerprint = sha256()
    for entry in entries:
        fingerprint.update(entry['path'].encode()); fingerprint.update(b'\0')
        fingerprint.update(bytes.fromhex(entry['sha256']))
    return {'schema':1, 'audit_date':date, 'game_version':version, 'steam_build':build,
            'status':'VERIFIED installed source inventory only', 'runtime_status':'NOT TESTED',
            'scope':'Installed client Lua: UI inheritance closure plus explicit UI-oriented directories; not a screen count.',
            'provenance_limit':'Existing third-party engine modifications are present. File identity is installed evidence, not pristine distribution certification. Known client/pzopt source is excluded and not analysed.',
            'parser_limit':'Textual derive declarations and directory candidates are discovery leads. Dynamic/engine/PZAPI template creation, support scripts and reachability require the curated work-area inventory. No copied source bodies.',
            'counts':{'inspected_client_lua_files':len(files), 'excluded_known_provider_files':len(excluded),
                      'ui_candidate_files':len(entries), 'ui_declarations':sum(len(e['ui_declarations']) for e in entries),
                      'boundaries':dict(sorted(Counter(e['coverage_boundary'] for e in entries).items()))},
            'source_digest':fingerprint.hexdigest(), 'excluded_paths':excluded, 'files':entries}

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--game-root',type=Path,required=True)
    parser.add_argument('--audit-date',required=True)
    parser.add_argument('--game-version',required=True)
    parser.add_argument('--steam-build',required=True)
    mode=parser.add_mutually_exclusive_group(required=True)
    mode.add_argument('--write',type=Path)
    mode.add_argument('--check',type=Path)
    args=parser.parse_args()
    data=discover(args.game_root.resolve(),args.audit_date,args.game_version,args.steam_build)
    if args.check:
        if json.loads(args.check.read_text(encoding='utf-8'))!=data:
            raise ValueError('Installed source catalogue differs from recorded snapshot')
        print('PASS catalogue fingerprints/counts/classification match recorded installed sources')
    else:
        if args.write.resolve().is_relative_to(args.game_root.resolve()):
            raise ValueError('Catalogue output must stay outside the game installation')
        args.write.write_text(json.dumps(data,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
    print(json.dumps(data['counts'],sort_keys=True))

if __name__=='__main__':
    try: main()
    except (ValueError,OSError) as error:
        print('FAIL:',error,file=sys.stderr);sys.exit(1)
