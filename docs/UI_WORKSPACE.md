# Options and safe HUD layout workspace

Project Version: 0.12.0-dev.2

Current evidence (2026-10-24, dev.2): [dated acceptance report](UI_RUNTIME_ACCEPTANCE_2026-10-24.md). Overall native acceptance is FAILED / INCOMPLETE. Earlier version-specific NOT TESTED statements below retain their original checkpoint scope. HUD selector text changed to Nearby Loot while Inventory remained the active preview and plus-button target; direct drags did not move it. Blank clicks stayed inert and Cancel/Discard protected the unsaved draft. Attempted main-menu logo drag closed that editor. Input/capture timing and Escape remain unresolved; offline input fixtures do not establish these paths work natively.

Historical 0.8.0-dev.2 added compatible PATCH fixes for HUD editor input/exit handling to the 0.8 Options workspace. The 0.7 series introduced safe HUD previews and shared unsaved-exit confirmation. Public API major 1, existing appearance storage, main-menu schema 1 and the owner-approved menu/logo defaults remain compatible. That original checkpoint did not package, deploy, launch or upload; the dated dev.2 report above records the later isolated runtime pass.

## Player controls

The actual native **Options** screen retains its existing pages, values, Apply/Back behavior, display confirmation, audio rollback and keybinding controls. Its new **Interface** page opens the existing hex/RGB appearance editor or the HUD layout workspace. The existing near-black native settings styling remains in place. The HUD workspace is also available through **Edit in-game UI** beside the main-menu layout button.

The workspace opens an opaque black screen containing clearly labeled **static previews**. The user explicitly approved these safe samples: no character, inventory, world, chat session or native map is constructed. These samples illustrate layout rather than reproduce every native screen's contents. Built-ins and explicitly registered provider previews are shown; arbitrary unknown mod windows are not automatically discovered.

Select a preview or choose it in the inspector. Drag its body to move it; highlighted edges/corners resize supported dimensions. The inspector has four percentage rows with larger slider thumbs, separate minus/plus buttons (0.5 percentage-point steps), and numeric fields. Numeric input accepts finite 0–100 values; the asset's minimum size and viewport bounds then clamp the result. Multiple pending fields commit together before clamping. Invalid entries keep the workspace open and prevent selection/save until corrected or reset. Height edits preserve an aspect-locked provider's proportions. Tab selects the next asset; arrows move, Shift+arrows resize supported axes; Enter commits a focused numeric field; bare Enter never saves/closes this workspace. Save requires its explicit button action (pointer or focused controller activation). Escape/controller B closes an expanded asset popup first, then requests exit confirmation if the workspace has unsaved changes. These input paths have offline fixtures, not native dispatch acceptance.

Save writes the HUD profile and closes only after the writer reports success. Cancel asks before discarding unsaved changes, with Keep editing as the safe default. Discard changes restores the saved profile without writing; unchanged drafts close directly. Reset overrides discards pending fields and removes registered editable overrides from the draft; Save is still required. Unknown/unavailable provider records are preserved. Reset releases this mod's override; native layout.ini or another mod may retain previously saved geometry, so it does not promise to reset the native window itself.

The scaled preview canvas represents the full current screen. One fixed transparent input surface sits above all preview children and below the inspector. Its local pointer coordinates hit-test the rendered asset rectangles in visible stacking order; only an asset body/allowed grip starts a captured drag. Pointer deltas on that fixed surface are divided by its scale before updating normalized geometry. Empty/out-of-bounds clicks, zero-delta gestures and hover do not create overrides or exit. Selection raises the chosen preview and then restores canvas/inspector layering. Outside/lost mouse release ends capture. The inspector sits outside the canvas and has a measured footer rather than a reserved blank section. Reference previews have disabled geometry fields. Editor captures, native slider flags and numeric focus release during temporary external modal activity, but the draft and any unsaved-exit prompt stay open. Input resumes after the modal clears without stealing another owner's focus. Actual owner removal/replacement/game entry still tears down safely. Close removes only this editor's owned popup/children; a shared dropdown borrowed by another combo is preserved. Focus is restored only while this editor still owns it.

