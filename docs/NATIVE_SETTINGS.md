# Native settings presentation

Project Version: 0.8.0-dev.2

The Options screen now uses the sidebar/search/card workspace described in [OPTIONS_LAYOUT.md](OPTIONS_LAYOUT.md). `NativeSettings.lua` remains its palette adapter: near-black surfaces, restrained rounded native controls, grey default accent `#B0B0B0` and guarded native/provider ownership. `OptionsLayout.lua` adds instance geometry/navigation after palette and Interface attachment. It replaces the recognized native tab strip with category navigation, while preserving the original tabs/pages/controls/actions underneath. The palette-only statements below describe NativeSettings, not the aggregate workspace layout.

## Ownership and compatibility

`NativeSettings.lua` adopts the verified `MainOptions` instance after construction through main-menu/game-start/Lua-reset events. It requires the native root renderers and tab panel. It walks owned children once, with internal depth/node limits (16/4096), and wraps the owned containers' `addChild` methods to adopt supported later additions. A replaced tab panel is checked at root prerender; no per-frame tree or world scan runs. These implementation safety limits are not player configuration.

Supported native instances: `ISTabPanel`, `ISButton`, `ISComboBox`, `ISTickBox`, `ISTextEntryBox`, `ISSliderPanel`, `ISVolumeControl`, `ISMegaVolumeControl` and native `ISPanel`/`ISPanelJoypad` containers, including MainOptions' stencil-enabled pages. Exact native renderer checks guard custom renderers and their subtrees. Empty-title buttons retain their live colour swatches. Specialized controller test panels, colour pickers, level indicators, rich text, labels and unknown mod panels keep their native/provider rendering. This first settings slice does not promise a complete skin for arbitrary mod pages.

The adapter changes instance palette/drawing only. It retains dimensions, fonts, anchors, tab/row objects, selected values, callbacks, `internal` identifiers, wheel/scroll handling, native tooltip behavior and controller registration. It does not change Apply/Accept/Back, audio preview/rollback, display-mode confirmation, restart/Lua-reset prompts, keybinding capture or option persistence. Native delegates still run; stencil cleanup remains in its original render phase. No vanilla files, global widget classes, input dispatchers, game options or third-party sources are edited.

The tab adapter intercepts only the native header textures, preserving native scrolling/clipping/fades; only the actual active tab receives the underline. Native audio controls retain their separate mouse/controller volume math rather than becoming generic sliders. The shared combo popup borrows settings background/border colours only while its current parent combo belongs to this root, restoring fields and drawing methods on success/error. Row highlighting still comes from the native parent combo's hover colour. Detached controls pass drawing through and restore their pre-adoption palette at the next native draw phase.

## State and configuration

This is client-local presentation with no shared gameplay ownership, networking, server module, save migration or sandbox configuration. Accent resolution uses UI's existing `B47ANCEDUI` local slot 0; no preference file is written by styling. Other consumers' appearance preferences remain separate. The styling adapter itself adds no labels: native translations and font metrics remain authoritative. The separate Interface page adds localized keys with explicit unreviewed English fallback. Public API major 1 is unchanged.

## Evidence and runtime gates

[VERIFIED — installed Lua] Steam build 25485521, target Build 42.21. Portable source fingerprints/line ranges are in `STYLE_SOURCE_EVIDENCE.json`; full engine version was not freshly queried through a game launch. No external-mod code/assets were used.

[TESTED — offline Windows, 2026-10-20] `python -X utf8 -B scripts/check_versions.py`, `python -X utf8 -B tests/run_tests.py`, `git diff --check`. Isolated Lua 5.1 contract doubles cover unchanged geometry/fonts/callbacks/value ownership/controller row references; original page stencil calls; late controls, recreation, custom-renderer/swatch refusal; active versus hovered tabs; detached controls; shared popup ownership, live accent colour and exception restoration; volume shim cleanup. Existing suites also pass. These doubles do not execute native Apply/rollback logic or simulate engine input.

[RUNTIME GATE — NOT TESTED] Open Options from the title screen and Esc menu; check every native tab at small/large fonts, translations and standard/ultrawide resolutions. Check tab overflow, wheel/stencil clipping, dropdown search/capture/ownership on another screen, disabled states, slider release outside bounds and mouse/keyboard/controller focus. Rebind/cancel a key; test audio preview then Back/rollback; change display mode and revert its confirmation; verify Accept/Apply/Back, restart prompts and mod option panels. Native drawing performance remains unmeasured. G6 NOT TESTED; project G7/stable G8 remain BLOCKED. No package, deployment, game/server launch or Workshop upload was performed for this source iteration.

## Interface page (0.7.0-dev.1)

OptionsInterface now adds a native page through MainOptions.addPage for the existing accent/appearance editor and safe HUD layout workspace. It restores mainPanel/addY after construction, preserves native page/controller/stencil paths and keeps existing settings controls/Apply/Back unchanged. Its HUD button is disabled in-game; return to the frontend to edit static previews. User-approved safe previews replace unsafe construction of live player/world HUDs. Page labels use fallback translation keys. See UI_WORKSPACE.md for support, persistence, provider API and runtime gates. Offline owned-page/action/stencil fixtures PASS; native Options/controller acceptance NOT TESTED.

## Deferred construction correction (0.7.0-dev.3)

The developer's 0.7.0-dev.2 local test reported vanilla settings/Options despite source/deployment hash parity. Current diagnostic evidence showed deferred hidden-screen construction and a later full native build. The old adapter ran only at module/menu/game/reset checkpoints, required root.tabs, and silently missed a screen built after those checkpoints. An independent delayed-construction regression fails before the fix with `Deferred Options creation left the screen vanilla`.

OptionsLifecycle now observes each MainOptions instance, wrapping only its existing create/prerender delegates. Callbacks run after completed construction or drawing, once per current tabs identity; this also catches a builder that invokes a saved native construction function without calling the instance create wrapper. Native multi-return values, including nil tails, and errors are preserved. There is a bounded per-frame readiness check, not a widget-tree scan or timer. Listener failures release the reentrancy guard and propagate. Global classes are unchanged.

NativeSettings recognizes only the observer's own prerender wrapper when validating an otherwise native renderer. Unfamiliar root renderers remain refused; native child/swatch/custom-panel guards remain. Existing styled roots adopt a new native tabs panel once. OptionsInterface keys its page marker to the current tabs panel, adds one page after readiness, and restores native mainPanel/addY. A bounded diagnostic reports styling/interface attachment booleans after tabs readiness; attachment alone does not prove the final pixels or input behavior.

Source-only Build42.21/Steam25485521 evidence and neutral third-party observations: STYLE_SOURCE_EVIDENCE.json and THIRD_PARTY_RESEARCH.md. Offline tests cover latecreate, saved construction during prerender, rebuilds, idempotence, returns, native failure and foreign-renderer refusal. User-facing Apply/Back/display/audio/keybinding/controller behavior remains native. Native post-fix opening/closing/tabs/controller acceptance is NOT TESTED; project G7/stable G8 remain BLOCKED. No new deployment/launch/upload at this source checkpoint.
