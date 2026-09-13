Command: workflow review usage-tracking-v2 (opened at review; wrap routes the lines)
Created: 2026-09-13
Base: e36b0e484201162e549e3f05ab842a3f9ed3b4ec
Inputs: review.md @ e36b0e484201162e549e3f05ab842a3f9ed3b4ec
Status: drafting

## Phase 4 — Review (2026-09-13)
- [durable→memory] A `try/catch` around a config/data load that only resets state (`poolEntries = []`) leaves an empty card with no trace — second occurrence in this repo (plugin-scaffold-v1 review C1-2 → TODO; usage-tracking-v2 `UsageService.qml` `loadPool`, review C1-3). Rule: every swallowed load/parse error in this plugin logs one `console.warn("oma-key-trainer: …")`, and a plan promise like "the warning moves into Step N" must appear in that step's check or it silently drops.
- [durable→memory] Wrapping every Omarchy bind in a Lua function is safe in Hyprland 0.56 because *every* Lua-config bind is already a `__lua` bind: flags travel in `opts`, `hl.dsp.*` objects run via `hl.dispatch`, and mouse drag works through `releasePending` on `m_currentKeybind` — but a hook that re-implements `command_from` must fall back to the original `o.bind` for any shape it doesn't recognise (review C1-2), because the failure surfaces at press time as a dead key.
- [drop] Six `omarchy-shell` restarts in 20 minutes during Steps 9–10 were all "Exiting due to IPC request" — QA restarts, not a crash loop.
