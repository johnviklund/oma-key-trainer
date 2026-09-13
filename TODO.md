# TODO

Intake scratchpad for ideas between workflow runs. Don't implement just because it's listed here
— an idea graduates to work only via `workflow brainstorm`.

## Open questions (from the PRD, deferred to Planning)

- Does a row's counter update live while the box is open, or only reflect the count as of when
  the box was last opened?
- Once a binding is complete, does its counter keep showing the running total past 10, or switch
  to a fixed "Complete" indicator?

## Ideas

(none yet)

## Deferred from runs

- **Re-base the trainer card on the kit's `PopupCard`/`Panel`** — deferred from `plugin-scaffold-v1`
  review (C1-1 P2, with C1-3 folded in). Today `KeyTrainer.qml` hand-rolls a full-screen
  `PanelWindow` anchored top-right, so a bottom/left/right bar or a second monitor puts the card
  away from its icon; `dismiss()` also still calls `shell.hide()` from the old overlay contract.
  `DESIGN.md`'s "no independent layout system" non-goal is the target. Small cleanups to take along:
  warn on `keybindings.json` load/parse failure instead of an empty card (C1-2); drop the unused
  `omarchyPath` property (C1-4).
