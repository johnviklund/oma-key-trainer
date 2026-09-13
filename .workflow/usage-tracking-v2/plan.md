Command: workflow plan usage-tracking-v2
Created: 2026-09-13
Base: 34a407d331be44c03ce90cb9397601ed2e2880d9
Inputs: .workflow/usage-tracking-v2/brainstorm.md @ fda38938f1c4c656f458b12c010de195c396a483, .workflow/usage-tracking-v2/spec.md @ fda38938f1c4c656f458b12c010de195c396a483
Status: complete

## Execution state

- Current: Step 3 — curate and validate the expanded binding pool
- Next: edit `keybindings.json`, validate every action against live Hyprland binds
- Writer: OpenAI · GPT-5 (self-declared)
- Baseline: `omarchy plugin validate .` exit 0; shell IPC exit 0; plugin present/enabled
- In flight: counts contract v1 at `~/.local/state/omarchy/oma-key-trainer/counts.json`; `o.bind(keys, description, dispatcher, options)` wrapped
- Step commits: Step 1 @ 2ee15bb; Step 2 @ 88d56fc
- Uncommitted: this execution-state receipt
- Pending decision: none

## Findings

| # | What is true | What it changes |
|---|---|---|
| F1 | Hyprland 0.56.2's event bus (`/usr/include/hyprland/src/event/EventBus.hpp`) and socket2 have no "bind fired" event; every one of the 10 pool actions also fires from mouse/app paths | `Hyprland.rawEvent` (spec) is dropped as the event source entirely |
| F2 | Omarchy registers every default and user keybind through the Lua global `o.bind(keys, description, dispatcher, opts)` (`$OMARCHY_PATH/default/hypr/helpers.lua`); user `~/.config/hypr/hyprland.lua` loads `default.hypr.omarchy` after `bootstrap.lua`; `bootstrap.lua` clears `package.loaded` for `default.hypr.*`/`hypr.*` only | Event source = wrap `o.bind` from a hook the user requires before `default.hypr.omarchy` (decision 1a); the hook must clear its own `package.loaded` entry so it re-runs on every reload |
| F3 | Probed live: `o.bind` is wrappable, `hl.dsp.*` results are userdata run via `hl.dispatch(d)`, `hl.bind(keys, fn, {description})` registers a `__lua` bind, `io.open` works in the config Lua state; a wrapped bind firing on a real keypress was not observed (key simulation blocked) | Step 1's QA presses a real chord; a Lua error inside a bind callback would break that bind, so the record step is `pcall`ed and dispatch always runs |
| F4 | The Omarchy description string is the only stable per-bind identity (`hyprctl binds -j` `description`; dispatchers are opaque closures) | `keybindings.json` `action` = that description; counts key on it (R7: action, not key) |
| F5 | First-party persistence: `~/.local/state/omarchy/<name>.json`, `{ "version": N, ... }`, FileView `atomicWrites`; dir watches can go quiet (Bar.qml) | Lua is the single writer of `~/.local/state/omarchy/oma-key-trainer/counts.json` (`{"version":1,"counts":{"<description>":n}}`, tmp+rename); QML only reads, watching the file plus `reload()` on card open (decision 3a) |
| F6 | Third-party bar widgets under the built-in bar get `bar.shell = createScopedPluginShell(..., allowOwnService=true)`; `shell.serviceFor("oma-key-trainer")` returns this plugin's service; `service`+`bar-widget`+`keepLoaded` is the `omarchy.media` shape; `omarchy-shell <target> <method>` reaches any `IpcHandler` | Spec interfaces for manifest/BarWidget hold; a `status()` IpcHandler makes the service checkable from the CLI (run it unsandboxed — `memory/executor-sandbox-blocks-omarchy-shell-ipc.md`) |
| F7 | Rotation order is fully derivable from counts (incomplete in authored order, then complete in authored order) | No rotation position is persisted; "persist rotation position" (brainstorm) is satisfied by the counts file |
| F8 | Decisions 2026-09-13: completed rows show a fixed "Complete" marker (2a); counter is live (3a); hook counts every described bind, not just the pool | Pool growth never touches the hook; the UI never shows a number past 10 |

