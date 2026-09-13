Command: workflow plan usage-tracking-v2 (re-audit of Step 8: stale-log check + missing visible window found by AE1; supersedes the plan @ 6ddbfe7)
Created: 2026-09-13
Base: 3afd4a490a34c8971ae46da1c23e0ca9f871a303
Inputs: .workflow/usage-tracking-v2/brainstorm.md @ fda38938f1c4c656f458b12c010de195c396a483, .workflow/usage-tracking-v2/spec.md @ fda38938f1c4c656f458b12c010de195c396a483
Status: complete

## Execution state

- Current: Steps 1–10 done; ready for Phase 4 review
- Writer: OpenAI · GPT-5 (self-declared, Steps 1–10)
- Baseline: validate exit 0; Step 8 model check `l a b d e f g h i j c k 12`; Step 9 real-key check `{"pool":32,"visible":11,"complete":1,"allLearned":false}`, count ≥11, live-log matches 0; Step 10 all-learned check `1`
- In flight: `parseCounts(raw)`, `visibleEntries(pool, counts, threshold, windowSize)`, `allLearned(rows)`; counts contract v1; threshold 10; window 10
- Step commits: Step 1 @ 2ee15bb; Step 2 @ 88d56fc; Step 3 @ 20a2fea; Step 4 @ e73efa8; Step 5 @ a9eff63; Step 6 @ 796a546; Step 7 @ a7f8a32; Step 8 @ 985f702; Step 9 @ 9c69ee7; Step 10 @ 2aa4e1d
- Pending decision: none; original counts restored from `/tmp/oma-key-trainer-counts-step9-backup.json` (decision 4a: 10-row window, pulled entries inserted at the top)

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
| F9 | `omarchy-plugin-validate` line 86 (mirroring `PluginRegistry.qml`) fails on a declared entry point whose file is missing, and the repo is symlinked into `~/.config/omarchy/plugins/`, so a manifest naming an absent `UsageService.qml` breaks validation and would drop the plugin on the next rescan | Old Steps 5 and 6 are one verifiable unit → merged Step 5; the already-applied `manifest.json` edit stays uncommitted until that step's commit |
| F10 | On rescan `shell.qml` `onScanFinished` runs `_syncServices()` (synchronous `ensureService`, `Component.PreferSynchronous`) before `syncPluginWidgets()`; `_services` is a `property var` reassigned wholesale | The bar widget's `bar?.shell?.serviceFor(...)` binding resolves at widget creation and re-evaluates on service replacement; no lazy retry needed |
| F11 | Third-party services are created with `createObject(null)` and get `shell`/`manifest` injected only if declared; `omarchy.idle`/`omarchy.media` use an `Item` root with `IpcHandler { target }` and `status(): string`; `omarchy.idle` watches its state *directory* (`FileView { path: dir; watchChanges: true; onFileChanged }`) and re-reads, because a rename-replaced file leaves a file-path watch stale | `UsageService.qml` is an `Item` with `property var shell`, `property var manifest`; it watches the state dir and `reload()`s a second `FileView` on counts.json on `fileChanged` and in `refresh()` |
| F12 | `visibleEntries` returns every pool row (32 visible); `PRODUCT.md` "Visible list — the ~10-row window", R8/R9/AE1 require a window that pulls entries in; decision 4a: window of 10 incomplete, each pulled entry inserted at the top | Window = shortest pool prefix holding 10 incomplete rows (whole pool if fewer); rows = incomplete with index ≥ 10 in reverse pool order, then incomplete with index < 10 in pool order, then the window's complete rows in pool order — still derived from counts alone, F7's "no persisted position" stands |
| F13 | `by-id/*/log.log` keeps dead instances (`vrxzzalt`, `tv8179bblt`); `by-pid/<pid>` → the live one, `pgrep -xo quickshell` gives that pid; `omarchy-launch-shell` also pipes stderr to the journal (`journalctl --user -t omarchy-shell`) — `AGENTS.md`'s "no journald unit" is stale | Log check reads `by-pid/$(pgrep -xo quickshell)/log.log`; `omarchy-restart-shell` is the restart command (pid changes, selector follows) |

## Checklist

