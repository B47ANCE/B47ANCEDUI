# MenuButton Workshop MP test update

Project Version: 0.3.0-dev.1

Status: UPLOAD SUCCESS VERIFIED. SteamCMD exited 0 and reported successful commit; independent public Steam metadata confirmed the same public item and exact staged description. Dated receipt: WORKSHOP_UPDATE_0.3.0-dev.1_2026-10-18.json.

2026-10-18: owner requested merging PR 6 and publishing this MP testing build. PR 6 merged as 1234dcd91ee356ea5b6281a970e23cc035b9ffbf after offline CI passed. The compatible MINOR component addition retains public API 1. Publication metadata does not change the runtime version.

Existing public Workshop item 3822582242, App ID 108600, Mod ID B47ANCEDUI. The listing adds the separate large-text, borderless MenuButton and explicitly states that vanilla main/pause menus are not automatically replaced. Small/Normal regular buttons and grey/hex/RGB appearance remain.

Canonical listing and notes: docs/WORKSHOP_DESCRIPTION.md and docs/WORKSHOP_CHANGELOG.md. Generated BBCode: workshop/description.bbcode. Deterministic package: dist/current/B47ANCEDUI-0.3.0-dev.1.zip. Existing-item staging, VDF and release manifest: ignored dist/workshop-update-0.3.0-dev.1-*. Source/ZIP/stage hashes, real newlines, identity, version and exact merged-head CI must pass before cached-login SteamCMD upload. The uploader captures authentication output privately and performs no Steam desktop action.

Recovery: preserve the completed 0.1.0-dev.1 and 0.2.0-dev.3 packages, staging and provenance. Prior 0.2.0-dev.3 ZIP SHA-256: eb97707aff4fc022551d399972380d44b472d7c850146ba7169af57a5a2371ad. No cleanup or live rollback is implied.

MP testing build - dedicated multiplayer NOT TESTED. Native SP/menu/controller/split-screen/settings acceptance and subscription/download are NOT TESTED. G7 BLOCKED / NOT TESTED; stable G8 BLOCKED. Upload success is distribution evidence only. Next human checks: subscription/download, consumer menu states and callbacks, font scale, scoped accent/save/reload, dependency startup, then dedicated join/rejoin and unchanged gameplay synchronization/persistence/restarts. No local deployment or game/server launch. A Steam desktop restart requires a separate affirmative reply after upload success.

Confirmed release source/validation commit: fce8d4a84ca9fd2a2c8bf3158b7c7dfe8ae967b9. ZIP SHA-256: 40155c541835efed91bee98d749dbab59f0f044bbdfd9d87bcce06637c18485a. All 40 runtime files matched source, ZIP and stage; the previous ZIP hash remained unchanged before/after upload. Public transport size: 67088 bytes (distinct from ZIP size). No Steam desktop restart was performed. No local deployment, game/server launch or remote server change.

[TESTED — offline Windows, 2026-10-18] Exact commands from the release checkout: `python -X utf8 -B tests/run_tests.py`; `python -X utf8 -B scripts/build.py`; `python -X utf8 -B scripts/build.py --verify`; `python -X utf8 -B scripts/check_versions.py --release`; `python -X utf8 -B <team-tools>/Build-WorkshopDescription.py --repo . --input docs/WORKSHOP_DESCRIPTION.md --output workshop/description.bbcode --check`; `python -X utf8 -B scripts/prepare_workshop_update.py`. All PASS, plus exact merged-head GitHub CI, public staged/tracked-file audit, identity/VDF/newline guards and freshness PASS before upload.

Focused consumer command PASS from unchanged Quartermaster 3e643183306b5175fcb6f931d76832ae311bebd3: `python -X utf8 -B tests/run_tests.py --only-ui --ui <ui-mp-030>/B47ANCEDUI --rooms <repositories>/B47ANCEDRooms --require-rooms --pc-framework <pc-workshop-publication>/B47ANCEDPCFramework`. PC commit c77cac2add9702e846d2c16adef9e88064ada136. This is host/Lua fixture evidence, not PZ runtime or dedicated proof.