## Checklist

- [x] Step 1 — `hook.lua`: wrap `o.bind` (require `default.hypr.helpers` first); on fire, `pcall` an increment of `counts[description]` and atomic write of counts.json, then dispatch the original (`hl.dispatch` for userdata, call for functions); load existing counts at start via `gmatch` over the flat JSON; `mkdir -p` the state dir; clear `package.loaded[...]` at the end (F2, F3, F5)
  - Check: `luac -p hook.lua && grep -o 'o.bind' hook.lua | wc -l` (pre: `cannot open hook.lua`, exit 1)
  - Skills: none
  - Writer: OpenAI · GPT-5
- [x] Step 2 — Install + prove the hook live: `README.md` documents the one-line opt-in `require("default.hypr.require_optional").module("omarchy.plugins.oma-key-trainer.hook")` placed before `require("default.hypr.omarchy")` in `~/.config/hypr/hyprland.lua`; the human adds it, runs `hyprctl reload && hyprctl configerrors` (empty), presses SUPER+W once (F3)
  - Check: `test -s ~/.local/state/omarchy/oma-key-trainer/counts.json && grep -o '"Close window"' ~/.local/state/omarchy/oma-key-trainer/counts.json | wc -l` (pre: exit 1)
  - Skills: none
  - Writer: OpenAI · GPT-5
- [ ] Step 3 — `keybindings.json`: add `"action"` (Omarchy description) to the 10 rows; extend the pool to ~30 entries in authored order from `$OMARCHY_PATH/default/hypr/bindings/*.lua` (tiling first, then utilities/media/clipboard); every action must be a live bind description (F4)
  - Check: `python3 -c "import json,subprocess; pool=json.load(open('keybindings.json')); descs={b.get('description','') for b in json.loads(subprocess.check_output(['hyprctl','binds','-j']))}-{''}; missing=[e['id'] for e in pool if e.get('action','') not in descs]; print(len(pool), 'entries;', len(missing), 'unmatched:', missing)"` — expect ≥ 30 entries, 0 unmatched (pre: `10 entries; 10 unmatched`)
  - Skills: none
- [ ] Step 4 — `UsageModel.js`: pure helpers — `parseCounts(raw)` (tolerates empty/torn JSON → `{}`), `visibleEntries(pool, counts, threshold)` → rows `{id, keys, description, action, count, complete}` ordered incomplete-then-complete in authored order, `allLearned(rows)`; threshold 10 (F7)
  - Check: `node -e "eval(require('fs').readFileSync('UsageModel.js','utf8')); var r=visibleEntries([{id:'a',action:'A'},{id:'b',action:'B'}],{A:10,B:3},10); console.log(r.map(function(x){return x.id+':'+x.count+':'+x.complete}).join(' '), allLearned(r))"` — expect `b:3:false a:10:true false` (pre: ENOENT, exit 1)
  - Skills: none
- [ ] Step 5 — `manifest.json`: `kinds` += `"service"`, `"keepLoaded": true`, `entryPoints.service = "UsageService.qml"`; bump version to 0.2.0 (F6)
  - Check: `grep -o '"service"' manifest.json | wc -l && omarchy plugin validate .` (pre: `0`, validate exit 0)
  - Skills: none
- [ ] Step 6 — `UsageService.qml`: kept-loaded service owning the pool (`FileView` on `keybindings.json`, moved out of `KeyTrainer.qml`), a `FileView { watchChanges: true }` on counts.json, `visibleEntries` ListModel + `allLearned` rebuilt via `UsageModel.js`, `refresh()` (`reload()` both files), and `IpcHandler { target: "oma-key-trainer" }` with `status(): string` returning `{pool, complete, allLearned}` JSON (F5, F6)
  - Check: `grep -o 'IpcHandler' UsageService.qml | wc -l && omarchy-shell shell rescanPlugins && omarchy-shell oma-key-trainer status` (pre: `0`; `Target not found.` exit 1)
  - Skills: none
