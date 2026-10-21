"""Read-only source inventory, Lua-only, case and translation checks."""
from pathlib import Path
import hashlib,json,re
ROOT=Path(__file__).resolve().parents[1]
SOURCE=ROOT/'src/B47ANCEDUI'
def validate():
    files={p.relative_to(SOURCE).as_posix():p for p in SOURCE.rglob('*') if p.is_file()}
    expected=json.loads((ROOT/'scripts/production-files.json').read_text())
    assert set(files)==set(expected),'Source inventory drift'
    assert len(files)==len({n.lower() for n in files}),'Case collision'
    for name in files:
        assert '..' not in Path(name).parts and not name.startswith('/')
        assert files[name].suffix in {'.lua','.json','.info','.png'},name
    info=(SOURCE/'42/mod.info').read_text()
    assert 'id=B47ANCEDUI\n' in info and 'require=' not in info
    keys=set()
    for p in (SOURCE/'42/media/lua/client').rglob('*.lua'):
        text=p.read_text()
        for prohibited in ('B47ANCEDQuartermaster','UI_QMSS_','sendClientCommand','sendServerCommand','ModData','getSpecificPlayer'):
            assert prohibited not in text,(p,prohibited)
        for required in re.findall(r"require\s*\(?\s*['\"](B47ANCEDUI/[^'\"]+)",text):
            assert (SOURCE/'42/media/lua/client'/f'{required}.lua').is_file(),required
        keys.update(re.findall(r"getText\(['\"](UI_B47ANCEDUI_[^'\"]+)",text))
    translations=SOURCE/'42/media/lua/shared/Translate'
    english=json.loads((translations/'EN/UI.json').read_text())
    # AppearanceEditor's concatenated prefix is explicitly enumerated.
    keys.update('UI_B47ANCEDUI_'+k for k in ('ResetAppearance','Close','WindowOpacity','AccentHex','Red','Green','Blue','InvalidHex','SaveFailed'))
    # MenuLayoutEditor's concatenated keys use explicit English fallback in all locales.
    keys.update('UI_B47ANCEDUI_'+k for k in ('EditMenuLayout', 'LayoutTitle', 'LayoutMenu', 'LayoutLogo', 'LayoutX', 'LayoutY', 'LayoutWidth', 'LayoutHeight', 'LayoutSave', 'LayoutCancel', 'LayoutReset', 'LayoutHelp', 'LayoutKeys', 'LayoutAspect', 'LayoutSaveFailed', 'LayoutShortcut'))
    # Owned editor/workspace prefixes: explicit English fallback, not translated claims.
    keys.update('UI_B47ANCEDUI_'+k for k in ('InvalidPercent', 'InterfaceTab', 'InterfaceTitle', 'InterfaceAppearance', 'InterfaceLocalNotice', 'InterfaceEditorNotice', 'InterfaceMenuOnly', 'EditInGameUI', 'HudEditorTitle', 'HudPreviewNotice', 'HudProperties', 'HudPropertiesHelp', 'ResetHudOverrides', 'LayoutFuture', 'HudReferenceOnly', 'HudResizeHelp', 'HudMoveOnly', 'HudOverridesNotice', 'PreviewUnavailable', 'SampleContent', 'AssetInventory', 'AssetLoot', 'AssetCharacter', 'AssetMechanics', 'AssetChat', 'AssetEquipment', 'AssetHotbar', 'AssetMinimap', 'AssetClock', 'AssetMoodles'))
    assert set(english)==keys,(set(english),keys)
    locales=[]
    for p in translations.glob('*/UI.json'):
        data=json.loads(p.read_text());assert set(data)==keys and all(isinstance(v,str) and v for v in data.values()),p
        locales.append(p.parent.name)
    assert set(locales)==set(json.loads((ROOT/'SOURCE_INVENTORY.json').read_text())['locales'])
    print(f'PASS source inventory {len(files)} files; Lua-only; require case; {len(keys)} keys across {len(locales)} locales (English fallback, unreviewed translations)')
    return files
if __name__=='__main__': validate()
