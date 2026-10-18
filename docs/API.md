# Public Lua API

Project Version: 0.2.0-dev.1

Client only. `local API=require 'B47ANCEDUI/API'`; `API.requireVersion(1)` returns the provider or errors for an unsupported API major before application UI is constructed. `API.apiVersion` is the independent contract major; `API.version` is the project version. API 1 is the initial contract. Add `B47ANCEDUI` to mod.info `require`; no bundled implementation fallback or private module require is supported for consumers.

`local UI=API.forMod('StableModID', options)` returns a cached, scoped facade. IDs are case-sensitive ASCII `[A-Za-z][A-Za-z0-9_.-]*`, at most 64 bytes; no filesystem paths. Registration is idempotent with the same options and rejects conflicting migration prefixes. Optional `legacyAppearancePrefix` permits read-only import of `<prefix><localPlayer>.txt` containing `opacity=N`; never use another mod's prefix without its owner's permission. Quartermaster explicitly registers its existing prefix.

| API | Contract |
|---|---|
| `UI.WindowShell/Panel/Button/IconButton/ScrollList/TextInput/NumberInput/Toggle:new(...)` | Same arguments and lifecycle as the corresponding native factory in Controls; returned native instance is styled and tagged with consumer scope. Caller initializes/instantiates/adds/removes it. |
| `UI.skin(widget,kind,role)` / `skinChildren(parent)` | Owned instances only; idempotent styling. Never pass unknown third-party trees or native global classes. Kinds include window/panel/button/list/input/dropdown/label; role primary/destructive optional. |
| `UI.Dropdown.style(widget)` | Style an existing native combobox. |
| `UI.Button.sized(size,x,y,width,title,target,onclick,...)` | Opt-in `small`, `normal`, `large`: minimum heights 24/32/44, horizontal padding 8/12/18, corner radii 3/4/6. Height grows with native font metrics. Same native lifecycle/callback arguments; also available on IconButton/Toggle. Unknown IDs error. |
| `UI.Button.setSize(widget,size)` / `UI.Theme.buttonSize(size)` | Opt-in height/font/padding/radius update; returns widget. Theme returns a fresh caller-owned metric record. Existing `:new(...)` dimensions and legacy `Theme.metrics().button` stay unchanged. |
| `UI.Theme.colors/fonts/spacing`, `Theme.metrics()` | Shared design tokens/read-only-by-contract. Font metrics cached. Do not mutate shared tables per app. Arbitrary fonts/themes are not provided. |
| `UI.Renderer.rect/border/text/fit/icon/background`, `UI.Table.prepare/draw` | Shared drawing/table helpers, same retained native arguments; text/rows and callbacks supplied by application. No gameplay data fetching. |
| `UI.Layout.place(widget,x,y,width,height)` / `.scrollbar(list)` | Explicit geometry, disables competing native right/bottom anchors. `UI.bounds(window,playerNum)` clamps origin; oversized-window reflow remains caller-owned. |
| `UI.TabBar.add/select`, `UI.SectionHeader.draw`, `UI.SearchField.attach` | Native-semantic styled controls; SearchField returns entry/clear/layout handles. Caller owns search and translated labels. |
| `UI.Focus.visibleRows(owner,build)` / `.restore(player,owner)` | Rebuild visible controller rows and restore reachable owner; no mouse-only assumption. |
| `UI.menu(menu)` | Style an owned existing context menu without replacing options/callbacks. Application decides eligibility. |
| `UI.Dialog.decorate(dialog,player,owner)` / `.confirm(player,text,labels,callback,owner)` | Focus-restoring dialogs. labels supplies accept/cancel/optional extra; callback gets accept/cancel/extra. Native behavior retained. |
| `UI.Tooltip.attach/dispose/hide/set/inspect/context`, `UI.RowTooltip.attach/place/hide` | Instance-managed bounded tooltips; inspect(player,text,owner) returns a focusable panel. Caller cleans owned UI. |
| `UI.Appearance.get(player)` / `.set(player,percent)` / `.save(player)` | Consumer/player-specific opacity; default 82, bounds 20–100. Set changes local cache only; save returns false on missing/failing writer. Valid local slots 0–3. Reading/importing never writes. |
| `UI.AppearanceEditor.open(owner)` | Lazy native-slider editor, player/scoping inherited from owner; controller B/Close returns focus; existing preview/save behavior retained. |
| `UI.Clipboard.colors`, `.draw(panel,view,metrics,title)` | Original Lua clipboard geometry; view.left is the content inset; title is supplied/localized by app, generic translated fallback if omitted. No inventory/world mutation. |

The API contract includes the exported helpers above; implementation files are not public load entry points. Styling never authorizes a gameplay operation. Consumers must validate server authority, permissions and network replies in their own mods. No new sandbox gameplay option is appropriate for local colors/geometry/opacity. Internal layout constants are technical constraints.

Appearance migration is a read fallback only; new explicit saves write `B47ANCEDUI/appearance/<consumer>.<player>.txt` through vanilla cache/Lua APIs. Legacy files are preserved. The file is bounded-value data, not executable Lua. Invalid values use default. This is not atomic crash-safe multi-record profile storage. See architecture for recovery limits.

Main menu/CCTV, whole-game theming, arbitrary fonts, universal No Click and automatic layout editing are not claimed by API 1. Support for those requires separate Lua-only evidence/design.

The 0.2.0-dev.1 style uses near-black surfaces, muted sage accents and restrained corners. Rounded fill/border helpers use cached, bounded Lua scanlines through native drawRect; instance wrappers round only exact backing bounds. Textures and decorative subrectangles retain native geometry. Texture clipping, antialiasing and rounded hit testing are not provided; native rectangular hit areas remain. Native performance, pixels and input require runtime acceptance. These technical presentation tokens need no shared gameplay sandbox options.
