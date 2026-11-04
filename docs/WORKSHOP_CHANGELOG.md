Version 0.12.0-dev.3

MP testing build - dedicated multiplayer NOT TESTED

- Fix menu/HUD editor capture, dropdown selection and unsaved-change guards; preserve approved menu/logo defaults and saved overrides.
- Improve Options keybinding rows, checkbox captions, controller sections and color-picker placement while retaining native settings and actions.
- Apply complete preset-colored scrollbar tracks, thumbs and arrows to supported native/PZAPI controls, preserving geometry, per-mod scope, exclusions and foreign content.
- Fix empty displaced Advanced Audio tooltips; the user confirmed the correction.
- Improve native panel selection, radio headers, code-view/mod-path contrast, crafting/stencil descendants and selected images; retain semantic colors and native callbacks.
- Clarify Save preset, percent opacity and duplicate preset names. Include the preceding dev.2 RGB editor startup fix.

Offline Lua5.1 regression, source/version/localization, archive and preset-packaging checks PASS. API1, schemas, artwork and defaults are unchanged. Native acceptance remains INCOMPLETE; final scrollbar runtime tests and other unreached paths remain pending. Current dev.3 evidence:60 bounded incremental development cases are recorded in docs/UI_RUNTIME_DEV3_CHECKPOINT_2026-11-04.md. They do not certify all61 areas or the final payload. Advanced Audio tooltip fix is user-confirmed; final scrollbar visual/input retest, controller/split-screen, ultrawide hardware, plugin publication/subscription and dedicated paths remain pending. G7 BLOCKED / NOT TESTED; stable G8 BLOCKED.
