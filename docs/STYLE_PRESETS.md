# Editable UI style presets

Project Version: 0.12.0-dev.1

0.12 adds39 independent colors (53 total) and a separate Scrollbar family, alongside the existing19 family choices including All components. Hex and RGB sliders stay synchronized and display inherited colors. Specific channels cover surfaces; pressed/selected/disabled/focus states; title/status bars; slider tracks/thumbs; scrollbar tracks/thumbs/arrows; checks/icons; progress; menu text/hover/underline; tooltips; and owned input text/placeholders. Old generic values remain fallbacks. Scrollbar values inherit old Slider colors before explicit Scrollbar overrides.

[Packs and sharing](PRESET_PLUGINS.md) add inactive external choices, explicit preview/local copies, multi-preset switching and export/New versus Update. Exports contain authored styling only. Layouts and legacy Appearance preferences remain separate. Every supported token is editable, but tokens affect only drawing paths that consume them: item/map/health/document semantics and engine internals are retained. Native input text/placeholder customization is limited to API-owned inputs; arbitrary native cursor/selection cannot be recolored safely. PZAPI image icons and scrollbar thumb bodies are supported; universal PZAPI thumb-hover and arbitrary icons are not. Focus outlines remain visible even with ordinary borders disabled.

0.11 extends live shared presets to guarded audited native frames/controls throughout frontend, gameplay and specialist windows. Existing API/Options/inventory owners retain their scopes. Native standard slider dimensions refresh on preview/Cancel; the separate PZAPI chrome adapter refreshes palette presets and restores native colors on opt-out. Native fonts, semantic content and unsupported engine/custom rendering remain outside generic replacement. See [NATIVE_ROLLOUT.md](NATIVE_ROLLOUT.md) for exact coverage and runtime limits.

Open **Options → Interface → UI Style Presets**. Select the shared preset or a registered mod, then a component and property. Hex colors accept six digits with optional `#`; numeric properties have a bounded slider and text field. Empty values inherit. Duplicate, rename or delete presets (the default cannot be deleted), inherit one property, reset one component, or remove a mod's preset binding with Follow shared preset. Reset removes that component's explicit values only; inherited all-component/shared values still apply.

The default preset starts empty, preserving the existing near-black UI and grey/previously saved accent. Resolution, font/spacing, button size helpers, HUD/menu layout and native setting values remain separate. Presets are local presentation, not authoritative gameplay configuration; no server sandbox option or networking is appropriate.

| Component family | Coverage |
|---|---|
| Normal/small buttons | Shared native/API Button, IconButton and Toggle; size remains caller-owned |
| Menu navigation | Text/underline styling on API MenuButton and verified main/Esc labels |
| Sliders | Native/API slider palettes, bounded track thickness and thumb dimensions; range, step, value, callback and bar input mapping retained |
| Volume | Native Options volume controls keep their own hit/drag/controller math |
| Checkbox, input, dropdown | Supported native Options controls; API inputs/dropdowns and renderer checkbox primitive |
| Panel/window/dialog/list/tabs | Shared API surfaces and verified native Options/quit adapters; custom native renderers and live color swatches stay guarded |
| Row, text, progress | Shared Renderer rows, labels/section headers/badges and progress helpers |
| Tooltip frames | Managed native tooltip backing/border and inspect panel; rich text content/semantic markup remains native |

Properties include background, hover, selected, border/focus, text/muted/disabled, accent/hover, alternate and semantic danger/warning/success colors; backing opacity 20–100%; frame radius 0–8px; border width 0–3px; and slider-only track 1–12px, thumb width 4–32px/height 8–48px. A property affects a family's corresponding supported drawing only: radius/stroke do not reshape textures, arbitrary content or slider hit tests. Focus rings remain drawn even with ordinary borders disabled. Translucent child panels never gain a backing. Untagged arbitrary RGB values retain provider semantics.

Each local player slot 0–3 has one preset book. A mod can bind a different preset; otherwise it follows the active shared preset. Within the chosen preset, resolution is existing Theme/Appearance → shared all-component values → shared family values → mod all-component values → mod family values. Explicit preset values take precedence over the older accent/opacity preferences; Inherit exposes those preferences again. Missing fields never force changes. Per-mod overrides belong to that preset, and removing a binding does not erase them. Unknown bounded families/properties/mod records are retained inactive for future providers.

The editor owns a full-viewport input veil and a stable inspector. Draft styles apply to actual supported live controls and the sample area, while the inspector and its exit confirmation remain usable. The preview area and long form scroll independently; controller focus reveals form controls. Save writes only after complete valid input and verified read-back. Cancel/Escape/controller B close an owned dropdown first, then use Keep editing / Discard changes for unsaved drafts. Bare Enter does not save. Discard restores the saved preset book without writes. Failed saves keep the draft open. Actual owner/game teardown releases drafts, owned popups, focus/capture, key subscriptions and veil without writing. Temporary unrelated modal focus is preserved.

## Storage and recovery

