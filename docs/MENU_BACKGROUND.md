# Security-room main menu

Project Version: 0.5.0-dev.7

Compatible MINOR addition from 0.4.0-dev.1; public API major 1, appearance storage and consumer contracts are unchanged. This is development source, not a Workshop upload.

## Behavior and ownership

`MenuBackground.lua` wraps only a recognized, out-of-game `MainScreen` instance's native `prerender`. It draws an opaque black underlay, four animated screen surfaces, then the original room artwork. The artwork's transparent screen apertures mask the effects. The 0.5.0-dev.5 room extends the accepted room view to the right of the desk, maintaining a continuous back wall, pipe run, wall paint/baseboard and floor perspective with one lamp. The wider field of view reframes the desk toward the center-left rather than preserving earlier pixel coordinates. The 2172x724 panorama uses uniform cover scaling through 32:9 (5120x1440), focusing narrow horizontal crops on the left menu and desk group while ultrawide views reveal more right scenery. The image is top-aligned so ultrawide cropping removes lower floor rather than the overhead pipe and lamp. No side panels, seam overlays or concealed joins are drawn. The original PZ logo is fitted above the native menu in the left column. Visible interactive ISLabel and ISButton children are discovered each menu render; native controller helper labels are excluded. Rows share the available vertical area beneath the logo. Standard native labels use drawTextZoomed (ISUIElement.lua:1260), up to 1.9x, reduced for crowded rows/long labels, with their centers aligned to the logo midpoint. Unknown custom renderers retain their text drawing; their row bounds are centered/refitted. Nested custom panels and nonstandard control types are not automatically adapted. Callbacks, visibility and controller rows are never replaced. Added/hidden/removed entries and explicit position changes trigger updated layout without restarting. Labels retain their native actions, visibility and controller references; the panel position and label widths are updated for the left column. Native delay, fade and modal logic still run once. The temporary instance logo-drawing override is restored even when native rendering throws.

Each newly constructed main-menu instance gets four independently phased animation states seeded from the local millisecond timestamp. Repeated events do not reset an existing instance. A private Park-Miller generator does not seed or consume game/random-library state. Screens begin dark, show subdued static after staggered delays, settle permanently into a localized NO SIGNAL loop after independently selected 1-60 second static durations. Eight original 64x48 grayscale frames play at independently chosen 7–10 fps. No full-screen flashing, per-frame texture generation, new global tick handler, generated audio, real camera feed or gameplay scanning is involved. Visible-menu render time advances the animation, clamped to 100 ms per render to avoid large jumps after a stall.

The in-game Esc menu is excluded. Unrecognized main-menu prerenders and missing artwork retain native behavior; a later mod can still replace this adapter. There is no custom networking, server state, persistence, world mutation or save schema. Pixel coordinates and animation limits are implementation details, not gameplay configuration; no sandbox option is warranted. NO SIGNAL uses a translation key with the project's explicit English fallback across 29 locales. These are decorative monitors; live CCTV remains planned.

## Source evidence [VERIFIED]

Installed Build 42.21.0, revision `4a0e9546ec`, supplied these API references (source inspection, not new runtime proof):

- `media/lua/client/OptionScreens/MainScreen.lua`: `prerender` 818–895 draws the native logo, updates delay/fade and positions the label panel; `render` 785–808 handles native version/client menu state; `calcLogoHeight` 810–816. The adapter invokes the original instead of copying its implementation.
- `media/lua/client/ISUI/ISUIElement.lua`: `drawTextureScaled` at 1032, inherited rectangle/text drawing and element geometry.
- `media/lua/client/OptionScreens/MapSpawnSelect.lua:124`: `getTimestampMs()` is used by native client UI.
- Existing `NativeMenus.lua` verifies the native navigation label identities and registers after native construction. The background module likewise requires MainScreen before adding event callbacks.

The installed game has unrelated local modifications; these references establish observed method contracts, not pristine-install compatibility or external-mod reuse authorization. No third-party source or art was copied. Original user-directed image generation and asset SHA-256s are recorded in `MENU_ARTWORK.json`; the exact prompt is retained in `MENU_ARTWORK_PROMPT.txt`. The accepted room PNG is copied byte-for-byte. Non-screen partial alpha is composited against the black underlay.

## Validation [TESTED: offline]

Commands: `python -B scripts/check_versions.py` and `python -B tests/run_tests.py` (Python UTF-8 mode on Windows). Tests cover Lua 5.1 syntax, all existing API contracts, missing-art/foreign-renderer fallback, event idempotence, Esc exclusion, independent state ranges, boot/static/no-signal transitions, layer order, logo placement, exception restoration, and viewport fill and CRT-proportion preservation at 1024x768, 1280x720, 1920x1008, 3440x1440 and 5120x1440. PNG hashes/CRC and deterministic noise-frame reproduction are checked. The packaging suite uses disposable malformed fixtures; it does not build a release.

## Layout revision evidence

0.5.0-dev.2 [TESTED: offline]: dynamic add/hide/show/remove, 40-entry crowded layout, logo-centered labels, foreign callbacks without a fade object and persistent no-signal states at 1/60/600/3600 seconds after initial static. Initial static duration bounds are 1-60 seconds per monitor. This presentation timing is internal, with no gameplay configuration.

## Runtime gates [RUNTIME GATE]

