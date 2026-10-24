"""Offline Lua 5.1 contracts only; never runs the game or builds packages."""
from pathlib import Path
import sys,subprocess
from lupa.lua51 import LuaRuntime
ROOT=Path(__file__).resolve().parents[1]
subprocess.run([sys.executable,'-B',str(ROOT/'scripts/generate_native_registry.py'),'--check'],check=True)
subprocess.run([sys.executable,'-B',str(ROOT/'scripts/check_native_rollout.py')],check=True)
subprocess.run([sys.executable,'-B',str(ROOT/'scripts/check_versions.py')],check=True)
subprocess.run([sys.executable,'-B',str(ROOT/'scripts/check_source.py')],check=True)
subprocess.run([sys.executable,'-B',str(ROOT/'tests/test_package.py')],check=True)
subprocess.run([sys.executable,'-B',str(ROOT/'tests/test_menu_assets.py')],check=True)
for path in sorted((ROOT/'src').rglob('*.lua')):
    LuaRuntime().execute('assert(loadstring(...))',path.read_text())
print('PASS Lua 5.1 syntax')
def client_runtime():
    runtime=LuaRuntime(unpack_returned_tuples=True)
    runtime.globals().next=None  # Kahlua startup regression: never assume standard next().
    return runtime
lua=client_runtime()
lua.globals().package.path=(ROOT/'src/B47ANCEDUI/42/media/lua/client').as_posix()+'/?.lua;'+lua.globals().package.path
lua.execute((ROOT/'tests/test_api.lua').read_text())
lua.execute((ROOT/'tests/test_theme.lua').read_text())
lua.execute((ROOT/'tests/test_menu.lua').read_text())
lua.execute((ROOT/'tests/test_accent.lua').read_text())
lua.execute((ROOT/'tests/test_native_menus.lua').read_text())
lua.execute((ROOT/'tests/test_menu_background.lua').read_text())
lua.execute((ROOT/'tests/test_menu_status.lua').read_text())
layout=client_runtime()
layout.globals().package.path=(ROOT/'src/B47ANCEDUI/42/media/lua/client').as_posix()+'/?.lua;'+layout.globals().package.path
layout.globals().B47ANCEDUI_FIXTURE_ONLY=True
layout.execute((ROOT/'tests/test_api.lua').read_text())
layout.execute((ROOT/'tests/test_menu_layout.lua').read_text())
layout.execute((ROOT/'tests/test_menu_layout_editor.lua').read_text())
layout.execute((ROOT/'tests/test_ui_workspace.lua').read_text())
layout.execute((ROOT/'tests/test_editor_exit.lua').read_text())
layout.execute((ROOT/'tests/test_hud_editor_input.lua').read_text())
layout.execute((ROOT/'tests/test_style_editor.lua').read_text())
hud=client_runtime()
hud.globals().package.path=(ROOT/'src/B47ANCEDUI/42/media/lua/client').as_posix()+'/?.lua;'+hud.globals().package.path
hud.globals().B47ANCEDUI_FIXTURE_ONLY=True
hud.execute((ROOT/'tests/test_api.lua').read_text())
hud.execute((ROOT/'tests/test_ui_layout.lua').read_text())
hud.execute((ROOT/'tests/test_hud_runtime.lua').read_text())
settings=client_runtime()
settings.globals().package.path=(ROOT/'src/B47ANCEDUI/42/media/lua/client').as_posix()+'/?.lua;'+settings.globals().package.path
settings.globals().B47ANCEDUI_FIXTURE_ONLY=True
settings.execute((ROOT/'tests/test_api.lua').read_text())
settings.execute((ROOT/'tests/test_native_settings.lua').read_text())
options=client_runtime()
options.globals().package.path=(ROOT/'src/B47ANCEDUI/42/media/lua/client').as_posix()+'/?.lua;'+options.globals().package.path
options.globals().B47ANCEDUI_FIXTURE_ONLY=True
options.execute((ROOT/'tests/test_api.lua').read_text())
options.execute((ROOT/'tests/test_options_layout.lua').read_text())
print('Offline only. Native SP/controller/split-screen/dedicated NOT TESTED.')
styles=client_runtime()
styles.globals().package.path=(ROOT/'src/B47ANCEDUI/42/media/lua/client').as_posix()+'/?.lua;'+styles.globals().package.path
styles.globals().B47ANCEDUI_FIXTURE_ONLY=True
styles.execute((ROOT/'tests/test_api.lua').read_text())
styles.execute((ROOT/'tests/test_style_presets.lua').read_text())
native=client_runtime()
native.globals().package.path=(ROOT/'src/B47ANCEDUI/42/media/lua/client').as_posix()+'/?.lua;'+native.globals().package.path
native.globals().B47ANCEDUI_FIXTURE_ONLY=True
native.execute((ROOT/'tests/test_api.lua').read_text())
native.execute((ROOT/'tests/test_native_overhaul.lua').read_text())
existing_event=client_runtime()
existing_event.globals().package.path=native.globals().package.path
existing_event.globals().B47ANCEDUI_FIXTURE_ONLY=True
existing_event.globals().B47ANCEDUI_EMPTY_EVENT_PREEXISTS=True
existing_event.execute((ROOT/'tests/test_api.lua').read_text())
existing_event.execute((ROOT/'tests/test_native_overhaul.lua').read_text())
rollout=client_runtime()
rollout.globals().package.path=native.globals().package.path
rollout.globals().B47ANCEDUI_FIXTURE_ONLY=True
rollout.execute((ROOT/'tests/test_api.lua').read_text())
rollout.execute((ROOT/'tests/test_native_rollout.lua').read_text())
atoms=client_runtime()
atoms.globals().package.path=native.globals().package.path
atoms.globals().B47ANCEDUI_FIXTURE_ONLY=True
atoms.execute((ROOT/'tests/test_api.lua').read_text())
atoms.execute((ROOT/'tests/test_atom_theme.lua').read_text())
