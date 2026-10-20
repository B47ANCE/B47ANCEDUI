# Full-room regeneration — 0.5.0-dev.10

User request: regenerate the entire image as one continuous image.

Tool mode: built-in `image_gen`, original owned dev.9 panorama supplied only as a subject/style/composition reference; transparent output requested. All scenery was regenerated in one call. The selected PNG is used unchanged, without raster post-processing or external artwork.

Asset: `src/B47ANCEDUI/42/media/ui/B47ANCEDUI/SecurityRoomPanorama.png`, 2172×724 RGBA.

SHA-256: `44cd90bc4f931afc10d20cda17534d7fdbb0be500e16b7fc774cab2e087773e1`.

The generated room has incidental partial alpha, so the existing opaque black underlay remains required. Four measured transparent glass openings mask the animated surfaces; full inset interiors and absence of other alpha-zero scenery holes are checked offline. Raw near-transparent RGB fringes are judged in the actual dark composite.

The following is the generation prompt, not proof that every requested coordinate was followed. Measured final coordinates are in MENU_ARTWORK.json; Lua masks and viewport tests use those measurements. Offline visual review covers room continuity and code-rendered compositions, not actual PZ rendering.

```text
Use case: stylized-concept.
Asset type: production pixel-art panoramic background for a survival game's main menu.
Primary request: Completely regenerate this abandoned bunker security room as ONE unified continuous illustration, drawn from edge to edge in a single coherent scene. This is a full redraw, not an extension, collage, seam repair, narrow edit, or reuse of rectangular image sections.
Input image 1 is ONLY a reference for the general subject, palette, layout and proportions. Repaint all of the room with unified perspective, textures, scale and lighting.
Canvas: very wide 3:1 panorama, preferably 2172 x 724 pixels.
Composition: a straight-on wide view of one continuous bunker wall and tiled floor. Left third contains an uncluttered dark charcoal wall for a large logo and a column of menu text which the game draws later. Keep the region from approximately x230 to x600 and y72 to y470 quiet and free of props or bright pipes. A small low storage trunk and a vent may sit at the extreme left edge, outside this clear region. The security desk is centered around x920 with a bank of EXACTLY FOUR vintage CRT monitors in a compact 2x2 grid, facing straight forward. Keep the four inner display apertures approximately near rectangles (744,182)-(882,262), (955,180)-(1090,262), (744,321)-(882,402), (954,321)-(1090,402), allowing natural bezels around them. Desk, keyboard, mug, papers, radio, and cables belong to the same room. The right third contains old metal filing cabinets, archive boxes, a noticeboard with indistinct diagrams, a key rack, wall telephone and a fire extinguisher.
Continuity: one uninterrupted wall paint boundary, consistent baseboard, consistent tile perspective and floor elevation across the full width. A physically plausible metal conduit runs continuously near the top of the wall from left to right with neat joined bends and branches only where useful. No awkward raised rectangular detour, dead-ended duplicate segments, floating pipe pieces, abrupt material boundaries, panel seams, scale changes or mismatched light pools.
Style: detailed crisp dark pixel art, controlled pixel clusters and weathered metal; restrained olive-charcoal, black, tarnished bronze, muted grey. Gentle amber bunker lamps, deep but readable shadow, coherent global lighting. No photographic blur. No people.
Transparency: the room fills the entire rectangle and is opaque EXCEPT the four rounded inner CRT screen apertures, which must be actual fully transparent alpha cutouts for live video animation underneath. No other transparent holes. Keep monitor frames and their buttons opaque.
No logo, menu text, readable writing, watermark, UIWorks branding, no-signal lettering, simulated CRT content or checkerboard painted into the image. Do not bake a game UI into the artwork. Deliver only the single continuous room illustration with the four transparent display openings.
```