- [x] Step 1 — `hook.lua`: wrap `o.bind` (require `default.hypr.helpers` first); on fire, `pcall` an increment of `counts[description]` and atomic write of counts.json, then dispatch the original (`hl.dispatch` for userdata, call for functions); load existing counts at start via `gmatch` over the flat JSON; `mkdir -p` the state dir; clear `package.loaded[...]` at the end (F2, F3, F5)
  - Check: `luac -p hook.lua && grep -o 'o.bind' hook.lua | wc -l` (pre: `cannot open hook.lua`, exit 1)
  - Skills: none
  - Writer: OpenAI · GPT-5
- [x] Step 2 — Install + prove the hook live: `README.md` documents the one-line opt-in `require("default.hypr.require_optional").module("omarchy.plugins.oma-key-trainer.hook")` placed before `require("default.hypr.omarchy")` in `~/.config/hypr/hyprland.lua`; the human adds it, runs `hyprctl reload && hyprctl configerrors` (empty), presses SUPER+W once (F3)
  - Check: `test -s ~/.local/state/omarchy/oma-key-trainer/counts.json && grep -o '"Close window"' ~/.local/state/omarchy/oma-key-trainer/counts.json | wc -l` (pre: exit 1)
  - Skills: none
  - Writer: OpenAI · GPT-5
- [x] Step 3 — `keybindings.json`: add `"action"` (Omarchy description) to the 10 rows; extend the pool to ~30 entries in authored order from `$OMARCHY_PATH/default/hypr/bindings/*.lua` (tiling first, then utilities/media/clipboard); every action must be a live bind description (F4)
  - Check: `python3 -c "import json,subprocess; pool=json.load(open('keybindings.json')); descs={b.get('description','') for b in json.loads(subprocess.check_output(['hyprctl','binds','-j']))}-{''}; missing=[e['id'] for e in pool if e.get('action','') not in descs]; print(len(pool), 'entries;', len(missing), 'unmatched:', missing)"` — expect ≥ 30 entries, 0 unmatched (pre: `10 entries; 10 unmatched`)
  - Skills: none
  - Writer: OpenAI · GPT-5
- [x] Step 4 — `UsageModel.js`: pure helpers — `parseCounts(raw)` (tolerates empty/torn JSON → `{}`), `visibleEntries(pool, counts, threshold)` → rows `{id, keys, description, action, count, complete}` ordered incomplete-then-complete in authored order, `allLearned(rows)`; threshold 10 (F7)
  - Check: `node -e "eval(require('fs').readFileSync('UsageModel.js','utf8')); var r=visibleEntries([{id:'a',action:'A'},{id:'b',action:'B'}],{A:10,B:3},10); console.log(r.map(function(x){return x.id+':'+x.count+':'+x.complete}).join(' '), allLearned(r))"` — expect `b:3:false a:10:true false` (pre: ENOENT, exit 1)
  - Skills: none
  - Writer: OpenAI · GPT-5
- [x] Step 5 — `manifest.json` (already edited: `kinds` += `"service"`, `"keepLoaded": true`, `entryPoints.service = "UsageService.qml"`, version 0.2.0) + new `UsageService.qml`, committed together: `Item` root with `property var shell`, `property var manifest`; `FileView` on `keybindings.json` (pool, moved out of `KeyTrainer.qml`); `FileView` on counts.json plus a `FileView { path: <state dir>; watchChanges: true; onFileChanged: countsFile.reload() }`; `visibleEntries` ListModel + `allLearned` rebuilt via `UsageModel.js` whenever either file loads; `refresh()` (`reload()` both files); `IpcHandler { target: "oma-key-trainer" }` with `status(): string` returning `{pool, complete, allLearned}` JSON (F5, F6, F9, F10, F11)
  - Check: `omarchy plugin validate . && grep -o 'IpcHandler' UsageService.qml | wc -l && omarchy-shell shell rescanPlugins && sleep 2 && omarchy-shell oma-key-trainer status` — expect validate exit 0, `1`, then a JSON line with `"pool":32` (pre: `entry point file not found: 'UsageService.qml'`, exit 1; `omarchy-shell oma-key-trainer status` alone: `Target not found.`, exit 1)
  - Skills: none
  - Writer: OpenAI · GPT-5
- [x] Step 6 — `BarWidget.qml`: `readonly property var usageService: bar?.shell?.serviceFor("oma-key-trainer") ?? null`, injected into the loaded `KeyTrainer` alongside `shell`; `open()` calls `usageService.refresh()` first (F6, F10, decision 3a)
  - Check: `grep -o 'serviceFor' BarWidget.qml | wc -l` — expect `1` (pre: `0`)
  - Skills: none
  - Writer: OpenAI · GPT-5
