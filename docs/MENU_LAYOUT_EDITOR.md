# Main-menu layout editor

Project Version: 0.6.0-dev.1

Compatible MINOR addition; public consumer API major 1 is unchanged. Development source only. Workshop remains 0.5.0-dev.11; this feature is not deployed or uploaded.

## Player controls

Choose **Edit menu layout** at the lower-left of the main menu, press **F10**, or press controller **X** while the native main-menu graph has focus. Controller Y retains the vanilla Terms of Service action outside editing. Editing is unavailable during initial menu delay, native modals, submenu screens and the in-game Esc menu.

The menu column and logo have separate selection frames. Drag a frame body to move it; drag its lower-right corner to resize it. Logo proportions remain locked. Select Menu or Logo in the properties panel to adjust horizontal position, vertical position, width and height with native percentage sliders. Changing either logo dimension scales it uniformly. Tab switches targets, arrow keys move the selected target by 2 pixels, and Shift+arrows resize it. Native slider/controller navigation provides larger-step adjustments.

**Save layout** or Enter writes the local preferences and exits. **Cancel**, Escape or controller Back discards the draft. **Reset layout** previews the automatic wall layout; Save commits it, while Cancel restores the previous saved settings. A failed save keeps the editor open with feedback; Cancel remains available. The recovery button and properties panel are outside the editable rectangles. Players may deliberately overlap their logo/menu or place them over scenery; viewport clamps and Reset provide recovery.

Only completed Save writes preferences. Dragging, slider movement, rendering, Cancel and resolution changes do not write. Native navigation objects/actions remain in place; the owned overlay consumes pointer input while editing and temporarily takes the front-end controller focus. Initial child focus is explicitly highlighted. Capture and tooltips are released on close, screen replacement, game start, hidden navigation or renderer replacement. Focus is restored only if it still belongs to this editor, preserving a later modal's focus.

## State ownership and persistence

`MenuLayout.lua` owns a data-only profile at `B47ANCEDUI/main-menu-layout.txt` under the engine cache/Lua directory, through existing exposed file-reader/writer APIs. It is one preference for this local installation's front-end, independent of per-consumer/player appearance settings. It is never a world/save, shared gameplay, server setting, network command or authority source. No sandbox option is appropriate for local menu coordinates.

Schema 1 stores optional normalized menu x/y/width/height and logo x/y/width. Logo height is derived from the native texture aspect ratio. Untouched targets retain the current automatic wall layout. On each viewport, custom targets are resolved into pixels and clamped inside the screen without rewriting their stored values. Moving only one target leaves its peer automatic. Added/hidden/removed actionable menu entries and optional provider notes continue to fit inside the selected menu rectangle; individual actions, widget references, menu counts and child positions are not persisted. Compact rows can become very small by player choice; no minimum readability guarantee is claimed for arbitrarily crowded menus.

The first line must be `schema=1`. Readers inspect at most 8 lines and accept only lines of at most 160 characters. They reject non-finite/out-of-range or incomplete rectangles, preserve a valid peer target, and never execute data. The native line reader's allocation for oversized lines is not bounded by this parser. Supported normalized values are 0–1, with positive dimensions. Pixel minima (menu 160×80, logo width 100, reduced for smaller viewports) and viewport maxima are internal drawing safeguards. Serialization preserves small positive values. Missing/invalid/unknown-schema files fall back to automatic placement. Reset saves the empty schema rather than deleting files. Older UI versions ignore this new file; existing appearance files remain untouched.

Writer failures close the writer and retain the in-memory saved profile. No atomic durability guarantee is inferred from protected calls; silent native storage failures remain a runtime gate. A truncated profile recovers to valid targets/defaults on a later load.

## Implementation and verified source

`MenuBackground.lua` separates automatic rectangle calculation from optional local overrides. It continues to call native prerender once, restoring the temporary logo-draw override on errors, then fits the dynamic menu column. Artwork, private animation RNG, 1–60 second static/no-signal timing, native music behavior and public API 1 remain unchanged.

`MenuLayoutEditor.lua` attaches one owned recovery button and temporary overlay to the recognized MainScreen instance. It wraps only that instance's key/controller entrypoints and delegates ordinary input. It does not modify MainScreen/ISUI classes or the global keyboard dispatcher. A competing renderer disables editing. There is no tick/world scan or custom Java/JAR dependency. Native title/status callbacks remain the consuming widget's responsibility.

[VERIFIED: installed vanilla Lua, Steam build 25485521, 2026-10-20; source only] UI element capture/child registration, native button callbacks, slider callbacks and front-end joypad ownership were inspected. MainScreen's existing key dispatcher calls the instance handler; controller A/Y stay native outside editing. `ISPanel`'s stock child dragging moves its parent, so owned drag callbacks explicitly update only normalized target geometry. `ISPanelJoypad:restoreJoypadFocus` supplies the initial visible child focus. Portable source fingerprints/line ranges are in STYLE_SOURCE_EVIDENCE.json. Target engine version is 42.21; a historical local log reports 42.21.0, but no new engine launch/full-version invocation was performed for this audit. API evidence does not establish native input behavior.

## Validation and runtime gates

[TESTED: offline Windows] `python -X utf8 -B scripts/check_versions.py`, `python -X utf8 -B tests/run_tests.py`, `git diff --check`. New fixtures cover bounded malformed/future profiles, independent defaults/overrides, nine viewport sizes, proportional logos, reload/reset, no per-frame writes, write/read/close failures, pointer move/outside-release/resize callbacks, keyboard and controller delegation/initial focus, Save/Cancel, viewport change/capture release,40mod-added rows, native modal focus, hidden/replaced screens and game-start cleanup. A large-font compact-menu row regression failed against the old 0.05 zoom floor and passes with responsive fitting. These are owned-code fixtures with UI doubles; they are not native engine input or rendering proof.

[RUNTIME GATE] Native drag capture and outside release, click shielding, hover/audio, keyboard event ordering, controller graph/visible focus/restore, actual file persistence/reload, language/font scales, resolution changes, optional provider states, modded menu interactions and entering/leaving a save/server remain NOT TESTED. G6 NOT TESTED; project G7/stable G8 remain BLOCKED. No deployment, game/server launch, packaging or publication is authorized by this development request.
