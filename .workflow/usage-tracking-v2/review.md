Command: workflow review usage-tracking-v2
Created: 2026-09-13
Base: aa3eed535687c441601f28e1a78f7a6c0e2cd314
Inputs: .workflow/usage-tracking-v2/plan.md @ 3afd4a490a34c8971ae46da1c23e0ca9f871a303
Status: drafting

Cycle 1 reviewed diff: `fda38938..e36b0e48`; cycle 2 reviews `e36b0e48..aa3eed53` (patch cycle 1 fixes only). Cycle 1 reviewed the whole run — Steps 1–7 were committed before the re-plan
at `3afd4a4`; the plan's own Base only covers Step 8). Code files: `hook.lua`, `keybindings.json`,
`UsageModel.js`, `UsageService.qml`, `BarWidget.qml`, `KeyTrainer.qml`, `manifest.json`; receipt:
`README.md`.

## Coverage
- [x] brainstorm.md scope: pick/validate the background event source → delivered by Steps 1–2 (`o.bind` wrapper; live-proven SUPER+W, SUPER+J, SUPER+SHIFT+J, SUPER+P; `Hyprland.rawEvent` correctly dropped per F1)
- [x] brainstorm.md scope: persist per-binding counts + rotation position across reboots → delivered by Steps 1, 4, 5 (`counts.json` v1 on disk; rotation derived from counts, F7; restart proof Step 9)
- [x] brainstorm.md scope: completion at 10, rotation, all-learned (R8, R9, R11) → delivered by Steps 4, 5, 7, 8; AE1–AE4 human-verified Steps 9–10; model checks re-run clean
- [x] brainstorm.md scope: larger curated pool in author-fixed order (R9) → delivered by Step 3 (32 entries, 0 duplicate ids/actions, 0 unmatched against `hyprctl binds -j`, every action registered via `o.bind`)
- [x] brainstorm.md non-goal: settle the two UI questions during brainstorm → resolved in planning by decision 2a/3a, which the brainstorm explicitly deferred to planning — untouched
- [x] brainstorm.md non-goal: split pool authoring into a separate run → untouched
- [x] brainstorm.md non-goal: rewrite/inject the user's Hyprland keybinds (Option B) → untouched: the hook wraps `o.bind` registration via Omarchy's own API; no config file rewritten, no bind unbound/redefined (`grep unbind|hyprland.lua|bindings.lua hook.lua` empty); flags `locked/repeating/release` pass through `options` untouched; `hyprctl binds -j` shape is identical (every Lua-config bind is `__lua`)
- [x] brainstorm.md non-goal: poll `hyprctl` on a timer (Option C) → untouched (`grep Timer|hyprctl|rawEvent` over the QML/Lua is empty)
- [x] plan.md steps 1–10 checks + Deviations — static checks re-run at Base: Step 1 `luac -p` ok / `o.bind`×4; Step 2 counts.json has `"Close window"`; Step 4 `b:3:false a:10:true false`; Step 5 `IpcHandler`×1; Step 6 `serviceFor`×1; Step 7 `usageService`×9, `FileView`×0; Step 8 `l a b d e f g h i j c k 12`; `omarchy plugin validate .` exit 0; live `omarchy-shell oma-key-trainer status` → `{"pool":32,"visible":10,"complete":0,"allLearned":false}`; QA seams restored (no `hl.unbind` in `~/.config/hypr/bindings.lua`; counts.json back to the pre-Step-9 values, "Toggle window split":3)
- [x] `.workflow/` dependency grep → no hits (grep exit 1 on a real run)
- [x] hook.lua — see C1-2, C1-4, C1-5; reload path verified (`bootstrap.lua` clears `default.hypr.*`, hook re-requires helpers, clears its own `package.loaded` and returns `false`); load/write JSON round-trip safe for every live description (none contain `"`, `\`, `{`, `}`); `pass_event`/`ok` result tables pass through unchanged; mouse-drag binds still work — traced in Hyprland v0.56.2 `LuaBindingsDispatchers.cpp:681` (`dsp_mouseDrag` sets `releasePending` on `m_currentKeybind`, which is the hook's bind)
- [x] keybindings.json — clean (see scope line above)
- [x] UsageModel.js — `visibleEntries` window rule matches F12 for pulls, multiple pulls, complete-outside-prefix rows; `allLearned` false on empty/partial, true only when the whole pool is complete; `parseCounts` tolerant of empty/torn/non-numeric
- [x] UsageService.qml — see C1-1, C1-3; `Qt.resolvedUrl` pool path verified live (`pool:32`); IpcHandler reachable
- [x] BarWidget.qml — `serviceFor` binding + `refresh()` on open + re-injection on service replacement: clean
- [x] KeyTrainer.qml — counts/Complete marker/dimming/all-learned/missing-service warning: clean (`count + "/10"` hardcodes the service's `completionThreshold` — style, not reported)
- [x] manifest.json — `service` kind, `keepLoaded`, entry point present, 0.2.0: clean; validate exit 0
- [x] README.md opt-in instructions — correct module name (resolves via bootstrap's `~/.config/?.lua`), correct placement (after the bootstrap `dofile`, before `default.hypr.omarchy`); matches the live `~/.config/hypr/hyprland.lua`
- [x] Regression: validate exit 0; node checks pass; live status ok; live shell log (`by-pid/$(pgrep -xo quickshell)/log.log`) has 0 `oma-key-trainer` lines; `hyprctl configerrors` empty; the six shell restarts since 21:33 are all "Exiting due to IPC request" (deliberate `omarchy-restart-shell`), not crashes
Independence: cross-vendor — writer OpenAI · GPT-5 (plan `## Execution state`, every step `Writer:` line); reviewer Anthropic · Opus 5

## Cycle 1 findings

### C1-1 · P2 — Live counter silently degrades to snapshot-on-open once the state-dir watch goes quiet; `refresh()` never re-arms it
- Evidence: `UsageService.qml:48-51` `refresh()` reloads `keybindingsFile` and `countsFile` only; `UsageService.qml:85-91` `stateDirWatcher` is created once. Quickshell 0.3.1 `FileView::reload()` → `updatePath()` → `updateWatchedFiles()` destroys and recreates the `QFileSystemWatcher` (fileview.cpp:379, 494–530) — that is the re-arm, and the first-party idle service uses exactly it (`/usr/share/omarchy/shell/plugins/services/idle/Service.qml:308` `stayAwakeStateDirWatcher.reload()` after its mkdir probe). Omarchy documents the quirk this defends against: `Bar.qml:1181-1184` "The directory watch can permanently stop delivering events after flag changes land in quick succession … until the shell restarts". This service produces a directory event per keypress (tmp write + rename) and ~30/s on a held `repeating` bind (volume/brightness) — a higher burst rate than any first-party watcher sees. Plan F5 named the quirk and chose "reload() on card open" as the mitigation; the shipped `refresh()` reloads the files, not the watch, so a quiet watch stays quiet until `omarchy-restart-shell`.
- Not reproduced here (needs a real key burst); the gap in `refresh()` is confirmed from code. Fresh-install case (dir absent at service start) is *not* part of this finding — Quickshell's parent-dir watch re-adds the path when the dir appears (fileview.cpp:540-546).
- Disposition: fix now — add `stateDirWatcher.reload()` to `refresh()` (one line; same pattern as idle). Optional: also `mkdir -p` the state dir from the service, as idle does.
- Resolved: —

### C1-2 · P2 — An `o.bind` dispatcher shape the hook doesn't recognise breaks that bind at press time instead of registering it untracked
- Evidence: `hook.lua:96-124` `resolve_dispatcher` is a copy of Omarchy's `command_from` (`/usr/share/omarchy/default/hypr/helpers.lua:56-82`, five table shapes). An unmatched table is returned as-is; `hook.lua:146` then calls `hl.dispatch(<table>)` on every press → Hyprland `hlDispatch` rejects it ("hl.dispatch: expected a dispatcher", `LuaBindingsToplevel.cpp`) → the keybind lambda errors and the key does nothing. Today all five shapes match (verified against the installed helpers.lua), so this is latent: it fires the day an Omarchy update adds a shape (helpers.lua is actively evolving — `{ tui = }`, `{ webapp = , focus = }` are recent additions). The user would see a dead bind with a Hyprland-side Lua error, nothing attributing it to this plugin.
- Disposition: fix now — in `tracked_bind`, if `resolve_dispatcher` returns neither a function nor a userdata, call `original_bind(keys, description, dispatcher, options)` and return (untracked, but stock behaviour). Larger alternative not recommended for this cycle: stop duplicating `command_from` by capturing the resolved dispatcher at the `hl.bind` boundary.
- Resolved: —

### C1-3 · P3 — `loadPool` swallows a `keybindings.json` parse error silently → empty card, no warning (repeat of plugin-scaffold-v1 C1-2)
- Evidence: `UsageService.qml:24-32` `catch (error) { root.poolEntries = [] }` with no `console.warn`. `KeyTrainer.qml:120-131` warns only when the *service* is missing. The plan's "TODO impacts" promised "the parse warning itself moves with the FileView into Step 5"; no step check covered it and it did not land. Same class as the v1 review's C1-2 (still in `TODO.md`) — second occurrence, tagged `[durable→memory]` in `learnings.md`.
- Disposition: fix now — one `console.warn("oma-key-trainer: keybindings.json parse failed: " + error)` in the catch; lets wrap close C1-2 truthfully.
- Resolved: —

### C1-4 · P3 — The counts write runs before the dispatch, inside Hyprland's 100 ms keybind watchdog
- Evidence: `hook.lua:137-147` `run()` does `pcall(record, …)` (open/write/flush/close/rename) *then* dispatches. `ConfigManager.hpp:110` `LUA_TIMEOUT_KEYBIND_CALLBACK_MS = 100`; the watchdog is a Lua count hook (`ConfigManager.cpp:443-456`) so it cannot interrupt the C-level I/O, but once the deadline has passed it raises on the next Lua instruction — the `pcall` swallows the first raise, the second lands in `run()` before `hl.dispatch`, and the keypress is lost. Sub-millisecond on this SSD; a real risk only under heavy I/O stalls.
- Disposition: defer — speculative today; revisit if a keypress ever drops. (If touched: dispatch first, record after, both `pcall`ed.)
- Resolved: —

### C1-5 · P3 — `drag`-style binds are counted twice per use (press and release both enter `run()`)
- Evidence: Hyprland `dsp_mouseDrag`/`dsp_mouseResize` (`LuaBindingsDispatchers.cpp:681-697`) set `releasePending` on the current keybind, so `KeybindManager.cpp:782-788` re-invokes the same `__lua` handler on release — i.e. `run()` and therefore `record()` twice per SUPER+drag. "Move window"/"Resize window" are counted in `counts.json` but are not in the pool, so no visible row is affected today.
- Disposition: wontfix — not in the pool; pool curation note: a `drag`/`click`/`release`-flagged bind must not enter the pool without dedupe.
- Resolved: —

## Pre-existing / environmental
- `journalctl --user -t omarchy-shell` 19:00:08 `WARN qml: service plugin load failed for oma-key-trainer: … UsageService.qml: File name case mismatch` — the pre-Step-5 window where `manifest.json` named a not-yet-created file (plan F9 / deviation); dead instance `vrxzzalt`. The live instance log has 0 plugin lines.
- A kept-loaded service is not reloaded by `omarchy-shell shell rescanPlugins`; `omarchy-restart-shell` is required to pick up `UsageService.qml` edits (plan Step 8 deviation) — patch-cycle checks must restart the shell.
- `omarchy-shell` IPC needs an unsandboxed session (`memory/executor-sandbox-blocks-omarchy-shell-ipc.md`).
- `hyprctl binds -j` reports `key: ""`, `keycode: 0` for Omarchy's `code:NN` workspace binds (SUPER+1…0) with or without the hook — a Hyprland display quirk; `AGENTS.md`'s "no journald unit" line is stale (plan F13, routed to wrap).

## Cycle 1 verdict
**Patch, then re-review.** 0 P0 · 0 P1 · 2 P2 · 3 P3. The run delivers all four brainstorm scope items and touches no non-goal; the event source, persistence, window rule and all-learned state are correct and were human-verified (AE1–AE4). Both P2s are robustness gaps with one-to-five-line fixes (C1-1 `UsageService.qml`, C1-2 `hook.lua`); C1-3 is a one-line repeat of a v1 finding. Recommended: fix C1-1, C1-2, C1-3 now; defer C1-4; wontfix C1-5. Patch plan: `patch_plan.md` (lighter, P2/P3 only). No test file exists to protect the fixes; the patch checks are grep-presence plus the live status/keypress checks the plan already uses.

## Cycle 2 coverage (re-review of patch cycle 1 — C1-1, C1-2, C1-3; nothing else re-implemented)
- [ ] Patch scope: `git diff --stat e36b0e48..HEAD -- . ':(exclude)*.md' ':(exclude)*.txt'` is exactly `UsageService.qml` + `hook.lua` (no test files exist; no other code touched)
- [ ] C1-2 fix @ 149f08c — `hook.lua` untracked fallback: placement, `original_bind` in scope, return-value parity with stock `o.bind`, happy path unchanged
- [ ] C1-3 fix @ f811b34 — `UsageService.qml` `loadPool` catch warns once, still resets `poolEntries`
- [ ] C1-1 fix @ 003a734 — `UsageService.qml` `refresh()` ends with `stateDirWatcher.reload()`; id resolvable; directory-path reload is warning-free
- [ ] Deferred/wontfix reasoning still holds: C1-4 (defer), C1-5 (wontfix) — confirm, do not implement
- [ ] patch_plan.md Deviations (Step 2 sandbox false negative; Step 3 `grep -c` exit-1 check) — assess
- [ ] `.workflow/` dependency grep → still no hits
- [ ] Regression at HEAD: `luac -p hook.lua`; `omarchy plugin validate .` exit 0; UsageModel.js node checks; `hyprctl configerrors` empty; live `omarchy-shell oma-key-trainer status`; live shell log 0 plugin lines; running shell/Hyprland actually carry the patched code
Independence: cross-vendor — patch writer OpenAI · GPT-5 (patch_plan.md `## Execution state` + per-step `Writer:`); reviewer Anthropic · Opus 5

## Cycle 2 findings
