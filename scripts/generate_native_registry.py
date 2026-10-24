"""Generate names/inheritance only from the frozen installed-source inventory.

Never import, execute or copy installed game function bodies.
"""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'docs/UI_SOURCE_CATALOG_2026-10-24.json'
TARGET = ROOT / 'src/B47ANCEDUI/42/media/lua/client/B47ANCEDUI/NativeRegistry.lua'


def render():
    catalog = json.loads(SOURCE.read_text(encoding='utf-8'))
    entries = []
    for file in catalog['files']:
        for declaration in file['ui_declarations']:
            if declaration.get('type_name') and declaration['type_name'] != 'UNKNOWN':
                entries.append((declaration['name'], declaration['type_name'], declaration['base']))
    lines = ['-- Generated names/inheritance, not game source. See scripts/generate_native_registry.py.',
             '-- Installed Build 42.21.0; provenance and limits: docs/NATIVE_ROLLOUT.md.', 'return {']
    for entry in sorted(set(entries)):
        lines.append(' {' + ','.join(json.dumps(value) for value in entry) + '},')
    return '\n'.join(lines + ['}', ''])


if __name__ == '__main__':
    import sys
    text = render()
    if '--check' in sys.argv:
        assert TARGET.read_text(encoding='utf-8') == text, 'Native registry drift'
        print('PASS native registry matches frozen installed-source declarations')
    else:
        TARGET.write_text(text, encoding='utf-8')