- [x] Step 7 — `KeyTrainer.qml`: render `usageService.visibleEntries` — count column (`n/10`), fixed "Complete" marker + dimmed row for complete entries, all-learned message in place of the list; drop the local `FileView`/`keybindingsModel`; warn on missing service instead of an empty card (F8; TODO C1-2 tag-along)
  - Check: `grep -o 'usageService' KeyTrainer.qml | wc -l; grep -o 'FileView' KeyTrainer.qml | wc -l` — expect ≥ 3 and 0 (pre: `0`, `1`)
  - Skills: none
  - Writer: OpenAI · GPT-5
- [x] Step 8 — `UsageModel.js` `visibleEntries(pool, counts, threshold, windowSize)` per F12 (window 10, pulled rows on top); `UsageService.qml`: pass `windowSize`, `statusJson()` gains `visible` (row count) and `pool` becomes `poolEntries.length` (F7, F12)
  - Check: `node -e "eval(require('fs').readFileSync('UsageModel.js','utf8')); var p='abcdefghijkl'.split('').map(function(c){return {id:c,action:c.toUpperCase()}}); var r=visibleEntries(p,{C:10,K:10},10,10); console.log(r.map(function(x){return x.id}).join(' '), r.length)" && omarchy-shell shell rescanPlugins && sleep 2 && omarchy-shell oma-key-trainer status` — expect `l a b d e f g h i j c k 12` then `"pool":32,"visible":10,"complete":0` (pre: `a b d e f g h i j l c k 12`; `{"pool":32,"complete":1,"allLearned":false}`)
  - Skills: none
  - Writer: OpenAI · GPT-5
- [x] Step 9 — Manual QA, AE1 + AE2 + persistence + log: back up `counts.json`; set `"Toggle window split"` to 9 in it; `hyprctl reload` (hook re-reads); open the card; press SUPER+J with the card open → row turns "Complete", dims, drops to the bottom, "Pseudo window" appears at the top (AE1, live 3a); close the card, press SUPER+J again (AE2, counts past 10); `omarchy-restart-shell`, reopen → same rows (R12); log clean (F13)
  - Check: `omarchy-shell oma-key-trainer status; grep -o '"Toggle window split":1[1-9]' ~/.local/state/omarchy/oma-key-trainer/counts.json | wc -l; grep -i 'oma-key-trainer' /run/user/$(id -u)/quickshell/by-pid/$(pgrep -xo quickshell)/log.log | wc -l` — expect `"visible":11,"complete":1`, `1`, `0` (pre: `{"pool":32,"complete":1,"allLearned":false}`, `0`, `0`)
  - Skills: none
  - Writer: OpenAI · GPT-5
- [x] Step 10 — Manual QA, AE3 + AE4: append `hl.unbind("SUPER + J")` + `o.bind("SUPER + SHIFT + J", "Toggle window split", hl.dsp.layout("togglesplit"))` to `~/.config/hypr/bindings.lua`, `hyprctl reload`, press SUPER+SHIFT+J → the "Toggle window split" count rises, the row still reads "SUPER + J" (AE3); revert, reload. Then write a counts.json with all 32 pool actions at 10 except "Pseudo window" at 9 (python over `keybindings.json`), `hyprctl reload`, press SUPER+P → "All keybindings learned" replaces the list (AE4); run the check, then restore the Step 9 backup and `hyprctl reload`
  - Check: `omarchy-shell oma-key-trainer status | grep -o '"allLearned":true' | wc -l` (run before restoring the backup) — expect `1` (pre: `0`)
  - Skills: none
  - Writer: OpenAI · GPT-5

## Coverage

- Pick/validate the background event source → Steps 1, 2 (F1–F3: `o.bind` hook, not socket2)
- Persist per-binding counts + rotation position across reboots → Steps 1, 4, 5 (F5, F7, F11); restart proof in Step 9
- Completion at 10, rotation, all-learned state (R8, R9, R11) → Steps 4, 5, 7, 8 (window, F12); proven by Steps 9–10 (AE1–AE4)
- Author the larger curated pool in author-fixed order (R9) → Step 3
- Non-goal: settle the two UI questions now → resolved 2026-09-13 by decision (2a, 3a) — recorded in F8, applied in Steps 6–7
- Non-goal: split pool authoring into its own run → untouched
- Non-goal: rewrite/inject the user's Hyprland keybinds (Option B) → untouched (the hook wraps registration; no bind is redefined)
- Non-goal: poll `hyprctl` on a timer (Option C) → untouched

