# Native UI rollout

Project Version: 0.12.0-dev.2

Current evidence (2026-10-24, dev.2): [dated acceptance report](UI_RUNTIME_ACCEPTANCE_2026-10-24.md). Overall native acceptance is FAILED / INCOMPLETE. Earlier version-specific NOT TESTED statements below retain their original checkpoint scope. The 45-case pass combines published baseline, candidate frontend/disposable-SP observations and offline fixture packaging; all61 areas are classified (18 LIMITED,17 FAIL,26 NOT_REACHED), with no complete-area PASS. Orange native selections/local subclasses and Options/editor geometry/input failures remain.

0.12 extends these same guarded drawing paths with53 editable colors and specific surface/state/slider/scrollbar/check/title/menu/tooltip/progress channels. Disabled-button outlines use the native enable field and retain focus precedence; pressed colors preserve native fade interpolation. Native text-entry text/placeholder setters are used only for API-owned inputs. PZAPI icon and scrollbar thumb bodies are supported; universal thumb-hover and native cursor/selection/semantic item colors remain outside this adapter. Palette loans still restore on errors and Cancel. Shareable data packs add inactive choices, never implicit styling; [preset workflow and helper](PRESET_PLUGINS.md).

The shared near-black theme now has an automatic adoption route for the audited native Lua UI classes, across frontend setup, gameplay windows and specialist tools. It preserves each screen's native controls and behavior. The source implementation and offline checks are supplemented by the bounded failed/incomplete native pass linked above. It is not a claim that every candidate is an active screen or that every pixel has been replaced.

## Coverage

| Area | Implemented presentation route |
|---|---|
| Solo/challenges, saves, worlds/spawns, sandbox, character creation/traits | Audited native frames and descendants; shared controls retain native geometry, values and callbacks. |
| Multiplayer browser, connections/errors/downloads, hosting/server configuration, invites/co-op | The same bounded native-instance route, including native modal/text-entry frames. Server permissions and connection logic remain native. |
| Mod manager/presets, Workshop wizard, credits/legal/help, advanced audio | Native window and control chrome; supplied content/artwork is retained. The mod neither submits nor publishes anything through these adapters. |
| Character/health/skills/protection, chat, maps, recipes/building/workstations, mechanics/vehicles | Native frames, tabs, lists, inputs, dropdowns, buttons and scrollbars. Bodies, map layers, recipe/item icons, gauges and gameplay state are retained. |
| Radios/media, foraging, fishing, animals, farming, fluids, appliances, documents, sleep/death, social/player tools, tutorials | Audited Lua frames/shared descendants; native semantic content, timers and actions stay intact. |
| Admin/debug/controller/split-screen tools | Same native chrome route without changing access checks, controller rows, focus callbacks or input capture. |
| Shared controls | Neutral frame/palette tokens, rounded main surfaces, list selection/hover palettes, active-tab treatment, native slider/volume colors and both scrollbar orientations. |
| Existing menu/Options/inventory/editors | Existing specialized adapters retain ownership. The new adapter does not rearrange menu/logo/defaults or replace those renderers. |
| PZAPI | Separate Window/FishWindow/PrintMedia lifecycle adapter. Native BuildUI and direct Inventory/playerInventory prototype instances receive only recognized chrome. TextButton/ImageButton/tab hover and scroll thumb palettes keep native callbacks; printed documents are excluded. |

[The 61-area rollout record](NATIVE_ROLLOUT_COVERAGE.json) maps every prior work area to its current route and limits. The [2026-10-24 pre-rollout audit](UI_COVERAGE_AUDIT_2026-10-24.md) is frozen historical evidence for 0.10.0-dev.2. Its old unadopted counts and source fingerprints are not current completion figures. Registry metadata contains **591 simple/qualified Lua declarations**; the catalogue's separate **16 PZAPI template declarations** are handled through reviewed template contracts. These counts do not prove runtime reachability or independently completed screens.

## Ownership and lifecycle

NativeTheme wraps only two verified native lifecycle methods, `ISUIElement.new` and `addChild`, delegating each once with all results. New/changed instances enter a deduplicated construction queue. `OnPreUIDraw` drains it after constructors and specialized owners complete; there is no recurring whole-UI/world scan. Initial traversal is bounded to 8,192 nodes/64 levels. Native renderer classes and instance identity must match the source-name registry. Qualified globals are resolved by path; inaccessible local classes and changed renderers fail closed.

MainScreen is a recognized transparent container when its existing background adapter owns the renderer; its menu column is excluded. MainOptions and live inventory trees remain under their dedicated adapters. Owned/API/editor trees, custom instance renderers and unknown provider parents are excluded, including after reparenting. Pooled dropdowns are themed only while their current parentCombo is an eligible native owner. Popup palette loans restore on success and exceptions. Tooltips and context menus reuse their existing specialized painters.

