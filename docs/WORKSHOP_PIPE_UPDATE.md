# Selected pipe artwork — Workshop MP testing update

Project Version: 0.5.0-dev.11

2026-10-19: UPLOAD SUCCESS VERIFIED on existing public Workshop item 3822582242, App ID 108600, Mod ID B47ANCEDUI. SteamCMD exited 0 and confirmed commit success. Independent public metadata confirms the same public item and exact staged description, including "MP testing build - dedicated multiplayer NOT TESTED". User declined the separate Steam restart; Steam desktop remained unchanged.

The user requested applying the selected left-wall pipe image, merging open UI PRs and publishing. PR 14 was the only open UI PR and merged after CI as 83ff4d7099209ff41ea3f0f63321bc0676d91ece. The selected generated PNG is shipped unchanged. Its straight horizontal pipe, four transparent CRTs and standard/ultrawide crop are paired with a dynamic menu below the pipe and above the baseboard. Public API 1, native actions/controller label objects, status-note ownership, static/no-signal timing and audio behavior are unchanged.

Release source/validation commit: `83ff4d7099209ff41ea3f0f63321bc0676d91ece`. ZIP SHA-256: `5d73de36f5d9767f1ab52cbdf8c4af7e94fa4ec14d6e49368c75f245f89ed9f2`. Active panorama SHA-256: `340e86248af1da41a23bda51a46ecd7fff39d356096a8ebf6313d7685c87d5c0`. All 52 runtime files match source, ZIP and stage. Public transport size 4364560 bytes is distinct from ZIP size. Portable immutable receipt: WORKSHOP_UPDATE_0.5.0-dev.11_2026-10-19.json. Authentication output remains private and excluded from Git.

Canonical listing/notes: docs/WORKSHOP_DESCRIPTION.md and docs/WORKSHOP_CHANGELOG.md. Generated listing: workshop/description.bbcode. Package: dist/current/B47ANCEDUI-0.5.0-dev.11.zip. Staging: dist/workshop-update-0.5.0-dev.11-83ff4d709920, whose release-manifest.json binds source, version, item and file hashes.

[TESTED: offline Windows] Exact commands:

```text
python -X utf8 -B tests/run_tests.py
python -X utf8 -B scripts/build.py
python -X utf8 -B scripts/build.py --verify
python -X utf8 -B scripts/check_versions.py --release
python -X utf8 -B <team-tools>/Build-WorkshopDescription.py --repo . --input docs/WORKSHOP_DESCRIPTION.md --output workshop/description.bbcode
python -X utf8 -B <team-tools>/Build-WorkshopDescription.py --repo . --input docs/WORKSHOP_DESCRIPTION.md --output workshop/description.bbcode --check
python -X utf8 -B scripts/prepare_workshop_update.py
git diff --check
```

All PASS. Freshness confirms clean merged source matching upstream/main. Source inventory is Lua-only, case-correct and free of custom Java/JAR dependencies. Exact merged-head CI, public tracked-file audit, identity/VDF/real-newline checks and cached-login uploader preflight PASS. Offline tests cover PNG SHA/CRC, full inset alpha interiors/no extra transparent holes and nine viewport sizes with normal/oversized width requests. Code-composited 1080p, 32:9 and 4:3 previews were visually checked with illustrative fonts; these are not native PZ screenshots.

Recovery: prior 0.5.0-dev.8 ZIP/provenance retained unchanged, SHA-256 `2fdb0a7c6c5e637c91e4b5d8d186033038fb650dfb18aa12ba9c3a72d1ab4c6f`. Older packages, source history and receipts remain intact. No cleanup or live rollback is implied.

[RUNTIME GATE] Native menu rendering/input/controller, optional provider states, audio restoration/rain-thunder listening, settings, split-screen, subscribed download and dedicated dependency startup/join/rejoin/synchronization/persistence/restart acceptance remain NOT TESTED. G7 BLOCKED / NOT TESTED; stable G8 BLOCKED. Upload success proves distribution only. No local deployment, Steam restart or game/server launch was performed. Server changes require separate authorization.
