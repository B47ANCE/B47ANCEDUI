# B47ANCE'd UI

## Overview
Shared Lua-only interface components for B47ANCE'd Workshop mods in Project Zomboid. This foundation supplies a consistent presentation API to cooperating mods. It does not replace every vanilla interface.

## Features
- Development source: native Options/settings styling with near-black surfaces, rounded tab/button headers and existing local accent colours. Native settings/input remain owned by PZ; custom renderers are guarded. Native acceptance NOT TESTED; not uploaded.
- Development source: local main-menu layout editing with independent menu/logo move/resize, locked logo proportions, percentage sliders and Save/Cancel/Reset. Not uploaded; Workshop remains 0.5.0-dev.11.
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

Offline Lua 5.1 contracts, syntax, source inventory, translation coverage and package integrity fixtures passed. The earlier 0.5.0-dev.2 menu visuals were observed in an isolated local game profile; 0.6.0-dev.2 ultrawide and inherited audio behavior, controller, split-screen, subscription/download and dedicated-server behavior are NOT TESTED. This is test distribution, not stable-release certification.

## Configuration
Consuming mods can expose the shared local appearance editor: background opacity, a #RRGGBB hex field and Red/Green/Blue sliders (0–255). Changes preview locally; Reset restores opacity 82 and grey #B0B0B0. Existing opacity-only settings retain their values. Values are isolated by mod and local player. Appearance settings do not change gameplay or server permissions. There are no shared-gameplay sandbox options in this presentation-only foundation.

## Source Code & Development
GitHub: https://github.com/B47ANCE/B47ANCEDUI

Mod developers consume the versioned public Lua API. Application data, server authority and synchronization remain with the application mod.

## Known Issues
The native menu adapter changes verified navigation labels only; other menu mods may conflict or leave guarded items in their original style. Startup/profile loading and native main/Esc acceptance require in-game testing. Live CCTV feeds, the full vanilla UI overhaul and general window-layout editing remain planned. Runtime visual/input acceptance, actual settings reload, native rounded-draw performance and texture-corner clipping remain outstanding. No universal click-through, arbitrary custom font support or multiplayer verification is claimed.

## Credits & Permissions
Developed by B47ANCE'd Workshop. Original B47ANCE-owned shared code extracted from Quartermaster with explicit owner authorization. No external mod implementation or assets copied. No reuse license is implied beyond permissions separately granted by the owner.

## Development background

Version 0.6.0-dev.2 applies the selected left-wall pipe artwork with matching transparent CRT masks and standard/ultrawide crop. Existing title-screen music gain mute remains unchanged. Offline viewport checks cover 4:3, 16:9 at 720p/1080p/1440p/4K, 21:9 and 32:9 through 5120x1440. Native acceptance of this revision remains NOT TESTED.
