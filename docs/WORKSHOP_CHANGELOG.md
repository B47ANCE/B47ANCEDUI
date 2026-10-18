Version 0.1.0-dev.1

MP testing build - dedicated multiplayer NOT TESTED

Initial shared UI foundation: public client Lua API 1, native controls, rendering/layout helpers, dialogs, focus, tooltips, per-mod/local-player appearance settings and clipboard drawing. Quartermaster integration consumes this standalone provider. Old registered appearance files import read-only; explicit saves use the new scoped location without overwriting legacy files.

Offline standalone and paired Quartermaster tests passed. Native SP, controller, split-screen and dedicated multiplayer NOT TESTED. Full vanilla UI overhaul and CCTV remain future work. No custom Java/JAR dependency. No stable-release approval.
