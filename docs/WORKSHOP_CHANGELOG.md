Version 0.9.0-dev.1

- Development main-menu Quit to desktop confirmation now uses shared near-black rounded surfaces and local accent; native Yes/No actions/focus/geometry retained. Native acceptance NOT TESTED; not uploaded.

- Development HUD editor input fix: explicit Save/Cancel/Escape exits, shared unsaved confirmation, direct preview movement/resizing, inert empty canvas, guarded dropdown dismissal and retained modal drafts. Native dispatch NOT TESTED; not uploaded.

- Development Options workspace: searchable header, category sidebar, responsive native section cards, editable grey accent and fixed native Back/Apply/Accept actions. Native settings values and behavior preserved; specialized/provider content keeps native internals. Native input/controller acceptance NOT TESTED. Not uploaded; Workshop remains0.5.0-dev.11.

MP testing build - dedicated multiplayer NOT TESTED

Development source only; NOT uploaded. Workshop remains 0.5.0-dev.11.

Fix native Options remaining vanilla when its build is deferred until opening. Attach styling and Interface after completed construction/draw, once per current tab panel; preserve native settings/returns/errors and custom-renderer boundaries. Offline regression passes; post-fix native acceptance NOT TESTED.

Guard unsaved layout exits with Keep editing / Discard changes, including unfinished numeric entries and switching editors. Default to Keep; preserve drafts/focus and prevent underlying controller slider updates. Clean/reverted layouts and successful Save close directly. Native popup input NOT TESTED.

Add an Interface page to the actual native Options screen for accent/appearance and a safe in-game UI layout workspace. Preserve native settings, tabs and Apply/Back behavior. Add Edit in-game UI to the main menu: black canvas, clearly labeled synthetic previews, no loaded character/world.

Improve both layout inspectors with larger slider thumbs and click targets, separate step buttons, numeric percentages, edge/corner handles and compact footer spacing. Correct pending-entry switching/reset and batched clamping. Preserve the owner's approved main-menu/logo defaults and existing saved profiles.

Save explicit local overrides for supported native HUD windows. Inventory/loot/chat resize both dimensions; mechanics supports height, fixed-size assets support position; clock/moodles remain reference-only. Providers can register safe owned previews through the compatible public Lua API. Unknown mod windows are not automatically adopted. Native controller layouts are skipped; native layout persistence may retain prior positions after Reset releases our override.

Offline Lua 5.1/source/version/translation/archive/regression fixtures PASS. Native input/controller/settings/HUD restoration, split-screen and actual persistence acceptance NOT TESTED. Project G7/stable G8 BLOCKED. Existing artwork, four independent 1–60 second static/no-signal screens and title-screen audio behavior are unchanged. No package, deployment, game/server launch or upload in this iteration.

Development source addition: editable local UI style presets for supported component families, shared styles/per-mod overrides, live preview, explicit verified Save and unsaved Cancel/Escape protection. Native input/persistence acceptance NOT TESTED. Workshop item remains on the historical published build until a separate upload is requested.
