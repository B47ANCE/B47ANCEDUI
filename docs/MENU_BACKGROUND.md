# Security-room main menu

Project Version: 0.5.0-dev.1

Compatible MINOR addition from 0.4.0-dev.1; public API major 1, appearance storage and consumer contracts are unchanged. This is development source, not a Workshop upload.

## Behavior and ownership

`MenuBackground.lua` wraps only a recognized, out-of-game `MainScreen` instance's native `prerender`. It draws an opaque black underlay, four animated screen surfaces, then the original room artwork. The artwork's transparent screen apertures mask the effects. The room is aspect-fitted without cropping; extra viewport space stays black. The original PZ logo is fitted above the native menu in the left column. Labels retain their native actions, visibility and controller references; the panel position and label widths are updated for the left column. Native delay, fade and modal logic still run once. The temporary instance logo-drawing override is restored even when native rendering throws.

Each newly constructed main-menu instance gets four independently phased animation states seeded from the local millisecond timestamp. Repeated events do not reset an existing instance. A private Park-Miller generator does not seed or consume game/random-library state. Screens begin dark, show subdued static after staggered delays, settle into localized NO SIGNAL, and occasionally lose signal briefly. Eight original 64x48 grayscale frames play at independently chosen 7–10 fps. No full-screen flashing, per-frame texture generation, new global tick handler, audio, real camera feed or gameplay scanning is involved. Visible-menu render time advances the animation, clamped to 100 ms per render to avoid large jumps after a stall.

The in-game Esc menu is excluded. Unrecognized main-menu prerenders and missing artwork retain native behavior; a later mod can still replace this adapter. There is no custom networking, server state, persistence, world mutation or save schema. Pixel coordinates and animation limits are implementation details, not gameplay configuration; no sandbox option is warranted. NO SIGNAL uses a translation key with the project's explicit English fallback across 29 locales. These are decorative monitors; live CCTV remains planned.

## Source evidence [VERIFIED]

Installed Build 42.21.0, revision `4a0e9546ec`, supplied these API references (source inspection, not new runtime proof):

- `media/lua/client/OptionScreens/MainScreen.lua`: `prerender` 818–895 draws the native logo, updates delay/fade and positions the label panel; `render` 785–808 handles native version/client menu state; `calcLogoHeight` 810–816. The adapter invokes the original instead of copying its implementation.
- `media/lua/client/ISUI/ISUIElement.lua`: `drawTextureScaled` at 1032, inherited rectangle/text drawing and element geometry.
- `media/lua/client/OptionScreens/MapSpawnSelect.lua:124`: `getTimestampMs()` is used by native client UI.
- Existing `NativeMenus.lua` verifies the native navigation label identities and registers after native construction. The background module likewise requires MainScreen before adding event callbacks.

The installed game has unrelated local modifications; these references establish observed method contracts, not pristine-install compatibility or external-mod reuse authorization. No third-party source or art was copied. Original user-directed image generation and asset SHA-256s are recorded in `MENU_ARTWORK.json`; the exact prompt is retained in `MENU_ARTWORK_PROMPT.txt`. The accepted room PNG is copied byte-for-byte. Non-screen partial alpha is composited against the black underlay.

## Validation [TESTED: offline]

Commands: `python -B scripts/check_versions.py` and `python -B tests/run_tests.py` (Python UTF-8 mode on Windows). Tests cover Lua 5.1 syntax, all existing API contracts, missing-art/foreign-renderer fallback, event idempotence, Esc exclusion, independent state ranges, boot/static/no-signal transitions, layer order, logo placement, exception restoration, and aspect fitting at 1024x768, 1280x720 and 3440x1440. PNG hashes/CRC and deterministic noise-frame reproduction are checked. The packaging suite uses disposable malformed fixtures; it does not build a release.

## Runtime gates [RUNTIME GATE]

New background/animation native execution NOT TESTED. Check initial boot, restart variation, all four rounded openings, resize/fullscreen/ultrawide, large fonts/long translations, controller focus, submenu/modal return, quit cooldown, Lua reload, missing texture fallback and other menu mods. Very small viewports or oversized localized menu text need native acceptance. Confirm the Esc screen retains its native background and no drawing runs over gameplay. Previous 0.4 screenshots do not validate this 0.5 feature. Dedicated G7 and stable G8 remain BLOCKED under the project's integration acceptance policy. No deployment, game launch, package or publication was performed for this iteration.
