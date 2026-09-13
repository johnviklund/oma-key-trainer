Command: workflow review plugin-scaffold-v1
Created: 2026-09-13
Base: 0ae072205741a4f184624dca9779ae806e33a8bf
Inputs: plan.md @ 9ccf23db656590fdeb6a277429249b7ecc7d5c4f; brainstorm.md @ 94d4abe2e2c74ea2d1761ded064c42f4a6bdc8a5
Status: complete

Scope note: the plan's Base 9ccf23d already contains the plugin code shipped by the superseded
plan (efeccd7 … 9ccf23d); no review ever ran on it. Code diff since plan Base is `KeyTrainer.qml`
only (Step 1), but the brainstorm's scope items are the requirements of record, so the whole
plugin source is in coverage — not just the 7-line diff.

## Coverage
- [x] brainstorm.md scope: plugin folder that `omarchy plugin enable` loads → delivered (F1; `listPlugins` enabled=true, `omarchy plugin validate .` exit 0)
- [x] brainstorm.md scope: an entry point (menu row / bar icon per decision 1a) that opens the box → delivered (bar icon `BarWidget.qml`; menu row present at `~/.config/omarchy/extensions/omarchy-menu.jsonc:30`; `summon` → `ok`)
- [x] brainstorm.md scope: box renders the curated ~10 keybindings per DESIGN.md → delivered (10 rows, all 10 match `default/hypr/bindings/*.lua` verbatim; kit components + theme singletons — see C1-1 for the positioning deviation)
- [x] brainstorm.md non-goal: usage tracking / counters / persistence / rotation → untouched (no counters, no state files, no service kind)
- [x] brainstorm.md non-goal: `learn.keybindings` entry and `omarchy-menu-keybindings` script → untouched (`learn.keybindings` line identical to `default/omarchy/omarchy-menu.jsonc:40`; `pacman -Qkk omarchy` reports no mismatch on the script)
- [x] brainstorm.md non-goal: TODO.md v2 counter-display questions → untouched (TODO.md unchanged since bootstrap)
- [x] plan.md Steps 1–4 checks re-run + Deviations → all four checks pass at HEAD (1/0 · main/1 · symlink → `~/Work/oma-key-trainer`, enabled true · summon `ok`/hide exit 0); Deviations are environmental (session bus, token) and left no code residue
- [x] plan.md provenance / freshness → `Status: complete`; brainstorm.md untouched since its creating commit f2c5365; code diff `9ccf23d..HEAD` is `KeyTrainer.qml` only (Step 1, 09a8f29)
- [x] `.workflow/` dependency grep from code → no hits (grep exit 1, command present)
- [x] manifest.json → `defaultSection: "right"` valid (`PluginRegistry.qml:75`); `omarchy plugin validate .` exit 0; homepage/repository match the published remote
- [x] BarWidget.qml → extends `qs.Ui/BarWidget`; exposes `opened`/`open()`/`close()` exactly as `Bar.qml:735 findPanelWidget` requires; `WidgetButton.pressed(int)` signature matches; `bar` null-guarded
- [x] KeyTrainer.qml → every `Style.*`, `Color.menu.*`, `Border.surfaceSpec`, `BorderSurface`, `PanelHero`, `PanelSeparator` property verified against `/usr/share/omarchy/shell/{Commons,Ui}`; findings C1-1…C1-4
- [x] keybindings.json → 10 rows, unique ids, content verified against Omarchy defaults
- [x] README.md → install command matches `omarchy-plugin-add`; "immediately after the system tray" verified (`PluginRegistry.qml:270` right-section anchor `omarchy.tray`, index+1); menu-row snippet matches the live line
- [x] Live shell → `summon` prints `ok`, `hide` exit 0; shell log (`/run/user/1000/quickshell/by-id/*/log.log`, since 14:57 restart) has no line mentioning the plugin
- [x] Publish state → `main` == `origin/main` == 0ae0722; symlink target correct
Independence: cross-vendor (writer OpenAI · GPT-5 per plan.md; reviewer Anthropic · Opus 5)

## Cycle 1 findings

