# Roadmap

Sequencing only — see `PRODUCT.md` for what/why. Each item is sized to one future
`workflow brainstorm → wrap` run. Check items off here at wrap; don't grow prose here.

## Phase 1 — Plugin scaffold + v1 static list

- [ ] Scaffold the plugin folder (`manifest.json`, menu entry, overlay QML) and get it loading
  via `omarchy plugin enable`.
- [ ] Author the initial curated ~10 (key combo, description) as static content.
- [ ] Render the box using `qs.Ui`/`qs.Commons` per `DESIGN.md`; wire the menu entry (R1–R3).

## Phase 2 — v2 usage tracking

- [ ] Pick and validate a background event source for Hyprland action-level usage (matches R7:
  action, not literal key).
- [ ] Persist per-binding counts and rotation position across reboots (R12).
- [ ] Wire completion at 10 uses, rotation, and all-learned state (R8, R9, R11).
- [ ] Author the larger curated pool beyond the initial ~10, in author-fixed order (R9).

## Later / not yet sequenced

- `PRODUCT.md`'s open product decisions get resolved during whichever phase-2 planning run first
  needs them, not before.
