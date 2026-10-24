# Main-menu and in-game UI coverage audit

Audit date: **2026-10-24**. Observed project **0.10.0-dev.2**, runtime source **b69932929acdd3589aabd5053f977ae4d9f59385**. Installed game **42.21.0 / revision 4a0e9546ec / Steam 25485521**. This is a source audit and backlog, not another UI implementation or native acceptance pass.

Most full native screens still need the new UI. Existing source covers main/Esc navigation, selected Options/confirmation flows and owned editors. The first gameplay slice adds parts of live inventory/loot and reached context/tooltip frames; it does not automatically redesign other menus that happen to contain native buttons.

## Inventory and evidence

- **61 grouped work areas:** 8 current scopes, 7 shared families, 17 frontend, 23 gameplay, 3 specialist, 2 integration and 1 engine boundary. Groups overlap; these are not 61 independent screens or a completion percentage.
- **623 UI-related installed source candidates /607 textual UI definitions**, discovered from 727 client Lua files after excluding 11 known provider files. The full searchable catalogue includes nested panels/support files and inactive/alternate candidates. It does not prove every candidate is a reachable menu.
- The curated work areas bind **169 distinct source files** and **187 source targets** with portable hashes/line anchors. Nested targets now explicitly include challenge-player selection, spawn seed/list/info panels, co-op setup/character variants, mod presets/info/help, controller recovery and animal tracking.
- Source coverage counts: 4 implemented scopes, 10 partial scopes, 1 preview/geometry workspace, 1 API opt-in scope, 36 families without broad visual adoption, 5 geometry-only families, 1 reference-only family, 2 engine audits and 1 provider opt-in boundary. Each partial family retains substantial unfinished work. No source category implies native visual/input PASS.

[Structured work-area inventory](UI_COVERAGE_INVENTORY_2026-10-24.json) contains every row's source evidence, current scope and concrete declaration targets. [Full source catalogue](UI_SOURCE_CATALOG_2026-10-24.json) lists all 623 candidates. [Coverage rules](UI_COVERAGE_RULES_2026-10-24.json) bind these reviewed instance/routes to exact project fingerprints. The older 2026-10-23 audit remains unchanged as historical evidence.

Discovery now also recognizes qualified declarations (such as `Fishing.ISTensionUI`) and named PZAPI templates (`UI.FishWindow = UI.Window{...}`). This adds 1 file and 31 definitions over the older 622-file/576-definition method: 15 qualified derive declarations and 16 named templates. Nested child assignments are not counted as named types. The old snapshot remains unchanged; counts changed because discovery expanded.

## What changed since the previous audit

| Area | Current automatic scope | Still missing |
|---|---|---|
| Inventory/loot | Current player inventory/loot chrome, neutral detail rows, native headers/container/action buttons and vertical scrollbar palette | Whole-screen visual acceptance, remaining content and all native transfer/drag/drop/controller states |
| Context menus | Event-observed world/item/empty-container roots and discovered pooled native submenus | Guaranteed fresh-session adoption through other entry routes, custom subclasses/renderers and input acceptance |
| Tooltips | Existing native generic/item frames reached through adopted contexts or live inventory panes | Other creation routes/custom types; ObjectTooltip stats/content stay native |
| Confirmations | Frontend Quit, exact Options unsaved/display-change confirmations and inventory information modal | Restart, leave-game, save/delete, text/password entry, key capture and other dialog routes |
| Shared lists/scrolling | Inventory detail rows/headers and existing inventory vertical bar palette | General lists/trees/tables/bespoke rows; horizontal bars and other windows' vertical bars |

`ISContextMenu.get` reuses each player's root. Once our adapter observes/adopts it, later inventory-filter/chat gear reuse can retain the skin. Therefore those routes are conditional, not universally unstyled and not guaranteed from a fresh session. See installed `ISContextMenu.lua:1166–1196`, `ISInventoryPane.lua:191`, and `ISChat.lua:246` in the structured evidence. This lifetime needs explicit runtime acceptance.

The native inventory skin considers all four player slots and carries an explicit preset player context; it preserves controller input. Separately, HUD geometry overrides still skip controller players. Neither fact styles the on-screen keyboard, disconnected-controller UI or controller binding/test panels.

## Recommended order

