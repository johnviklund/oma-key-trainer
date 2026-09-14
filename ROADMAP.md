# Roadmap

Sequencing only — see `PRODUCT.md` for what/why. Each item is sized to one future
`workflow brainstorm → wrap` run. Check items off here at wrap; don't grow prose here.

## Phase 1 — Plugin scaffold + v1 static list

- [x] Scaffold the plugin folder (`manifest.json`, bar widget + card QML) and get it loading
  via `omarchy plugin enable`. (plugin-scaffold-v1)
- [x] Author the initial curated ~10 (key combo, description) as static content. (plugin-scaffold-v1)
- [x] Render the box using `qs.Ui`/`qs.Commons` per `DESIGN.md`; wire the entry point — bar icon,
  optional menu row (R1–R3). (plugin-scaffold-v1)

## Phase 2 — v2 usage tracking

- [x] Pick and validate a background event source for Hyprland action-level usage (matches R7:
  action, not literal key). (usage-tracking-v2)
- [x] Persist per-binding counts and rotation position across reboots (R12). (usage-tracking-v2)
- [x] Wire completion at 10 uses, rotation, and all-learned state (R8, R9, R11). (usage-tracking-v2)
- [x] Author the larger curated pool beyond the initial ~10, in author-fixed order (R9). (usage-tracking-v2)

## Later / not yet sequenced

- (none — `PRODUCT.md`'s open product decisions were resolved during `usage-tracking-v2`; only
  pool-content curation remains open, tracked there directly)
