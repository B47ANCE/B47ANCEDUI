# Changelog

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