1. **P0 acceptance:** verify current main-menu/logo saved/default placement and source version, Options/sidebar/search/Apply, editors/unsaved prompts, inventory/loot, contexts/tooltips, display rollback and controller/split-screen. Startup markers alone do not establish these.
2. **P1 shared foundations:** finish dialog/text-entry, context entry routes, tooltip ownership, scrolling/list/tree/header and remaining control-family adapters. Reuse guarded instance patterns; preserve actions, permissions and semantic colours.
3. **P1 composite screens:** character/health/skills, equipment/hotbar, chat, maps, handcraft/build/workstations, mechanics and fluid transfer. These are frequent player interfaces; outer geometry changes do not count as a skin.
4. **P2 frontend:** saves, world/spawn, sandbox, character/traits, server browser/connect/host/settings, mod manager and dependency download. Advanced sound, publishing/social/legal panels can follow.
5. **P2 gameplay:** vehicle dashboard/seats/climate, radio/media, foraging/tracking, fishing/animals/farming, appliances, reading/writing, sleep/death and player tools. Specialist admin/debug and native/PZAPI renderer contracts remain separate passes.

Priorities are implementation-planning judgements, not engine facts or user approval to implement/release them. The tables below retain all 61 work areas; the JSON carries explicit per-family scope and native source targets.

## Current scopes

| ID / priority | Menu or UI family | Current source coverage | Remaining work |
|---|---|---|---|
| C01 / P0 validation | Main menu navigation and security-room scene | Implemented scope; validate | Validate actual positions/profile persistence and loaded source identity, all dynamic entries, audio restoration, boot loops and4:3/16:9/32:9. |
| C02 / P0 validation | Esc/pause navigation | Partial; more work | Verify native pause navigation and controller actions; in-game leave/quit confirmations and other pause panels still need explicit adapters. |
| C03 / P0 validation | Frontend Quit to desktop confirmation | Implemented scope; validate | Accept native Yes/No, cooldown, controller focus and real quit behavior; only the strict frontend dialog is adopted. |
| C04 / P0 validation | Native Options and Interface page | Partial; more work | Accept sidebar/search, section navigation, all native setting actions, Apply/save, display rollback and specialized panel overflow. |
| C05 / P0 validation | Main-menu layout editor | Implemented scope; validate | Validate native drag/resize, sliders/fields, Save/Reset/Cancel, unsaved warning and reload at multiple sizes/fonts/controllers. |
| C06 / P0 validation | HUD preview/layout editor | Static previews + geometry | Validate direct hit/resize and popup/unsaved exits. Ten samples are static; only eight native asset targets have geometry bindings. Add real skins independently. |
| C07 / P0 validation | Style preset and accent/appearance editors | Implemented scope; validate | Validate all supported component previews, per-mod inheritance, pending fields, file reload, Save failures, controller and unsaved exits. |
| C08 / P0 validation | Shared API controls, dialogs and managed tooltip helpers | API opt-in only | Confirm consumer opt-in and native method contracts. These helpers do not globally adopt vanilla controls or arbitrary mod renderers. |

## Shared components

| ID / priority | Menu or UI family | Current source coverage | Remaining work |
|---|---|---|---|
| X01 / P1 | Native confirmations, warnings and text-entry dialogs beyond frontend Quit | Partial; more work | Add restart, text/password entry, leave-game, save/delete, key capture and other dialog routes; retain actions, focus and modal ownership. |
| X02 / P1 | World/item/container context menus and submenus | Partial; more work | Validate pooled/native root reuse and controller/scroll/disabled semantics; cover remaining entry routes from a fresh session without assuming class-wide conversion. |
| X03 / P1 | Item, rich, world-object and container tooltips | Partial; more work | Audit other generic/world/moveable/custom tooltip routes and ownership/lifetime; preserve engine item content and measurement. |
| X04 / P1 | Native scrollbars, scrolling panels and clipping | Partial; more work | Cover horizontal bars, other screens vertical bars and scroll panels with native clipping, focus and accessible hit areas retained. |
| X05 / P1 | Lists, tables, trees and column headers | Partial; more work | Theme general scrolling lists, tables/trees, sorting/expansion and screen-specific doDrawItem renderers independently. |
| X06 / P1 | Native tabs, check/radio controls, color pickers and popups outside Options | Partial; more work | Add radio controls, spinboxes, pickers, rich content, generic progress/LCD/knob/image controls and other screen routes while preserving semantic swatches. |
| X07 / P1 | Typography, density, icon states and preset coverage | Partial; more work | Decide supported font/spacing/density/layout tokens, safe bounds and per-family adoption; current color/radius/stroke/slider presets do not configure every visual property or asset. |

