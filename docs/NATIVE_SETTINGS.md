# Native settings presentation

Project Version: 0.6.0-dev.2

The native Options screen uses a near-black backdrop and restrained grey surfaces. Tab headers and ordinary buttons have small rounded corners; the active tab has an accent underline. Checkmarks, slider thumbs and controller-focused control borders use UI's existing local accent preference, default `#B0B0B0`. Text-entry backgrounds retain native drawing/clipping. The settings backdrop stays nearly opaque for readability. This is an internal native-screen adapter, not a new public API or replacement settings implementation.

## Ownership and compatibility

`NativeSettings.lua` adopts the verified `MainOptions` instance after construction through main-menu/game-start/Lua-reset events. It requires the native root renderers and tab panel. It walks owned children once, with internal depth/node limits (16/4096), and wraps the owned containers' `addChild` methods to adopt supported later additions. A replaced tab panel is checked at root prerender; no per-frame tree or world scan runs. These implementation safety limits are not player configuration.

Supported native instances: `ISTabPanel`, `ISButton`, `ISComboBox`, `ISTickBox`, `ISTextEntryBox`, `ISSliderPanel`, `ISVolumeControl`, `ISMegaVolumeControl` and native `ISPanel`/`ISPanelJoypad` containers, including MainOptions' stencil-enabled pages. Exact native renderer checks guard custom renderers and their subtrees. Empty-title buttons retain their live colour swatches. Specialized controller test panels, colour pickers, level indicators, rich text, labels and unknown mod panels keep their native/provider rendering. This first settings slice does not promise a complete skin for arbitrary mod pages.

The adapter changes instance palette/drawing only. It retains dimensions, fonts, anchors, tab/row objects, selected values, callbacks, `internal` identifiers, wheel/scroll handling, native tooltip behavior and controller registration. It does not change Apply/Accept/Back, audio preview/rollback, display-mode confirmation, restart/Lua-reset prompts, keybinding capture or option persistence. Native delegates still run; stencil cleanup remains in its original render phase. No vanilla files, global widget classes, input dispatchers, game options or third-party sources are edited.

The tab adapter intercepts only the native header textures, preserving native scrolling/clipping/fades; only the actual active tab receives the underline. Native audio controls retain their separate mouse/controller volume math rather than becoming generic sliders. The shared combo popup borrows settings background/border colours only while its current parent combo belongs to this root, restoring fields and drawing methods on success/error. Row highlighting still comes from the native parent combo's hover colour. Detached controls pass drawing through and restore their pre-adoption palette at the next native draw phase.

## State and configuration

This is client-local presentation with no shared gameplay ownership, networking, server module, save migration or sandbox configuration. Accent resolution uses UI's existing `B47ANCEDUI` local slot 0; no preference file is written by styling. Other consumers' appearance preferences remain separate. There are no new player-facing strings: native translations and font metrics remain authoritative. Public API major 1 is unchanged.

## Evidence and runtime gates

[VERIFIED — installed Lua] Steam build 25485521, target Build 42.21. Portable source fingerprints/line ranges are in `STYLE_SOURCE_EVIDENCE.json`; full engine version was not freshly queried through a game launch. No external-mod code/assets were used.

[TESTED — offline Windows, 2026-10-20] `python -X utf8 -B scripts/check_versions.py`, `python -X utf8 -B tests/run_tests.py`, `git diff --check`. Isolated Lua 5.1 contract doubles cover unchanged geometry/fonts/callbacks/value ownership/controller row references; original page stencil calls; late controls, recreation, custom-renderer/swatch refusal; active versus hovered tabs; detached controls; shared popup ownership, live accent colour and exception restoration; volume shim cleanup. Existing suites also pass. These doubles do not execute native Apply/rollback logic or simulate engine input.

[RUNTIME GATE — NOT TESTED] Open Options from the title screen and Esc menu; check every native tab at small/large fonts, translations and standard/ultrawide resolutions. Check tab overflow, wheel/stencil clipping, dropdown search/capture/ownership on another screen, disabled states, slider release outside bounds and mouse/keyboard/controller focus. Rebind/cancel a key; test audio preview then Back/rollback; change display mode and revert its confirmation; verify Accept/Apply/Back, restart prompts and mod option panels. Native drawing performance remains unmeasured. G6 NOT TESTED; project G7/stable G8 remain BLOCKED. No package, deployment, game/server launch or Workshop upload was performed for this source iteration.
