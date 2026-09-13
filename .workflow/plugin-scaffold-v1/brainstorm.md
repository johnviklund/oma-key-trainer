Command: workflow brainstorm plugin-scaffold-v1
Created: 2026-09-13
Base: 94d4abe2e2c74ea2d1761ded064c42f4a6bdc8a5
Inputs: none
Status: done

## Roadmap status

Belongs to a committed roadmap item: `ROADMAP.md` Phase 1 — "Plugin scaffold + v1 static list".
Its scope is the boundary for this run (all three Phase 1 checklist items). Not related to
either `TODO.md` open question (both are v2 counter-display questions; v1 has no counters).

## Problem statement and scope

Take the plugin from nonexistent to a working, view-only v1: a plugin folder that
`omarchy plugin enable` loads, a menu entry that opens a box, and that box rendering the curated
~10 keybindings per `DESIGN.md`. All of Phase 1 in one run (confirmed over scaffold-only).

## Grounded facts (read from the local Omarchy install, not assumed)

- Real plugin shape confirmed against `~/.config/omarchy/plugins/akshar.radio-atlas` (installed,
  third-party) and `/usr/share/omarchy/shell/plugins/emojis` (first-party, `kind: overlay`).
- `kind: "overlay"` is the right kind: `entryPoints.overlay` → one QML file with `open()`/`close()`,
  toggled via `omarchy-shell shell toggle <plugin-id>`. Emojis is the closest analog (menu-summoned
  box, `qs.Commons`/`qs.Ui` theming) and is the pattern to build from, structurally.
- Menu extension is a real, already-populated file: `~/.config/omarchy/extensions/omarchy-menu.jsonc`
  (JSONC, dotted-id hierarchy, `action` runs a shell command). No wrapper bin script is needed —
  the action can inline `omarchy-shell shell toggle <plugin-id>` directly, same as `trigger.emoji`
  does via its wrapper (a wrapper is convention, not required).
- A first-party entry **already exists**: `learn.keybindings` → `omarchy-menu-keybindings`, a live
  fzf-style search over every current Hyprland binding via `hyprctl binds`. Distinct feature (live,
  exhaustive, no tracking) from this plugin (curated, small, trained) — the new entry must read as
  a sibling, not a duplicate.

## Chosen approach

- New menu id as a sibling of `learn.keybindings` (e.g. `learn.keybindings-trainer`) in
  `omarchy-menu.jsonc`, action toggles this plugin's overlay.
- Plugin folder: `manifest.json` (`kind: overlay`, one `entryPoints.overlay` QML file), built on
  `qs.Ui`/`qs.Commons` per `DESIGN.md` (Panel/PanelHero/PanelSectionHeader + row-list convention).
- Curated ~10 authored as static content shipped with the plugin (format — JSON data file vs. QML
  ListModel — is a Planning-phase call, not decided here).
- Dev/QA loop: symlink this repo folder into `~/.config/omarchy/plugins/<id>/`, then
  `omarchy plugin enable <id>` + `omarchy-shell shell rescanPlugins`, per `AGENTS.md`.

## Explicit non-goals (this run)

- No usage tracking, counters, persistence, or rotation — that's Phase 2/v2, untouched here.
- No change to the existing `learn.keybindings` entry or `omarchy-menu-keybindings` script.
- No resolution of the two v2 counter-display open questions in `TODO.md` — out of scope for a
  view-only v1.

## Open questions (deferred to Planning, per `PRODUCT.md`)

- Plugin id / distribution name (`PRODUCT.md`'s own open decision).
- Exact menu id/label wording for the new sibling entry (structure — sibling under Learn — is
  decided; exact string isn't).
- Curated pool data format (JSON file vs. inline QML model).
- Exact content of the initial curated ~10 (content curation, authored during implementation).

Next: plan