## Frontend

| ID / priority | Menu or UI family | Current source coverage | Remaining work |
|---|---|---|---|
| F01 / P2 | Solo mode, difficulty and challenge selection | Needs visual adapter | Redesign screen panels, challenge cards/lists, descriptions and action buttons while retaining native flow. |
| F02 / P2 | Load/save browser and saved-game configuration | Needs visual adapter | Theme save lists, details/mod panels, configuration/delete warnings and loading actions. |
| F03 / P2 | World/map and spawn selection | Needs visual adapter | Theme region lists/map preview/seed controls and navigation; preserve map data and selection. |
| F04 / P2 | Sandbox settings and presets | Needs visual adapter | Adopt dynamic native setting factories, preset dialogs, category navigation and validation; shared gameplay values remain native/server owned. |
| F05 / P2 | Character identity, clothing and avatar creation | Needs visual adapter | Theme forms, selectors, appearance controls and layout around the native model viewport; audit UI3DModel separately. |
| F06 / P2 | Occupation and traits | Needs visual adapter | Theme profession/trait lists, points, descriptions and selection states without changing balance or validation. |
| F07 / P2 | Multiplayer server browser | Needs visual adapter | Theme server rows/details/favorites/filters/actions and error states; preserve discovery/network behavior. |
| F08 / P2 | Connection, bootstrap, progress and error popups | Needs visual adapter | Theme connection/password/progress/error/return states; do not replace connection logic. |
| F09 / P2 | Host/local-coop setup | Needs visual adapter | Theme host profiles/start controls and cooperative setup; preserve server startup actions and confirmations. |
| F10 / P2 | Server configuration editor | Needs visual adapter | Audit every native settings group/list/tooltip, presets and validation; UI skinning must not redefine authoritative settings. |
| F11 / P2 | Mod manager, mod presets and missing-mod warnings | Needs visual adapter | Theme mod list/details/search/presets, map-order/missing-dependency adjuncts and activation warnings; preserve enable/load-order behavior. |
| F12 / P3 | Server Workshop dependency installation | Needs visual adapter | Theme dependency lists, download/progress/retry states and confirmations without changing subscriptions. |
| F13 / P3 | Workshop submission/update wizard | Needs visual adapter | Theme wizard forms, preview selection and status/errors; retain native submission behavior and confirmation. |
| F14 / P3 | Credits, Terms/legal, help/report and ancillary entry controls | Needs visual adapter | Theme owned text/button frames and standalone screens; retain legal text, report links and original actions. |
| F15 / P3 | Steam invitations and scoreboard | Needs visual adapter | Theme Lua invitations/player lists and actions; the Steam platform overlay is a separate engine boundary. |
| F16 / P2 | Local-player/cooperative character join flow | Needs visual adapter | Adopt username/avatar/profession/spawn/join screens with independent player/controller focus ownership. |
| F17 / P3 | Advanced sound browser | Needs visual adapter | Theme the separate sound/debug browser rather than assuming native Options root adoption reaches it. |

## Gameplay

