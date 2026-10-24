# UI coverage audit and remaining inventory

Audit date: 2026-10-23. Observed project version: **0.9.0-dev.4**, source **7c452b86a43f26af2457f330d3d9fe9aab835b7e**. Installed game: **42.21.0**, revision **4a0e9546ec**, Steam build **25485521**.

This is a dated source audit, not a new visual implementation or runtime acceptance report. The current branch and its upstream matched, with a clean tree at intake (0 ahead/behind upstream; 13 ahead/0 behind main). A read-only comparison still finds 68/68 deployed runtime files matching this source. Existing PZ Optimization engine overrides are present; installed-source fingerprints do not certify a pristine vanilla distribution. No game/server launch, deployment, publication or gameplay change is part of this audit. Canonical version stays 0.9.0-dev.4.

## Main finding

**The shared UI library is not yet a whole-game reskin.** Automatic adapters reach main/Esc navigation, the strict frontend Quit confirmation and supported native Options widgets/layout. Shared API controls/styles require an owned/adopted instance or consumer opt-in. A preset family name does not prove every native widget in that family is adopted.

The HUD editor contains 10 static samples. Eight targets have explicit native geometry bindings: inventory, loot, character window, mechanics, equipment, minimap, hotbar and chat. Inventory/loot/chat can resize supported dimensions; mechanics supports height only; fixed native assets keep their dimensions. Clock and moodles are references only. These bindings do not change live HUD visuals and currently skip controller-player layouts.

There are **61 grouped work areas** below: 8 current implementation scopes plus 53 cross-cutting, screen-family, specialist, integration and engine-boundary areas. Rows overlap by component; they are not 61 independent screens. No percentage-complete estimate is justified.

The installed-source catalogue contains **622 UI-related candidate files**, including **576 textual UI class declarations**. It inspected 727 client Lua files after excluding 11 known client/pzopt files. Of the 622 candidates, 457 have UI declarations with no global adoption by this project, 145 are support/alternate-framework candidates, 10 are conditionally adopted component files, 7 hold geometry-only classes, and 3 relate to the partial main-menu/Options/selected-Quit adapters. These are file classifications, not counts of unfinished player-facing windows. Some files are helpers, diagnostics, prototypes or inactive paths.

## What is already in source

| Area | Existing work | Still required |
|---|---|---|
| Main menu | Security-room artwork/CRT animation, menu navigation, independent logo/menu layout | Native visual/input/audio acceptance across sizes and mod-added entries |
| Esc menu | Navigation text/hover/focus adapter | Real pause acceptance; leave-game and other dialogs are separate |
| Frontend Quit | Strict native dialog/button skin | Actual Yes/No/controller/cooldown acceptance |
| Options | Adopted root/control palettes, section/page/search/sidebar shell, Interface page | Dev.4 acceptance; specialized key/controller/provider internals and semantic swatches remain guarded |
| Editors/presets | Owned main-menu/HUD/appearance/style tools, unsaved guard and supported component tokens | Native pointer/controller/large-font/file-roundtrip acceptance |
| HUD | Static preview samples and eight geometry targets | Live skins, additional assets and controller/split-screen layouts |
| Consumer API | Factories, renderer, dialog/focus/tooltip/layout/style helpers | Explicit per-consumer adoption; arbitrary mod UIs are not auto-converted |

## Recommended order

| Priority | Work package | Completion criteria |
|---|---|---|
| P0 validation | Finish acceptance of Options, native dialogs and current editors | User-visible fit; all categories/settings reachable; no UI stack traces; Save/Cancel/Escape/dropdown/controller/display/audio rollback verified |
| P1 foundation | Context menus, rich/item tooltips, dialog families, scrollbar/list/tab/picker adapters; inventory/loot/equipment/chat | Consistent black/grey visuals and editable supported tokens, with native actions/values/semantic colors and hit areas preserved |
| P2 frequent workflows | Character/health, maps, crafting/building/entities, mechanics/vehicle controls, fluids, new/load/character/MP setup; PZAPI strategy | Every family has an explicit adapter scope and native acceptance matrix; gameplay ownership unchanged |
| P3 remaining workflows | Mods/Workshop adjuncts, radio, farming/fishing/animals/appliances/media/tutorial/social tools | All identified panels/popups in the family audited; custom/engine renderers identified instead of silently skipped |
| P4 specialist/boundary | Admin/debug utilities and engine/platform-only portions | Opt-in coverage where supported; documented Lua-only alternatives or explicit unsupported limits |

