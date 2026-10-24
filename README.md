# B47ANCE'd UI

Development version: 0.10.0-dev.2.

**0.10.0-dev.2** fixes a startup failure found during the authorized dev.1 local test: the native empty-inventory event must be registered through LuaEventManager before subscription. The stricter absent-event regression reproduces the failure and passes after correction. Existing event handlers, API1 and user data are preserved. [Source evidence and test limits](docs/NATIVE_OVERHAUL.md).

The first native overhaul slice adds black inventory/loot chrome, neutral rows, context menus and pooled submenus, item tooltip frames, inventory scrollbars and selected native confirmation dialogs. It follows shared presets and per-player appearance while preserving native item actions, transfers, geometry and semantic colours. This is a compatible MINOR addition; API1 and saved schemas/defaults remain unchanged. **Offline tests pass; native rendering/input is NOT TESTED.** [Exact coverage and runtime checks](docs/NATIVE_OVERHAUL.md).

The current [main-menu and in-game coverage audit](docs/UI_COVERAGE_AUDIT_2026-10-24.md) inventories 61 work areas, 623 installed source candidates and 187 concrete source targets across the curated families. Inventory/context/tooltip/dialog/list adoption is partial; most full frontend/gameplay screens still need adapters. The report lists remaining menus, priorities and exact source/runtime limits. The [previous audit](docs/UI_COVERAGE_AUDIT_2026-10-23.md) remains historical.

Historical development **0.9.0-dev.2** fixes a startup rendering error caused by unsupported global `next()` in the installed Kahlua runtime. Table-presence checks now use a private `pairs()` helper; all behavioral tests run with `next` unavailable. No profile/API/schema change. The local corrected build starts and attaches Options styling without the prior UI exception at observation; full interactive acceptance is pending.

Historical **0.9.0-dev.4** corrected a native dropdown tooltip API mismatch that stopped Options construction. It restores the **Options** categories and search after dropdown dismissal. A section selector and bounded Previous/Next pages keep supported settings inside the window without unnecessary scrollbars or tiny text. Search reveals the original setting on its section/page. Native values, callbacks, controller rows and Apply/save ownership remain unchanged. Crowded category lists use navigation pages; specialized/controller/provider content retains genuine overflow access. Existing page-specific resets remain. [Layout, compatibility and runtime checks](docs/OPTIONS_LAYOUT.md).

The **Interface** category opens **UI Style Presets**, accent/appearance settings and the safe HUD layout workspace. Presets edit supported buttons, menu navigation, sliders, inputs, dropdowns, surfaces, rows, tabs and tooltip frames with shared values and optional per-mod overrides. Duplicate/rename/delete presets, edit hex colors and bounded numeric properties, preview live, then Save or Cancel with unsaved protection. The inspector stays usable while previewing. [Coverage, inheritance, storage and runtime limits](docs/STYLE_PRESETS.md). Native setting controls, callbacks, Apply/Back, display confirmation, key capture and audio rollback remain native. The preceding dev.3 build was deployed but native Options setup failed at an unsupported dropdown tooltip setter. The dev.4 correction passes the stricter native contract offline; post-fix visual/input/controller acceptance is **NOT TESTED**. Workshop distribution is unchanged.

The main-menu **Quit to desktop** confirmation uses the same near-black rounded surfaces and local accent as the rest of UI. Its native Yes/No actions, placement and controller behavior remain intact. [Native confirmation adapter and test limits](docs/NATIVE_MENUS.md).

The HUD editor now uses a fixed input surface above the static previews: click an asset's body to move it or its highlighted edges/corners to resize supported dimensions. Blank canvas clicks are inert. Dropdown selection and Enter no longer save/close the workspace; temporary modal activity preserves drafts. Save commits explicitly; Cancel/Escape use the same Keep editing / Discard changes confirmation as the main-menu editor. Native click routing still needs in-game verification.

**Edit in-game UI** on the main menu opens a black canvas with static previews, as approved by the owner. Move supported HUD assets and resize permitted dimensions before loading a game. Save applies explicit overrides to supported real windows after native construction; clock and moodles are reference-only. Inventory/loot/chat support width and height, mechanics supports height, and fixed-size native assets support position. Unknown mod windows need an explicit public preview/layout provider.

