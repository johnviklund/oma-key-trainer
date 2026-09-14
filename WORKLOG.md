# Worklog

Bounded, rolling index (~15 most recent entries) of what shipped, pointing into git history —
not a source of truth. See the workflow skill's `references/learning-worklog.md` for entry shape.

## 2026-09-14 · usage-tracking-v2 · v2 usage tracking: background counting, completion, rotation, all-learned · OpenAI · GPT-5
- Shipped `hook.lua` (wraps `o.bind`, counts on fire, atomic `counts.json` write); extended
  `keybindings.json` to 32 curated entries with `action` identity; `UsageModel.js`
  (`parseCounts`/`visibleEntries`/`allLearned`, 10-row pull-to-top window); `UsageService.qml`
  (service kind, IPC `status()`, dir-watch + FileView reload); `BarWidget.qml`/`KeyTrainer.qml`
  wired to the service; README opt-in install line
- Re-planned mid-run to add the 10-row visible window (F12) and an active-log QA check (F13);
  patch cycle fixed C1-1 (watcher re-arm), C1-2 (unknown dispatcher-shape fallback), C1-3
  (parse-failure warning)
- Product docs updated to shipped truth (event source, live counter, fixed Complete marker,
  window ordering); ROADMAP Phase 2 checked off; 2 new memory pages + 1 bumped
- Commits: 2ee15bb..2aa4e1d (Steps 1–10), 8e64d7b (re-plan + window), 81e2b40 (review cycle 1),
  149f08c f811b34 003a734 (patch fixes), 8828d96 (review cycle 2)
- Review: ship as-is (0 P0 · 0 P1 · 0 P2 · 0 P3 open; C1-4 deferred, C1-5 wontfix) @ aa3eed5
- Run: 10 steps (+1 re-plan) · 2 review cycles · 6 deviations · 0 findings overturned
- Seats: 3 OpenAI·GPT-5 · 4 Anthropic·Opus 5 · wrap Anthropic·Sonnet 5
- Skills: workflow (version unrecorded)
- Why: ROADMAP Phase 2 — turn the v1 static list into the spaced-reinforcement drill the product
  was always meant to be

## 2026-09-13 · plugin-scaffold-v1 · v1 plugin: bar icon + curated-10 card, published · OpenAI · GPT-5
- Shipped `manifest.json` (`bar-widget`, id `oma-key-trainer`), `BarWidget.qml`, `KeyTrainer.qml`,
  `keybindings.json` (10 rows, verified against Omarchy defaults), README install + optional menu row
- Re-planned mid-run from menu-summoned overlay to top-right bar widget (decision 1a); published `main`
  to github.com/johnviklund/oma-key-trainer; local folder renamed `~/Work/oma-key-trainer`
- Product docs updated to shipped truth; PopupCard re-base deferred to TODO.md (review C1-1)
- Commits: efeccd7 345039d e62ef06 83164b9 9ccf23d 09a8f29 800ddb2 30b0acb 6b6d3ee 87ecfd6 200be27
- Review: ship as-is (0 P0 · 0 P1 · 1 P2 · 3 P3, all deferred) @ 0ae0722
- Run: 4 steps (re-plan; 5 of the superseded 6-step plan shipped) · 1 review cycle · 2 deviations · 0 findings overturned
- Seats: 0 Anthropic·Sonnet 5 · 2 Anthropic·Opus 5 · 3 OpenAI·GPT-5 · 4 Anthropic·Opus 5 · wrap Anthropic·Opus 5 (not Sonnet 5 per ROUTING)
- Skills: workflow@cca3536
- Why: ROADMAP Phase 1 — get a loadable, view-only v1 in front of the user before any tracking work

## 2026-09-13 · bootstrap · doc set + repo scaffold from PRD.md
- Generated PRODUCT.md, DESIGN.md, AGENTS.md, ROADMAP.md, MEMORY.md/memory/, TODO.md, README.md
- Confirmed the Omarchy shell plugin architecture (Quickshell/QML, `manifest.json`,
  `qs.Ui`/`qs.Commons`) against the local install — not stated in the PRD
- Archived PRD.md to docs/archive/PRD-2026-09-13.md
- Commits: (initial commit — `git log --oneline -1`; a literal sha can't self-reference)
- Why: turn a finished PRD into a workflow-ready repo
