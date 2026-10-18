# B47ANCE'd UI

## Overview
Shared Lua-only interface components for B47ANCE'd Workshop mods in Project Zomboid. This foundation supplies a consistent presentation API to cooperating mods. It does not replace every vanilla interface.

## Features
- Near-black native buttons, windows, lists, text inputs and context menus with restrained rounded corners.
- Small and Normal button sizes; older Large requests use Normal.
- Separate large-text MenuButton for consumer-owned menu navigation: transparent backing, no button frame, subtle accent text and underline on hover or controller focus.
- Shared rendering, layout helpers, controller focus, dialogs and bounded tooltips.
- Independent appearance preferences for each consuming mod and local player.
- Local opacity and hex/RGB accent editor with live preview; default accent is neutral grey (#B0B0B0).
- Read-only import of registered legacy opacity preferences.
- Original clipboard drawing for cooperating application screens.

## Compatibility & Requirements
Target: Project Zomboid Build 42.21. Mod ID: B47ANCEDUI. Public client Lua API: 1.

UI does not require Quartermaster, Rooms, PC Framework or custom Java/JAR components. Dependent mods supply their own application screens, labels, gameplay callbacks and required dependencies. Install and enable UI with dependent mods on the server and clients.

MP testing build - dedicated multiplayer NOT TESTED

Offline Lua 5.1 contracts, syntax, source inventory, translation coverage, paired Quartermaster UI regressions and package/staging integrity checks passed. Native single-player, controller, split-screen, subscription/download and dedicated-server behavior are NOT TESTED. This is test distribution, not stable-release certification.

## Configuration
Consuming mods can expose the shared local appearance editor: background opacity, a #RRGGBB hex field and Red/Green/Blue sliders (0–255). Changes preview locally; Reset restores opacity 82 and grey #B0B0B0. Existing opacity-only settings retain their values. Values are isolated by mod and local player. Appearance settings do not change gameplay or server permissions. There are no shared-gameplay sandbox options in this presentation-only foundation.

## Source Code & Development
GitHub: https://github.com/B47ANCE/B47ANCEDUI

Mod developers consume the versioned public Lua API. Application data, server authority and synchronization remain with the application mod.

## Known Issues
MenuButton is an opt-in component; it does not automatically replace the vanilla main or pause/Esc menus. The full vanilla UI overhaul, main-menu/CCTV system and advanced layout editor are planned, not implemented. Runtime visual/input acceptance, actual settings reload, native rounded-draw performance and texture-corner clipping remain outstanding. No universal click-through, arbitrary custom font support or multiplayer verification is claimed.

## Credits & Permissions
Developed by B47ANCE'd Workshop. Original B47ANCE-owned shared code extracted from Quartermaster with explicit owner authorization. No external mod implementation or assets copied. No reuse license is implied beyond permissions separately granted by the owner.
