# B47ANCE'd UI

## Overview
Development candidate0.12.0-dev.2 fixes preset-editor construction. Not uploaded; the public Workshop build remains0.12.0-dev.1.
A shared near-black interface for Project Zomboid Build 42.21, with a neutral grey accent, restrained rounded corners and a public Lua API for cooperating mods. Version 0.12.0-dev.2 is an MP testing build.

MP testing build - dedicated multiplayer NOT TESTED

## Features
- Shared styling for audited native frontend, gameplay and specialist windows: frames, buttons, tabs, lists, dropdowns, checks, sliders and scrollbars, with guarded PZAPI window chrome. Native actions, settings and semantic content are preserved.
- Searchable Options categories, section cards and contained pages using the original native settings and Back/Apply/Accept behavior. Specialized or oversized provider content retains genuine scrolling.
- Styled inventory/loot chrome, context menus, tooltips and selected native confirmations, including main-menu Quit to desktop.
- 53 editable color channels with hex and RGB controls, shared component presets and per-mod overrides. Specific surfaces, button states, focus outlines, title/status bars, checks, progress, menus, tooltips and supported input colors can be adjusted independently.
- Multiple local presets with live preview, explicit Save and unsaved-exit protection. Small/Normal ordinary buttons and separate large text-only main/Esc navigation retain native actions and controller ownership.
- Preset plugins from enabled mods add inactive choices to the preset list. Select one to preview an editable local copy; Save keeps it. Installing a pack never switches your theme automatically. Saved copies survive removal or updates of the source pack.
- Export selected styling as a custom data pack. The optional manually started offline packager prepares a dependent Workshop mod; with its watcher running, one export click stages it. New and Update previous export are separate choices. Final publishing stays in PZ's native Workshop uploader.
- Independently move/resize the main-menu logo and menu. Valid saved overrides retain priority over shipped defaults, and visible mod-added entries fit the selected menu area.
- Main-menu Edit in-game UI workspace with clearly labelled static previews on a black canvas. Move/resize supported assets without loading a character; supported overrides apply when native HUD windows exist. Clock/moodles are reference-only.
- Original continuous bunker/security-room artwork with filing cabinets and other room details, plus four decorative CRTs: independent 1-60 second startup static followed by persistent no-signal loops. Uniform artwork scaling supports normal and 32:9 ultrawide views. The existing selected artwork is preserved.
- Runtime-only main-menu music gain mute; saved audio preferences remain unchanged. Audible rain/thunder suppression still needs a listening check.
- Independent local-player/consumer preferences, original clipboard drawing and read-only import of registered legacy opacity preferences.

## Compatibility & Requirements
Target: Project Zomboid Build 42.21. Mod ID: B47ANCEDUI. Public client Lua API: 1. Runtime is Lua-only; no custom Java/JAR component is required.

UI works without Quartermaster, Rooms or PC Framework. Enable it with dependent mods; follow those mods' server/client installation requirements. The optional PZ Optimization menu-entry adapter preserves its action and live status while reserving a subtitle line. Other custom renderers remain guarded and may retain their original styling.

Offline Lua 5.1 regression, version, source, translation and integrity checks pass. Native acceptance is FAILED / INCOMPLETE: representative frontend/SP/preset discovery-export-selection paths were reached, with known Options/editor/styling defects. Complete input/controller/split-screen, changed-profile cold reload, plugin Workshop publication/subscription and dedicated acceptance remain pending. G7 and stable-release G8 remain blocked. Test distribution is not stable-release certification.

## Configuration
Open Options > Interface for appearance, UI Style Presets and layout editing. Colors accept #RRGGBB or Red/Green/Blue sliders. The default accent is grey #B0B0B0. Inherit restores fallback values; explicit component values take priority over legacy accent/opacity preferences. Save keeps a preset; Cancel restores the saved selection.

Preset packs share authored component styling only. Menu/HUD positions, other presets and legacy Appearance preferences stay separate. Up to 16 local presets and 256 external choices are supported. Enabling a new pack may require the normal mod reload before opening or refreshing the preset list.

The optional export packager requires Python 3.12+ with its standard library, started manually on your computer. It is not a runtime dependency for UI or subscribed preset packs. Setup and the exact versioned helper are available below. Appearance is local presentation and does not change gameplay or server permissions.

## Source Code & Development
GitHub: https://github.com/B47ANCE/B47ANCEDUI

Preset sharing guide: https://github.com/B47ANCE/B47ANCEDUI/blob/869fd6d288608c409e5d4d396b31581344ee50b5/docs/PRESET_PLUGINS.md

Offline helper download: https://raw.githubusercontent.com/B47ANCE/B47ANCEDUI/869fd6d288608c409e5d4d396b31581344ee50b5/scripts/preset_packager.py

Mod developers consume the versioned public Lua API. Application data, server authority and synchronization stay with each application mod.

## Known Issues
This styles supported audited chrome, not every engine-owned pixel. Native clock/moodle/radial/model/platform internals, documents, live item/map/health colors, bespoke rows and unknown provider renderers retain their native content. Native input text/placeholders are customizable for API-owned inputs; arbitrary native cursor/selection colors and universal PZAPI thumb-hover are unsupported. Unknown mod layouts are not automatically editable, and controller HUD layouts are skipped.

Pure Lua cannot safely create new Workshop staging content through a verified API, so exporting a new plugin requires the optional packager before native Publish. Real file round trips, helper/uploader handoff, upload/download and persistence still require acceptance testing. Live CCTV feeds remain planned; the monitors are decorative. Rounded-draw performance, clipping, load order and compatibility with other UI/menu mods need runtime testing.

## Credits & Permissions
Developed by B47ANCE'd Workshop. Original B47ANCE-owned shared code extracted from Quartermaster with explicit owner authorization. No external mod implementation or assets copied. No reuse license is implied beyond permissions separately granted by the owner.

Current candidate acceptance (2026-10-24): FAILED / INCOMPLETE. The bounded45-case report includes baseline/candidate runtime and offline fixture packaging. RGB editor construction is corrected; Options clipping, layout-editor input, native selection chrome and unreached areas remain. Full controller/split-screen/ultrawide/dedicated acceptance and plugin publication remain pending. Workshop remains0.12.0-dev.1; this candidate has not been uploaded. See docs/UI_RUNTIME_ACCEPTANCE_2026-10-24.md in the public source.
