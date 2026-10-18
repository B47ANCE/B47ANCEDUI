# First Workshop publication preparation

Historical pre-upload preparation. The owner subsequently authorized creation and public item 3822582242 was verified; see WORKSHOP_PUBLICATION.md. Original package and validation commits below retain their actual identities.

Project Version: 0.1.0-dev.1

2026-10-18: owner requested publishing UI after merging UI PR 1 and Quartermaster PR 27, in that order. UI merge commit is 38ef51ec08759f75cecd138fa6f461f6158f2d73; Quartermaster merge is 3839523c53f59e2e36cab02463eff23009a6b44a. The public API/runtime source is unchanged by this publication tooling/documentation preparation, so the intended mod version stays 0.1.0-dev.1. This is not a relabeling of old runtime evidence or a new compatibility contract.

No Workshop item is assigned. The global publish contract authorizes updating an existing item; new-item creation requires explicit authorization. Preparation creates no SteamCMD submission VDF and never logs in, uploads, deploys or restarts Steam. UI is excluded from generic team fallback art, and no replacement image is invented. Workshop preview/artwork constraints must be resolved for actual submission.

Canonical description: WORKSHOP_DESCRIPTION.md. Canonical changenote: WORKSHOP_CHANGELOG.md. Generated BBCode: workshop/description.bbcode. Use the installed team's strict renderer, supplying its actual local path:

```powershell
python -B <team-tools>/Build-WorkshopDescription.py --repo . --input docs/WORKSHOP_DESCRIPTION.md --output workshop/description.bbcode
python -B tests/run_tests.py
python -B scripts/build.py
python -B scripts/build.py --verify
python -B scripts/prepare_workshop.py
python -B scripts/check_versions.py --release
```

Build requires a clean committed tree, tests and exact manifest; writes one deterministic ZIP, preserves any existing package, verifies safe/case-unique/member/CRC/content parity and records commit/version/hash. Package includes 40 inventoried runtime files and five empty common/engine directories; no generated source or development tooling is shipped. The source inventory remains authoritative. Draft staging verifies the same bytes beneath Contents/mods/B47ANCEDUI and binds description/changenote hashes to the receipt. Item ID remains null; upload NOT PERFORMED. Version --release verifies declared version/package mirrors only, never stable G8 or native readiness. No previous published UI package exists.

Offline tests include public API, scopes/preferences, syntax, translations, package traversal/case/unexpected/missing/changed members. Dedicated/SP/controller acceptance remains NOT TESTED. G7/stable G8 BLOCKED. Proposed description and note carry the exact MP testing label. A first upload additionally requires item creation/visibility authorization, correct SteamCMD content/preview inputs, fresh pushed commit/CI, complete package provenance and cached authentication. Do not treat this preparation as permission to create an item. After a verified upload, ask separately before any Steam desktop restart.

The initial package at source commit c8898283db0e723f314cf8a87faef115b706b97e exposed a CRLF-sensitive ZIP version selector. The selector correction changes no runtime source/version/manifest. Preserve that package and its original receipt: validation may use a descendant commit only after ancestry plus exact source/version/inventory equivalence and byte/hash checks. Draft receipt records the newer validation commit separately. This is explicit metadata-only applicability, not relabeling the package source or any runtime evidence. No current artifact is overwritten or deleted.