## Supported built-ins

| Asset | Preview editing | Native binding |
|---|---|---|
| Inventory / nearby loot | Move, width, height | ISPlayerData.playerInventory / lootInventory, exact ISInventoryPage |
| Character and health | Move | characterInfo, exact ISCharacterInfoWindow; native size retained |
| Vehicle mechanics | Move, height | mechanicsUI, exact ISVehicleMechanics; native width/content layout retained, native minimum height respected |
| Chat | Move, width, height | Primary ISChat.instance after chat initialization |
| Equipment | Move | equipped, exact ISEquippedItem; native size retained |
| Hotbar | Move | playerHotbar, exact ISHotbar; native slot-dependent size retained |
| Minimap | Move | miniMap, exact ISMiniMapOuter; native size retained and userPosition enabled only for an explicit override |
| Clock / moodles | Reference only | Exposed geometry mutation APIs are not verified; no runtime changes |

HUDLayoutRuntime requires native registration modules before registering its own create/game-start/resolution/chat-init callbacks. It applies only explicit saved overrides after native restoration, to at most four current local-player data slots. It leaves visibility, inventory contents, pinning, controller rows and callbacks with the native UI. Controller-owned player layouts are skipped. A single installation-wide normalized profile is resolved within each mouse-driven player's viewport; independent per-player HUD profiles are not implemented.

The native hotbar recenters every update. Its verified current instance therefore delegates setSizeAndPosition once, then reapplies saved position while that instance still belongs to the same local player. There is no global class patch, new tick event, world scan or per-frame file read. Removing its saved override restores the native positioning path. Native resize callbacks receive absolute width/height; native axis restrictions and widget minima are respected. Application providers are responsible for their own runtime lifecycle and call the public apply method on their owned widgets.

## Local persistence and configuration

The separate cache/Lua data file is `B47ANCEDUI/in-game-layout.txt`:

```text
schema=1
B47ANCEDUI.inventory=0.1,0.2,0.32,0.3
Provider.window=0.2,0.1,0.25,0.4
```

IDs are ASCII scoped names, at most 96 characters. Values are normalized x/y/width/height; sizes must be positive. Reading inspects at most 130 records, accepts lines up to 240 characters, and protects an oversized profile against truncated saves. The format accepts up to 128 asset records; registration supports up to 64 current definitions including built-ins. Unknown valid records survive normal saves. Missing/invalid entries use preview defaults, but defaults alone never force native HUD geometry. Future-schema, read-error and overflow profiles refuse normal Save until explicit Reset acknowledges replacement. Save writes sorted data and advances the cache only after successful write/close; failed calls close the writer. Native silent storage failures and atomic crash durability are not established.

These are local presentation preferences, not gameplay state, player saves, server configuration or network messages. No shared-gameplay sandbox settings are appropriate. Coordinates, registration bounds and minima are technical presentation constraints. Existing menu and appearance files are neither migrated nor overwritten. Older UI builds ignore the separate HUD file. Join/reconnect and player recreation reapply local geometry through the same native creation events; actual event ordering/acceptance remains a runtime gate.

## Public provider contract

```lua
local UI=require('B47ANCEDUI/API').requireVersion(1).forMod('Provider')
UI.LayoutAssets.register('window', {
    labelKey='UI_Provider_Window',
    default={x=.1,y=.1,w=.3,h=.3},
    resizable=true, minWidth=240, minHeight=160,
    preview=function(parent)
        local sample=UI.Panel:new(0,0,240,160)
        sample:initialise()
        sample:instantiate()
        return sample
    end,
})
-- After constructing/restoring an owned real window:
UI.LayoutAssets.apply('window', window, viewportLeft, viewportTop, viewportWidth, viewportHeight)
```