| ID / priority | Menu or UI family | Current source coverage | Remaining work |
|---|---|---|---|
| G01 / P1 | Live inventory and loot windows | Partial; more work | Accept live inventory and loot scrolling, all buttons/pooled bags, rejected drops/heat/progress/blink, search/filter, item tooltips, transfers/drag-drop and controller/split-screen; redesign remaining content only through explicit contracts. |
| G02 / P1 | Character, skills, health, protection, insulation, fitness and garment panels | Geometry only; needs skin | Theme every inner tab/body diagram/skill bar/state and auxiliary fitness/tailoring/makeup dialog; moving the outer window does not skin these. |
| G03 / P1 | Equipment and hotbar | Geometry only; needs skin | Theme live slots, equip/attach indicators, selection/hovers and prompts; preserve item rendering and hotkey/controller behavior. |
| G04 / P2 | Clock/watch and moodles/status indicators | Reference only | Audit available exposed engine/Lua drawing and movement routes; static editor references are not editable bindings or a completed skin. |
| G05 / P1 | Chat | Geometry only; needs skin | Theme native tabs/channel colors/input/history/scroll/mentions/size states while retaining chat behavior and moderation semantics. |
| G06 / P1 | Minimap, world/paper maps, symbols, legends and sharing | Geometry only; needs skin | Theme toolbars/frames/annotations/sharing/symbol pickers; minimap positioning does not redesign engine UIWorldMap content. |
| G07 / P1 | Build42 handcraft and recipe UI | Needs visual adapter | Theme current handcraft windows plus recipe/filter/list/ingredient/tool/output widgets. Do not target the legacy ISCraftingUI helper as the active screen. |
| G08 / P1 | Building, placement and moveable controls | Needs visual adapter | Theme current build recipe windows, headers, placement controls, cursor help and moveable tooltips; preserve placement intent and server validation. |
| G09 / P1 | Entities and crafting workstations | Needs visual adapter | Theme entity/tab windows and craft-bench/logic component panels with data-driven custom widget coverage. |
| G10 / P1 | Vehicle mechanics | Geometry only; needs skin | Theme part tree, inspection/details, body diagram, lists and action feedback. Existing override supports height only and is not visual adoption. |
| G11 / P2 | Vehicle dashboard, seats, climate, lightbar and radial controls | Needs visual adapter | Theme Lua panels/prompt states and audit native gauges/radials independently; preserve vehicle functions and input mapping. |
| G12 / P2 | Radio, television and recorded media | Needs visual adapter | Theme radio-window modules, frequency/presets/media controls, decorative sliders/knobs and metadata; preserve tuning/playback logic. |
| G13 / P2 | Foraging, search and tracking overlays | Needs visual adapter | Theme search/zone panels, world-item hints/icons and tracking help without changing discovery results. |
| G14 / P2 | Fishing and newer PZAPI fish window | Needs visual adapter | Theme tension/activity feedback and the distinct PZAPI organism/template window; classic ISPanel adoption alone is insufficient. |
| G15 / P2 | Animals, designation zones, hutches, tracks and butchering | Needs visual adapter | Theme animal details/lists/actions, zone editing, hutch and vehicle-animal panels; preserve native animal management and authority. |
| G16 / P2 | Farming and plant information | Needs visual adapter | Theme crop/health/water/state panels and farming context feedback without changing farming values or commands. |
| G17 / P1 | Fluid transfer and container information | Needs visual adapter | Theme composition/bars/transfer quantities, selectors and warnings; preserve meaningful fluid colors and authoritative transfer logic. |
| G18 / P2 | Appliances, heating, generator and BBQ information | Needs visual adapter | Theme oven/microwave controls and power/fuel/temperature/information windows with native timers/ranges and warnings intact. |
| G19 / P2 | Literature, journals, notes and printed media | Needs visual adapter | Theme reading/writing/print panels and newer PZAPI PrintMedia templates; preserve text entry, paging, content and document actions. |
| G20 / P2 | Alarm, sleeping and post-death/respawn UI | Needs visual adapter | Theme timers/dialogs/overlays/respawn actions while preserving safe defaults and game-state transitions; audit engine-rendered portions separately. |
| G21 / P2 | Player tools, factions, safehouses, tickets, trading and wars | Needs visual adapter | Theme ordinary multiplayer player panels/lists/invites/confirmations, retaining all permissions and server-owned actions. |
| G22 / P2 | Tutorial, survival help and focus overlays | Needs visual adapter | Theme instruction panels, highlighted targets and help navigation without changing tutorial sequencing or player input lock. |
| G23 / P2 | Timed-action progress, radials and transient HUD feedback | Lua/engine API audit needed | Inventory exposed draw/asset controls and explicit Lua-only alternatives for engine-backed progress/radial renderers; do not infer coverage from preview rectangles. |

## Specialist

| ID / priority | Menu or UI family | Current source coverage | Remaining work |
|---|---|---|---|
| A01 / P4 | Administration and player/server management | Needs visual adapter | Theme admin/item/server/sandbox/role/zone/player-stat panels separately; preserve access levels, permissions and server validation. |
| A02 / P4 | Debug and developer tools | Needs visual adapter | Catalogue opt-in debug windows and avoid applying aggressive global skins to custom diagnostic renderers. |
| A03 / P1 | Controller, split-screen, on-screen keyboard and reconnect UI | Needs visual adapter | Validate inventory skin separately for controller/split-screen, then adopt specialized controller/keyboard/reconnect panels. Do not infer their coverage from generic Options styling. |

