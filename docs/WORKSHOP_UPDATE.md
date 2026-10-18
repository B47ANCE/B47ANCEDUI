# Current Workshop MP test update

Project Version: 0.2.0-dev.3

2026-10-18: owner authorized merging UI PR 2, then PR 3, and publishing the next MP testing build. PR 2 merged as 5401417aba4343470ef8c2e07c33434a814e8b4f; PR 3 then merged as 0654c0c87f97c79a75377d12251ee9e6afc19ff0. Before upload, the owner removed the third button size. This checkpoint offers only Small/Normal; legacy Large requests alias Normal. API 1 and explicit native geometry/callbacks stay compatible. Grey #B0B0B0 default and local hex/RGB editing remain.

Status: UPLOAD SUCCESS VERIFIED. SteamCMD exited 0 and reported successful commit; independent public Steam metadata confirms the unchanged public item and exact staged description. See WORKSHOP_UPDATE_0.2.0-dev.3_2026-10-18.json for the dated immutable receipt. Existing item 3822582242, App ID 108600, Mod ID B47ANCEDUI and public visibility remain fixed. No item creation, visibility change, generic fallback art, local deployment or game/server launch is authorized by tooling.

Publication-only metadata/tooling changes accompany the 0.2.0-dev.3 button checkpoint; no separate runtime bump for staging helpers. Canonical inputs: docs/WORKSHOP_DESCRIPTION.md and docs/WORKSHOP_CHANGELOG.md. The listing now documents near-black rounded surfaces, two button sizes, grey default and the hex/RGB editor, while retaining original credits and explicit missing runtime evidence. Changenotes use real paragraphs and the required testing label.

Run from the fresh public-source checkout:

```sh
python -B tests/run_tests.py
python -B scripts/build.py
python -B scripts/build.py --verify
python -B scripts/check_versions.py --release
python -B <team-tools>/Build-WorkshopDescription.py --repo . --input docs/WORKSHOP_DESCRIPTION.md --output workshop/description.bbcode
python -B <team-tools>/Build-WorkshopDescription.py --repo . --input docs/WORKSHOP_DESCRIPTION.md --output workshop/description.bbcode --check
python -B scripts/prepare_workshop_update.py
```

The new helper reuses deterministic source/ZIP validation, copies exact runtime files and empty engine directories, and emits an assigned-ID VDF and release manifest under ignored dist/workshop-update-*. It performs no upload, authentication or Steam desktop action. Invalid/zero identities, visibility/app mismatch, stale source, unsafe archives and escaped newline strings fail closed. Package receipts now bind the assigned canonical Workshop ID. [Valve's description-size constant](https://partner.steamgames.com/doc/api/ISteamRemoteStorage#Constants) is 8000 bytes; generated descriptions stay below it and preserve real line breaks.

The private local uploader uses the already verified SteamCMD executable and cached account only, capturing authentication output outside public tracked files. It verifies actual commit-success output and the unchanged item identity, then independently checks public Steam metadata. No automatic Steam desktop restart: ask only after upload success, and act only after a specific affirmative response.

Recovery: preserve the original 0.1.0-dev.1 ZIP, source/staging/provenance and public receipt. Prior ZIP SHA-256 dfda5d43a46f3f107abca8be1dbc4d1ff0ce269607ccdc8e1c1fb067483ba671. No cleanup, package overwrite or live rollback is implied. Older UI versions read opacity but may drop the newer accent on save; old legacy files remain unchanged.

MP testing build - dedicated multiplayer NOT TESTED. Offline checks and upload success do not establish native SP/controller/split-screen/typing/settings reload/draw performance/download or dedicated behavior. G7 BLOCKED / NOT TESTED; stable G8 BLOCKED. Next human gates: subscription/download, UI/Quartermaster dependency startup, two local profiles, hex/RGB save/reload, controller, then dedicated client join/rejoin, unchanged gameplay synchronization and persistence/restarts. No server mutation/launch is performed here.

Confirmed upload: source/validation commit 0871b353a3775a932b70a16c6876006c514e4bbd; package SHA-256 eb97707aff4fc022551d399972380d44b472d7c850146ba7169af57a5a2371ad. The 40-file source/ZIP/staging content and canonical description/changenote matched exactly. Steam public transport size is 65585 bytes, distinct from the ZIP archive size. Main-source CI, standalone and paired UI tests, version --release, archive integrity, strict BBCode and VDF/newline guards passed offline. The prior ZIP hash was verified unchanged before and after upload.

PR 4 merged the final Small/Normal checkpoint before packaging. User explicitly declined a Steam desktop restart for this upload; no client shutdown, restart or launch occurred. No local deployment, game/server launch or remote server change. Dedicated remains NOT TESTED and stable G8 BLOCKED.
