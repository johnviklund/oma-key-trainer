# Product

> Supersedes `PRD.md` as of 2026-09-13. The PRD is archived verbatim at
> `docs/archive/PRD-2026-09-13.md` — it holds the full Key Flows and Acceptance Examples this
> file only summarizes.

## What this is

**Omarchy Keybindings Trainer** — a plugin for the Omarchy Linux desktop (Hyprland-based) that
helps a user learn Omarchy's system-level keybindings by showing a curated list and, in its full
form, tracking real usage until each binding is second nature.

## Current state → desired end state

- **Current:** v1 built and published (plugin id `oma-key-trainer`, `main` on
  `https://github.com/johnviklund/oma-key-trainer`, run `plugin-scaffold-v1`): a bar icon at the
  top-right of the bar opens a card listing the curated 10. View-only; no tracking yet.
- **v1 (first milestone, shipped):** a static reference box, reachable from a dedicated top-right
  bar icon (and, optionally, a user-added row in Omarchy's Learn menu — see `README.md`), listing
  ~10 curated keybindings (key combo + description). View-only. Decision 2026-09-13: the bar icon
  replaced the PRD's menu-entry shape (R1) as the primary entry point; the menu row stays optional.
- **v2 (desired end state):** the same box tracks real usage per keybinding in the background
  (box open or closed), marks a binding complete at 10 uses, rotates it to the bottom of the
  visible list, and pulls the next binding from a larger curated pool to the top. Progress
  persists across reboots. An all-learned state appears once the whole pool is complete.

v1 and v2 are milestones of one product, not two products — every v1 decision must not foreclose
v2.

## Purpose

Omarchy/Hyprland keybindings aren't discoverable or reinforced by anything in the desktop today;
they're easy to forget after a first read. This plugin turns ordinary daily use into spaced
reinforcement, with no separate practice session required.

## Users

Single local user, single machine — the person using this Omarchy install. No accounts, sync, or
multi-user concept in v1 or v2.

## Platform facts (confirmed against the local Omarchy install; not stated in the PRD)

- Omarchy's UI is one long-running Quickshell (QML) process (`omarchy-shell`). Third-party
  additions are **shell plugins**: a folder with a `manifest.json` (schema checked by
  `omarchy plugin validate`) declaring one or more `kinds` (`menu`, `overlay`, `bar-widget`,
  `service`, `panel`, ...) and QML entry points.
- The "top-right menu" (R1) is the first-party `omarchy.menu` plugin, defined by
  `default/omarchy/omarchy-menu.jsonc` plus user extensions. Adding a menu entry whose action
  opens a box is the same pattern first-party overlays (Emojis, Clipboard — `kind: "overlay"`)
  already use.
- The visual/interaction match R1 requires is achievable by building on the shared `qs.Ui`
  component kit (`Panel`, `PanelHero`, `PanelSectionHeader`, `Button`, ...) and the `qs.Commons`
  theme singletons (`Color`, `Style`, `Border`) rather than inventing new styling — see
  `DESIGN.md`.
- Background usage counting that survives the box being closed (R5) implies a `service`-kind
  plugin, the pattern `omarchy.idle`, `omarchy.battery`, and `omarchy.nightlight` already use for
  always-on background state, rather than logic that only runs while the overlay is mounted. The
  event source is Omarchy's `o.bind` Lua registration hook (decided 2026-09-13, `usage-tracking-v2`):
  a `hook.lua` the user opts into with one line in `~/.config/hypr/hyprland.lua` (before
  `default.hypr.omarchy`) wraps every bind registration and counts on fire. This is a real install
  step for the core v2 feature, not just a nice-to-have.
- User-installed plugins live at `~/.config/omarchy/plugins/<plugin-id>/`. This repo is that
  plugin's source — installable via
  `omarchy plugin add https://github.com/johnviklund/oma-key-trainer.git --enable`, or via a
  symlink into that path during development (`AGENTS.md`).

## Core objects

- **Curated pool** — the full, author-ordered list of keybindings the plugin knows about, larger
  than the visible list. Fixed order; never randomized; never user-editable (deferred).
- **Visible list** — the 10-row window into the pool shown in the box: newly-pulled incomplete
  rows stack at the top (most-recently-pulled first), the initial rows keep pool order, and
  completed rows sit at the bottom in pool order.
- **Binding entry** — one pool item: default key combo (display only), description, the
  underlying Hyprland action it's matched against (the bind's Omarchy description string — the
  only stable per-bind identity Hyprland exposes), usage count, complete/not-complete state.
- **Usage count** — increments on every real trigger of a binding entry's *action* (not its
  literal key), regardless of the user's own rebinding, regardless of whether the box is open.
- **Completion** — automatic at 10 uses; never manual. Triggers rotation.
- **All-learned state** — shown once every pool entry is complete; no further rotation.

## Key workflows

F1 open/view, F2 background counting, F3 completion + rotation — full detail preserved verbatim
in `docs/archive/PRD-2026-09-13.md`.

## Principles

- Completion reflects only real recorded usage — never a manual override (R10).
- Tracking is scoped to Hyprland/Omarchy system-level bindings; app-specific shortcuts have no
  generically observable event source and are out of scope (R6).
- The box's look and feel conforms to Omarchy's existing menu/overlay conventions; this plugin
  does not introduce its own visual language.
- The curated pool is authored content shipped with the plugin, not derived from the user's live
  Hyprland config.

## Anti-goals (explicit non-goals)

- No leaderboard or cross-user comparison — would need opt-in telemetry and a backend, neither
  addressed here.
- No user customization of the curated pool's contents or order.
- No manual "mark as known" / skip control, ever.
- No tracking of application-specific (non-Hyprland) shortcuts.

## Vocabulary

Curated pool, visible list, binding entry, usage count, completion, rotation, all-learned state —
see Core objects above. "v1"/"v2" name milestones of one product, not separate products.

## Open product decisions

- Exact content of the curated pool beyond the shipped 32 (which bindings, descriptions, priority
  order) — content curation, authored during implementation.
- ~~Plugin id / distribution name~~ — decided 2026-09-13: `oma-key-trainer` (folder, manifest id,
  GitHub repo name all match).
- ~~Live-updating counter while the box is open, vs. a snapshot~~ — decided 2026-09-13
  (`usage-tracking-v2`): live — `refresh()` re-reads on open and a state-dir watch updates while
  open.
- ~~Whether a completed row keeps showing its running total past 10, or switches to a fixed
  indicator~~ — decided 2026-09-13 (`usage-tracking-v2`): a fixed "Complete" marker.
- ~~Exact background event source~~ — decided 2026-09-13 (`usage-tracking-v2`): see Platform facts.