## Integration

| ID / priority | Menu or UI family | Current source coverage | Remaining work |
|---|---|---|---|
| I01 / P2 | Newer PZAPI atoms, templates and organisms | Needs visual adapter | Plan explicit PZAPI adapters/token contracts separately from ISUI; use fish/printed-media surfaces as scoped acceptance cases. |
| I02 / P3 | Consuming mods and arbitrary provider UI | Provider opt-in boundary | Audit B47ANCE consumers individually through the public API; record provider ownership and permissions before adding overrides. Arbitrary external mod windows do not auto-convert; no external-mod source was inspected in this audit. |

## Engine boundary

| ID / priority | Menu or UI family | Current source coverage | Remaining work |
|---|---|---|---|
| E01 / P4 | Boot/logo/loading layers, native renderer internals and platform overlays | Lua/engine API audit needed | Separate Lua-owned chrome from UI3DModel/ObjectTooltip/UIWorldMap/RadialMenu/VehicleGauge and Steam overlay internals. Record unsupported capabilities and propose exposed-Lua/asset alternatives; never custom Java. |
## Concrete frontend and gameplay targets

These are source declaration candidates within the curated families, not independent active-screen counts. The JSON records exact paths/lines/hashes; source helpers and nested panels may share a window. The register includes named PZAPI templates as well as Lua class declarations. Frontend Options includes Display/Performance, UI, Audio, Key Bindings, Accessibility, Controller, Multiplayer, conditional native Mods settings and the new Interface page. Its frame/whitelist does not establish a complete skin of each specialized section.

### Frontend source-target register

| Area | Native source targets |
|---|---|
| F01 Solo mode, difficulty and challenge selection | `NewGameScreen`, `LastStandPlayerSelect` |
| F02 Load/save browser and saved-game configuration | `LoadGameScreen` |
| F03 World/map and spawn selection | `WorldSelect`, `MapSpawnSelect`, `MapSpawnSelectImage`, `MapSpawnSelectListBox`, `MapSpawnSelectInfoPanel`, `MapSpawnSelectSeedPanel` |
| F04 Sandbox settings and presets | `SandboxOptionsScreen` |
| F05 Character identity, clothing and avatar creation | `CharacterCreationMain`, `CharacterCreationMainCharacterPanel`, `CharacterCreationMainPresetPanel`, `CharacterCreationAvatar`, `CharacterCreationProfession` |
| F06 Occupation and traits | `CharacterCreationProfession` |
| F07 Multiplayer server browser | `MultiplayerUI` |
| F08 Connection, bootstrap, progress and error popups | `ConnectToServer`, `BootstrapConnectPopup`, `ServerConnectPopup` |
| F09 Host/local-coop setup | `CoopOptionsScreen`, `CoopOptionsScreenPanel`, `ServerToolbox` |
| F10 Server configuration editor | `ServerSettingsScreen`, `BaseServerSettingsPanel`, `SpawnRegionsNameFilePanel`, `Page3.ChooseModsWindow` |
| F11 Mod manager, mod presets and missing-mod warnings | `ModSelector`, `ISModsNagPanel`, `ModMoreInfo`, `ISModsHelpPanel`, `ModInfoPanel`, `ModListPresets`, `ModSelector.MapOrderListBox`, `ModSelector.MapOrderUI`, `ModSelector.MissedModsPanel`, `ModSelector.MissedModsWindow`, `ModInfoPanel.Desc`, `ModInfoPanel.InteractionParam`, `ModInfoPanel.Param`, `ModInfoPanel.Thumbnail`, `ModInfoPanel.Title`, `ModSelector.ModListBox`, `ModSelector.ModListPanel`, `ModSelector.ModLoadOrderPanel`, `ModSelector.ModOrderListBox` |
| F12 Server Workshop dependency installation | `ServerWorkshopItemScreen` |
| F13 Workshop submission/update wizard | `WorkshopSubmitScreen` |
| F14 Credits, Terms/legal, help/report and ancillary entry controls | `CreditsScreen`, `ISTermsOfServiceUI`, `MainScreen` |
| F15 Steam invitations and scoreboard | `InviteFriends`, `ISScoreboard` |
| F16 Local-player/cooperative character join flow | `CoopCharacterCreation`, `CoopUserName`, `CoopCharacterCreationMain`, `CoopCharacterCreationProfession`, `CoopMapSpawnSelect` |
| F17 Advanced sound browser | `ISGameSounds` |

