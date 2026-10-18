# Changelog

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
