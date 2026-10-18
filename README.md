# B47ANCE'd UI

Development version: 0.5.0-dev.2.

Lua-only shared presentation for Project Zomboid Build 42.21. Public client API 1 provides styled native controls, rendering, layout helpers, focus, dialogs, bounded tooltips, per-mod/per-local-player appearance preferences, the appearance editor and original clipboard drawing.

Near-black surfaces, neutral grey accents and restrained rounded corners define the shared style. Opt into `UI.Button.sized('small' / 'normal', ...)` for two font-aware sizes; existing native constructor dimensions are preserved.

The in-game appearance editor offers a `#RRGGBB` field and Red/Green/Blue sliders (0–255), with immediate local preview. Default accent: grey `#B0B0B0`. Settings are isolated per consumer/local player; Reset restores opacity 82 and the grey accent. Existing opacity-only preferences keep their values.

A separate `UI.MenuButton:new(x,y,width,label,target,callback,...)` creates large text navigation for main/pause/Esc-style menus: native Large font, transparent background, no button border and a label-only accent underline on hover/controller focus. It is independent of ordinary Small/Normal controls.

The native adapter applies that style automatically to the native main-menu and in-game Esc-menu navigation when UI is loaded. The adapter retains native labels, localized text, actions, controller order and visibility; the old grey hover rectangle is replaced by accent text and a label-only underline. Native quit cooldown and modal guards remain intact. Appearance uses UI's own local slot 0, with grey as default, separately from Quartermaster. Other menu mods may conflict or cause guarded items to remain native. See [native menu integration and runtime checks](docs/NATIVE_MENUS.md). This iteration is not deployed or published.

Quartermaster consumes this library; UI works without Quartermaster, Rooms or PC Framework. Application rows, labels, callbacks, permissions and network/gameplay state belong to consuming mods. No global vanilla class patches or custom Java/JAR dependencies.

Development 0.5.0-dev.2 includes the original security-room main-menu artwork, with dark menu space on the left and four CRT screens on the right. Each boot creates independent short startup delays and 1-60 seconds of static per monitor, followed by a persistent subdued NO SIGNAL loop. Menu labels are enlarged and centered beneath the logo; visible direct-child menu entries are discovered dynamically and rows refit when mods add, hide or remove them. Standard labels scale; custom renderers retain their own text drawing. These are decorative animations, not live cameras. The Esc background stays native; original menu actions and controller label objects remain. See [background design and runtime gates](docs/MENU_BACKGROUND.md).

```lua
local UI=require('B47ANCEDUI/API').requireVersion(1).forMod('MyMod')
local button=UI.Button:new(20,20,160,32,getText('UI_MyMod_Action'),owner,onActivate)
button:initialise()
button:instantiate()
owner:addChild(button)
```

Enable Mod ID `B47ANCEDUI` alongside dependent mods. [Subscribe on Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=3822582242). The public MP testing upload is verified; native SP/dedicated acceptance remains NOT TESTED. [Publication and source/package provenance](docs/WORKSHOP_PUBLICATION.md). No new deployment or Steam restart is performed by this iteration. No fallback artwork was substituted.

This is an extracted shared-UI foundation, **not the complete vanilla UI overhaul**. Main/Esc navigation styling is implemented in development source; live CCTV feeds, the full layout editor, two finished themes and broad vanilla adapters remain planned. Earlier Java proposals are historical and not current authorization.

Native SP, controller, split-screen, saved settings and dedicated multiplayer acceptance are NOT TESTED. Offline Lua fixtures do not establish game behavior. G6 NOT TESTED; G7/stable G8 BLOCKED for integration acceptance. Version 0.3.0-dev.1 is published on public Workshop item 3822582242. SteamCMD commit-success and exact public description verification passed; see [current publication provenance](docs/WORKSHOP_MENU_UPDATE.md). Prior [0.2.0-dev.3](docs/WORKSHOP_UPDATE.md) and 0.1.0-dev.1 publication evidence remains historical. Steam desktop was not restarted for this upload.

```sh
python -m pip install -r requirements-dev.txt
python -B scripts/check_versions.py
python -B tests/run_tests.py
```

See [API](docs/API.md), [architecture and migration](docs/ARCHITECTURE.md), [tests and runtime gates](docs/TESTING.md), [source provenance](docs/PROVENANCE.json), [version inventory](docs/VERSIONING.md) and [policy](docs/VERSION_POLICY.md). Source is `src/B47ANCEDUI`; root `VERSION` is canonical. `dist/` and generated `workshop/` are ignored. Host Python/Lupa are test tools, never runtime dependencies.

Original B47ANCE-owned code extracted with explicit owner approval from [Quartermaster](https://github.com/B47ANCE/B47ANCEDQuartermaster) commit `2c1d663dadd68ec1757845ff90e14b6225908904`. No external-mod code/assets copied. Source provenance grants no implied third-party reuse license; no license was invented for the owner.