P1/P2 are sequencing recommendations, not authorization to implement them. A screen-specific priority appears below; broad package names include later adjuncts. Controller and split-screen acceptance cuts across every package.

## Evidence and limitations

[VERIFIED: source] NativeSettings adoption is restricted to its owned MainOptions root and a verified widget whitelist. Unknown/custom renderers and subtrees are deliberately refused; live color swatches preserve data colors. OptionsLayout card-reflows recognized scalar pages, retaining fallback internals for specialized/provider/oversized content. NativeMenus separately guards the exact frontend Quit dialog. Controls/API factories are opt-in. HUDLayoutRuntime applies geometry only. The machine inventory records portable paths, line anchors and SHA256 fingerprints for these findings.

[TESTED: offline] The current dev.4 regression suite passed, including the stricter Combo tooltip-map contract and contained-page fixtures. The dev.3 source was actually deployed and failed at unsupported ISComboBox.setTooltip; dev.4 fixes that call through native setToolTipMap after clear. Earlier offline passes did not prove engine compatibility.

[Historical runtime observation] The dev.4 session log contains styling=true/interface=true and no observed UI exception traces at audit intake. This is not proof of final Options pixels, every click, native setting persistence, file reload, controller or split-screen behavior. Those acceptance gates remain NOT TESTED. Prior failure evidence is preserved in TESTING.md and OPTIONS_LAYOUT_SOURCE.json; it is not silently upgraded.

[UNKNOWN / RUNTIME GATE] Textual source discovery does not establish active screen reachability, dynamic providers, every Java-owned UI layer, all PZAPI templates or every possible generated sandbox/recipe/item control. No installed external-mod repository or Workshop source was reviewed; known provider source is excluded. Unattributed installed files are discovery facts rather than permission to reuse implementation. New family work must verify provenance and current exposed Lua APIs. No game code, assets, source bodies or private logs are copied into this audit.

Engine-backed item tooltip content, radial menus/progress, maps, avatar models and vehicle gauges require separate exposed-Lua/API/asset audits. A black enclosing panel does not replace ObjectTooltip, RadialMenu, RadialProgressBar, UIWorldMap, UI3DModel or VehicleGauge internals. Clock/moodles and platform overlays cannot be declared implemented from editor rectangles. Never substitute custom Java.

The current handcraft/build/entity layers are the relevant Build42 crafting UI. ISCraftingUI.lua now contains helper functions and should not be mistaken for the active old crafting screen. Newer PZAPI FishWindow and PrintMedia use a different atom/template framework and need their own adoption route.

## Inventory

Status describes project source reachability. **Every row still has native acceptance work**; rows marked no adoption/geometry/reference/boundary require new visual or integration implementation. Full evidence for each row, including source hashes, is in UI_COVERAGE_INVENTORY_2026-10-23.json.

### Current scopes

| ID / priority | Surface | Current coverage | Remaining action |
|---|---|---|---|
| C01 / P0 validation | Main menu navigation and security-room scene | Scoped implementation; acceptance pending | Validate dynamic entries, logo/menu placement, boot loops, audio restoration and 4:3/16:9/32:9; ancillary frontend controls are separate. |
| C02 / P0 validation | Esc/pause navigation | Partial adoption | Verify native pause navigation and controller actions; in-game leave/quit confirmations and other pause panels still need explicit adapters. |
| C03 / P0 validation | Frontend Quit to desktop confirmation | Scoped implementation; acceptance pending | Accept native Yes/No, cooldown, controller focus and real quit behavior; only the strict frontend dialog is adopted. |
| C04 / P0 validation | Native Options and Interface page | Partial adoption | Accept dev.4 section pages/sidebar/search and all setting actions. Keybinding/controller/provider internals retain fallback layouts; color swatches retain semantic colors. |
| C05 / P0 validation | Main-menu layout editor | Scoped implementation; acceptance pending | Validate native drag/resize, sliders/fields, Save/Reset/Cancel, unsaved warning and reload at multiple sizes/fonts/controllers. |
| C06 / P0 validation | HUD preview/layout editor | Static preview + geometry only | Validate direct hit/resize and popup/unsaved exits. Ten samples are static; only eight native asset targets have geometry bindings. Add real skins independently. |
| C07 / P0 validation | Style preset and accent/appearance editors | Scoped implementation; acceptance pending | Validate all supported component previews, per-mod inheritance, pending fields, file reload, Save failures, controller and unsaved exits. |
| C08 / P0 validation | Shared API controls, dialogs and managed tooltip helpers | Consumer opt-in only | Confirm consumer opt-in and native method contracts. These helpers do not globally adopt vanilla controls or arbitrary mod renderers. |

