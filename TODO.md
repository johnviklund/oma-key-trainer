# TODO

Intake scratchpad for ideas between workflow runs. Don't implement just because it's listed here
— an idea graduates to work only via `workflow brainstorm`.

## Open questions

(none — both resolved 2026-09-13 during `usage-tracking-v2`; see `PRODUCT.md`)

## Ideas

(none yet)

## Deferred from runs

- **Re-base the trainer card on the kit's `PopupCard`/`Panel`** — deferred from `plugin-scaffold-v1`
  review (C1-1 P2). Today `KeyTrainer.qml` hand-rolls a full-screen `PanelWindow` anchored
  top-right, so a bottom/left/right bar or a second monitor puts the card away from its icon;
  `dismiss()` also still calls `shell.hide()` from the old overlay contract. `DESIGN.md`'s "no
  independent layout system" non-goal is the target. Small cleanup to take along: drop the unused
  `omarchyPath` property (C1-4). (The parse-failure warning this item originally listed, C1-2, was
  done in `usage-tracking-v2` — see `UsageService.qml:29`.)
- **A real automated test for `hook.lua`** — `usage-tracking-v2`'s review built a standalone
  harness (stub `o`/`hl`, redirect `HOME`, `dofile` the hook) kept as
  `.workflow/usage-tracking-v2/scratch/hook_test.lua.txt` (a receipt, not code). Promoting it to a
  real test file needs its own run.
- **Dispatcher-shape drift in `hook.lua`'s `resolve_dispatcher`** (C1-4, deferred at
  `usage-tracking-v2` review, P3) — `run()` records counts before dispatching, inside Hyprland's
  100ms keybind watchdog; revisit only if a keypress is ever observed dropped.
