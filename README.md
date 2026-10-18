# B47ANCE'd UI

Development version: 0.1.0-dev.1.

Lua-only shared presentation for Project Zomboid Build 42.21. Public client API 1 provides styled native controls, rendering, layout helpers, focus, dialogs, bounded tooltips, per-mod/per-local-player appearance preferences, the appearance editor and original clipboard drawing.

Quartermaster consumes this library; UI works without Quartermaster, Rooms or PC Framework. Application rows, labels, callbacks, permissions and network/gameplay state belong to consuming mods. No global vanilla class patches or custom Java/JAR dependencies.

```lua
local UI=require('B47ANCEDUI/API').requireVersion(1).forMod('MyMod')
local button=UI.Button:new(20,20,160,32,getText('UI_MyMod_Action'),owner,onActivate)
button:initialise()
button:instantiate()
owner:addChild(button)
```

Enable Mod ID `B47ANCEDUI` alongside dependent mods. No Workshop item is assigned or published; use source in the established B42 layout for separately authorized local testing. This iteration is not deployed. No artwork is invented or substituted.

This is an extracted shared-UI foundation, **not the complete vanilla UI overhaul**. Main-menu replacement/CCTV, the full layout editor, two finished themes and broad vanilla adapters remain planned and are not implemented here. Earlier Java proposals are historical and not current authorization.

Native SP, controller, split-screen, saved settings and dedicated multiplayer acceptance are NOT TESTED. Offline Lua fixtures do not establish game behavior. G6 NOT TESTED; G7/stable G8 BLOCKED for integration acceptance. No package/deploy/Workshop upload.

```sh
python -m pip install -r requirements-dev.txt
python -B scripts/check_versions.py
python -B tests/run_tests.py
```

See [API](docs/API.md), [architecture and migration](docs/ARCHITECTURE.md), [tests and runtime gates](docs/TESTING.md), [source provenance](docs/PROVENANCE.json), [version inventory](docs/VERSIONING.md) and [policy](docs/VERSION_POLICY.md). Source is `src/B47ANCEDUI`; root `VERSION` is canonical. `dist/` is generated/ignored; no package generated. Host Python/Lupa are test tools, never runtime dependencies.

Original B47ANCE-owned code extracted with explicit owner approval from [Quartermaster](https://github.com/B47ANCE/B47ANCEDQuartermaster) commit `2c1d663dadd68ec1757845ff90e14b6225908904`. No external-mod code/assets copied. Source provenance grants no implied third-party reuse license; no license was invented for the owner.