### Shared components

| ID / priority | Surface | Current coverage | Remaining action |
|---|---|---|---|
| X01 / P1 | Native confirmations, warnings and text-entry dialogs beyond frontend Quit | No project-wide adoption found | Add guarded dialog-family adapters for display/restart, leave-game, save/delete, password/text entry and key capture; preserve native actions/modal ownership. |
| X02 / P1 | World/item/container context menus and submenus | No project-wide adoption found | Style nested frames/rows, hover/disabled/checked states, icons, scrolling and controller navigation without changing actions or permissions. |
| X03 / P1 | Item, rich, world-object and container tooltips | No project-wide adoption found | Adopt tooltip families explicitly; preserve item stats/rich text/semantic colors and engine ObjectTooltip content. Managed helper frames are not global coverage. |
| X04 / P1 | Native scrollbars, scrolling panels and clipping | No project-wide adoption found | Define matching track/thumb/hover/focus visuals and minimum hit areas for genuinely overflowing windows; removing Options bars is not a global scrollbar theme. |
| X05 / P1 | Lists, tables, trees and column headers | No project-wide adoption found | Build explicit adapters for rows/alternation/selection/headers/sorting/expansion; bespoke doDrawItem and native renderer paths need their own contracts. |
| X06 / P1 | Native tabs, check/radio controls, color pickers and popups outside Options | Partial adoption | Extend verified family coverage outside the owned Options root; preserve color meaning and shared-popup restore/ownership. |
| X07 / P1 | Typography, density, icon states and preset coverage | Partial adoption | Decide supported font/spacing/density/layout tokens, safe bounds and per-family adoption; current color/radius/stroke/slider presets do not configure every visual property or asset. |

### Frontend

| ID / priority | Surface | Current coverage | Remaining action |
|---|---|---|---|
| F01 / P3 | Solo mode, difficulty and challenge selection | No project-wide adoption found | Redesign screen panels, challenge cards/lists, descriptions and action buttons while retaining native flow. |
| F02 / P2 | Load/save browser and saved-game configuration | No project-wide adoption found | Theme save lists, details/mod panels, configuration/delete warnings and loading actions. |
| F03 / P2 | World/map and spawn selection | No project-wide adoption found | Theme region lists/map preview/seed controls and navigation; preserve map data and selection. |
| F04 / P2 | Sandbox settings and presets | No project-wide adoption found | Adopt dynamic native setting factories, preset dialogs, category navigation and validation; shared gameplay values remain native/server owned. |
| F05 / P2 | Character identity, clothing and avatar creation | No project-wide adoption found | Theme forms, selectors, appearance controls and layout around the native model viewport; audit UI3DModel separately. |
| F06 / P2 | Occupation and traits | No project-wide adoption found | Theme profession/trait lists, points, descriptions and selection states without changing balance or validation. |
| F07 / P2 | Multiplayer server browser | No project-wide adoption found | Theme server rows/details/favorites/filters/actions and error states; preserve discovery/network behavior. |
| F08 / P2 | Connection, bootstrap, progress and error popups | No project-wide adoption found | Theme connection/password/progress/error/return states; do not replace connection logic. |
| F09 / P2 | Host/local-coop setup | No project-wide adoption found | Theme host profiles/start controls and cooperative setup; preserve server startup actions and confirmations. |
| F10 / P2 | Server configuration editor | No project-wide adoption found | Audit every native settings group/list/tooltip, presets and validation; UI skinning must not redefine authoritative settings. |
| F11 / P2 | Mod manager, mod presets and missing-mod warnings | No project-wide adoption found | Theme mod list/details/search/presets, map-order/missing-dependency adjuncts and activation warnings; preserve enable/load-order behavior. |
| F12 / P3 | Server Workshop dependency installation | No project-wide adoption found | Theme dependency lists, download/progress/retry states and confirmations without changing subscriptions. |
| F13 / P3 | Workshop submission/update wizard | No project-wide adoption found | Theme wizard forms, preview selection and status/errors; retain native submission behavior and confirmation. |
| F14 / P3 | Credits, Terms/legal, help/report and ancillary entry controls | No project-wide adoption found | Theme owned text/button frames and standalone screens; retain legal text, report links and original actions. |
| F15 / P3 | Steam invitations and scoreboard | No project-wide adoption found | Theme Lua invitations/player lists and actions; the Steam platform overlay is a separate engine boundary. |
| F16 / P2 | Local-player/cooperative character join flow | No project-wide adoption found | Adopt username/avatar/profession/spawn/join screens with independent player/controller focus ownership. |
| F17 / P3 | Advanced sound browser | No project-wide adoption found | Theme the separate sound/debug browser rather than assuming native Options root adoption reaches it. |