- [ ] Step 7 — `BarWidget.qml`: `readonly property var usageService: bar?.shell?.serviceFor("oma-key-trainer") ?? null`, injected into the loaded `KeyTrainer` alongside `shell`; `open()` calls `usageService.refresh()` first (F6, decision 3a)
  - Check: `grep -o 'serviceFor' BarWidget.qml | wc -l` (pre: `0`)
  - Skills: none
- [ ] Step 8 — `KeyTrainer.qml`: render `usageService.visibleEntries` — count column (`n/10`), fixed "Complete" marker + dimmed row for complete entries, all-learned message in place of the list; drop the local `FileView`/`keybindingsModel`; warn on missing service instead of an empty card (F8; TODO C1-2 tag-along)
  - Check: `grep -o 'usageService' KeyTrainer.qml | wc -l; grep -o 'FileView' KeyTrainer.qml | wc -l` — expect ≥ 3 and 0 (pre: `0`, `1`)
  - Skills: none
- [ ] Step 9 — Manual QA per `AGENTS.md`: rescan, open the card, press a pool chord with the card open (row count moves live), close/reopen, restart the shell (counts survive), walk AE1–AE4 in `docs/archive/PRD-2026-09-13.md`; shell log clean
  - Check: `omarchy-shell shell listPlugins | grep -o 'oma-key-trainer' | wc -l; grep -ic 'oma-key-trainer' /run/user/$(id -u)/quickshell/by-id/*/log.log` — expect `1` and `0` (pre: `1`, `0`)
  - Skills: none

## Coverage

- Pick/validate the background event source → Steps 1, 2 (F1–F3: `o.bind` hook, not socket2)
- Persist per-binding counts + rotation position across reboots → Steps 1, 4, 6 (F5, F7)
- Completion at 10, rotation, all-learned state (R8, R9, R11) → Steps 4, 6, 8
- Author the larger curated pool in author-fixed order (R9) → Step 3
- Non-goal: settle the two UI questions now → resolved 2026-09-13 by decision (2a, 3a) — recorded in F8, applied in Steps 7–8
- Non-goal: split pool authoring into its own run → untouched
- Non-goal: rewrite/inject the user's Hyprland keybinds (Option B) → untouched (the hook wraps registration; no bind is redefined)
- Non-goal: poll `hyprctl` on a timer (Option C) → untouched

## Risks

- Step 1 is the riskiest: it runs inside the compositor's Lua state on every keypress that hits a bind — an unhandled error there breaks the bind; the wrapped-bind-fires path is confirmed only at Step 2.
- Outside its files: the user's `~/.config/hypr/hyprland.lua` gains a `require` (opt-in, `require_optional` so a removed plugin is harmless); an Omarchy update renaming a description silently stops counting that action.
- Not taken: self-installing the hook from `~/.local/state/omarchy/toggles/hypr/` (needs a metatable proxy on `o`, a double reload, and leaves live code behind after uninstall).

## TODO impacts

- Open question "counter live vs snapshot" → resolved (3a: live), remove
- Open question "running total vs Complete indicator" → resolved (2a: fixed marker), remove
- Deferred C1-2 "warn on keybindings.json load/parse failure" → partially completed by Step 8 (warn on missing service); the parse warning itself moves with the FileView into Step 6 — mark done at wrap if both land
- Deferred C1-1 PopupCard re-base, C1-4 `omarchyPath` → untouched

## Product doc impacts

- `PRODUCT.md` — Platform facts: "exact event source … is a Planning-phase decision" → decided: Omarchy's `o.bind` Lua registration hook, opted in by one line in `~/.config/hypr/hyprland.lua`; Core objects "Binding entry … underlying Hyprland action" → the Omarchy bind description; Open product decisions: both UI questions → decided 2026-09-13 (fixed "Complete" marker; live counter). Note: v2 background counting requires the opt-in line — a real install step for the core feature (accepted with decision 1a, not an ESCALATE).
- `DESIGN.md` — Box layout v2: "open product decision" → completed rows show a fixed "Complete" marker and a dimmed row; the counter reads `n/10` live.
- `ROADMAP.md` — Phase 2's four items checked off at wrap; "Later" note about open decisions → resolved.