## Risks

- Step 8 is the riskiest remaining: the window rule (F12) is the rotation contract the user sees; a wrong prefix rule hides a complete-but-unpulled row or shows 11 incomplete — Step 9's AE1 is the only human-visible proof.
- Outside its files: Steps 9–10 hand-edit `counts.json` and `~/.config/hypr/bindings.lua` as test seams (R10 untouched — no product path marks completion); a forgotten restore leaves the user's progress or bindings altered.
- Not taken: a separate `visible` list in the service with `visibleEntries` unchanged — two orderings to keep in sync for no gain.

## Deviations

- Old Step 5's check failed after its prescribed edit: `omarchy plugin validate .` reported `entry point file not found: 'UsageService.qml'` — resolved by this re-plan (F9): merged into the new Step 5.
- Step 5's first IPC attempt was blocked by the executor sandbox (`omarchy-shell is not running`); the required rescan and status check then passed against the active desktop session with elevated sandbox access.
- Old Step 8: card + restart passed, but its log check hit `1` from the dead `vrxzzalt` runtime (the known 19:00 pre-Step-5 warning) and AE1 could not pass (all 32 rows visible) — re-planned as Steps 8–10 (F12, F13; decision 4a).
- Step 8: `omarchy-shell shell rescanPlugins` retained the existing kept-loaded service and returned its old status without `visible`; restarting the shell reloaded the service and produced the expected status. The implementation is verified; future hot-reload checks for this service need a shell restart.
- Step 9: `wtype -M logo -k j -m logo` exited 0 but did not traverse the live `SUPER+J` bind or the Lua hook: service remained `{"pool":32,"visible":10,"complete":0,"allLearned":false}` and the expected counts match was `0`. The original counts backup was restored and `hyprctl reload` passed. Finish this manual step with a physical SUPER+J press while the card is open.
- Step 9: the sandbox could not resolve the live Quickshell PID for the prescribed log path; the same read-only check in the active desktop environment returned `0` after reopening the card.
- Step 10: AE3's visible-counter wording was incompatible with the settled fixed-`Complete` marker. The live `SUPER+SHIFT+J` bind registered and the persisted action count rose from 11 to 15, so the action-match requirement passed; the displayed default shortcut remained `SUPER+J`. Reopening the card refreshed the manually restored counts file.

## TODO impacts

- Open question "counter live vs snapshot" → resolved (3a: live), remove
- Open question "running total vs Complete indicator" → resolved (2a: fixed marker), remove
- Deferred C1-2 "warn on keybindings.json load/parse failure" → partially completed by Step 7 (warn on missing service); the parse warning itself moves with the FileView into Step 5 — mark done at wrap if both land
- Deferred C1-1 PopupCard re-base, C1-4 `omarchyPath` → untouched

## Product doc impacts

- `PRODUCT.md` — Platform facts: "exact event source … is a Planning-phase decision" → decided: Omarchy's `o.bind` Lua registration hook, opted in by one line in `~/.config/hypr/hyprland.lua`; Core objects "Binding entry … underlying Hyprland action" → the Omarchy bind description; Open product decisions: both UI questions → decided 2026-09-13 (fixed "Complete" marker; live counter). Note: v2 background counting requires the opt-in line — a real install step for the core feature (accepted with decision 1a, not an ESCALATE).
- `PRODUCT.md` — Vocabulary "Visible list — … not-yet-complete bindings in pool order" → the 10-row window: pulled entries stack at the top (newest first), the initial rows keep pool order, completed rows sit at the bottom (decision 4a); `AGENTS.md` — Shell log: "no journald unit" → also in the journal under tag `omarchy-shell` (`journalctl --user -t omarchy-shell`); the runtime file is `by-pid/$(pgrep -xo quickshell)/log.log`.
- `DESIGN.md` — Box layout v2: "open product decision" → completed rows show a fixed "Complete" marker and a dimmed row; the counter reads `n/10` live.
- `ROADMAP.md` — Phase 2's four items checked off at wrap; "Later" note about open decisions → resolved.
