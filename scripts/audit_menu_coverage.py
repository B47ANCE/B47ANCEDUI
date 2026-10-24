"""Read-only menu discovery with an explicit, source-bound coverage review.

The legacy scanner's dev.4 coverage labels are never used as current coverage.
No game/Lua execution, profile access, external-mod analysis or deployment.
"""
import argparse
from collections import Counter
from hashlib import sha256
import json
from pathlib import Path, PurePosixPath
import re
import sys

from audit_ui_inventory import discover

ROOT = Path(__file__).resolve().parents[1]
QUALIFIED_DERIVE = re.compile(r'''(?m)^[ \t]*([A-Za-z_]\w*(?:\.[A-Za-z_]\w*)+)\s*=\s*([A-Za-z_]\w*(?:\.[A-Za-z_]\w*)*)\s*:\s*derive\s*\(\s*["']([^"']+)["']''')
TEMPLATE = re.compile(r'''(?m)^[ \t]*(UI\.[A-Za-z_]\w*(?:\.[A-Za-z_]\w*)*)\s*=\s*(UI\.[A-Za-z_]\w*)\s*\{''')


def relative_file(root, name):
    rel = PurePosixPath(name)
    if rel.is_absolute() or '..' in rel.parts or '\\' in name or ':' in name:
        raise ValueError('Expected portable relative evidence path')
    path = root / name
    if not path.resolve().is_relative_to(root.resolve()):
        raise ValueError('Evidence path escaped its root')
    if any(p.is_symlink() or getattr(p, 'is_junction', lambda: False)()
           for p in (path, *path.parents) if p.is_relative_to(root)):
        raise ValueError('Linked evidence is not followed')
    return path


def catalog(game, rules):
    # Bind the reviewed classifications to their exact project source. A future
    # version or changed runtime requires a new review, never an automatic PASS.
    if (ROOT / 'VERSION').read_text().strip() != rules['project_version_observed']:
        raise ValueError('Project version changed since this coverage review')
    expected = {'src/B47ANCEDUI/' + name for name in json.loads(
        (ROOT / 'scripts/production-files.json').read_text())}
    if set(rules['project_fingerprints']) != expected:
        raise ValueError('Coverage bindings must include the exact runtime inventory')
    for name, digest in rules['project_fingerprints'].items():
        if sha256(relative_file(ROOT, name).read_bytes()).hexdigest() != digest:
            raise ValueError('Project source changed since review: ' + name)
    data = discover(game, rules['audit_date'], rules['game_version'], rules['steam_build'])
    data['counts']['simple_derive_declarations'] = data['counts']['ui_declarations']
    # The old textual scanner misses Fishing.ISTensionUI-style declarations
    # and PZAPI's UI.FishWindow = UI.Window{...} composition. Index these as
    # source candidates, never as proof of runtime reachability/adoption.
    entries = {e['path']: e for e in data['files']}
    known = {'ISUIElement'} | {d['name'] for e in entries.values() for d in e['ui_declarations']}
    pending = []
    for path in sorted((game / 'media/lua/client').rglob('*.lua')):
        rel = path.relative_to(game).as_posix()
        if rel.startswith('media/lua/client/pzopt/'):
            continue
        raw = relative_file(game, rel).read_bytes()
        source = raw.decode('utf-8-sig', errors='replace')
        for match in QUALIFIED_DERIVE.finditer(source):
            pending.append((rel, raw, dict(name=match[1], base=match[2], type_name=match[3],
                line=source.count('\n', 0, match.start()) + 1, discovery='qualified_derive')))
        for match in TEMPLATE.finditer(source):
            pending.append((rel, raw, dict(name=match[1], base=match[2], type_name='UNKNOWN',
                line=source.count('\n', 0, match.start()) + 1, discovery='ui_template')))
    while pending:
        remaining = []
        for rel, raw, declaration in pending:
            if declaration['base'] not in known and not declaration['base'].startswith('UI.'):
                remaining.append((rel, raw, declaration))
                continue
            known.add(declaration['name'])
            entry = entries.setdefault(rel, dict(path=rel, sha256=sha256(raw).hexdigest(),
                bytes=len(raw), ui_declarations=[]))
            entry['ui_declarations'].append(declaration)
        if len(remaining) == len(pending):
            break
        pending = remaining
    data['files'] = [entries[key] for key in sorted(entries)]
    data['counts']['ui_candidate_files'] = len(data['files'])
    data['counts']['ui_declarations'] = sum(len(e['ui_declarations']) for e in data['files'])
    data['counts']['additional_qualified_or_template_declarations'] = sum(
        'discovery' in d for e in data['files'] for d in e['ui_declarations'])
    data['counts']['qualified_derive_declarations'] = sum(
        d.get('discovery') == 'qualified_derive' for e in data['files'] for d in e['ui_declarations'])
    data['counts']['named_ui_template_definitions'] = sum(
        d.get('discovery') == 'ui_template' for e in data['files'] for d in e['ui_declarations'])
    fingerprint = sha256()
    for entry in data['files']:
        fingerprint.update(entry['path'].encode()); fingerprint.update(b'\0')
        fingerprint.update(bytes.fromhex(entry['sha256']))
    data['source_digest'] = fingerprint.hexdigest()
    data['scope'] = 'Installed client Lua: simple/qualified UI inheritance, named UI templates and explicit UI directories. Candidates are not independent active screens.'
    data['parser_limit'] = 'Simple/qualified derive declarations plus UI.* template assignments and UI directories. Candidates include support/inactive/nested panels; dynamic/engine routes still require curated review. No copied source bodies.'
    by_class = rules['class_boundaries']
    for entry in data['files']:
        # A class can have guarded instances only. It is never globally styled
        # merely because a file declares it or another class derives from it.
        entry['coverage_targets'] = [
            {'class': d['name'], 'line': d['line'], **by_class[d['name']]}
            for d in entry['ui_declarations'] if d['name'] in by_class
        ]
        boundaries = {t['boundary'] for t in entry['coverage_targets']}
        if boundaries - {'geometry_only'}:
            entry['coverage_boundary'] = 'contains_scoped_or_conditional_targets'
        elif boundaries:
            entry['coverage_boundary'] = 'contains_geometry_only_targets'
        elif entry['ui_declarations']:
            entry['coverage_boundary'] = 'no_automatic_adoption_found'
        else:
            entry['coverage_boundary'] = 'support_or_alternate_ui_candidate'
    data['counts']['boundaries'] = dict(sorted(Counter(
        e['coverage_boundary'] for e in data['files']).items()))
    data.update(
        project_version_observed=rules['project_version_observed'],
        project_source_commit=rules['project_source_commit'],
        coverage_rules='UI_COVERAGE_RULES_2026-10-24.json',
        coverage_limit='Reviewed guarded instance/routes only. File/class counts are not screens or completion percentages. No runtime acceptance inferred.',
    )
    return data