Independent schema1 data journals live in the engine cache/Lua directory at `B47ANCEDUI/style-presets.<player>.a.txt` and `.b.txt`. Display names are UTF-8 hex data, never filenames or executable Lua. Preset/scope IDs use the existing bounded ASCII identifier convention. Limits: 16 presets, 32 bindings, 3072 values, 48-byte names, 512-byte lines, 4094 body records and 256KiB files. Canonical sorted records include a generation and Adler-32 corruption checksum, not an authentication signature.

Only explicit Save writes the alternate journal, closes it, then reopens and validates its generation/checksum/content before replacing the live saved cache. Reload chooses the newest valid generation. One invalid slot with another valid slot can recover via the next Save. A future-schema or unreadable slot blocks writes; two invalid slots also block writes. The editor permits preview/discard but offers no destructive replacement of protected files. Recovery requires retaining originals and restoring a known-good copy outside the editor. Old versions ignore this separate store; appearance/menu/HUD files are unchanged.

Two slots and read-back limit interrupted-write loss; native atomic rename/fsync/disk durability are not established. A writer can report failure after data reached disk, so a later reload can recover a complete newer generation even if the previous session reported failure. Checksums do not guarantee power-loss durability or protect against external modifications. No in-game native file round-trip is claimed.

## Public API and evidence

API major1 adds `UI.Slider:new/style`, `UI.StyleEditor.open(owner)`, and `UI.Styles.setFamily/color/number`. Use the existing scoped `API.forMod('StableModID')` facade and shared controls/Renderer; no internal module requires or Theme mutation. Custom rendering opts in with the public token resolver, supplying a fallback for numeric values and preserving its own semantic drawing, layout and lifecycle. Arbitrary third-party code is not modified.

```lua
local UI=require('B47ANCEDUI/API').requireVersion(1).forMod('MyMod')
UI.Styles.setFamily(myOwnedWidget,'panel')
local c=UI.Styles.color(myOwnedWidget,UI.Theme.colors.panel)
myOwnedWidget:drawRect(0,0,myOwnedWidget:getWidth(),myOwnedWidget:getHeight(),c.a,c.r,c.g,c.b)
local radius=UI.Styles.number(myOwnedWidget,'radius',4)
```

[VERIFIED: installed Build42.21 Lua/Steam25485521] Slider pagination/drawing/input ownership, combo clear, standalone key subscription and frontend joypad focus contracts are fingerprinted in STYLE_PRESETS_SOURCE.json. All implementation is original client Lua; no external-mod source/assets or custom Java.

[TESTED: offline Windows, Lua5.1 doubles] `python -X utf8 -B scripts/check_versions.py`, `python -X utf8 -B tests/run_tests.py`, `git diff --check`. Tests cover journals, limits, unknown records, write/close/interruption failures, protected files, scoped inheritance/copy/lease ownership, palette rollback, slider geometry/value isolation, shared popup palette/error/foreign-owner restoration, default rounded outlines, independent primitive families, persistent focus rings, shared preview isolation, menu underline tokens, CRUD, invalid pending fields, explicit Save and unsaved exits, popup-first Escape, stale callbacks, frontend focus, viewport/stencil/scroll and lifecycle cleanup.

[RUNTIME GATE] Actual PZ pixels, mouse/keyboard/controller dispatch, split-screen, file reload/failure recovery, custom-provider integration and performance remain NOT TESTED. G6 NOT TESTED; project G7/stable G8 BLOCKED. This iteration is source-only: no deployment, launch, package, merge or Workshop upload.

0.9.0-dev.2 compatibility correction: the actual dev.1 frontend failed in ComponentStyles.prepare at its global next call. The installed Kahlua runtime does not provide that callable. One private pairs-based presence helper now handles all style/preset/editor/tooltip/Options checks; every behavioral test VM disables global next and the reproduction fails before the fix. Names, schema1 journal records, colors/geometry defaults and API1 are unchanged. Native post-fix acceptance remains pending. The earlier dev.1 offline pass is historical and did not establish Kahlua compatibility.

Post-fix dev.2 local deployment/limited startup on 2026-10-22:68 source/destination hashes match, saved preferences preserved, responding game window, Options styling/interface attachment true and no UI exception trace in the fresh console at observation. This is startup evidence, not full visual/input/preset/controller or persistence acceptance. Existing engine modifications and unrelated warnings remain; see TESTING.md.

The subsequent user screenshot of the dev.2 local test showed blank Options categories and overflowing rows. This is failed Options visual acceptance despite successful startup; dev.3 corrects those separate layout defects in source. Preset rendering/input acceptance remains NOT TESTED.

## Native overhaul coverage (0.10)

Context menus use List, inventory/loot chrome uses Window, neutral inventory drawing uses Row, owned native controls use Normal button, tooltips use Tooltip, selected confirmations use Dialog, and inventory scrollbar colours use Scrollbar (with legacy Slider inheritance). These are scoped adapters. Native text/semantic colours/fonts/geometry remain native; scrollbar dimension presets do not resize its hit areas. Transparent icon backings stay transparent and controller focus remains visible at zero border width. See [exact token/alpha bounds](NATIVE_OVERHAUL.md).
