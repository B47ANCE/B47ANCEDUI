# Optional menu interoperability

## PZ Optimization menu label - 2026-10-19

Purpose: style the optional main-menu entry and relocate its live version/update subtext within B47ANCEDUI's menu layout. No gameplay or optimization capability is implemented or required.

Provenance: public repository https://github.com/xD3I/PZ_Optimization (owner xD3I); official README links Workshop item 3805285544. Human author and reuse license are UNKNOWN; no license-based reuse is claimed. Inspected installed text metadata reports release 25, commit d1bbdcf and game revision 4a0e9546ec. The narrow Lua evidence file is `media/lua/client/pzopt/pzopt_mainscreen_menu.lua`, SHA-256 `874f797249523303f64e1797952ba857f11cdad859709002aec10fe1eba8143a`.

[VERIFIED: source inspection] Public widget contract observed by a read-only scout:
- ISLabel, internal PZOPT_MENU, parent MainScreen.bottomPanel, native Large font; own click callback and custom prerender.
- The renderer invokes vanilla title/fade/glyph/tooltip behavior and emits a live note with drawText using UIFont.Small. The note covers version/update state and has state-dependent colors.
- It temporarily changes row height while rendering. Its own update loop controls visibility, text and sizing.

Source references: external Lua lines 124-131, 3448-3459, 3474-3488, 3524-3535 and 3671-3692; vanilla OptionScreens/MainScreen.lua 897-906 and ISUI/ISLabel.lua 70-98. No source bodies are reproduced here. Installed metadata dates are not runtime evidence.

[VERIFIED: own source] B47ANCEDUI 0.5.0-dev.6 NativeMenus.lua adopted known vanilla renderers only. The custom label therefore entered background layout without b47NativeMenu scaling/style, while its note retained the old local Y. This explains the reported mismatch and overlap.

## Independent implementation boundary

The implementer used the scout's neutral widget/draw contract and existing own/vanilla UI interfaces. The optional adapter matches ordinary Lua widget fields, invokes the existing renderer once, temporarily intercepts title/Small-note text, its row backing and its own joypad texture, then restores methods and height even on failure. Title uses shared styling; the live note is centered in reserved space below it. The controller glyph follows the transformed title and primary row, while other textures pass through. It preserves callback, glyph selection, tooltip, visibility, original status text/colors and error propagation. It delegates unchanged outside the active security-room main menu.

No external source, algorithms, assets, strings, updater code, classes or runtime components were imported. No external or vanilla file was modified. No PZ Optimization require/API, installer, Java bridge or dependency was introduced. Unknown custom renderers keep the previous behavior. Absence of PZOPT_MENU is a no-op.

## Clean-room checklist

- [x] Narrow public compatibility question and provenance recorded.
- [x] Source observation separated from implementation through a read-only scout.
- [x] External code/assets imported: NONE; license-based reuse: NONE.
- [x] Original synthetic fixture uses dummy title/status, not external source.
- [x] No game/server launch, deployment or publication during the original dev.7 research checkpoint; subsequent test distribution is recorded separately.
- [x] Independent read-only compatibility/clean-room reviewer signoff: /root/panorama_geometry_review, 2026-10-19. Final own source/tests, neutral ledger and vanilla contracts reviewed; glyph finding resolved, no further concrete defects found. No external implementation was read by the reviewer. Limited engineering/source review only, not provider/PZ runtime acceptance or legal clearance.

[TESTED: offline Lua 5.1] New fixture fails on the pre-fix dev.6 NativeMenus/MenuBackground and passes on dev.7. It checks title style, live note changes/colors, reserved rows, callbacks, glyph coordinates/scaling and unrelated texture pass-through, tooltip invocation, exception restoration, inactive-background delegation, scoping/idempotence and crowded layout. Current commands: `python -X utf8 -B scripts/check_versions.py`, `python -X utf8 -B tests/run_tests.py` and `git diff --check`. This is not MP or in-game evidence.

[RUNTIME GATE] Test with the installed menu provider: resize/font scales, hover/controller navigation and glyphs, opening/returning, release/update/download/error/restart notes and other menu mods/load order. Provider changes outside this observed contract remain UNKNOWN. G7/stable G8 stay BLOCKED under project integration gates.
