Command: workflow review usage-tracking-v2
Created: 2026-09-13
Base: e36b0e484201162e549e3f05ab842a3f9ed3b4ec
Inputs: .workflow/usage-tracking-v2/plan.md @ 3afd4a490a34c8971ae46da1c23e0ca9f871a303
Status: drafting

Reviewed diff: `fda38938..e36b0e48` (the whole run — Steps 1–7 were committed before the re-plan
at `3afd4a4`; the plan's own Base only covers Step 8). Code files: `hook.lua`, `keybindings.json`,
`UsageModel.js`, `UsageService.qml`, `BarWidget.qml`, `KeyTrainer.qml`, `manifest.json`; receipt:
`README.md`.

## Coverage
- [ ] brainstorm.md scope: pick/validate the background event source → Steps 1–2
- [ ] brainstorm.md scope: persist per-binding counts + rotation position across reboots → Steps 1, 4, 5
- [ ] brainstorm.md scope: completion at 10, rotation, all-learned (R8, R9, R11) → Steps 4, 5, 7, 8
- [ ] brainstorm.md scope: larger curated pool in author-fixed order (R9) → Step 3
- [ ] brainstorm.md non-goal: settle the two UI questions during brainstorm → resolved in planning (2a, 3a) as the brainstorm allowed
- [ ] brainstorm.md non-goal: split pool authoring into a separate run
- [ ] brainstorm.md non-goal: rewrite/inject the user's Hyprland keybinds (Option B) — verify the hook wraps registration without redefining bind semantics
- [ ] brainstorm.md non-goal: poll `hyprctl` on a timer (Option C)
- [ ] plan.md steps 1–10 checks + Deviations
- [ ] `.workflow/` dependency grep (code outside `.workflow/` must not reference it)
- [ ] hook.lua (event source, persistence writer, reload safety, bind-semantics preservation)
- [ ] keybindings.json (pool content, action ↔ live bind descriptions)
- [ ] UsageModel.js (parseCounts, visibleEntries window rule F12, allLearned)
- [ ] UsageService.qml (FileViews, dir watch, model rebuild, IpcHandler)
- [ ] BarWidget.qml (serviceFor injection, refresh on open)
- [ ] KeyTrainer.qml (render counts, Complete marker, all-learned, missing-service warning)
- [ ] manifest.json (service entry point, keepLoaded, version)
- [ ] README.md opt-in instructions (correct require line + placement)
- [ ] Regression: `omarchy plugin validate .`, node model checks, live `omarchy-shell oma-key-trainer status`, shell log
Independence: cross-vendor — writer OpenAI · GPT-5 (plan `## Execution state`, every step `Writer:` line); reviewer Anthropic · Opus 5

## Cycle 1 findings

## Pre-existing / environmental