Local keys contain no dot; the facade prefixes its registered consumer ID. Duplicate IDs, invalid labels/defaults/callbacks/dimensions and excess registrations fail explicitly. Definitions are copied; resolve returns pixel geometry for preview/default/profile use. apply returns false without an explicit saved override, editable definition, valid finite positive viewport or required widget geometry methods. The owning provider must decide when to apply after its own restoration.

Optional fields: `editable=false` for reference-only samples, `resizeWidth=false` / `resizeHeight=false` to limit axes, `aspect` for a fixed ratio, `resize(widget,width,height)` for an owned resize callback, and `dispose(preview)` for non-child preview resources. Aspect and disabled-axis constraints cannot be combined. A preview factory must return an initialized owned Lua UI child or unattached widget; it must use safe synthetic data and must not construct gameplay/native world UI, fetch a player, open popups, register events/UIManager roots or write preferences. Keep partial resources under the supplied frame and clean any external resources before throwing. Failed factories show an explicit placeholder and diagnostic; an attached successful preview receives dispose exactly once on close, and children leave with the owned frame. Providers remain trusted Lua code, not a security sandbox. UI never copies or edits external mod implementations.

## Evidence and remaining gates

[VERIFIED: installed vanilla Lua, Steam build 25485521 / target 42.21] Native addPage/stencil/controller setup, text-entry focus, slider pagination, player-data restoration, resize callback dimensions, hotbar positioning and minimap userPosition paths are fingerprinted in STYLE_SOURCE_EVIDENCE.json. Native mechanics uses a y-only resize widget and recomputes width from content. Clock reads do not prove mutable geometry.

[TESTED: offline Windows, Lua 5.1 doubles] `python -X utf8 -B scripts/check_versions.py`, `python -X utf8 -B tests/run_tests.py`, `git diff --check` pass. Fixtures cover profile corruption/future/read/write/overflow, unavailable-provider retention, copy isolation, five viewport ratios, scoped registration, saved-override-only native application, axis/minimum/callback preservation, local-player/controller/stale-instance guards, scaled canvas drag/resize, batch numeric edits, invalid selection, Reset/Cancel/Save, provider aspect/failure/disposal, slider pagination/capture, popup-first cancellation, resolution/modal cleanup and native Options page/action ownership. There are 62 runtime files and 61 translation keys across 29 locales with explicit unreviewed English fallback.

[RUNTIME GATE] Actual native dragging/outside capture, keyboard Enter dispatch, controller focus/popup flow, fonts/languages, settings Apply/Back/display/audio/keybinding acceptance, HUD construction/restoration, split-screen, file reload, hotbar/minimap behavior, provider compatibility and native performance are NOT TESTED for this source. Historical dev.2 local startup does not validate these additions. G6 NOT TESTED; project G7 and stable-release G8 remain BLOCKED. No deployment/launch/upload performed for 0.7.0-dev.1.

## Unsaved exits (0.7.0-dev.2)

The same owned Keep editing / Discard changes confirmation guards both editors. Dirty state includes saved-data differences, meaningful pending/invalid numeric text, and explicit replacement intent after Reset on a future/error profile. Opening the prompt never commits or writes pending text. Keep preserves the draft and text; Discard closes without Save. Saved or unchanged/reverted profiles close directly. A write failure leaves changes unsaved and still protected by confirmation.

The prompt is a child scrim/panel of the editor root rather than a detached gameplay dialog. It owns pointer/wheel input and keyboard/controller routing, clears underlying slider child focus, measures its text/buttons and follows viewport changes. Keep restores the selected native child focus. Duplicate/stale actions are inert. Normal Cancel/Escape/B and switching away are guarded; forced owner replacement, hidden-screen/modal invalidation or game entry cleans up both roots without prompting against a missing owner. No new state/network/schema/sandbox setting. Native popup acceptance remains NOT TESTED.

## Interface page readiness (0.7.0-dev.3)