### P2 — C1-1: Card window hand-rolls positioning the kit's `PopupCard` already solves (bar position, screen, per-monitor instance)
- Evidence: `KeyTrainer.qml:73-81` full-screen `PanelWindow` (no `screen:` binding, `ExclusionMode.Ignore`, Overlay layer + scrim) with the card at `anchors.top/right` + `Style.gapsOut` (`KeyTrainer.qml:98-101`). The kit's `Ui/PopupCard.qml:25-36,106-127` anchors to the button's window/screen and branches on `bar.position` (`top|bottom|left|right`, `Bar.qml:67`, `shell.json` `bar.position`); first-party bar-widget panels (`plugins/panels/power/Panel.qml:9,292-294`) use `Panel` + a kit card with `anchorItem: button`. `Ui/PanelKeyCatcher.qml` exists for the Escape handling hand-rolled at `KeyTrainer.qml:111-123`.
- Consequence: with `bar.position` ≠ `top` the card opens top-right, away from the icon; the scrim covers the bar itself (the icon is under the overlay while open); with >1 monitor each bar instance owns its own screen-less window and `toggle` picks an instance via `BarModel.pickPanelSlot`, so one can open while another is still open. Not live on this machine (one monitor `eDP-1`, `bar.position: "top"`; human QA passed in Step 2) — latent for anyone installing from the public repo.
- Disposition: defer — the human chose this look (decision 1a) and it works on the target setup; DESIGN.md is already scheduled for the `PanelWindow + BorderSurface` wording at wrap. Route to `TODO.md` at wrap as "re-base the card on `PopupCard`/`Panel` so bar position and multi-monitor are handled by the kit" for a later run. (P2 defer needs no approval; human may choose fix now — see verdict.)
- Resolved: —

### P3 — C1-2: Load failure yields a silent empty card
- Evidence: `KeyTrainer.qml:44-50,67-71` — `FileView` has no `onLoadFailed`; `JSON.parse` failure swallows to `[]`; no empty-state text or `console.warn`. The card would open with a hero and zero rows and nothing in the shell log.
- Disposition: defer — data is shipped static and `omarchy plugin validate .` passes; a one-line `console.warn` is cheap if the human prefers fix now.
- Resolved: —

### P3 — C1-3: `dismiss()` calls `shell.hide(id)` after already closing itself
- Evidence: `KeyTrainer.qml:38-42`; in the bar-widget path `shell.hide` → `Bar.qml:751 hideBarWidget` → `findPanelWidget` (slot chosen by focused screen) → `item.close()`. Redundant on one monitor; on several it may target a different instance than the one dismissing. Leftover from the overlay contract (plan F4 already notes it).
- Disposition: defer — fold into the C1-1 follow-up.
- Resolved: —

### P3 — C1-4: Unused property `omarchyPath`
- Evidence: `KeyTrainer.qml:11` `property string omarchyPath: Quickshell.env("OMARCHY_PATH")` — no reader anywhere (`grep -n omarchyPath *.qml` → 1 hit, the declaration).
- Disposition: defer — dead line, no behavior; remove in the next code-touching run.
- Resolved: —

Further P3s: 0. No P0–P2 repeats a class recorded in `MEMORY.md` (index empty) or `evals/strict-reviewer/` (absent) — no `[durable→memory]` tag; no confirmed P0/P1 → no `[durable→eval]` case.

## Pre-existing / environmental
- No automated test or lint harness exists (AGENTS.md TODO). Regression proof for this run: code diff since plan Base is the 7-line `KeyTrainer.qml` anchoring change; `omarchy plugin validate .` exit 0; live `summon`/`hide` exit 0 with no shell-log output; human QA (plan Step 2).
- Shell log carries two `qt.qpa.services` portal-registration warnings at startup — Qt/portal, unrelated to any plugin.
- `omarchy-shell shell isPluginOpen` is not an exposed IPC method (`Function not found.`) — the shell-internal function exists (`shell.qml:1201`) but is not part of the CLI surface; not something this run relies on.

## Cycle 1 verdict
**Ship as-is pending dispositions** — 0 P0 · 0 P1 · 1 P2 · 3 P3, every recommended disposition is *defer*. If the human accepts the defaults there is nothing worth acting on: skip the patch plan and go to `workflow wrap`, which records C1-1 (and C1-3 folded in) as a `TODO.md` idea and C1-2/C1-4 as a one-line "cleanup on next touch" note. If any item is switched to *fix now*, a lighter P2/P3 patch plan is written first and `workflow execute` runs it before re-review (cycle 2).