Both layout inspectors now have larger sliders, separate step buttons, numeric percentage fields, edge/corner handles and compact footer spacing. Pending numeric edits commit together and stay with the selected asset; Reset discards them. The main-menu editor keeps F10/controller X access, independent menu/logo geometry, native logo proportions, approved saved defaults and existing profile priority. [Main-menu editor](docs/MENU_LAYOUT_EDITOR.md).

Both layout editors now warn before discarding unsaved changes: Cancel, Escape and controller B open a popup with **Keep editing** selected by default and **Discard changes** as the explicit exit action. Pending/invalid numeric entries and Reset changes count; unchanged/reverted layouts and successful saves close directly. Switching from menu editing to the HUD workspace also waits for confirmation. Native input acceptance is NOT TESTED.

The current 0.10 development addition passes offline tests; native input/controller/HUD acceptance remains **NOT TESTED**. Historical 0.9 dev.2 had a limited startup check and dev.3 failed native Options setup; dev.4 corrected its tooltip API. Workshop remains 0.5.0-dev.11. Historical startup evidence does not validate the current overhaul.

The selected security-room background now extends its horizontal pipe straight across the left wall at the existing height. The published dev.11 automatic layout fitted the logo/menu beneath that pipe and above the baseboard; development defaults now use the independently placed menu and logo saved by the owner. Four genuine transparent CRT screens retain their independent static/no-signal animation. Standard and ultrawide crops are checked offline through 5120x1440; native rendering for dev.11 remains NOT TESTED. Version 0.5.0-dev.11 is published as the authorized Workshop MP testing update. [Selected artwork provenance](docs/MENU_SELECTED_PIPE_PROMPT.md).

Lua-only shared presentation for Project Zomboid Build 42.21. Public client API 1 provides styled native controls, rendering, layout helpers, focus, dialogs, bounded tooltips, per-mod/per-local-player appearance preferences, the appearance editor and original clipboard drawing.

Near-black surfaces, neutral grey accents and restrained rounded corners define the shared style. Opt into `UI.Button.sized('small' / 'normal', ...)` for two font-aware sizes; existing native constructor dimensions are preserved.

The in-game appearance editor offers a `#RRGGBB` field and Red/Green/Blue sliders (0–255), with immediate local preview. Default accent: grey `#B0B0B0`. Settings are isolated per consumer/local player; Reset restores opacity 82 and the grey accent. Existing opacity-only preferences keep their values.

A separate `UI.MenuButton:new(x,y,width,label,target,callback,...)` creates large text navigation for main/pause/Esc-style menus: native Large font, transparent background, no button border and a label-only accent underline on hover/controller focus. It is independent of ordinary Small/Normal controls.

The native adapter applies that style automatically to the native main-menu and in-game Esc-menu navigation when UI is loaded. The adapter retains native labels, localized text, actions, controller order and visibility; the old grey hover rectangle is replaced by accent text and a label-only underline. Native quit cooldown and modal guards remain intact. Appearance uses UI's own local slot 0, with grey as default, separately from Quartermaster. The optional PZ Optimization menu label also uses the shared title style; its live version/update text is centered in a reserved small-text line below its title. Its original action, renderer, status colors, controller glyph and tooltip are retained. Other custom menu renderers remain guarded. See [native menu integration and runtime checks](docs/NATIVE_MENUS.md). Version 0.5.0-dev.11 is published as a Workshop MP testing build; native acceptance remains NOT TESTED.

Quartermaster consumes this library; UI works without Quartermaster, Rooms or PC Framework. Application rows, labels, callbacks, permissions and network/gameplay state belong to consuming mods. No global vanilla class patches or custom Java/JAR dependencies.

