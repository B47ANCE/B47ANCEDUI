# Changelog

## [0.8.0-dev.2] - 2026-10-21

- Fix implicit HUD editor exits after dropdown Enter and temporary modal activity. Cancel/Escape/controller Back use the same shared unsaved confirmation; Save remains explicit, and blank canvas clicks do nothing.
- Use one fixed canvas input surface to hit-test real preview rectangles in visible order, move assets directly and resize supported edges/corners. Preserve reference-only/axis/aspect limits, saved schemas/defaults and provider ownership.
- Guard popup dismissal/release click-through and stale UI callbacks; retain drafts during temporary modal focus and clean up only on actual owner/game teardown. Compatible PATCH within 0.8; offline regression/runtime limits in TESTING.md. No deployment, launch, package, merge or upload.

## [0.8.0-dev.1] - 2026-10-21

- Redesign native Options with a searchable header, category sidebar, responsive section cards, contextual native help and a fixed Back/Apply/Accept footer. Use the existing editable grey accent.
- Preserve native option/control/callback identities, values, parent graph and controller rows. Search jumps to existing settings; specialized/provider pages keep native content with horizontal overflow access. Native dirty/display confirmation, audio rollback, key capture and apply/persistence delegates remain unchanged.
- Compatible MINOR presentation addition; public API major1 and saved menu/HUD schema1/defaults unchanged. Offline validation and untested native input/render/controller gates are recorded in TESTING.md. No deployment, launch, packaging, merge or upload.

## [0.7.0-dev.3] - 2026-10-21

- Fix Options remaining vanilla when its construction is deferred until opening. Observe each native Options instance's create/draw completion and attach styling/Interface page once per tab panel, including rebuilt tabs.
- Preserve native action/return/error behavior, custom-renderer guards, settings values, controller ownership and global classes. Compatible PATCH within 0.7; API major1, saved formats/defaults and unsaved-exit protection remain unchanged.
- Regression reproduces missed deferred attachment before the fix. Offline/native evidence and runtime limits are recorded in TESTING.md; no new deployment/launch/publication in this development checkpoint.

## [0.7.0-dev.2] - 2026-10-20

- Confirm unsaved layout changes before Cancel, Escape, controller B or switching away. Keep editing is the safe default; Discard changes closes without writing. Both layout editors include unfinished/invalid numeric fields in dirty detection and preserve drafts while the popup is open.
- Unchanged or successfully saved layouts close directly. Own popup input/focus/capture/cleanup stays within the frontend editor; forced owner/game lifecycle teardown remains unconditional. Compatible PATCH behavior within the 0.7 development iteration; API major1 and saved formats/defaults unchanged.
- Offline regression and native runtime evidence are recorded in TESTING.md; no deployment, launch, packaging or publication.

## [0.7.0-dev.1] - 2026-10-20

- Add an Interface page to the native Options screen and a main-menu workspace for editing supported in-game UI layouts with safe static previews, without constructing players or loading a world.
- Add provider-scoped layout registration, a separate local HUD profile and supported native runtime geometry adapters. Preserve the saved main-menu defaults, schema1 profile and native Options behavior. Reference-only assets are explicitly marked.
- Rework editor sliders, numeric percentage inputs, resize grips and compact inspector spacing. Refresh native slider pagination after final bounds to fix stale 1px thumb geometry.
- Compatible MINOR presentation/API addition; public API major1 remains compatible. Validation and native input/runtime limits are documented with this iteration; no deployment, launch, package or publication requested.

## [0.6.0-dev.3] - 2026-10-20

- Promote the owner's saved main-menu placement to the built-in defaults: menu x18%, y14.5%, width27.9696133%, height52.5%; logo x4%, y26.5%, width22%, preserving native proportions.
- New/missing/invalid profiles and Reset use the approved layout with viewport clamps. Existing valid target overrides keep priority; schema1 and preference files are unchanged. Compatible PATCH presentation adjustment within unreleased 0.6; public API major1 remains unchanged.
- Offline regression first fails against the prior default and passes with exact approved placement, partial-profile precedence, reset/editor behavior and tiny/standard/ultrawide viewport/ratio clamps. This source iteration is not deployed or published; current running local test remains dev.2 with the owner's saved profile. Native defaults acceptance, project G7/stable G8 remain NOT TESTED/BLOCKED.

## [0.6.0-dev.2] - 2026-10-20

- Theme the native settings/options screen with a near-black backdrop, rounded tab/button surfaces, subtle active-tab accents and scoped checkbox/slider colours. Reuse UI's local accent preference, default grey.
- Preserve native fonts, layout, control identities, callbacks, tab scrolling/clipping, controller rows, display confirmation, audio preview/rollback and keybinding ownership. Keep colour swatches and custom renderers untouched; adopt supported late-added native controls without a per-frame tree scan.
- Borrow the shared dropdown popup palette only during settings-owned drawing and restore on success/error. Lua-only client presentation; no option writes/networking introduced.
- Offline contracts cover styling/lifecycle/ownership and error restoration. Native SP/input/controller/display/audio acceptance NOT TESTED; G7/stable G8 remain BLOCKED. No package, deploy, game/server launch or Workshop upload.