def check_areas(game, data, installed_catalog):
    if data['project_version_observed'] != (ROOT / 'VERSION').read_text().strip():
        raise ValueError('Area inventory project version differs')
    ids = set()
    for area in data['areas']:
        if area['id'] in ids:
            raise ValueError('Duplicate work-area id')
        ids.add(area['id'])
        for evidence in area['evidence']:
            if evidence['kind'] not in {'installed_source', 'project_source'}:
                raise ValueError('Unknown evidence kind')
            base = game if evidence['kind'] == 'installed_source' else ROOT
            path = relative_file(base, evidence['path'])
            if sha256(path.read_bytes()).hexdigest() != evidence['sha256']:
                raise ValueError('Changed area evidence: ' + evidence['path'])
            if not 1 <= evidence['line'] <= len(path.read_text(encoding='utf-8-sig').splitlines()):
                raise ValueError('Invalid evidence line: ' + evidence['path'])
        for target in area.get('menu_targets', []):
            source = installed_catalog[target['path']]
            if not any(d['name'] == target['class'] and d['line'] == target['line']
                       for d in source['ui_declarations']):
                raise ValueError('Menu target no longer matches its declaration')
    if len(ids) != data['counts']['work_areas']:
        raise ValueError('Area count differs')
    counts = {
        'by_group': dict(Counter(a['group'] for a in data['areas'])),
        'by_coverage': dict(Counter(a['source_coverage'] for a in data['areas'])),
        'by_priority': dict(Counter(a['priority'] for a in data['areas'])),
        'distinct_evidence_files': len({(e['kind'], e['path']) for a in data['areas'] for e in a['evidence']}),
        'distinct_candidate_targets': len({(t['path'], t['class'], t['line']) for a in data['areas'] for t in a.get('menu_targets', [])}),
    }
    if any(data['counts'][key] != value for key, value in counts.items()):
        raise ValueError('Curated inventory counts differ')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--game-root', type=Path, required=True)
    parser.add_argument('--rules', type=Path, required=True)
    parser.add_argument('--areas', type=Path)
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument('--write', type=Path)
    mode.add_argument('--check', type=Path)
    args = parser.parse_args()
    game = args.game_root.resolve()
    rules = json.loads(args.rules.read_text(encoding='utf-8'))
    data = catalog(game, rules)
    if args.check:
        if json.loads(args.check.read_text(encoding='utf-8')) != data:
            raise ValueError('Source/coverage catalogue differs from recorded review')
    else:
        requested = args.write if args.write.is_absolute() else ROOT / args.write
        if not requested.resolve().is_relative_to(ROOT):
            raise ValueError('Output must stay inside the project')
        destination = relative_file(ROOT, requested.relative_to(ROOT).as_posix())
        if destination.resolve().is_relative_to(game):
            raise ValueError('Output must stay outside installed game')
        destination.write_text(json.dumps(data, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')
    if args.areas:
        check_areas(game, json.loads(args.areas.read_text(encoding='utf-8')),
                    {e['path']: e for e in data['files']})
    print('PASS source-bound menu catalogue' + (' and work-area evidence/targets' if args.areas else ''))
    print(json.dumps(data['counts'], sort_keys=True))


if __name__ == '__main__':
    try:
        main()
    except (ValueError, OSError, KeyError, TypeError) as error:
        print('FAIL:', error, file=sys.stderr)
        sys.exit(1)
