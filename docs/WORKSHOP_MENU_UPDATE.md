# MenuButton Workshop MP test update

Project Version: 0.3.0-dev.1

Status: PREPARED SOURCE / UPLOAD NOT YET PERFORMED.

2026-10-18: owner requested merging PR 6 and publishing this MP testing build. PR 6 merged as 1234dcd91ee356ea5b6281a970e23cc035b9ffbf after offline CI passed. The compatible MINOR component addition retains public API 1. Publication metadata does not change the runtime version.

Existing public Workshop item 3822582242, App ID 108600, Mod ID B47ANCEDUI. The listing adds the separate large-text, borderless MenuButton and explicitly states that vanilla main/pause menus are not automatically replaced. Small/Normal regular buttons and grey/hex/RGB appearance remain.

Canonical listing and notes: docs/WORKSHOP_DESCRIPTION.md and docs/WORKSHOP_CHANGELOG.md. Generated BBCode: workshop/description.bbcode. Deterministic package: dist/current/B47ANCEDUI-0.3.0-dev.1.zip. Existing-item staging, VDF and release manifest: ignored dist/workshop-update-0.3.0-dev.1-*. Source/ZIP/stage hashes, real newlines, identity, version and exact merged-head CI must pass before cached-login SteamCMD upload. The uploader captures authentication output privately and performs no Steam desktop action.

Recovery: preserve the completed 0.1.0-dev.1 and 0.2.0-dev.3 packages, staging and provenance. Prior 0.2.0-dev.3 ZIP SHA-256: eb97707aff4fc022551d399972380d44b472d7c850146ba7169af57a5a2371ad. No cleanup or live rollback is implied.

MP testing build - dedicated multiplayer NOT TESTED. Native SP/menu/controller/split-screen/settings acceptance and subscription/download are NOT TESTED. G7 BLOCKED / NOT TESTED; stable G8 BLOCKED. Upload success is distribution evidence only. Next human checks: subscription/download, consumer menu states and callbacks, font scale, scoped accent/save/reload, dependency startup, then dedicated join/rejoin and unchanged gameplay synchronization/persistence/restarts. No local deployment or game/server launch. A Steam desktop restart requires a separate affirmative reply after upload success.
