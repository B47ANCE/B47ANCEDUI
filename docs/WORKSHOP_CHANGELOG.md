Version 0.12.0-dev.2

Development candidate, NOT UPLOADED. Fix preset editor initialization before native RGB callbacks; current Workshop distribution is0.12.0-dev.1.

MP testing build - dedicated multiplayer NOT TESTED

- Extend the near-black theme across audited frontend, gameplay and specialist native window/control chrome, inventory/loot, context menus, tooltips and selected confirmations. Preserve native actions, settings, semantic colors and guarded provider content.
- Add searchable Options categories, responsive section cards and contained pages. Correct deferred initialization, dropdown/category visibility and installed tooltip-map usage; keep native Back/Apply/Accept behavior.
- Add 53 editable color channels, synchronized hex/RGB controls, specific Scrollbar styling, multiple local component presets and per-mod overrides. Save/Cancel and unsaved-exit protection preserve user choices.
- Enabled data-only preset plugins add inactive choices. Explicit selection previews a detached editable copy; saved copies survive source-pack removal or updates. Installing a pack never activates it automatically.
- Export selected styling with separate New/Update choices, verified data and identity journals. An optional manually started Python packager stages dependent Workshop mods with retained history and native item metadata. Final Publish remains explicit in PZ's uploader; layouts and legacy Appearance preferences are not exported.
- Improve main-menu/logo layout editing and the black-canvas HUD workspace with direct preview movement/resizing, larger inspector controls, inert blank clicks, guarded dropdown dismissal and unsaved confirmation. Preserve the approved shipped defaults and valid local overrides; clock/moodles remain reference-only.
- Apply the shared style to main-menu Quit to desktop confirmation. Correct unsupported Kahlua global-next checks and the absent empty-inventory event bootstrap without changing gameplay or public API1/profile schema1 contracts.
- Preserve the existing security-room artwork, independent 1-60 second CRT static/no-signal loops and title-screen audio behavior.

Offline syntax/regression/source/version/translation/integrity checks pass. Native acceptance is FAILED / INCOMPLETE; representative frontend/SP/preset paths were reached, but full visual/input/controller, split-screen, helper-to-uploader handoff, plugin publication/subscription and dedicated multiplayer acceptance remain pending. G7 BLOCKED / NOT TESTED; stable G8 BLOCKED. Distribution does not establish runtime acceptance.

Current candidate acceptance (2026-10-24): FAILED / INCOMPLETE. The bounded45-case report includes baseline/candidate runtime and offline fixture packaging. RGB editor construction is corrected; Options clipping, layout-editor input, native selection chrome and unreached areas remain. Full controller/split-screen/ultrawide/dedicated acceptance and plugin publication remain pending. Workshop remains0.12.0-dev.1; this candidate has not been uploaded. See docs/UI_RUNTIME_ACCEPTANCE_2026-10-24.md in the public source.
