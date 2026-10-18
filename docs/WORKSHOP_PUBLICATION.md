# First public Workshop MP testing upload

2026-10-18: owner explicitly authorized creating a new public Steam Workshop item and uploading the MP testing build. SteamCMD reported `Committing update...Success.` and exit 0; its VDF was updated with assigned item **3822582242**. Independent public Steam API metadata confirms title B47ANCE'd UI, consumer App ID 108600, visibility 0/public, the testing label and non-banned state. No second creation request was made.

- Canonical identity: WORKSHOP_ID.txt. Never create another item for this project.
- Published version: 0.1.0-dev.1; Mod ID B47ANCEDUI; public client API 1; target PZ 42.21.0.
- Package source commit: c8898283db0e723f314cf8a87faef115b706b97e.
- Upload/validation commit: 37b9e5fbaaff055fdff97134ceabd4efdd92de7c; the intervening validation correction changed no runtime/version/source inventory. Exact source/ZIP/staging byte/hash checks passed.
- Package SHA-256: dfda5d43a46f3f107abca8be1dbc4d1ff0ce269607ccdc8e1c1fb067483ba671.
- 40 runtime files plus empty engine/common directories. Public Steam payload size: 46671 bytes (Steam transport size is distinct from ZIP size).
- Canonical listing: docs/WORKSHOP_DESCRIPTION.md. Canonical note: docs/WORKSHOP_CHANGELOG.md. Generated description: workshop/description.bbcode.
- Exact checks: `python -B tests/run_tests.py`; `python -B scripts/build.py --verify`; `python -B scripts/check_versions.py --release`; strict team BBCode renderer `--check`; direct staged/source hash parity; exact-head offline GitHub CI PASS. Version --release PASS covers metadata/artifacts only, not stable G8.
- Private authentication/uploader logs and local creation receipts remain ignored under dist/. The first result detector expected a different success-string format and reported unconfirmed; preserve that initial receipt. The actual commit-success line, assigned VDF ID and independent public metadata establish confirmed success in a separate receipt.
- No preview supplied; UI's exclusion from generic fallback branding is preserved. No fabricated/custom image substituted.

[Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=3822582242) · [Public GitHub source](https://github.com/B47ANCE/B47ANCEDUI).

MP testing build - dedicated multiplayer NOT TESTED. Native SP/controller/split-screen/subscribed-download/dedicated acceptance NOT TESTED. G7/stable G8 BLOCKED. Upload is distribution evidence only. No local deployment or game/server launch. User explicitly chose to leave Steam unchanged; no desktop shutdown/restart/launch was performed.

This is a dated immutable publication record, not a current runtime-validation mirror. Future versions must preserve these original version/commit/hash identities. Existing-item updates must reuse 3822582242; the draft-only preparation helper refuses new-item work when WORKSHOP_ID exists.
