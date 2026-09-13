Command: workflow review usage-tracking-v2 (patch plan, cycle 1 — lighter P2/P3 plan)
Created: 2026-09-13
Base: e36b0e484201162e549e3f05ab842a3f9ed3b4ec
Inputs: .workflow/usage-tracking-v2/review.md @ e36b0e484201162e549e3f05ab842a3f9ed3b4ec
Status: complete

Scope: fix C1-2, C1-3, C1-1 (recommended dispositions, confirmed by the human before execution —
see review.md "Cycle 1 verdict"). C1-4 deferred, C1-5 wontfix — no steps. Nothing else is
re-implemented. Every step: edit, run its check, commit, then the next. `omarchy-shell` /
`omarchy-restart-shell` need an unsandboxed session (`memory/executor-sandbox-blocks-omarchy-shell-ipc.md`);
a kept-loaded service only picks up QML edits after `omarchy-restart-shell` (review.md, pre-existing).

## Execution state

- Current: Step 1 done; Step 2 paused — prescribed shell-restart check exited 1 before status
- Writer: OpenAI · GPT-5 (self-declared)
- Baseline: `omarchy plugin validate .` exit 0; Step 1 count `"Toggle window split":3` → `4` after one physical press
- Step commits: Step 1 @ 149f08c
- In flight: `loadPool` now warns before clearing an invalid pool
- Uncommitted: `UsageService.qml`, `.workflow/usage-tracking-v2/patch_plan.md`
- Pending: rerun or revise Step 2 check after `omarchy-restart-shell` readiness failure; follow-up IPC status is healthy (`pool:32`)

## Checklist

- [x] Step 1 — C1-2 · `hook.lua`: in `tracked_bind`, right after `local resolved_dispatcher = resolve_dispatcher(dispatcher, description)`, add an untracked fallback for shapes the hook cannot run itself:
  ```lua
  if type(resolved_dispatcher) ~= "function" and type(resolved_dispatcher) ~= "userdata" then
    original_bind(keys, description, dispatcher, options)
    return
  end
  ```
  Nothing else in the file changes. Then the human runs `hyprctl reload && hyprctl configerrors` (empty output) and presses SUPER+J once.
  - Check: `luac -p hook.lua && grep -o 'original_bind(keys, description, dispatcher, options)' hook.lua | wc -l` — expect `1` (pre: `0`); then, after the reload + one SUPER+J press, `grep -o '"Toggle window split":[0-9]*' ~/.local/state/omarchy/oma-key-trainer/counts.json` — expect the number to be exactly one higher than before the press (the hook still counts through the unchanged happy path)
  - Skills: none
  - Writer: OpenAI · GPT-5
- [ ] Step 2 — C1-3 · `UsageService.qml`: in `loadPool`'s `catch (error)` branch, add `console.warn("oma-key-trainer: keybindings.json parse failed: " + error)` before `root.poolEntries = []`. Nothing else changes.
  - Check: `grep -o 'console.warn' UsageService.qml | wc -l && omarchy plugin validate . && omarchy-restart-shell && sleep 3 && omarchy-shell oma-key-trainer status` — expect `1` (pre: `0`), validate exit 0, then a JSON line containing `"pool":32` (the service still loads)
  - Skills: none
  - Writer: —
- [ ] Step 3 — C1-1 · `UsageService.qml`: `refresh()` gains `stateDirWatcher.reload()` as its last statement (after `countsFile.reload()`), so every card open recreates the directory watch (same pattern as `/usr/share/omarchy/shell/plugins/services/idle/Service.qml:308`). Nothing else changes.
  - Check: `grep -o 'stateDirWatcher.reload()' UsageService.qml | wc -l && omarchy plugin validate . && omarchy-restart-shell && sleep 3 && omarchy-shell oma-key-trainer status && grep -ic 'oma-key-trainer' /run/user/$(id -u)/quickshell/by-pid/$(pgrep -xo quickshell)/log.log` — expect `1` (pre: `0`), validate exit 0, a JSON line containing `"pool":32`, then `0` (no plugin warning from the reload of a directory path — `printErrors: false` is already set)
  - Skills: none
  - Writer: —

## Deferred / wontfix (no steps — confirm the reasoning still holds, do not implement)

- C1-4 (P3, defer): record-before-dispatch under the 100 ms keybind watchdog — speculative on this hardware; revisit only if a keypress ever drops.
- C1-5 (P3, wontfix): `drag`-style binds count twice per use — not in the pool; pool-curation note recorded in review.md.

## Deviations

- Step 2: `console.warn` count was `1` and validation passed, but `omarchy-restart-shell` exited 1 with `Omarchy shell did not become ready after restart.` The immediate follow-up IPC status returned `{"pool":32,"visible":11,"complete":1,"allLearned":false}` and `hyprctl configerrors` was empty; stopped without committing `UsageService.qml` because the prescribed check itself failed.

## After the last step

`workflow review usage-tracking-v2` — re-review cycle 2: verify C1-1, C1-2, C1-3 at the new HEAD, stamp `Resolved: @ <sha> (cycle 2)`; nothing else is re-implemented.
