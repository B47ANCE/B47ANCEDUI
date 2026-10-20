# Selected left-wall pipe artwork — 0.5.0-dev.11

User selected this pipe-only edit for application, merge and Workshop publication. Built-in image generation, precise-object-edit mode; selected output PNG used unchanged. No external artwork or raster post-processing.

Asset: src/B47ANCEDUI/42/media/ui/B47ANCEDUI/SecurityRoomPanorama.png, 2172x724 RGBA. SHA-256: `340e86248af1da41a23bda51a46ecd7fff39d356096a8ebf6313d7685c87d5c0`.

Visual review confirms a straight connected left-wall pipe at the existing height and the same scene composition. This does not assert pixel-identical preservation outside the pipe; generated CRT edge RGB/alpha varies slightly. The opaque black underlay remains required. Measured bounds/masks are in MENU_ARTWORK.json; inset glass transparency and absence of extra alpha-zero holes are checked offline. Native PZ rendering remains NOT TESTED. Earlier full-room prompts are historical.

```text
Use case: precise-object-edit.
Edit the attached security-room panorama. Make ONE small localized change only: extend the existing horizontal metal pipe across the empty LEFT wall at its existing height, approximately y=95 on the 2172x724 canvas. Join the short pipe coming in from the left edge above the vent to the main horizontal pipe that currently starts around x600 above the CRTs. Fill the gap between them with one straight continuous pipe at this same level, matching the pipe's diameter, muted worn-metal finish, highlight, shadow and small couplings. It should run uninterrupted from the left image edge all the way to the existing central/right pipe. Do not route it along the top edge, raise it, add a rectangular detour, or add another parallel run.
Keep everything else in this supplied image exactly as it is: same canvas, crop, desk position/size, four CRT monitors in 2x2 layout, wall paint, lighting, floor, vent, storage chest, filing cabinets and all props. Do not regenerate or recompose the room. Preserve the four genuine transparent CRT display openings and the existing image alpha; all other scenery should retain its existing appearance. No text, logo, menu or watermark. Return the entire original panorama with only that missing left pipe segment completed.
```
