# Shareable preset plugins

Project Version: 0.12.0-dev.1

Open **Options → Interface → UI Style Presets**. Color properties accept hex or Red/Green/Blue sliders. Choose a shared preset or a registered consumer scope; changes preview immediately on supported UI. Save keeps the selection; Cancel restores the saved book. Multiple presets can be kept and switched without restarting. Menu/HUD layout profiles remain separate.

## Subscribe and choose

Subscribe to a preset pack, enable it together with B47ANCE'd UI, then open the preset editor. Packs appear in the existing preset list with their source Mod ID in brackets. Discovery is lazy on opening or **Refresh preset plugins**; it reads only enabled mods. A pack never changes the active preset, bindings, preferences or preview lease during discovery.

Selecting a pack makes an editable local copy and previews it. Save persists the copy. Cancel discards it. Removing or updating the source plugin leaves saved copies intact; choosing updated data creates a separate copy. Repeatedly choosing identical data reuses its copy. Same display names from different sources remain disambiguated. Up to16 local presets and256 external choices are supported; a full local book reports a limit without replacing anything. Discovery scans at most1024 enabled IDs. Malformed, unreadable and future-format packs are skipped with a catalogue warning, independently of local journal protection.

## Export and publish

**Export preset** exports the selected draft's authored component values and name. It does not implicitly Save or activate the draft. Exports contain styling and its scoped overrides; they omit bindings, other presets, menu/HUD geometry, legacy Appearance preferences, account IDs, saves, logs and local paths. Blank/inherited colors still inherit on the recipient's installation. To make a portable color explicit, set it in the component preset before exporting.

**New plugin** is the default. **Update previous export** is a separate choice that displays the previous export's name and requires its exact identity to still match. This prevents reused local preset keys from silently updating an unrelated item. New exports use independent file-safe IDs. Installation-local linkage uses a two-slot checksummed identity journal; updates do not rewrite it. Unreadable or future journals block writes; one valid slot can recover an interrupted alternate-slot write. Checksums detect corruption, not authenticity or power-loss durability.

Pure Lua has no verified safe writer for creating arbitrary new Workshop staging content. The in-game button writes bounded data under the game's Lua cache at `B47ANCEDUI/exports/<ID>.b47ui.txt`; the optional standalone helper turns it into a dependent mod. The helper is authoring tooling only, never required by the UI runtime or subscribed preset packs. It requires Python3.12+ with the standard library. Download `scripts/preset_packager.py` from this repository. Start it manually once per editing session, using your actual PZ data folder (the folder containing Lua and Workshop):

```sh
python preset_packager.py --watch --zomboid-dir "<your PZ data folder>"
```

With the helper running, each export click automatically stages its matching completed request. The editor changes from waiting to ready only for that exact export checksum. **Open Workshop** then hands the staged item to PZ's native uploader; review title, description, preview, visibility and terms and use its final Publish action. New staged items start private. No helper or UI code uploads, logs into Steam, launches a process or installs a background task. Steam mode and the main-menu Workshop screen are required for this handoff. Unsaved editor changes use the existing confirmation; native Options retains its own Back/rollback/confirmation flow.

For a manual single export:

```sh
python preset_packager.py "<export file>.b47ui.txt" --zomboid-dir "<your PZ data folder>"
```

**Open export folder** locates the data. If staging fails, keep the helper console open for its error; no ready status is issued for that revision. Re-export after editing: an earlier ready receipt cannot authorize changed data. The uploader itself is native; item creation/upload/download remain runtime acceptance gates.

The helper accepts only generated data/metadata/poster paths. It rejects unowned folders, unexpected content, changed generated files and escaping paths. It prepares an entire replacement before swapping directories, retains prior packages outside Workshop under `B47ANCEDUI-PresetPackages/history`, and rolls back failed installs. Native `workshop.txt` is preserved exactly on updates, including assigned item ID/visibility/tags. Data changes increment the plugin's own patch version; UI's canonical version stays independent. Original palette-swatch previews are generated, not native screenshots. No automatic history cleanup occurs. Manual changes to generated files require a new export identity or deliberate recovery outside the helper; the tool never erases them to make an update pass.

## Data contract

A standard Build42 mod depends on `B47ANCEDUI`. Generated content is `Contents/mods/<ID>/42/mod.info`, posters and `common/media/B47ANCEDUI/style-pack.txt`; there is no executable Lua in the plugin. This is a player-authored data format, not a new runtime dependency or automatically created team repository.

```text
b47ui-plugin=1
id=StablePackID
version=1.0.0
<complete schema1 StylePresets journal including checksum>
```

The transport header has its own schema1, stable ASCII ID (1–64 bytes) and canonical three-part version (≤32 bytes). Payload bounds remain16 presets,32 bindings,3072 values,48-byte UTF-8 names,512-byte lines and256KiB; total pack limit262400 bytes. Transport active/binding fields are parsed but never applied during discovery. Unknown bounded values remain inactive for future providers. Data is parsed without loadstring, require or code evaluation. Adler-32 detects accidental corruption and is not a signature. External mods are executable PZ mods generally; this format does not sandbox arbitrary third-party mod code.

`API.PresetPacks.schema`, `.path` and `.refresh()` expose the format version, fixed relative data path and copied catalogue/issues. Catalogue records contain source Mod ID, pack ID/version/key and detached preset data. Consumers should use API1; internal parser/editor/export modules are private.

## Evidence and limits

[VERIFIED: installed source] Build42.21.0/revision4a0e9546ec/Steam25485521 contracts for enabled-mod lists, text-entry colors, Options rollback and Workshop navigation are bound in NATIVE_ROLLOUT_SOURCE.json. Packaged native inspection constrains Lua-cache writers and existing-mod readers; absence of a verified arbitrary staging writer is a capability limit, not a universal proof about every engine method. Installed overrides mean this is not pristine-distribution certification.

[TESTED: offline Windows, Lua5.1/Python] Cross-language format round trips; inactive discovery; copies/collisions/capacity; read/close/partial-write/future-file guards; identity journals; RGB/hex/editor state; completed-request/status checks; exact data-only inventory; preview PNG CRC; versioned staging; metadata retention; transactional fault injection/recovery. Tests use disposable folders and doubles, with global next unavailable. No real player exports or Workshop folders were staged.

[RUNTIME GATE] Real enabled-mod reads, in-game export/read-back, selection/reload, native input/controller, filesystem permissions, helper-to-PZ wizard handoff, upload/download and performance remain NOT TESTED. G6 NOT TESTED; project G7/stable G8 BLOCKED. The initial implementation was source-only. The UI provider was subsequently merged/published as0.12.0-dev.1 on2026-10-24; see [distribution receipt](WORKSHOP_PRESETS_UPDATE.md). That upload does not verify this user-authored plugin workflow. No local deployment or game/server launch was performed.
