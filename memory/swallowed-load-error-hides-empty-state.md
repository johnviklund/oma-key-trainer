# A swallowed load/parse error that only resets state leaves an empty UI with no trace
Applies when: writing or reviewing a `try/catch` (or `pcall`) around a config/data load in this plugin (QML `FileView`/JSON parse, Lua `io.open`/JSON decode) whose catch body only resets a property (e.g. `poolEntries = []`) and returns.
Root cause: the reset makes the failure indistinguishable from "legitimately empty" — the user sees a blank card with nothing pointing at the real cause, and a plan's promise to add the warning later ("the warning moves into Step N") drops silently if no step's check actually asserts it.
Fix: every swallowed load/parse error in this plugin logs one `console.warn("oma-key-trainer: …")` (or the Lua equivalent) alongside the reset; if a plan defers the warning to a later step, that step's `Check:` must assert the warning exists, not just the feature it rides along with.
Evidence: plugin-scaffold-v1, usage-tracking-v2
Occurrences: 2 · Last confirmed: 2026-09-14 · Status: active
