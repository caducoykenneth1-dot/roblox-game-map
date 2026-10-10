# Waterfall repair — 10 October 2026

Applied in Roblox Studio and saved in the repository's `robloxgamemap.rbxl`.

- Reshaped and joined the two cascade tiers; waterfall widths increased by 20%.
- Raised the source from about 44 to 48.1 studs.
- Enlarged the ground basin to 50.4 × 52.8 studs; widened the stream by 15%.
- Rebuilt the connected water union, repositioned shore stones and reeds, and added moss ledges, fine flow bands, impact foam, mist, and droplets using existing scene assets and native effects.
- Applied the requested lighter palette: pale aqua, mint green, sage stone, cream banks, and pink blossoms.
- Revised client motion uses 72 pooled parts, 70 animated details, and five scrolling textures.

Verification: inspected the scene and captured the result in Edit and Play. Client flow moved during the probe, with no script errors. Water joins and anchored geometry checked. The two adjacent plot paths passed WorldCheck (0 errors, 0 warnings). UiCheck returned no findings; no UI elements were in scope.

The original place is retained in Git history. Local recovery files are excluded from Git. A full pre-edit copy of the affected Studio models and source is also in `ServerStorage.WaterfallRepairBackup_20261010`.

`reshape-waterfall.luau` records the initial geometry pass; `finish-waterfall.luau` records the subsequent palette and finishing adjustments. These are Edit-mode authoring scripts, not runtime scripts. The saved map already includes their changes. `StuddedWaterVisuals.client.luau` is the installed client animation source.