The shared OptionsLifecycle observer now adds the Interface page after native tabs are constructed, including providers that defer construction until Options opens. Its marker belongs to that tabs generation, so a replacement panel receives one new page; ordinary draws never add duplicate pages. Native stencil/controller setup and root mainPanel/addY are retained. Native settings styling uses the same readiness observer; no provider dependency is required. Offline delayed/rebuilt page tests pass. Actual native tab/keyboard/controller acceptance remains NOT TESTED.


The 0.8 actual Options screen now presents Interface within the shared category sidebar/search/card shell. Interface actions and the safe HUD workspace are unchanged; this does not construct live HUDs from the frontend or change saved schemas/defaults. See OPTIONS_LAYOUT.md.


## HUD input correction (0.8.0-dev.2)

[VERIFIED source / TESTED offline] The old key handler called Save on bare Enter after the native dropdown had cleared expanded, so a selection release could write/close the entire editor. A new regression first fails on the previous source with `Dropdown Enter release saved/closed the HUD editor`. Separately, the former availability predicate included global modal visibility and its update/key paths directly closed the editor; that bypassed the already-shared unsaved confirmation. Owner lifetime and temporary input availability are now separate.

The new fixed canvas covers preview children and validates actual asset bounds before moving/resizing. A registered native SharedPopup belonging to this expanded selector is recognized separately from the global modal boolean (exact popup identity, parentCombo and UIManager membership are required); it cannot trigger suspension by itself. Stale expanded flags do not qualify. Coexisting unrelated native modals remain a runtime check. Dropdown open releases canvas capture; hide clears its stale mouse-down marker and blocks pointer actions through that dismissal until release is observed. Owned footer/step buttons require their own matching down/up; mouse-up alone cannot activate them. Native controller forceClick remains an explicit button action. Sliders are guarded during popup/modal activity. Selection preserves the full multi-asset draft. Save/Cancel/Reset and selector callbacks from removed roots cannot act on a reopened editor. No global classes/provider code are patched.

[TESTED offline Windows] Existing suites plus `test_hud_editor_input.lua` cover native-shaped dropdown ordering, Return release, unpaired/dismissal click-through, fixed-canvas body/edge/corner dragging, overlap order, blank/out-of-bounds/zero-delta events, scaled coordinates with nonzero owner offset, outside/lost release, height-only/fixed/reference-only definitions, explicit Save/Cancel/Escape, pending invalid entries, Keep/Discard, modal draft/prompt/focus retention, stale callbacks, shared popup ownership and actual owner teardown. The old tests' hidePopup double incorrectly cleared expanded; it now mirrors native removal-only semantics, and callers explicitly clear expansion.

[RUNTIME GATE] The user reports mouse dropdown selection closing the workspace on the locally deployed dev.3 build. Current console evidence has no correlated owned-editor exception; the exact engine mouse-event sequence remains unverified. The deterministic close paths above are source/offline findings, not a claim that the mouse symptom is reproduced in PZ. Check native dropdown pointer/controller opening/selecting/outside dismissal, no click-through to Save/Cancel/sliders, body and all enabled grips, empty canvas, outside-window release, unsaved Cancel/Escape Keep/Discard, focus recovery and save/reopen after separately authorized deployment. No deployment/launch/publication in this source checkpoint; native SP/controller acceptance NOT TESTED, project G7/stable G8 BLOCKED. See STYLE_SOURCE_EVIDENCE.json.

## Separate style editing (0.9.0-dev.1)

Options → Interface also opens the style preset inspector. Visual presets are separate from layout geometry, providers and saved schema1 menu/HUD files. It reuses the existing unsaved guard with a style-specific message, and preserves pending invalid fields, explicit Save and popup-first exits. The new full-viewport veil blocks underlying Options actions; its sample area is scrollable and inspector styling is protected. No new gameplay HUD construction is added. See STYLE_PRESETS.md; native input/render acceptance NOT TESTED.
