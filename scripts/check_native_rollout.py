"""Check reviewed rollout/source bindings; no game execution or file writes."""
from pathlib import Path
import argparse
import hashlib
import json
from generate_native_registry import render

ROOT = Path(__file__).resolve().parents[1]


def digest(path, project_text=False):
    data = path.read_bytes()
    if project_text and path.suffix in {'.lua','.json','.info'}:
        data = data.replace(b'\r\n',b'\n')
    return hashlib.sha256(data).hexdigest()


def check(game_root=None):
    source = json.loads((ROOT/'docs/NATIVE_ROLLOUT_SOURCE.json').read_text(encoding='utf-8'))
    coverage = json.loads((ROOT/'docs/NATIVE_ROLLOUT_COVERAGE.json').read_text(encoding='utf-8'))
    version = (ROOT/'VERSION').read_text().strip()
    assert source['project_version'] == coverage['project_version'] == version
    assert source['runtime_acceptance'] == coverage['runtime_acceptance'] == 'NOT TESTED'
    runtime = ROOT/'src/B47ANCEDUI'
    assert source['project_hash_format'] == 'SHA256; .lua/.json/.info CRLF normalized to LF; binary exact bytes'
    files = {p.relative_to(ROOT).as_posix(): digest(p,True) for p in runtime.rglob('*') if p.is_file()}
    assert files == source['project_fingerprints'], 'Rollout source changed; review/rebind evidence'
    catalog = json.loads((ROOT/'docs/UI_SOURCE_CATALOG_2026-10-24.json').read_text())
    known = {item['path']: item['sha256'] for item in catalog['files']}
    for evidence in source['installed_contracts']:
        assert evidence['path'].startswith('media/lua/client/') and '..' not in Path(evidence['path']).parts
        if evidence['catalogued']:
            assert known[evidence['path']] == evidence['sha256'], evidence['path']
        assert evidence['lines'] and all(isinstance(n, int) and n > 0 for n in evidence['lines'])
        if game_root:
            path = (game_root/evidence['path']).resolve()
            assert path.is_relative_to(game_root.resolve())
            assert digest(path) == evidence['sha256'], 'Installed contract drift: '+evidence['path']
            assert max(evidence['lines']) <= len(path.read_text(encoding='utf-8-sig').splitlines())
    old = json.loads((ROOT/'docs/UI_COVERAGE_INVENTORY_2026-10-24.json').read_text())
    assert [(a['id'],a['title']) for a in coverage['areas']] == [(a['id'],a['title']) for a in old['areas']]
    assert len(coverage['areas']) == 61
    assert coverage['counts']['native_lua_declarations'] == 591
    assert coverage['counts']['separate_pzapi_templates'] == 16
    assert (runtime/'42/media/lua/client/B47ANCEDUI/NativeRegistry.lua').read_text() == render()
    for area in coverage['areas']:
        assert area['route'] and area['limits'] and area['runtime_acceptance'] == 'NOT TESTED'
    print('PASS rollout bindings: 76 runtime files, 61 reviewed areas; native acceptance NOT TESTED')
    if game_root:
        print('PASS exact installed contract hashes/line bounds; source inspection only')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--game-root', type=Path)
    args = parser.parse_args()
    check(args.game_root)