Painters lend palette/drawing methods only during native drawing and restore before returning or propagating errors. Geometry/fonts, event actions, data colors, images, stencil calls, selection indices, scroll/hit mathematics, values, callbacks and native return tuples stay native. Standard slider preset dimensions resolve against the existing captured native geometry, including live preview and Cancel. User layout/profile files and their defaults are unchanged. API1 and all schema1 formats remain compatible. This is a compatible **MINOR** presentation addition. Local presentation introduces no shared gameplay state or server sandbox option.

PZAPI uses its declared `_mt.instantiate`/`_addChild` lifecycle. Callback wrappers are prepared before native callback capture; palette setters run after initialization. A fixed list of adopted chrome nodes refreshes through the native root renderUpdate delegate, preserving results and errors. Native palette snapshots support opt-out restoration and native hover helpers that save their previous RGB. Provider-scoped trees are excluded. Only native Texture function identities are compared: its exposed class table can be deep-copied by Meta. No template, native class palette, dispatch metatable, Java class, input handler or third-party file is replaced.

The installed Meta source declares `_mt.instantiate` without `__index`, although native callers use instance dispatch. The adapter preserves this exact contract and does not invent a dispatch repair. Native dispatch/callback timing is a **RUNTIME GATE**. Offline fixtures explicitly call the declared Meta method with no fabricated `__index`.

## Deliberate content and engine boundaries

- Preserve red/green warnings, health diagrams, durability/progress meaning, item/swatch colors, map data/shroud/layers, document typography/artwork, controller glyphs and vehicle instruments. Neutral full frames are chrome; arbitrary neutral rectangles in custom content are not blanket-recolored.
- Native clock/moodle internals, engine radial segment backgrounds, loading/platform overlays and model/item-stat rendering have no verified universal palette contract here. Native exposed geometry/access does not prove a tint API. Those internals remain unchanged; Lua-owned surrounding frames can inherit styling. No custom Java substitute is permitted.
- Bespoke row painters, hardcoded inner textures, inaccessible local UI classes, provider overrides and engine-native internals may retain their native appearance. They are explicit remaining boundaries, not silently marked complete. Register provider-owned API controls or add a separately verified Lua painter when a runtime discrepancy identifies a concrete contract.
- The source identity guard recognizes native class tables/functions observed on first encounter; it cannot certify a class patched by another provider before that encounter. Load order and compatibility still need native testing. Existing engine overrides are present in the installed evidence, so it is not certified pristine vanilla.

Providers can call `UI.excludeNativeTheme(widget)` before attaching a custom subtree; `UI.excludeNativeTheme(widget,false)` releases the opt-out. Ordinary native draw wrappers check this live. PZAPI chrome restores its last themed RGB during the next root renderUpdate without overwriting newer native color changes. API-owned widgets already retain their own styling. The method changes no saved preferences.

## Evidence and acceptance

[Source contracts and fingerprints](NATIVE_ROLLOUT_SOURCE.json) bind the installed Build42.21.0/revision4a0e9546ec/Steam25485521 evidence and current runtime files. Metadata contains names, hashes and line references, not copied game or external-mod function bodies. All implementation is original Lua. Known third-party provider source was excluded and no installed game/mod file was changed.

Current project text fingerprints normalize CRLF to LF for Linux CI/Windows checkout portability; binary assets and installed-game evidence use exact bytes. This normalization is explicitly declared in the new record. Frozen prior audit hashes retain their original formats and observations.

[TESTED: offline Windows, Lua5.1 with next unavailable] `python -X utf8 -B scripts/check_versions.py`, `python -X utf8 -B tests/run_tests.py`, `python -X utf8 -B scripts/check_native_rollout.py` and `git diff --check`. Strict new fixtures cover deferred/late construction, known frontend/gameplay/admin roots, existing owners, custom/reparented/provider trees, native results/errors, semantic colors, transparent frames, player presets, active versus hovered tabs, pooled popup ownership, slider preview/Cancel and horizontal/vertical scrollbars. Atom fixtures cover two-phase initialization/callback capture, separate PrintMedia collapse, live preview/Cancel, native hover snapshots, active search, native Texture identity, dynamic thumb ancestry, scoped presets, document exclusion and opt-out restoration. Existing API/menu/editor/inventory/Options regressions remain required.

[RUNTIME GATE] Validate actual pixels and input across the 61 work areas, including missing/late/pooled windows, existing menu/logo placement, standard/ultrawide/font scales, mouse/keyboard/controller, split-screen player palettes, provider load order, modal focus, tooltips/clipping, native performance, PZAPI dispatch and file reload. Offline fixtures do not establish native rendering, gameplay transfers, permissions, MP synchronization or server behavior. G6 NOT TESTED; project G7/stable G8 BLOCKED. No package/deployment/game launch/Workshop upload is part of this iteration.
