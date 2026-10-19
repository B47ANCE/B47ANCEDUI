# B47ANCE'd UI

## Overview
Shared Lua-only interface components for B47ANCE'd Workshop mods in Project Zomboid. This foundation supplies a consistent presentation API to cooperating mods. It does not replace every vanilla interface.

## Features
- Near-black native buttons, windows, lists, text inputs and context menus with restrained rounded corners.
- Small and Normal button sizes; older Large requests use Normal.
- Separate large-text MenuButton for consumer-owned menu navigation: transparent backing, no button frame, subtle accent text and underline on hover or controller focus.
- Native main-menu and in-game Esc-menu navigation use the same text/underline style, preserving native actions, visibility and controller order.
- Security-room main menu with four decorative CRTs: independent 1-60 second startup static, then persistent no-signal loops. The room artwork fills narrow and 32:9 ultrawide screens without distorting the CRTs; visible mod-added menu items are placed beneath the logo.
- Runtime-only main-menu music gain mute; saved audio preferences remain unchanged. Audible rain/thunder suppression requires an in-game listening check.
- Shared rendering, layout helpers, controller focus, dialogs and bounded tooltips.
- Independent appearance preferences for each consuming mod and local player.
- Local opacity and hex/RGB accent editor with live preview; default accent is neutral grey (#B0B0B0).
- Read-only import of registered legacy opacity preferences.
- Original clipboard drawing for cooperating application screens.

## Compatibility & Requirements
Target: Project Zomboid Build 42.21. Mod ID: B47ANCEDUI. Public client Lua API: 1.

UI does not require Quartermaster, Rooms, PC Framework or custom Java/JAR components. Dependent mods supply their own application screens, labels, gameplay callbacks and required dependencies. Install and enable UI with dependent mods on the server and clients.

MP testing build - dedicated multiplayer NOT TESTED

Offline Lua 5.1 contracts, syntax, source inventory, translation coverage and package integrity fixtures passed. The earlier 0.5.0-dev.2 menu visuals were observed in an isolated local game profile; 0.5.0-dev.3 ultrawide and audio behavior, controller, split-screen, subscription/download and dedicated-server behavior are NOT TESTED. This is test distribution, not stable-release certification.

## Configuration
Consuming mods can expose the shared local appearance editor: background opacity, a #RRGGBB hex field and Red/Green/Blue sliders (0–255). Changes preview locally; Reset restores opacity 82 and grey #B0B0B0. Existing opacity-only settings retain their values. Values are isolated by mod and local player. Appearance settings do not change gameplay or server permissions. There are no shared-gameplay sandbox options in this presentation-only foundation.

## Source Code & Development
GitHub: https://github.com/B47ANCE/B47ANCEDUI

Mod developers consume the versioned public Lua API. Application data, server authority and synchronization remain with the application mod.

## Known Issues
The native menu adapter changes verified navigation labels only; other menu mods may conflict or leave guarded items in their original style. Startup/profile loading and native main/Esc acceptance require in-game testing. Live CCTV feeds, the full vanilla UI overhaul and an advanced layout editor remain planned. Runtime visual/input acceptance, actual settings reload, native rounded-draw performance and texture-corner clipping remain outstanding. No universal click-through, arbitrary custom font support or multiplayer verification is claimed.

## Credits & Permissions
Developed by B47ANCE'd Workshop. Original B47ANCE-owned shared code extracted from Quartermaster with explicit owner authorization. No external mod implementation or assets copied. No reuse license is implied beyond permissions separately granted by the owner.

## Development background

The 0.5.0-dev.3 development branch extends the security-room art for 32:9 screens and mutes title-screen music gain. Workshop currently remains at 0.3.0-dev.1. Native acceptance of this revision remains NOT TESTED.