### Gameplay source-target register

| Area | Native source targets |
|---|---|
| G01 Live inventory and loot windows | `ISInventoryPage`, `ISInventoryPageContainerButtonPanel`, `ISInventoryPane`, `ISInventoryWindowContainerControls`, `ISLootWindowContainerControls` |
| G02 Character, skills, health, protection, insulation, fitness and garment panels | `ISCharacterInfoWindow`, `ISHealthPanel`, `ISNewHealthPanel`, `ISHealthBodyPartPanel`, `ISHealthBodyPartListBox`, `ISSkillProgressBar`, `ISFitnessUI`, `ISGarmentUI`, `ISCharacterScreen`, `ISCharacterScreenAvatar` |
| G03 Equipment and hotbar | `ISEquippedItem`, `ISMoveablesIconPopup`, `ISMapPopup`, `ISHotbar` |
| G04 Clock/watch and moodles/status indicators | Engine/reference or source-helper boundary; inspect structured evidence |
| G05 Chat | `ISChat` |
| G06 Minimap, world/paper maps, symbols, legends and sharing | `WorldMapOptions`, `ISWorldMapButtonPanel`, `ISWorldMap`, `AnnotatedMapOverlay`, `ISMap`, `ISMapWrapper`, `ISMiniMapOuter`, `ISMiniMapInner`, `ISMiniMapTitleBar`, `ISMiniMapOptionsPanel`, `ISWorldMapSymbols`, `ISWorldMapSymbolsTabPanel`, `ISWorldMapSharing`, `ISWorldMapSharing_PanelPlayers` |
| G07 Build42 handcraft and recipe UI | `ISHandcraftWindow`, `ISHandCraftPanel`, `ISCraftRecipePanel` |
| G08 Building, placement and moveable controls | `ISBuildWindow`, `ISBuildPanel`, `ISExtendedPlacementUI`, `ISMoveablesIconToolTip` |
| G09 Entities and crafting workstations | `ISEntityWindow`, `ISEntityTabWindow`, `ISCraftBenchPanel`, `ISCraftLogicPanel` |
| G10 Vehicle mechanics | `ISVehicleMechanics` |
| G11 Vehicle dashboard, seats, climate, lightbar and radial controls | `ISVehicleDashboard`, `ISVehicleSeatUI`, `ISVehicleACUI`, `ISLightbarUI`, `ISVehicleGauge` |
| G12 Radio, television and recorded media | `ISRadioWindow`, `ISMediaInfo` |
| G13 Foraging, search and tracking overlays | `ISSearchWindow`, `ISZoneDisplay`, `ISForageIcon`, `ISAnimalTracksUI` |
| G14 Fishing and newer PZAPI fish window | `Fishing.ISTensionUI`, `UI.FishWindow` |
| G15 Animals, designation zones, hutches, tracks and butchering | `ISAnimalUI`, `ISAnimalAvatar`, `ISDesignationZoneAnimalZoneUI`, `ISDesignationZoneAnimalZoneUI_AnimalsPanel`, `ISButcherHookUI`, `ISHutch3DModel`, `ISHutchNestBox`, `ISHutchNestParentPanel`, `ISHutchRoost`, `ISHutchRoostParentPanel`, `ISHutchUI`, `ISVehicleAnimalUI`, `ISAnimalInVehiclePanel`, `ISVehicleAnimal3DModel`, `ISAnimalTracksUI` |
| G16 Farming and plant information | `ISFarmingInfo`, `ISFarmingWindow` |
| G17 Fluid transfer and container information | `ISFluidTransferUI`, `ISFluidInfoUI`, `ISFluidBar`, `ISFluidContainerPanel` |
| G18 Appliances, heating, generator and BBQ information | `ISOvenUI`, `ISMicrowaveUI`, `ISGeneratorInfoWindow`, `ISBBQInfoWindow` |
| G19 Literature, journals, notes and printed media | `ISLiteratureUI`, `ISLiteratureList`, `ISLiteratureMediaList`, `ISLiteratureGrowingList`, `ISUIWriteJournal`, `ISPrintMediaTextPanel`, `ISPrintMediaMap`, `UI.PrintMedia`, `UI.PrintMedia.children.bar.children.name` |
| G20 Alarm, sleeping and post-death/respawn UI | `ISAlarmClockDialog`, `ISSleepingUI`, `ISPostDeathUI` |
| G21 Player tools, factions, safehouses, tickets, trading and wars | `ISUserPanelUI`, `ISSafehouseUI`, `ISFactionUI`, `ISTicketsUI`, `ISTradingUI`, `ISWarManagerUI` |
| G22 Tutorial, survival help and focus overlays | `TutorialMessage`, `TutorialFocus` |
| G23 Timed-action progress, radials and transient HUD feedback | `ISRadialProgressBar`, `ISRadialMenu` |

