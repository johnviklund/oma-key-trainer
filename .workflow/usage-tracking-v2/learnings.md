Command: workflow review usage-tracking-v2 (opened at review; wrap routes the lines)
Created: 2026-09-13
Base: e36b0e484201162e549e3f05ab842a3f9ed3b4ec
Inputs: review.md @ e36b0e484201162e549e3f05ab842a3f9ed3b4ec
Status: done

## Phase 4 — Review (2026-09-13)
- [durable→memory] A `try/catch` around a config/data load that only resets state (`poolEntries = []`) leaves an empty card with no trace — second occurrence in this repo (plugin-scaffold-v1 review C1-2 → TODO; usage-tracking-v2 `UsageService.qml` `loadPool`, review C1-3). Rule: every swallowed load/parse error in this plugin logs one `console.warn("oma-key-trainer: …")`, and a plan promise like "the warning moves into Step N" must appear in that step's check or it silently drops. [routed → memory/swallowed-load-error-hides-empty-state.md 2026-09-14]
- [durable→memory] Wrapping every Omarchy bind in a Lua function is safe in Hyprland 0.56 because *every* Lua-config bind is already a `__lua` bind: flags travel in `opts`, `hl.dsp.*` objects run via `hl.dispatch`, and mouse drag works through `releasePending` on `m_currentKeybind` — but a hook that re-implements `command_from` must fall back to the original `o.bind` for any shape it doesn't recognise (review C1-2), because the failure surfaces at press time as a dead key. [routed → memory/bind-hook-must-fallback-unknown-dispatcher-shape.md 2026-09-14]
- [drop] Six `omarchy-shell` restarts in 20 minutes during Steps 9–10 were all "Exiting due to IPC request" — QA restarts, not a crash loop. [routed → dropped, no action 2026-09-14]

## Phase 4 — Review cycle 2 (2026-09-13)
- [durable→memory] `omarchy-shell` IPC fails inside the OpenAI executor CLI's sandbox — second occurrence (patch_plan Step 2 deviation: `omarchy-restart-shell`'s internal `shell ping` returned "did not become ready" in-sandbox, passed unsandboxed). Bump `memory/executor-sandbox-blocks-omarchy-shell-ipc.md` to Occurrences: 2; add `omarchy-restart-shell` to its "applies when" list. [routed → memory/executor-sandbox-blocks-omarchy-shell-ipc.md (occurrences 2) 2026-09-14]
- [durable→skill] A step check that expects *zero* matches must not be written as `grep -c … ` at the tail of an `&&` chain — `grep -c` exits 1 on zero matches, so the chain can never pass. The "presence over absence" check rule applies to the exit status as well as the count: assert `[ "$(grep -c … )" = 0 ]` or `! grep -q …`, or invert to a presence check. (Cycle 1 reviewer's own patch_plan Step 3 check; writer handled it correctly by running the equivalent conditional and logging a deviation.) [routed → already covered by workflow skill references/phase-2-plan.md ("grep -c" banned, use grep -o | wc -l); no skill edit needed 2026-09-14]
- [drop] `hook.lua` can be exercised outside Hyprland: stub `o`/`hl` (`io.stdout` stands in for an `HL.Dispatcher` userdata), redirect `HOME`, `dofile` the hook — kept as `scratch/hook_test.lua.txt` (receipt, not code). Promote to a real test only through a run (`workflow todo`). [routed → dropped, noted as workflow todo candidate in review.md cycle 2 verdict 2026-09-14]