### Gameplay

| ID / priority | Surface | Current coverage | Remaining action |
|---|---|---|---|
| G01 / P1 | Live inventory and loot windows | Geometry only; live skin outstanding | Theme window chrome, rows/columns, item categories, capacity/search/filter, container buttons, selection, transfer and drag/drop; retain item actions and quantities. |
| G02 / P2 | Character, skills, health, protection, insulation, fitness and garment panels | Geometry only; live skin outstanding | Theme every inner tab/body diagram/skill bar/state and auxiliary fitness/tailoring/makeup dialog; moving the outer window does not skin these. |
| G03 / P1 | Equipment and hotbar | Geometry only; live skin outstanding | Theme live slots, equip/attach indicators, selection/hovers and prompts; preserve item rendering and hotkey/controller behavior. |
| G04 / P2 | Clock/watch and moodles/status indicators | Reference only; API audit needed | Audit available exposed engine/Lua drawing and movement routes; static editor references are not editable bindings or a completed skin. |
| G05 / P1 | Chat | Geometry only; live skin outstanding | Theme native tabs/channel colors/input/history/scroll/mentions/size states while retaining chat behavior and moderation semantics. |
| G06 / P2 | Minimap, world/paper maps, symbols, legends and sharing | Geometry only; live skin outstanding | Theme toolbars/frames/annotations/sharing/symbol pickers; minimap positioning does not redesign engine UIWorldMap content. |
| G07 / P2 | Build42 handcraft and recipe UI | No project-wide adoption found | Theme current handcraft windows plus recipe/filter/list/ingredient/tool/output widgets. Do not target the legacy ISCraftingUI helper as the active screen. |
| G08 / P2 | Building, placement and moveable controls | No project-wide adoption found | Theme current build recipe windows, headers, placement controls, cursor help and moveable tooltips; preserve placement intent and server validation. |
| G09 / P2 | Entities and crafting workstations | No project-wide adoption found | Theme entity/tab windows and craft-bench/logic component panels with data-driven custom widget coverage. |
| G10 / P2 | Vehicle mechanics | Geometry only; live skin outstanding | Theme part tree, inspection/details, body diagram, lists and action feedback. Existing override supports height only and is not visual adoption. |
| G11 / P2 | Vehicle dashboard, seats, climate, lightbar and radial controls | No project-wide adoption found | Theme Lua panels/prompt states and audit native gauges/radials independently; preserve vehicle functions and input mapping. |
| G12 / P3 | Radio, television and recorded media | No project-wide adoption found | Theme radio-window modules, frequency/presets/media controls, decorative sliders/knobs and metadata; preserve tuning/playback logic. |
| G13 / P2 | Foraging, search and tracking overlays | No project-wide adoption found | Theme search/zone panels, world-item hints/icons and tracking help without changing discovery results. |
| G14 / P3 | Fishing and newer PZAPI fish window | No project-wide adoption found | Theme tension/activity feedback and the distinct PZAPI organism/template window; classic ISPanel adoption alone is insufficient. |
| G15 / P3 | Animals, designation zones, hutches, tracks and butchering | No project-wide adoption found | Theme animal details/lists/actions, zone editing, hutch and vehicle-animal panels; preserve native animal management and authority. |
| G16 / P3 | Farming and plant information | No project-wide adoption found | Theme crop/health/water/state panels and farming context feedback without changing farming values or commands. |
| G17 / P2 | Fluid transfer and container information | No project-wide adoption found | Theme composition/bars/transfer quantities, selectors and warnings; preserve meaningful fluid colors and authoritative transfer logic. |
| G18 / P3 | Appliances, heating, generator and BBQ information | No project-wide adoption found | Theme oven/microwave controls and power/fuel/temperature/information windows with native timers/ranges and warnings intact. |
| G19 / P3 | Literature, journals, notes and printed media | No project-wide adoption found | Theme reading/writing/print panels and newer PZAPI PrintMedia templates; preserve text entry, paging, content and document actions. |
| G20 / P2 | Alarm, sleeping and post-death/respawn UI | No project-wide adoption found | Theme timers/dialogs/overlays/respawn actions while preserving safe defaults and game-state transitions; audit engine-rendered portions separately. |
| G21 / P3 | Player tools, factions, safehouses, tickets, trading and wars | No project-wide adoption found | Theme ordinary multiplayer player panels/lists/invites/confirmations, retaining all permissions and server-owned actions. |
| G22 / P3 | Tutorial, survival help and focus overlays | No project-wide adoption found | Theme instruction panels, highlighted targets and help navigation without changing tutorial sequencing or player input lock. |
| G23 / P2 | Timed-action progress, radials and transient HUD feedback | Engine/Lua boundary audit needed | Inventory exposed draw/asset controls and explicit Lua-only alternatives for engine-backed progress/radial renderers; do not infer coverage from preview rectangles. |