## [0.6.0-dev.1]
- Compatible MINOR: player-local main-menu layout editor with independent menu/logo movement and resize, aspect-locked logo, viewport bounds and normalized saved placement. Existing users keep the automatic wall layout until they customize it.
- Edit menu layout control, F10 and main-menu controller X access; drag/corner handles, percentage sliders, keyboard nudges, Save/Cancel and reversible Reset. Controller Y retains its vanilla Terms of Service action.
- Dynamic mod-added entries/status notes continue fitting inside the chosen menu rectangle. Local data-only profile; no shared gameplay state, networking, server sandbox setting or public API major change.
- Native mouse/controller/keyboard/resolution-change acceptance NOT TESTED. Development source only; no deployment, game launch or Workshop upload. Published Workshop build remains 0.5.0-dev.11.

## [0.5.0-dev.11]
- Compatible PATCH: apply the user-selected room with the horizontal pipe extended straight across the left wall at its existing height. Use the approved generated PNG unchanged; retain the four transparent CRT openings and room composition.
- Match CRT masks/crop to the selected artwork. Keep all four casings visible from 4:3 through 32:9 and place the dynamic logo/menu below the pipe, above the baseboard and before the vertical conduit.
- Public API 1, callbacks, status ownership, 1-60 second startup static, no-signal loops and audio behavior remain unchanged. Authorized Workshop MP testing update; native rendering and dedicated acceptance NOT TESTED, G7/stable G8 BLOCKED.
- Workshop update verified on existing public item 3822582242 after PR 14 merge: SteamCMD exit 0/commit-success, exact public description and 52-file source/ZIP/stage parity. Prior dev.8 package retained; Steam restart declined. No local deployment or game/server launch.

## [0.5.0-dev.10]
- Compatible PATCH: regenerate the entire security room in one image-generation pass, with one wall, floor, conduit system and lighting scheme. No side-panel compositing; retain the quiet menu wall and bunker decorations.
- Retarget all four genuine transparent CRT apertures. Update the crop focus to retain the new monitor casings at 4:3 and fit the logo/menu within the quiet wall at source X440/Y72-470, before its conduit.
- Strengthen alpha validation to check full inset glass interiors. Public API 1, native actions, dynamic entries, startup/static timing and audio behavior remain unchanged. Offline validation only; not deployed or uploaded. Workshop remains dev.8.

## [0.5.0-dev.9]
- Pipe art refinement: extend one straight highest run to the left edge and remove its old left ascent/lower segment; retain a single coupled connection at the right. No Lua/layout or public API change.
- Compatible PATCH: recenter logo/navigation on the open wall at source X405 and fit the complete dynamic column inside source Y72-470, above the baseboard. Limit logo height to 34% of that wall region; preserve aspect ratio, native actions and status-note rows.
- Rework original artwork: tuck vent/footlocker farther left, calm the wall behind the menu and route the overhead pipe continuously above it. Four transparent CRTs and continuous right-hand room retained.
- New wall-bound regression fails on dev.8 and passes offline across the nine standard/ultrawide viewports with normal/oversized widths. Native rendering for this revision NOT TESTED; not deployed or uploaded. Workshop remains dev.8.

## [0.5.0-dev.8]
- Compatible PATCH: cap the main-menu/logo column before the outer CRT casing, including long translated or mod-added labels at 1024x768. Existing fit/truncation and row scaling preserve actions and screen visibility.
- Regression reproduces the prior bezel overlap; expanded standard 720p/1080p/1440p/4K and 4:3/21:9/32:9 matrices pass with normal and oversized menu-width requests. Native PZ/input and dedicated multiplayer remain NOT TESTED.
- Workshop MP testing upload verified on existing public item 3822582242 after PR 12 merge, including the continuous decorated room, shared optional status-label style and menu music gain mute. Exact source/package/stage and public description match; Steam unchanged by user choice. Public API 1 and runtime dependencies unchanged.

## [0.5.0-dev.7]
- Compatible PATCH: adapt the optional public PZ Optimization main-menu label to the shared large text/underline style while invoking its original renderer and preserving actions, controller glyph and tooltip ownership.
- Move its live version/update subtext into a reserved centered small-text lane beneath the title. Fit crowded rows without overlapping following entries; preserve status colors and error propagation. No external code/assets or Java dependency added.
- Offline regression/clean-room compatibility review; native PZ interaction and updater-state rendering NOT TESTED.
- Owner-authorized MP test publication preparation: explicit standard 720p/1080p/1440p/4K and 4:3/21:9/32:9 viewport checks, with current canonical Workshop description and changenotes. Release metadata/coverage only; runtime version unchanged.

## [0.5.0-dev.6]
- Compatible PATCH artwork refinement: add filing cabinets, archive boxes/binders, floor-plan noticeboard, keys, intercom and extinguisher on the right; shadowed footlocker/folders and a ventilation grille at the far left. Keep the menu area clear and room continuous.
- Genuine CRT transparency checked in composited previews and offline PNG/regression tests. No menu behavior change; native PZ runtime for this artwork NOT TESTED.

