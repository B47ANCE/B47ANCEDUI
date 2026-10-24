# Native UI overhaul: first slice

Project Version: 0.10.0-dev.1

This compatible MINOR addition starts the implementation following the [dated coverage audit](UI_COVERAGE_AUDIT_2026-10-23.md). That audit remains an unchanged historical snapshot. The whole-game overhaul is unfinished; the table below describes this iteration's source coverage, not runtime acceptance or a completion percentage.

| Audit area | Implemented in this slice | Still outstanding |
|---|---|---|
| X02 context menus | Native world/item/empty-container event roots and pooled submenus: black frames, neutral hover rows and borders | Semantic text/icon colours remain native; unrelated custom renderers and menus outside those event routes are excluded |
| X03 tooltips | Existing native generic and inventory tooltip frames reached through those menus or live inventory panes | ObjectTooltip item content, rich text, measurement and placement remain native; other tooltip routes need explicit adoption |
| G01 inventory/loot | Live player-owned inventory/loot backing, title/status chrome, neutral rows, native header/container/action buttons and scrollbar presentation | This is a skin of native windows, not a redesigned inventory layout; item text/stats, category semantics, sorting, transfers and drag/drop remain native |
| X04/X05 scrolling/lists | Inventory-owned vertical scrollbar backing/thumb and native row/header drawing | Other windows, trees and horizontal scrollbars remain separate work |
| X01 confirmations | Native Options unsaved/display-change confirmations and inventory information dialog | Restart notice, text entry, leave-game, delete/save/password and other dialog routes remain outstanding |

## Ownership and integration

`NativePresentation` supplies private drawing helpers. `NativeContext`, `NativeInventory` and `NativeDialogs` adopt exact supported native instances, refusing unfamiliar types/renderers or existing API-styled instances. No global native constructor/renderer replacement, UIManager scan or tick/world traversal is added. Context submenu discovery visits at most 256 entries only when the native generation changes or a fill event invalidates it. World capability probes (`test=true`) are ignored. Empty inventory uses the installed event name `OnFillInventoryContextMenuNoItems`.

Native player-data creation/layout restoration runs before inventory observation. A create event may recreate several players' windows, so the observer checks all four current slots. Only those current inventory/loot roots are styled; detached/replaced roots delegate without styling. Existing HUD geometry overrides remain independently owned by `HUDLayoutRuntime`. No placement, resizing, native saved-layout restore, item value/action/permission or transfer method is replaced. Known container/control panels observe later native button additions, including pooled bag buttons. Image/tint, font, callback, controller rows, native minima and hit areas remain unchanged.

The private Options lifecycle monitor observes its known `modal` field after native construction, without interfering with the Options renderer identity guard. Dialog type, owner and exact native callback must match. Display-confirmation countdown/automatic rollback and modal destruction/focus remain native. Inventory information rich text and pagination remain native. Locally scoped dialogs without an owned observable field are deliberately excluded.

Drawing interception is temporary around one original delegate call. Raw instance overrides are restored even when the native delegate throws; the exception propagates. Multiple/nil return values are retained. Item tooltips delegate the original native ObjectTooltip measurement/content path, rather than rebuilding stats. Generic tooltips paint in both native phases; both backing paths are intercepted. Coloured rejection/heat/progress/blink markers, item icons, text semantics, checkmarks, scrollbar arrows and resize/controller indicators pass through.

## Appearance and preset bounds

The native adapters use UI's existing `B47ANCEDUI` scope and the explicit local-player slot, including native widgets whose field is named `player` rather than `playerNum`. They do not modify either field. Presets preview through the existing journal/editor contracts and write nothing from drawing/adoption.

| Drawing | Existing preset family | Limits |
|---|---|---|
| Context backing/hover/borders | List | Native row geometry/fonts/semantic text stay native |
| Inventory/loot shell and title/status backing | Window | Native title/status/rail bounds retained; functional borders default to square |
| Inventory neutral rows/header | Row | Native overlay alpha, column/row geometry and semantic markers retained |
| Owned native buttons | Normal button | Palette/frame only; native size/font/pressed behaviour and semantic action colours retained |
| Item/generic tooltip frame | Tooltip | No stat/content/layout override |
| Inventory vertical scrollbar | Slider | Track/thumb palette only; native hit area/thumb geometry/arrows retained; slider dimension presets do not resize it |
| Selected native confirmations | Dialog | Frame plus supported button styling; no dialog reflow |

Main backings inherit the existing appearance opacity (82% by default) unless their family has a preset override. Native transparent icon-button backing remains transparent even with an opacity override. Native overlay alpha is retained where passed explicitly. Ordinary border width may be zero; controller focus still receives a visible minimum stroke. Not every preset property applies to every native drawing: text, spacing, fonts and semantic colours are not globally overridden.

## Evidence and remaining gates

[VERIFIED: installed source] Build 42.21.0, revision 4a0e9546ec, Steam build 25485521. Portable fingerprints and source observations: [NATIVE_OVERHAUL_SOURCE.json](NATIVE_OVERHAUL_SOURCE.json). Existing PZ Optimization engine overrides are installed; this is not certification of a pristine vanilla distribution. No third-party mod source or assets were copied or changed.

[TESTED: offline Windows, Lua 5.1 with `next` unavailable] Version/source/case/localization/syntax/archive/API/editor/Options suites and strict native-overhaul fixtures pass. New tests cover exact event names, capability probes, late/pooled submenus/buttons, custom-renderer refusal, semantic colours, tooltip phases, native content/delegate counts, multiple/nil returns, exception restoration, per-player presets, transparent controls, focus with zero borders, known modal ownership/countdown and stale windows. Runtime inventory: 72 files; 144 keys across 29 explicit English-fallback/unreviewed locales. Exact commands are in [TESTING.md](TESTING.md).

[RUNTIME GATE] Native screen pixels, hover/fades, open/close, clipping, long lists/scrolling, item/stack dragging, transfers/actions, context submenus/controller navigation, tooltip measurement, split-screen isolation and display-confirmation rollback are NOT TESTED for this revision. Check these alongside existing Options/sidebar/search/Apply/editor acceptance at standard/large fonts and normal/ultrawide resolutions. No performance or dedicated integration claim follows from the doubles. This is purely local presentation with no new shared gameplay configuration, network message or persistence ownership; existing project G6 is NOT TESTED and G7/stable G8 remain BLOCKED. No package, deployment, launch or Workshop upload occurred in this iteration.
