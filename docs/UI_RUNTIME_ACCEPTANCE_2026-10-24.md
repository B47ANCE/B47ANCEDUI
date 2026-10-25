# Native UI acceptance pass, 2026-10-24

Test candidate: **0.12.0-dev.2**, compatible PATCH to the published 0.12.0-dev.1. API1, schemas, approved layout defaults, native actions and gameplay ownership are unchanged.

**Overall result: FAILED / INCOMPLETE.** This pass records 45 cases across published-baseline/candidate runtime and offline fixture packaging and classifies all 61 audited areas: 18 have limited observations, 17 have unresolved defects or styling gaps, and 26 were not reached. These counts are areas, not individual windows or passed tests. No complete-area PASS is claimed. The [machine-readable record](UI_RUNTIME_ACCEPTANCE_2026-10-24.json) includes individual cases, source fingerprints, remaining checks and implementation targets.

## Environment and evidence

[TESTED: native Windows frontend and disposable SP] Build42.21.0, revision4a0e9546ec, Steam25485521. Computer Use inspected actual game rendering at 1280x800 and 1920x1009, with the existing fontSize option6 unchanged. A separate cache/profile contained only UI, then one generated data-only preset plugin. A new sandbox character/world used Zombie Count=None. Installed PZ Optimization engine overrides remained; this was not a pristine vanilla installation. Custom launcher agents were excluded. No upstream or engine files were modified.

The locally subscribed UI content matches all78 exact published dev.1 file hashes in the immutable distribution receipt. This verifies installed bytes, not download timing or preset-plugin Workshop publication.

Real saves were not loaded. Hashes of the original options, active-mod list, menu layout, HUD layout and appearance preferences still match their pre-test copies. The original console changed during the earlier game shutdown; its pre-test copy was retained. Raw logs, cache files and launch helpers remain private. Screenshots were inspected directly through Computer Use. The JSON binds private log hashes and the tested 78-file source snapshot, based on parent46db745ea1eca24d1c9270374d3aa2c552d2ec15 with the stated uncommitted candidate changes.

Mouse checks produced the observations below. Injected Escape, B, Ctrl+A and text input were inconsistent, including in native Credits and the focused search field. Alt+F4 closed cleanly. Input delivery, installed overrides and UI focus/capture remain possible factors; no keyboard/search root cause is assigned. Actual controller, split-screen, 21:9/32:9 hardware and audible menu-audio suppression were not tested.

## Confirmed blocker fixed

Published dev.1 failed when opening Options > Interface > UI Style Presets. Native `ISSliderPanel:setValues` calls `setCurrentValue`, which invokes its callback during construction. RGB callbacks reached `StyleEditor.lua:112` before the text handler existed. The previous double omitted that native behavior.

Dev.2 initializes the editor with synchronization active until construction and final refresh finish. The stricter fixture first reproduced the line112 failure, then passed after this one-line guard. It checks unchanged initial draft/persistence and all three RGB channels. Native retesting verified editor opening, Red click/drag, live hex/sample changes, Inherit, Keep editing, Discard, Save/reopen and plugin preview. There is no new API, profile or default change.

## Results by navigation group

| Group | Actual windows/actions reached | Result and limits |
|---|---|---|
| Startup/main menu | Published reload and cold boot, candidate cold boot, bunker, four static/no-signal transitions, optional subtitle, editor entry buttons | Limited pass at both sizes. Approved independent logo/menu defaults retained. Other font scales, dynamic row changes and audio listening pending. |
| Quit/pause | Frontend Quit confirmation cancelled; in-game Esc menu and Resume | Dark chrome/menu navigation reached. Native semantic red/green square outlines remain; inspect corner ownership separately from meaningful colors. |
| Options | Every category entry; Display sections; Audio pages1/2; Rendering and Accessibility pages1/2; key-capture Cancel; Interface tools | Ordinary contained pages fit. Keybinding and controller geometry fail at both sizes. Picker extends offscreen at1280. Search text acceptance unresolved. |
| Style/appearance | RGB/hex synchronization via sliders, Inherit, family/property dropdowns, Keep/Discard, Save/reopen, accent Reset/Close | Specific editor crash fixed. Full CRUD, typed hex, scopes, all53 channels/states, specific scrollbar tokens and cold reload of a changed profile remain pending. |
| Preset plugin | Actual191-byte export, offline helper stage, native Mods enable/Accept/Lua reload, inactive catalog entry, explicit detached preview, Save/reopen, original Default restoration | Bounded end-to-end local pass. Duplicate local Default labels are ambiguous. No actual Steam upload/download or helper-to-uploader handoff test. |
| Layout editors | Main-menu editor; black HUD preview workspace, selector, plus, blank click, Cancel/Discard | Failed interactions: attempted logo drag closed its editor; HUD selection label changed while Inventory remained active; plus edited the wrong asset; direct drags did not move it. Capture/input root cause unresolved. |
| New game | Difficulty, Custom Sandbox, spawn map, Time/Zombie settings, occupation/traits, avatar, Play | Usable flow. Orange native selections and local panel descendant gaps remain. Character/content/status colors preserved. |
| Load/Mods/Workshop | Disposable save details/More/Back; About Mods/selector; Workshop directory selector/Back | Usable navigation, native orange selection chrome remains. No save deletion/rename, publication or unrelated activation changes. |
| Multiplayer/Host | Empty Favorites browser; Host setup and empty configuration-management list | Chrome/navigation only. No connection, credentials, server configuration change or server launch. |
| Character | Info, Skills, Health, Exercise/Close, Protection, Temperature | Representative panels fit; native diagrams/status colors retained. Garment inspection and all descendants not reached. |
| Inventory/contexts | Inventory and cupboard loot expansion; Jeans tooltip/context/More submenu | Representative rendering works. Fixed-width long category clips. No transfer/equip/craft; pooling exhaustion and every row/state pending. |
| Craft/build | Natural table crafting and Building recipe browsers; requirements/disabled actions; close | Usable, with native orange category/recipe selections. No craft or placement. |
| Map/foraging/appliance | World map/key/symbols/settings/Close; Foraging/Search Focus dropdown; oven settings/Close | Representative windows fit. No annotations, Search Mode, appliance activation or knob changes. |
| Credits | Native scrolling content | Content renders; injected Escape unresolved, graceful OS close worked. Legal/help/report destinations not followed. |

