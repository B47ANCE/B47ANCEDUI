"""Offline Lua 5.1 contracts only; never runs the game or builds packages."""
from pathlib import Path
import sys,subprocess
from lupa.lua51 import LuaRuntime
ROOT=Path(__file__).resolve().parents[1]
subprocess.run([sys.executable,'-B',str(ROOT/'scripts/check_versions.py')],check=True)
subprocess.run([sys.executable,'-B',str(ROOT/'scripts/check_source.py')],check=True)
for path in sorted((ROOT/'src').rglob('*.lua')):
    LuaRuntime().execute('assert(loadstring(...))',path.read_text())
print('PASS Lua 5.1 syntax')
lua=LuaRuntime(unpack_returned_tuples=True)
lua.globals().package.path=(ROOT/'src/B47ANCEDUI/42/media/lua/client').as_posix()+'/?.lua;'+lua.globals().package.path
lua.execute((ROOT/'tests/test_api.lua').read_text())
print('Offline only. Native SP/controller/split-screen/dedicated NOT TESTED.')
