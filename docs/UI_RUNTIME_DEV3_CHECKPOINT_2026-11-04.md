# UI development checkpoint and MP test publication

Project Version: 0.12.0-dev.3

Recorded 2026-11-04. This is a compatible PATCH checkpoint to published 0.12.0-dev.1. API1, local schemas, approved menu/logo defaults, gameplay ownership and existing artwork remain unchanged. Publication is authorized as an MP testing build; it does not complete the acceptance suite.

## Evidence and scope

The [60-case development ledger](UI_RUNTIME_DEV3_CHECKPOINT_2026-11-04.json) records bounded frontend/disposable-SP observations and one offline preset-packaging case from incremental dev.3 snapshots: 38 PASS, 17 LIMITED, 4 retained FAIL_STYLING_GAP observations and 1 PASS_OFFLINE. The failures are retained alongside subsequent retests; these are case results, not the 61-area inventory or a certification of the final payload. Earlier cases without exact manifest bindings remain observations of that development checkpoint. The [dev.2 baseline](UI_RUNTIME_ACCEPTANCE_2026-10-24.md) remains byte-for-byte historical evidence.

Observed corrections include menu/logo body movement and menu edge/corner resizing; foreign-modal suspension with retained drafts; HUD selector targeting, direct body movement and dirty Cancel/Discard; contained keybinding rows/controller sections and picker placement at1920x1009; native selection/contrast on frontend, radio, code viewer, crafting images, Host configuration and MP browser. Real SP radio/device, fluids, maps, mechanics and other scoped routes are recorded individually. Callback-assisted routes are not proof of physical keyboard input. Existing engine/provider overrides prevent pristine-vanilla certification.

The user confirmed that Advanced Audio tooltips are fixed. The root cause was an alpha-zero native tooltip positioning pass painted opaque by the adapter. The fix preserves native alpha, content and later cursor positioning. The latest legacy/PZAPI scrollbar implementation has strict offline ownership, geometry, texture restoration, per-mod scope and error-cleanup coverage; final native scrollbar visual/input acceptance is still pending. Its last isolated copy manifest is SHA25679d37b604a42bf93148bdde98ac25f4e7f3eebac8ad55ceff840347c83eb1995. Current normalized runtime fingerprints are in NATIVE_ROLLOUT_SOURCE.json; historical observations are not silently rebound to them.

## Current checks

[TESTED: offline Windows, 2026-11-04] `python -X utf8 -B scripts/check_versions.py` and `python -X utf8 -B tests/run_tests.py` PASS using pinned requirements-dev.txt/lupa2.6. The suite checks Lua5.1 syntax with next unavailable, native-shaped regressions,78-file Lua-only inventory, case-correct requires,201 keys across29 unreviewed English-fallback locales, archive corruption/path/case/CRC rejection, image integrity, VDF real-newline/identity checks and disposable preset packaging. Independent read-only review found no production blocker in the dev.3 diff and focused scrollbar/tooltip/PZAPI probes passed. Package/release checks and CI must also pass before upload; their exact source/hash results belong to the separate publication receipt.

[RUNTIME GATE] Overall acceptance INCOMPLETE. Scrollbar rendering/input, full HUD resize/save/reload, small-screen specialized Options, physical input/controller/split-screen, fishing/appliances/tutorial/death and dedicated social/admin paths remain pending. No controller was available. A disposable dedicated server reached bootstrap and was shut down gracefully, but no client joined: G7 BLOCKED / NOT TESTED; stable G8 BLOCKED. Original real saves were not used. Private diagnostics, fixtures, credentials and account/profile data are excluded from this repository.