## Remaining fixes, in priority order

1. Correct narrowed Options keybinding columns, nested controller layout and owned color-picker bounds. Preserve native binding objects, callbacks, semantic palette, capture and focus return.
2. Reproduce layout-editor selection/drag/resize and Escape with controlled native input. Check owned-popup teardown, global modal guard, capture and mouse-button state before changing the guard. A changed combo label alone is not a successful asset switch.
3. Add scoped native selected-row/tab painters for the reached setup, save, Mods, Workshop, server-browser and craft/build paths. Local native subclasses are actionable Lua scope gaps. Do not remove global identity guards or overwrite external files.
4. Disambiguate imported local preset display names without changing stable IDs or authored pack data. Improve inspector terminology (the style Save button still says “Save layout”), disabled-button shape consistency and sparse-page density.
5. Resolve the native translation-format warning for `UI_B47ANCEDUI_StyleProperty_opacity`. It is separate from the fixed nil-handler crash. Specific scrollbar channels need a dedicated visual pass; changing generic Accent alone did not visibly recolor the horizontal sample thumb.

Intentional native content includes body/model/item/recipe/map/document artwork, warning/cost/condition colors, instrument/radial/clock/moodle internals and platform overlays. Their presence is not proof of missed chrome. Source targets and exact unresolved boundaries are in the JSON actionability list and [rollout record](NATIVE_ROLLOUT_COVERAGE.json).

## Unvisited gates

Natural FishWindow/PrintMedia routes, vehicles/mechanics/dashboard, fluid panes, animals/farming, radio/media controls, workstation descendants, alarms/sleep/death, chat/social/admin/debug, cooperative joins and advanced sound remain NOT REACHED or NOT TESTED. The SP fixture does not establish dedicated MP, reconnect, server startup or persistence correctness. G7 remains BLOCKED / NOT TESTED and stable G8 BLOCKED. Do not call the complete UI overhaul accepted.

The original real-profile `NativeMenus.lua:53` failure was not reproduced in isolated published/candidate startups. Its initiating error was absent from the supplied truncated logs. Duplicate same-ModID installations alone do not prove mixed modules; partial initialization and different-ModID path overrides remain hypotheses. This patch does not claim to resolve that original full-profile failure.

## Validation

[TESTED: offline Windows, Lua5.1 doubles/Python] Exact commands:

```text
python -X utf8 -B scripts/check_versions.py
python -X utf8 -B tests/run_tests.py
python -X utf8 -B scripts/check_native_rollout.py --game-root <verified installed ProjectZomboid directory>
git diff --check
python -X utf8 -B scripts/preset_packager.py <actual runtime export> --zomboid-dir <isolated test profile>
```

All passed. The rollout checker binds the current tested source and 61-area classifications to this report and rejects mismatched evidence; its PASS is consistency, not native acceptance. The actual export SHA256 is `d1353c27897fdce1e5c110a8e766fcd4c1550b9d2fd759fb161382a0c67ad586`; staged payload contains six exact files plus metadata/receipt and no runtime Lua code.

Game windows were closed gracefully. No UI release package or Workshop update was produced; the data-only preset fixture stayed private. Workshop item3822582242 remains at0.12.0-dev.1; immutable publication receipts retain their original versions and hashes.
