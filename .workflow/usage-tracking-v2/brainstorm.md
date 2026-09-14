Command: workflow brainstorm usage-tracking-v2
Created: 2026-09-13
Base: fda38938f1c4c656f458b12c010de195c396a483
Inputs: none
Status: done

## Problem statement

v1 (shipped) is a view-only curated list. v2 turns it into a background-tracked drill: real usage
of each Hyprland keybinding action counts up, hits completion at 10 uses, rotates to the bottom of
the visible list, and pulls in the next entry from a larger curated pool. Progress persists across
reboots. This is `ROADMAP.md` Phase 2 — a **committed roadmap item**, not new/contested scope.

## Scope (one run, all four `ROADMAP.md` Phase 2 sub-items)

- Pick/validate the background event source for action-level usage counting.
- Persist per-binding counts + rotation position across reboots.
- Wire completion at 10 uses, rotation, and the all-learned state (R8, R9, R11).
- Author the larger curated pool beyond the initial ~10, in author-fixed order (R9).

Bundled deliberately: persistence shape depends on what the event source can attribute, and
rotation logic depends on persistence — splitting them would just create integration risk between
runs. Pool-content authoring piggybacks once the mechanism exists.

## Chosen approach

- **Event source: Hyprland IPC event stream (socket2)**, inferring which curated action fired from
  resulting state-change events (workspace switch, window close, fullscreen toggle, etc.) — the
  `service`-kind pattern already used by `omarchy.idle`/`omarchy.battery`. Rejected: rewriting/
  injecting the user's Hyprland keybinds (too invasive, fights the user's own config on every
  Hyprland update); polling `hyprctl` on a timer (imprecise, wasteful).
  **Not yet validated:** whether every curated action produces a distinct, attributable IPC event.
  This is real risk — some curated bindings may turn out unobservable this way and need dropping
  or re-scoping. Sizing this is explicitly deferred to spec/plan, not decided here.
- **Persistence: follow whatever storage convention `omarchy.idle`/`omarchy.battery` already use**
  for persisted service state, rather than introducing a new pattern (format TBD by that audit).

## Non-goals

- Settling the two open UI/update-flow questions now (live-updating counter vs. snapshot-on-open;
  running count past 10 vs. fixed "Complete" badge) — left for Phase 2 planning per user request;
  still tracked in `TODO.md`/`PRODUCT.md`.
- Splitting pool-content authoring into a separate run — rejected in favor of one bundled run.
- Rewriting the user's Hyprland keybind config to intercept dispatch calls (Option B) — rejected
  for footprint/invasiveness.
- Polling `hyprctl` state on a timer (Option C) — rejected for imprecision/waste.

## Open questions (carried to Planning)

- Per-curated-action feasibility of the IPC event stream: does every current/planned curated
  binding have a distinct, attributable Hyprland IPC event? Any that don't may need to be dropped
  or re-scoped.
- Exact persistence format/location, once the `omarchy.idle`/`omarchy.battery` convention is
  confirmed.
- Live-updating vs. snapshot counter; running-count vs. "Complete" badge past 10 (`TODO.md`).
- Exact content/order of the larger curated pool (content curation, can happen during
  implementation).

Next: spec — this is schema/contract-coupled (persistence format, event→action attribution
contract) and touches a subsystem (Hyprland's actual socket2 event coverage) the brainstorm could
not size.