Development 0.10.0-dev.2 includes the original security-room main-menu artwork, with dark menu space on the left and four CRT screens on the right. The user-selected room retains its desk and decorations, with the horizontal conduit completed across the left wall at the same height. The wider field of view reframes the desk toward the center-left and retains a quiet left menu column. Filing cabinets, archive boxes, a security noticeboard, keys, intercom and extinguisher furnish the right wall; a shadowed footlocker and vent add detail at the far left. Uniform cover scaling fills 32:9 displays such as 5120x1440; narrow crops focus on the menu/desk group while ultrawide views reveal more right scenery. Each boot creates independent short startup delays and 1-60 seconds of static per monitor, followed by a persistent subdued NO SIGNAL loop. Menu labels scale and stay centered inside the chosen menu rectangle; the logo is placed independently, and visible direct-child menu entries are discovered dynamically and rows refit when mods add, hide or remove them. Standard labels scale; custom renderers retain their own text drawing. These are decorative animations, not live cameras. The Esc background stays native; original menu actions and controller label objects remain. The title screen mutes native music gain at runtime; audible rain/thunder suppression awaits an in-game listening check. See [background design and runtime gates](docs/MENU_BACKGROUND.md).

```lua
local UI=require('B47ANCEDUI/API').requireVersion(1).forMod('MyMod')
local button=UI.Button:new(20,20,160,32,getText('UI_MyMod_Action'),owner,onActivate)
button:initialise()
button:instantiate()
owner:addChild(button)
```

Enable Mod ID `B47ANCEDUI` alongside dependent mods. [Subscribe on Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=3822582242). The public MP testing upload is verified; native SP/dedicated acceptance remains NOT TESTED. [Current publication and source/package provenance](docs/WORKSHOP_PIPE_UPDATE.md). That publication did not deploy locally; the later dev.2 local startup test is historical. Steam was left unchanged after publication by user choice. No fallback artwork was substituted.

This is an extracted shared-UI foundation, **not the complete vanilla UI overhaul**. Main/Esc navigation styling is included in this MP testing build; live CCTV feeds, automatic adoption of arbitrary windows, two finished bundled themes and broad vanilla adapters remain planned; supported HUD layout previews are now implemented in development source. Earlier Java proposals are historical and not current authorization.

Native SP, controller, split-screen, saved settings and dedicated multiplayer acceptance are NOT TESTED. Offline Lua fixtures do not establish game behavior. G6 NOT TESTED; G7/stable G8 BLOCKED for integration acceptance. Version 0.5.0-dev.11 is published on public Workshop item 3822582242. SteamCMD commit-success and exact public description verification passed; see [current publication provenance](docs/WORKSHOP_PIPE_UPDATE.md). Prior [0.5.0-dev.8](docs/WORKSHOP_SECURITY_ROOM_UPDATE.md), [0.3.0-dev.1](docs/WORKSHOP_MENU_UPDATE.md), [0.2.0-dev.3](docs/WORKSHOP_UPDATE.md) and 0.1.0-dev.1 publication evidence remains historical. Steam was left unchanged by explicit user choice.

```sh
python -m pip install -r requirements-dev.txt
python -B scripts/check_versions.py
python -B tests/run_tests.py
```

See [API](docs/API.md), [architecture and migration](docs/ARCHITECTURE.md), [tests and runtime gates](docs/TESTING.md), [source provenance](docs/PROVENANCE.json), [version inventory](docs/VERSIONING.md) and [policy](docs/VERSION_POLICY.md). Source is `src/B47ANCEDUI`; root `VERSION` is canonical. `dist/` and generated `workshop/` are ignored. Host Python/Lupa are test tools, never runtime dependencies.

Original B47ANCE-owned code extracted with explicit owner approval from [Quartermaster](https://github.com/B47ANCE/B47ANCEDQuartermaster) commit `2c1d663dadd68ec1757845ff90e14b6225908904`. No external-mod code/assets copied. Source provenance grants no implied third-party reuse license; no license was invented for the owner.

0.5.0-dev.3 mutes native music runtime gain while the security-room main menu renders; native exit restores the configured gain. Saved preferences and in-game/Esc audio are untouched. Audible storm suppression and audio restoration require runtime listening; NOT TESTED. See docs/MENU_BACKGROUND.md for source evidence and limits.
