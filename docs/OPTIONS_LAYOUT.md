# Options workspace

Project Version: 0.11.0-dev.1

The owner-provided reference guides near-black Options with header search, left categories, original primitive icons/subtitles, rounded native settings and fixed Back / Apply / Accept actions. The editable accent defaults to grey. No reference pixels, third-party code or assets are copied.

## Native ownership

OptionsLayout attaches after NativeSettings/OptionsInterface through the deferred-construction lifecycle. Only adopted native roots/tabs qualify. The owned ISTabPanel instance suppresses its tab/body chrome, with tabHeight zero; original viewList/id/activeView/activation callbacks remain. Categories call activateViewById. Late tabs/controls invalidate discovery through owned add/remove delegates, without per-frame tree scans.

Known Display, UI, Audio, Accessibility and Multiplayer pages receive contained sections only when direct child types and GameOption references match the verified model. Labels, native controls, color swatches, compound sliders, microphone meter and translator panel stay with their original parent. Native control dimensions, values, callbacks, GameOption collection and joypad-row identities remain. Multiple controls sharing a row retain relative spacing. Native stencil/joystick scrolling precedes card backing; native render clears its stencil. Translator pagination refreshes geometry.

## Contained layout

The section dropdown selects the original localized heading, such as Window, Textures or Rendering and Performance. Measured rows fill one bounded card. Previous/Next controls and a counter handle more rows than the available height. Labels stack above controls when needed; native controls/text are not shrunk to force all settings onto one page. Native visibility intent is tracked separately from paging: hidden settings stay hidden; later native visibility changes take effect when shown. All settings remain in native Apply/save processing.

Fitting supported pages reset scroll offsets/extents to the viewport, hide the vertical bar and remove the unused horizontal bar. Hidden native separators do not contribute false horizontal overflow. Sidebar categories fit without wheel scrolling; compact rows omit subtitles, and additional mod categories use explicit navigation pages. Active-category changes reveal its navigation page. Footer buttons wrap when needed; content width stays bounded on ultrawide screens.

A native shared combo popup can retain a true visible flag after removal from UIManager. Category/search actions are blocked only while its parent is expanded and its actual UI object is registered, or during native modal/key capture. Ordinary dropdown activity no longer erases categories/search. Native footer hidden/disabled state is never forced on.

Specialized key/controller pages, unknown provider structures and an individual native row larger than its viewport retain native internals and genuine overflow access. Horizontal fallback excludes invisible/decorative separators, puts a necessary bar at the viewport bottom and removes it once actual content fits. Negative native horizontal bounds receive a uniform origin shift; key-label anchors retain alignment. Arbitrary providers cannot safely be guaranteed scrollbar-free. Long translations, very large native widgets and engine popup geometry require runtime acceptance.

## Search and controller input

Search indexes localized native labels, tooltip text and category names, using literal whitespace-separated tokens. Internal 128-character/eight-result/viewport caps protect UI work; these are not player settings. Pointer/controller results or Up/Down then Enter activate the original category and select the section/page containing its existing control. Unsupported pages retain native scroll-to-control behavior. Search does not apply/restore/save values. Escape exits focused search first; Return consumption prevents the same press from accepting Options. Otherwise native Return/Escape remain.

Native Left/Up boundary propagation hands focus to the owned navigation graph, preserving native slider/expanded-control direction handling. Right returns to native content. Search, section/page controls and categories belong to the owned graph; native page rows are unchanged. Section/page changes place controller focus on a visible native control. While navigation owns focus, B/X/Y/bumpers return to the native page and delegate. Native modal/combo/key capture blocks actions.

The reference's global Restore Defaults is omitted: installed restoreOriginal rolls back to the open-time snapshot, not factory defaults. Existing page-specific resets remain usable.

## Validation and runtime gate

This compatible PATCH correction preserves API1, saved menu/HUD/style schemas, approved defaults and preference files. It is client-local presentation without shared gameplay, sandbox or networking state. Native dirty/display confirmation, key capture, audio preview/rollback, Apply/Accept/Back and persistence remain authoritative. Build-specific fingerprints/findings: OPTIONS_LAYOUT_SOURCE.json.

[TESTED: offline Windows, 2026-10-22] The dismissed-popup regression fails against 88b019c with "Dismissed shared popup hid categories/search" and passes on current source. Full fixtures pass with global next unavailable: seven window sizes including 1344x864 from the screenshot, four simulated font heights, every section/page, native hidden/disabled intent, compound-row offsets, Apply collection identity, visible-row controller focus, search reveal, oversized separator removal, 35 added categories, and genuine fallback-bar placement/removal. Commands: `python -X utf8 -B scripts/check_versions.py`, `python -X utf8 -B tests/run_tests.py`, `git diff --check`. Inventory 68 runtime files / 144 keys / 29 English-fallback locales; translations unreviewed. Doubles are not native rendering/input proof.

The preceding 0.9.0-dev.2 local deployment reached Options styling/interface setup without the earlier global-next exception. Its subsequent user screenshot showed blank categories and overflowing Display layout: startup success was not visual acceptance. The dev.3 correction was deployed with68/68 file hash parity but native Options setup FAILED at OptionsLayout.lua448: ISComboBox has no generic setTooltip method.

[RUNTIME GATE] Check title-screen/Esc Options at standard/ultrawide sizes: visible categories/search, contained sections/pages at 1920x1080, all settings reachable, dropdown dismissal, controller visible-row focus, search into another section/page, and no spurious bars. Also check large fonts/translations, specialized-page fallback, key capture/cancel, audio preview then Back, display change/revert, unsaved Back, disabled Apply and native resets. G6 NOT TESTED; project G7/stable G8 BLOCKED. No new deploy, launch, package, merge or upload accompanies this source iteration.

0.9.0-dev.4 uses installed ISComboBox.setToolTipMap with defaultTooltip immediately after every sectionBox.clear, because clear resets the map. The native-shaped fixture now exposes setTooltip only on actual label/button/text-entry classes. It fails before the fix at the same attach call as the native stack and passes afterward, including map retention across layout/section rebuilds. No native option/control/profile ownership changes. Post-fix native Options acceptance NOT TESTED; retest the sidebar, contained pages and dropdown help.
