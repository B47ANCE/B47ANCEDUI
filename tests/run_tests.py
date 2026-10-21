"""Offline Lua 5.1 contracts only; never runs the game or builds packages."""
from pathlib import Path
import sys,subprocess
from lupa.lua51 import LuaRuntime
ROOT=Path(__file__).resolve().parents[1]
subprocess.run([sys.executable,'-B',str(ROOT/'scripts/check_versions.py')],check=True)
subprocess.run([sys.executable,'-B',str(ROOT/'scripts/check_source.py')],check=True)
subprocess.run([sys.executable,'-B',str(ROOT/'tests/test_package.py')],check=True)
subprocess.run([sys.executable,'-B',str(ROOT/'tests/test_menu_assets.py')],check=True)
for path in sorted((ROOT/'src').rglob('*.lua')):
    LuaRuntime().execute('assert(loadstring(...))',path.read_text())
print('PASS Lua 5.1 syntax')
lua=LuaRuntime(unpack_returned_tuples=True)
lua.globals().package.path=(ROOT/'src/B47ANCEDUI/42/media/lua/client').as_posix()+'/?.lua;'+lua.globals().package.path
lua.execute((ROOT/'tests/test_api.lua').read_text())
lua.execute((ROOT/'tests/test_theme.lua').read_text())
lua.execute((ROOT/'tests/test_menu.lua').read_text())
lua.execute((ROOT/'tests/test_accent.lua').read_text())
lua.execute((ROOT/'tests/test_native_menus.lua').read_text())
lua.execute((ROOT/'tests/test_menu_background.lua').read_text())
lua.execute((ROOT/'tests/test_menu_status.lua').read_text())
layout=LuaRuntime(unpack_returned_tuples=True)
layout.globals().package.path=(ROOT/'src/B47ANCEDUI/42/media/lua/client').as_posix()+'/?.lua;'+layout.globals().package.path
layout.globals().B47ANCEDUI_FIXTURE_ONLY=True
layout.execute((ROOT/'tests/test_api.lua').read_text())
layout.execute((ROOT/'tests/test_menu_layout.lua').read_text())
layout.execute((ROOT/'tests/test_menu_layout_editor.lua').read_text())
layout.execute((ROOT/'tests/test_ui_workspace.lua').read_text())
layout.execute((ROOT/'tests/test_editor_exit.lua').read_text())
hud=LuaRuntime(unpack_returned_tuples=True)
hud.globals().package.path=(ROOT/'src/B47ANCEDUI/42/media/lua/client').as_posix()+'/?.lua;'+hud.globals().package.path
hud.globals().B47ANCEDUI_FIXTURE_ONLY=True
hud.execute((ROOT/'tests/test_api.lua').read_text())
hud.execute((ROOT/'tests/test_ui_layout.lua').read_text())
hud.execute((ROOT/'tests/test_hud_runtime.lua').read_text())
settings=LuaRuntime(unpack_returned_tuples=True)
settings.globals().package.path=(ROOT/'src/B47ANCEDUI/42/media/lua/client').as_posix()+'/?.lua;'+settings.globals().package.path
settings.globals().B47ANCEDUI_FIXTURE_ONLY=True
settings.execute((ROOT/'tests/test_api.lua').read_text())
settings.execute((ROOT/'tests/test_native_settings.lua').read_text())
print('Offline only. Native SP/controller/split-screen/dedicated NOT TESTED.')