### Specialist source-target register

| Area | Native source targets |
|---|---|
| A01 Administration and player/server management | `ISAdminPanelUI`, `ISItemsListViewer`, `ISServerOptions`, `ISPlayerStatsUI`, `ISServerSandboxOptionsUI` |
| A02 Debug and developer tools | `ISDebugMenu`, `DebugErrorsWindow` |
| A03 Controller, split-screen, on-screen keyboard and reconnect UI | `ISControllerBindingsEditorPanel`, `ISControllerTestPanel`, `ISJoypadDisconnectedUI`, `ISOnScreenKeyboard`, `OnScreenKeyboardEntry`, `OnScreenKeyboardPanel` |

## Controls and engine boundaries

Shared presets are not a global native skin. Supported Options whitelist and exact inventory buttons are distinct from radio controls, spinboxes, color pickers/HSB, arbitrary rich content, generic progress/LCD/knob/image controls and bespoke screen rows. API consumers opt in explicitly. Preserve text/semantic swatches, native control values and input/Apply ownership.

Clock and moodles remain static editor references. Timed-action progress, radials, native gauges, UI3DModel, UIWorldMap and ObjectTooltip need exposed Lua/asset contracts; do not replace unsupported engine rendering with custom Java. Newer PZAPI FishWindow/PrintMedia atom/template composition needs its own adapter, not an ISPanel-only pass. Steam/platform overlays are outside the Lua mod's ownership.

## Runtime/distribution findings and limits

[VERIFIED source; TESTED offline] Canonical version stays 0.10.0-dev.2. At intake the clean branch matched its upstream exactly (b699329,0 ahead/behind upstream;17 ahead/0 behind main). Runtime remains72 files/144 keys/29 explicit English-fallback locales. Runtime/source fingerprints are unchanged by this audit. Installed source contains existing PZ Optimization engine overrides; this is not pristine vanilla certification. Known provider Lua is excluded; no external mod code/assets were copied or modified.

[VERIFIED limited local startup] The dev.1 native event bootstrap failure was corrected in dev.2. Controlled local startup reaches context hooks-ready and Options styling/interface markers without UI exception traces at observation. This proves bounded setup only. Native pixels, actual layout/input, controller/split-screen, transfers, modal rollback, profile durability, Linux and dedicated integration remain NOT TESTED. G6 remains NOT TESTED; project G7/stable G8 BLOCKED.

The main-menu rearrangement report requires source/version awareness: the original approved defaults were committed in 0.6.0-dev.3, but the Workshop item is still 0.5.0-dev.11 and predates saved-layout support. Both local and Workshop copies share the Mod ID. An unrestricted launch can select a different source; the inspected console did not conclusively identify its origin. The controlled local-only relaunch uses the current dev.2 build and preserves the saved layout. Do not treat prior display changes as proof that its profile was erased, or claim visual restoration without user/native evidence. This audit performs no deployment, launch, upload, UI move or preference write.

## Exact validation commands

```powershell
python -X utf8 -B scripts/check_versions.py
python -X utf8 -B tests/run_tests.py
python -X utf8 -B scripts/audit_menu_coverage.py --game-root <verified-game-root> --rules docs/UI_COVERAGE_RULES_2026-10-24.json --check docs/UI_SOURCE_CATALOG_2026-10-24.json --areas docs/UI_COVERAGE_INVENTORY_2026-10-24.json
git diff --check
```

The coverage check rehashes all 72 project runtime files, all 623 installed candidates and each curated evidence file/target. Changed project version/runtime requires a new coverage review. Its source-only success is not native UI acceptance. The legacy scanner's dev.4 classifications remain historical and are not reused as current adoption labels.