## [0.5.0-dev.5]
- Compatible PATCH artwork/layout refinement: expand the continuous room view to the right of the desk, retaining one wall, paint boundary, pipe, floor perspective and lamp. The desk is reframed toward the center-left.
- Retarget the four transparent CRT masks and left menu column; narrow crops keep the menu/desk group visible while ultrawide displays reveal more right scenery. API, actions, monitor timing and audio behavior unchanged.
- Offline alpha, geometry, source and regression checks; PZ runtime for this artwork NOT TESTED.

## [0.5.0-dev.4]
- Compatible PATCH correction: recompose the whole room from the original desk artwork with one continuous back wall, pipe run, floor perspective and lamp. Remove the architecture that still made 0.5.0-dev.3 look spliced.
- Update four genuine transparent CRT masks and keep the right CRT group visible during uniform cover cropping. Menu actions, static timing and audio behavior are unchanged.
- Offline alpha, source, geometry and regression checks; actual PZ rendering for this revision NOT TESTED. The rejected 0.5.0-dev.3 source/CI checks did not prove visual continuity.

## [0.5.0-dev.3]
- Replace the side additions with one continuous security-room panorama. Uniform cover scaling fills 32:9 and narrower viewports without stretching the CRTs; the room has no panel joins or seam overlays.
- Compatible PATCH refinement of the unreleased 0.5 UI: mute native menu music runtime gain while the security-room title screen renders. No saved audio options are changed; native menu exit restores the configured volume, and Esc/in-game rendering is excluded.
- Offline gain/idempotence/options-change/Esc regression coverage. Audible rain/thunder suppression and return-to-game audio require runtime listening; NOT TESTED.

## [0.5.0-dev.2]
- Each monitor independently runs initial static for 1-60 seconds, then stays in its subdued no-signal loop without recurring static bursts.
- Compatible layout refinement: larger main-menu text centered beneath the logo, with responsive rows and automatic discovery of added/hidden/removed menu labels and buttons. Native/foreign actions retained.


## [0.5.0-dev.1]
- MINOR: add the original security-room main-menu background with four independently timed static/no-signal monitors. Public API 1 and gameplay/save contracts remain unchanged.
- Main-menu-only instance rendering; native actions and controller objects preserved. Offline tests only; new runtime integration NOT TESTED. No deployment/publication.


## [0.4.0-dev.1]

Compatible MINOR native menu integration within public API 1. Apply the separate MenuButton text/underline style to verified main-menu and in-game Esc-menu navigation labels, retaining native identity, actions, controller order, visibility and geometry. No shared gameplay ownership or networking. Development source only; not deployed or published. Native acceptance remains NOT TESTED.

## [0.3.0-dev.1]

Compatible MINOR addition within API 1: separate MenuButton component for main/pause/Esc-style navigation. Larger native text, transparent surface, no button border, and label-only hover/controller focus underline. Regular buttons remain Small/Normal; legacy Large alias unchanged. No automatic vanilla menu replacement or gameplay action. Offline evidence only; native runtime acceptance pending. Workshop MP testing upload verified on existing public item 3822582242 after PR 6 merge, with exact source/package/stage and public description match. Earlier upload records preserved; no runtime bump for publication metadata. Native/dedicated acceptance remains NOT TESTED.

## [0.2.0-dev.3]

Owner-requested presentation checkpoint: Small and Normal are the only distinct button sizes; older Large requests alias Normal without breaking API 1 callers. Grey default and hex/RGB accent editor retained. Prepare the explicitly authorized existing-item MP testing update with assigned-ID package provenance and a no-upload staging/VDF helper. No native/dedicated acceptance inferred.

## [0.2.0-dev.2]

Next checkpoint in the compatible 0.2 MINOR iteration, public API 1 unchanged. Default accent is neutral grey (#B0B0B0). Add local in-game hex/RGB accent editing with live scoped preview and backward-compatible preference persistence. Offline evidence only; no deployment/upload or native acceptance.

## [0.2.0-dev.1]

Compatible MINOR iteration within public API 1. Near-black surfaces, muted sage accents and restrained rounded corners on owned controls. Add explicit Small/Normal/Large button sizing with font-aware heights and padding; existing constructor dimensions and native callbacks remain intact. Offline geometry/alpha/size contracts tested; native rendering, performance, input and dedicated integration NOT TESTED. Development source only, not deployed or uploaded.

## [0.1.0-dev.1]

Initial Lua-only shared presentation API extracted with owner authorization from Quartermaster 0.21.0-dev.5. Native controls, tokens, rendering, tooltips, dialogs, scoped local appearance/editor and clipboard drawing. No gameplay/network ownership, Java or Quartermaster dependency. Offline tests only; native SP/dedicated NOT TESTED. No package/deployment/Workshop publication.

Publication preparation (runtime version unchanged): canonical MP testing listing/changenote, explicit deterministic packaging and safe draft staging, plus archive boundary fixtures. No new Workshop item, upload or artwork substitution is authorized by the tooling.

First Workshop MP testing publication verified as item 3822582242; no runtime/version change. Dedicated remains NOT TESTED. Steam left unchanged by explicit user choice.