### Specialist

| ID / priority | Surface | Current coverage | Remaining action |
|---|---|---|---|
| A01 / P4 | Administration and player/server management | No project-wide adoption found | Theme admin/item/server/sandbox/role/zone/player-stat panels separately; preserve access levels, permissions and server validation. |
| A02 / P4 | Debug and developer tools | No project-wide adoption found | Catalogue opt-in debug windows and avoid applying aggressive global skins to custom diagnostic renderers. |
| A03 / P1 | Controller, split-screen, on-screen keyboard and reconnect UI | No project-wide adoption found | Validate separate player viewports/focus, glyphs, on-screen keyboard, controller test/bindings and disconnected states. Current HUD geometry intentionally skips controller players. |

### Integration

| ID / priority | Surface | Current coverage | Remaining action |
|---|---|---|---|
| I01 / P2 | Newer PZAPI atoms, templates and organisms | No project-wide adoption found | Plan explicit PZAPI adapters/token contracts separately from ISUI; use fish/printed-media surfaces as scoped acceptance cases. |
| I02 / P3 | Consuming mods and arbitrary provider UI | Provider integration needed | Audit B47ANCE consumers individually through the public API; record provider ownership and permissions before adding overrides. Arbitrary external mod windows do not auto-convert; no external-mod source was inspected in this audit. |

### Engine boundary

| ID / priority | Surface | Current coverage | Remaining action |
|---|---|---|---|
| E01 / P4 | Boot/logo/loading layers, native renderer internals and platform overlays | Engine/Lua boundary audit needed | Separate Lua-owned chrome from UI3DModel/ObjectTooltip/UIWorldMap/RadialMenu/VehicleGauge and Steam overlay internals. Record unsupported capabilities and propose exposed-Lua/asset alternatives; never custom Java. |

## Validation and repeatable source discovery

The scanner reads installed Lua text, filenames and hashes without loading Lua, the game, Java classes, mods or user profiles. Curated work areas are reviewed source conclusions; the scanner does not infer a completed redesign or automate adoption.

```powershell
python -X utf8 -B scripts/check_versions.py
python -X utf8 -B tests/run_tests.py
git diff --check
python -X utf8 -B scripts/audit_ui_inventory.py --game-root <verified-installed-game-root> --audit-date 2026-10-23 --game-version 42.21.0 --steam-build 25485521 --check docs/UI_SOURCE_CATALOG_2026-10-23.json
```

The catalogue command PASS means the recorded fingerprints/counts/classification still match that installation. It does not certify the installation, native rendering/input, Linux, SP gameplay or dedicated multiplayer. New changes are documentation and read-only audit tooling only; runtime files/API1/schemas/defaults/version are unchanged. G6 remains NOT TESTED; project G7/stable G8 remain BLOCKED.

Files: readable report (this document), structured work areas (UI_COVERAGE_INVENTORY_2026-10-23.json), installed candidate catalogue (UI_SOURCE_CATALOG_2026-10-23.json), and scripts/audit_ui_inventory.py. Dated snapshots retain their observed date/version/commit when future project versions change.
