# Native UI, editors and preset sharing — Workshop MP testing update

Project Version: 0.12.0-dev.1

2026-10-24: UPLOAD SUCCESS VERIFIED for existing public Workshop item3822582242, App108600, Mod ID B47ANCEDUI. SteamCMD exited0 and confirmed update commit success. Independent Steam public metadata confirms the same item/title/public visibility and exact staged description, including "MP testing build - dedicated multiplayer NOT TESTED". Transport size4974103 bytes is separate from ZIP size.

The owner's request was to merge all open UI PRs and publish. PR16 was the only open feature PR and merged after both required checks passed. Release source/validation commit: `d992608f31237885c5eae5a5bb3aef9f73594d0c`. Exact merged-head CI also passed. This combines the native UI/Options overhaul, layout editors,53 editable colors, multiple local styles and inactive data-only plugin catalogue/export. The optional helper and setup are linked from the public listing; the user-authored preset/plugin publishing workflow itself remains NOT TESTED in PZ. Provider upload success does not validate that separate flow.

All78 runtime files match source, deterministic ZIP and Workshop staging. ZIP SHA-256: `d90812f5d244c2ee5e0043decada9c85764774f571980b8196f439eaefaeb3d8`. Description SHA-256: `7ad6c6f0cc51d2728dad07aedb4600863fe8c0274e6b4d5b98c37afec35a8f4f`; changenote SHA-256: `7b5f4d816e919dde300efc23f980243617f15fb9f641481ccf6870bab5c46052`. The unchanged panorama SHA-256 is `340e86248af1da41a23bda51a46ecd7fff39d356096a8ebf6313d7685c87d5c0`. Existing thumbnail/artwork and public visibility were preserved; no preview replacement was submitted. Portable immutable receipt: WORKSHOP_UPDATE_0.12.0-dev.1_2026-10-24.json. Authentication output remains private and excluded from Git.

Canonical text: docs/WORKSHOP_DESCRIPTION.md and docs/WORKSHOP_CHANGELOG.md. Generated output: workshop/description.bbcode. Package: dist/current/B47ANCEDUI-0.12.0-dev.1.zip. Staging: dist/workshop-update-0.12.0-dev.1-d992608f3123. Its release-manifest.json binds exact source/version/item, target42.21.0/revision4a0e9546ec/Steam25485521, all file/package/text hashes and offline validation status. Runtime mods are Lua-only; the optional standard-library Python helper is authoring tooling outside the runtime payload.

[TESTED: offline Windows] Commands:

```text
python -X utf8 -B scripts/build.py
python -X utf8 -B scripts/build.py --verify
python -X utf8 -B scripts/check_versions.py --release
python -X utf8 -B scripts/check_native_rollout.py --game-root <verified-installed-game-root>
python -X utf8 -B <team-tools>/Build-WorkshopDescription.py --repo . --input docs/WORKSHOP_DESCRIPTION.md --output workshop/description.bbcode
python -X utf8 -B <team-tools>/Build-WorkshopDescription.py --repo . --input docs/WORKSHOP_DESCRIPTION.md --output workshop/description.bbcode --check
python -X utf8 -B scripts/prepare_workshop_update.py
git diff --check
```

All PASS. Build runs the complete Lua5.1 regression suite with global next unavailable, source/version/localization/case checks, package corruption/path/duplicate checks, artwork integrity and disposable cross-Lua preset packager tests. Inventory78 runtime files/198 keys/29 unreviewed English-fallback locales. Strict publication validation confirms App/item/content identity,6634-byte description, required labels, real newlines, public source/setup/helper links and exact VDF round trip. Independent read-only stage review confirms source/ZIP/stage hash parity, empty engine directories, clean merged checkout and no symlinks. Freshness confirmed HEAD/upstream/main equality with no unfinished operations. Public tracked-file audit passed.

Recovery: the prior0.5.0-dev.11 ZIP/provenance was retained unchanged and hash-verified before/after upload (`5d73de36f5d9767f1ab52cbdf8c4af7e94fa4ec14d6e49368c75f245f89ed9f2`). Earlier packages/receipts/source remain intact. No artifact cleanup or live rollback was performed.

After success, the owner explicitly approved this Steam desktop restart. Steam was already closed; its executable was verified from the registered local installation and Valve file identity, then started once with a hidden launch window. The desktop process was confirmed. No forced termination, game/server launch or local mod deployment was performed. Starting Steam does not prove subscribed content downloaded.

[RUNTIME GATE] Native visuals/input/controller/split-screen, actual settings/profile reload, enabled-plugin discovery/export, helper/uploader integration, performance, subscription/download and dedicated dependency startup/join/rejoin/synchronization/persistence/restarts remain NOT TESTED. G6 NOT TESTED; G7 BLOCKED / NOT TESTED; stable G8 BLOCKED. Upload success proves distribution only. Installed overrides mean source checks are not pristine-vanilla certification. No server files were changed.