New background/animation native execution NOT TESTED. Check initial boot, restart variation, all four rounded openings, resize/fullscreen/ultrawide, large fonts/long translations, controller focus, submenu/modal return, quit cooldown, Lua reload, missing texture fallback and other menu mods. Very small viewports or oversized localized menu text need native acceptance. Confirm the Esc screen retains its native background and no drawing runs over gameplay. Previous 0.4 screenshots do not validate this 0.5 feature. Dedicated G7 and stable G8 remain BLOCKED under the project's integration acceptance policy. No deployment, game launch, package or publication was performed for this iteration.

## Main-menu audio (0.5.0-dev.3)

The security-room prerender sets SoundManager runtime music gain to zero only outside a game. It does not edit saved audio options, stop sound instances, pause buses, or change world/UI sound categories. The installed MainScreenState.exit restores getOptionMusicVolume()/10 after its fade. The next title-screen render reapplies zero if the options screen changes the gain. Missing artwork or a foreign main renderer leaves native audio alone. No new sandbox setting: this is local presentation, with existing native audio preferences retained for gameplay.

[VERIFIED: installed 42.21.0, Steam build 25485521] LuaManager.Exposer exposes SoundManager. SoundManager.getMusicVolume()/setMusicVolume(float) read/write runtime gain and the Settings_Music VCA. MainScreenState.enter selects MainMenu music state; SoundManager starts MusicCombined (script event Music/Main). MainScreenState.exit restores configured music gain. Source inspection used javap -c -p against the installed stock projectzomboid.jar; no Java runtime mod is introduced.

[TESTED: offline Lua 5.1] Main-menu gain becomes zero, unchanged gain is not rewritten, options-preview changes are remuted, and in-game prerender does not change gain. These mocks do not establish FMOD routing. [RUNTIME GATE] Listen for both music and rain/thunder suppression, enter/leave a game and check configured music plus weather audio, and change audio options before repeating. Audible storm suppression is NOT TESTED; do not treat the VCA source audit as listening evidence. Earlier 0.5.0-dev.2 visual approval does not validate this audio change.

## Ultrawide artwork (0.5.0-dev.4)

A single original image-generated PNG recomposes the room from the original 16:9 desk art. The prior 0.5.0-dev.3 PNG retained changes in floor perspective and wall depth at the old side joins; source/CI checks did not detect that visual defect. It was rejected by the user and superseded. The current room has one flat back wall, one connected pipe run and a continuous wall/floor junction. There are no doors or tall cabinets at the former join positions. The 32:9 target is a practical aspect ratio, not a proven PZ maximum. The historical 0.5.0-dev.4 art hash and masks are retained at commit 7b974f0578817b2612fbc43bc2836043f78b2887. Current 0.5.0-dev.5 asset data is in MENU_ARTWORK.json.

[TESTED: offline] PNG alpha decoding, single-image draw, viewport coverage, four visible apertures and menu/CRT separation at 1024x768, 1280x720, 1920x1008, 3440x1440 and 5120x1440. Full-width art and viewport previews were visually inspected for a consistent wall, pipes and floor; this is separate from PZ runtime acceptance. At narrow ratios outer scenery and part of the desk may crop. [RUNTIME GATE] Actual PZ ultrawide/resize, text fit and controller acceptance for this revision are NOT TESTED.

## Right extension (0.5.0-dev.5)

The image-generator edit used the accepted 0.5.0-dev.4 panorama to add a broad right room section. It retained a continuous wall/pipe/baseboard/floor perspective, four CRTs and one lamp. Because the generated output remains 2172x724, the desk was reframed smaller and closer to center-left; this is a wider scene composition, not a byte-preserving canvas append. The source PNG is used as generated. Updated mask bounds and exact hash are in MENU_ARTWORK.json. The menu anchor moves into the remaining dark left area. Narrow crops focus on the menu/desk group; 32:9 reveals the full right extension.

[TESTED: offline] RGBA transparency, viewport coverage, four visible apertures and CRT casings, menu separation and existing regressions across 1024x768, 1280x720, 1920x1008, 3440x1440 and 5120x1440. Full-width art and viewport previews are inspected separately for scene continuity. [RUNTIME GATE] PZ rendering, resize, focus and integration for this revision NOT TESTED. No new deployment/publication.

## Decoration (0.5.0-dev.6)

User-requested filing cabinets and bunker security details occupy the right wall. A low footlocker and vent occupy the far-left edge; the middle-left menu area is clear. The 2172x724 image retains the same mask coordinates and viewport crop. Raw alpha previews may expose colorful RGB stored in near-transparent edge pixels; actual compositing over the opaque screen/black underlay was visually checked and shows clean edges. No pixel surgery or external art was used. [TESTED: offline] PNG alpha/hash/CRC and existing regression suite; code-rendered black-background viewport previews. Actual PZ rendering for this asset remains NOT TESTED.

## Optional status-label compatibility (0.5.0-dev.7)

The public PZOPT_MENU ISLabel is the audited exception to unknown-custom-renderer refusal. Its original renderer executes once; temporary instance draw interception supplies the shared title style and centers its live Small-font version/update line in reserved space beneath the title. The background layout subtracts that note lane before distributing normal rows, then fits title/note scale for crowded layouts. Callback, original text/status colors, glyph and tooltip ownership remain with the provider; height and methods restore on errors, which propagate. No provider API, Java dependency, external edits, network/save state or settings were added. Other custom renderers remain guarded. See [neutral contract and clean-room record](THIRD_PARTY_RESEARCH.md). Native PZ acceptance remains NOT TESTED.
