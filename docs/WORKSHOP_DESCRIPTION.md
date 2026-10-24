# B47ANCE'd UI

## Overview
Shared Lua-only interface components for B47ANCE'd Workshop mods in Project Zomboid. This foundation supplies a consistent presentation API to cooperating mods. It does not replace every vanilla interface.

## Features
- Development source: attach Options styling and Interface after deferred native construction or tab rebuilding. Native settings/actions and custom renderers remain guarded. Post-fix native acceptance NOT TESTED; not uploaded.
- Development source: unsaved layout exits require Keep editing / Discard changes confirmation; pending entries, Reset and editor switching are protected. Native popup acceptance NOT TESTED; not uploaded.
- Development source: actual Options Interface page plus main-menu Edit in-game UI workspace with safe static previews on a black canvas. Supported HUD positions/sizes apply after native construction; clock/moodles are reference-only. No character/world loading. Not uploaded.
- Development source: larger inspector sliders/steps, numeric percentages, edge/corner handles and compact footer; scoped opt-in preview/layout API for providers. Native acceptance NOT TESTED.
- Development source: native Options/settings styling with near-black surfaces, rounded tab/button headers and existing local accent colours. Native settings/input remain owned by PZ; custom renderers are guarded. Native acceptance NOT TESTED; not uploaded.
- Development source: owner-approved saved placement is the default for new/reset menu layouts; valid saved overrides keep priority. Local editing retains independent menu/logo move/resize, locked logo proportions, percentage sliders and Save/Cancel/Reset. Not uploaded; Workshop remains 0.5.0-dev.11.
- Near-black native buttons, windows, lists, text inputs and context menus with restrained rounded corners.
- Small and Normal button sizes; older Large requests use Normal.
- Separate large-text MenuButton for consumer-owned menu navigation: transparent backing, no button frame, subtle accent text and underline on hover or controller focus.
- Native main-menu and in-game Esc-menu navigation use the same text/underline style, preserving native actions, visibility and controller order.
- Security-room main menu with four decorative CRTs: independent 1-60 second startup static, then persistent no-signal loops. The room artwork fills narrow and 32:9 ultrawide screens without distorting the CRTs; visible mod-added menu items are placed beneath the logo.
- Runtime-only main-menu music gain mute; saved audio preferences remain unchanged. Audible rain/thunder suppression requires an in-game listening check.
- Selected continuous room with the horizontal pipe completed across the left wall at its existing height; the logo/menu fit beneath it, above the baseboard and clear of the desk.
- Bunker decoration: right-side filing cabinets, security board, keys and intercom; shadowed storage and ventilation at the far left.
- Optional PZ Optimization menu-entry compatibility: shared title style and a reserved version/update subtitle; original action and live status retained. No provider dependency.
- Shared rendering, layout helpers, controller focus, dialogs and bounded tooltips.
- Independent appearance preferences for each consuming mod and local player.
- Local opacity and hex/RGB accent editor with live preview; default accent is neutral grey (#B0B0B0).
- Read-only import of registered legacy opacity preferences.
- Original clipboard drawing for cooperating application screens.

## Compatibility & Requirements
Target: Project Zomboid Build 42.21. Mod ID: B47ANCEDUI. Public client Lua API: 1.

UI does not require Quartermaster, Rooms, PC Framework or custom Java/JAR components. Dependent mods supply their own application screens, labels, gameplay callbacks and required dependencies. Install and enable UI with dependent mods on the server and clients.

MP testing build - dedicated multiplayer NOT TESTED

Offline Lua 5.1 contracts, syntax, source inventory, translation coverage and package integrity fixtures passed. The earlier 0.5.0-dev.2 menu visuals were observed in an isolated local game profile; 0.10.0-dev.2 Options/editor/native HUD input, controller, split-screen, settings reload, subscription/download and dedicated-server behavior are NOT TESTED. This is test distribution, not stable-release certification.

## Configuration
Consuming mods can expose the shared local appearance editor: background opacity, a #RRGGBB hex field and Red/Green/Blue sliders (0–255). Changes preview locally; Reset restores opacity 82 and grey #B0B0B0. Existing opacity-only settings retain their values. Values are isolated by mod and local player. Appearance settings do not change gameplay or server permissions. There are no shared-gameplay sandbox options in this presentation-only foundation.

## Source Code & Development
GitHub: https://github.com/B47ANCE/B47ANCEDUI

Mod developers consume the versioned public Lua API. Application data, server authority and synchronization remain with the application mod.

## Known Issues
The native menu adapter changes verified navigation labels only; other menu mods may conflict or leave guarded items in their original style. Startup/profile loading and native main/Esc acceptance require in-game testing. Live CCTV feeds, the full vanilla UI overhaul and automatic adoption of arbitrary window layouts remain planned; supported HUD previews are implemented in development source. Runtime visual/input acceptance, actual settings reload, native rounded-draw performance and texture-corner clipping remain outstanding. No universal click-through, arbitrary custom font support or multiplayer verification is claimed.

## Credits & Permissions
Developed by B47ANCE'd Workshop. Original B47ANCE-owned shared code extracted from Quartermaster with explicit owner authorization. No external mod implementation or assets copied. No reuse license is implied beyond permissions separately granted by the owner.

## Development background

Version 0.10.0-dev.2 adds the actual Options Interface page and safe HUD layout workspace, preserves the approved main-menu defaults and existing security-room artwork/audio/animation. It is development source only and has not been uploaded. See GitHub for support limits and offline evidence; native acceptance remains NOT TESTED.

- Development Options workspace: searchable header, category sidebar, responsive native section cards, editable grey accent and fixed native Back/Apply/Accept actions. Native settings values and behavior preserved; specialized/provider content keeps native internals. Native input/controller acceptance NOT TESTED. Not uploaded; Workshop remains0.5.0-dev.11.

- Development HUD editor input fix: explicit Save/Cancel/Escape exits, shared unsaved confirmation, direct preview movement/resizing, inert empty canvas, guarded dropdown dismissal and retained modal drafts. Native dispatch NOT TESTED; not uploaded.

- Development main-menu Quit to desktop confirmation now uses shared near-black rounded surfaces and local accent; native Yes/No actions/focus/geometry retained. Native acceptance NOT TESTED; not uploaded.

## Development source preview
Editable UI Style Presets now live under Options → Interface in development source: shared component values and optional per-mod overrides, hex colors and bounded visual dimensions, live preview, explicit Save and unsaved-exit protection. Supported shared/native controls inherit styles; arbitrary provider rendering requires opt-in. Native acceptance is NOT TESTED. This description draft does not upload the development source; existing Workshop distribution remains unchanged.

Development compatibility update: dev.2 replaces unsupported Kahlua global-next checks with pairs-based table presence. Post-fix native acceptance remains pending; this remains a description draft, not a new upload.

Development dev.3 Options correction: restore visible categories/search after dropdown dismissal; fit supported settings into bounded section/page navigation and remove spurious scrollbars. Native values/Apply/callbacks are preserved; specialized or oversized provider content retains genuine overflow. Offline regressions PASS; native post-fix acceptance NOT TESTED. Source-only, not uploaded.

Development dev.4 fixes native Options setup aborting at the section dropdown by using the installed tooltip-map API after each clear. Strict regression first fails at the observed dev.3 source call, then passes. Native post-fix acceptance remains pending; this is a draft, not an upload.

Development source 0.10 adds the first native inventory/loot/context-menu/tooltip/dialog skin slice with shared presets and per-player appearance. Native input/rendering acceptance is NOT TESTED; this source is not uploaded. See GitHub NATIVE_OVERHAUL.md for exact coverage and limits.

0.10.0-dev.2 corrects native empty-inventory event bootstrap: register only when absent through vanilla LuaEventManager.AddEvent, preserving preexisting handlers. The strict fixture reproduces the dev.1 startup failure before correction. No public API/profile/action/geometry changes. Corrected native visual/input acceptance remains pending; no Workshop upload.
