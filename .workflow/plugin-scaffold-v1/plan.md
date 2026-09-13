Command: workflow plan plugin-scaffold-v1
Created: 2026-09-13
Base: 9ccf23db656590fdeb6a277429249b7ecc7d5c4f
Inputs: brainstorm.md @ 94d4abe2e2c74ea2d1761ded064c42f4a6bdc8a5 (supersedes plan.md @ f2c5365164d19fe59e51a72c0125925906167f49)
Status: done

## Findings

| # | What is true (verified against the live install / repo) | What it changes |
|---|---|---|
| F1 | Shipped and enabled: `keybindings.json` (10 rows), `manifest.json` id `oma-key-trainer`, `KeyTrainer.qml` card, README install section, menu row in `~/.config/omarchy/extensions/omarchy-menu.jsonc`; `omarchy plugin validate .` exits 0; `listPlugins` shows `enabled: true`, placed in `shell.json` right section after `omarchy.tray`. | No scaffold/render steps remain; this plan is QA + publish + rename. |
| F2 | `manifest.json` now `kinds: ["bar-widget"]`, `entryPoints.barWidget: "BarWidget.qml"`, `barWidget.defaultSection: "right"` (a real field — `services/PluginRegistry.qml:73`). `BarWidget.qml` extends `qs.Ui/BarWidget`, `Loader`s `KeyTrainer.qml` and exposes `opened`/`open()`/`close()`. | The overlay contract from the old plan is gone; the card is owned by the widget, not the shell's panel loader. |
| F3 | For a bar-widget-only plugin the shell routes `summon`/`hide`/`toggle` to the live bar instance (`shell.qml` `isBarWidgetPanelPlugin` → `Bar.qml:744 summonBarWidget` → `item.open()`; `hide` → `item.close()`). `omarchy-shell shell summon oma-key-trainer '{}'` prints `ok`; `hide` prints nothing, exit 0. | The README menu row (`omarchy-shell shell toggle oma-key-trainer '{}'`) still works without an `overlay` kind — only while the icon is in the bar layout. |
| F4 | `KeyTrainer.dismiss()` calls `shell.hide(manifest.id \|\| "oma-key-trainer")`; in the widget path `manifest` is never injected (falls back to the literal id) and `shell` is `bar.shell` — the full shell, no facade. Works via F3. | No change needed; note for v2 if the widget ever gets a facade. |
| F5 | Uncommitted `KeyTrainer.qml` diff: card anchored `top`/`right` with `Style.gapsOut` margins, height cap `Style.space(480)` → `Style.space(640)`. Colors/spacing still all `Color.menu.*`/`Style`. | Step 1 commits it as the intended v1 look (decision 1a). |
| F6 | Git: HEAD on `fix/top-right-trainer-widget` = `master` + 1 commit (fast-forwardable); no `main`; no `origin`; `init.defaultBranch=master`. GitHub `johnviklund/oma-key-trainer` exists, public, empty (`isEmpty: true`, no default branch). `gh` is logged in as `johnviklund` over https, but git has **no credential helper** — `gh auth setup-git` is required before the first push. | Step 3 shape. |
| F7 | `~/.config/omarchy/plugins/oma-key-trainer` → symlink to `/home/johnviklund/Work/plugin-keys-helper`; the shell scan follows it but `inotifywait` does not, so a rescan is manual. `omarchy plugin add <url> --enable` clones into that same path on a fresh machine (`omarchy-plugin-add:120`). | Step 4 must re-point the symlink and rescan; the dev loop stays symlink-based. |
| F8 | `PRODUCT.md` ("reachable from Omarchy's existing top-right menu", "Current: not yet built", "id — not yet chosen") and `DESIGN.md` ("summoned from a menu action", "build the box from `Panel`") describe the pre-pivot shape. | Product doc impacts below; wrap edits them, not a step. |

## Checklist

- [x] Step 1 — Commit the top-right card anchoring in `KeyTrainer.qml` (F5)
  - Check: `git show HEAD:KeyTrainer.qml | grep -o 'anchors.rightMargin: Style.gapsOut' | wc -l` (pre: 0 → expect 1) paired guard: `git diff --quiet -- KeyTrainer.qml; echo $?` (pre: 1 → expect 0)
  - Skills: none
  - Writer: OpenAI · GPT-5
- [x] Step 2 — Manual QA (R1–R3) on the bar-widget shape: click the bar icon → card opens top-right under it with all 10 pool rows; Escape and click-outside close it; `omarchy-shell shell toggle oma-key-trainer '{}'` opens and closes it (menu-row path); colors match the current theme; no `console.warn` mentioning `oma-key-trainer` in the shell output. Observed pass: top-right placement, 10 rows, current-theme colors, Escape/click-outside dismissal, and menu-row toggle all worked; no warning observed.
  - Check: `omarchy-shell shell summon oma-key-trainer '{}'; omarchy-shell shell hide oma-key-trainer` (pre: `ok` / exit 0 — already runnable; the step's deliverable is the pasted observation, not a changed exit code)
  - Skills: none
  - Writer: OpenAI · GPT-5
- [x] Step 3 — Publish: `gh auth setup-git && git branch -m master main && git checkout main && git merge --ff-only fix/top-right-trainer-widget && git branch -d fix/top-right-trainer-widget && git remote add origin https://github.com/johnviklund/oma-key-trainer.git && git push -u origin main` (F6)
  - Check: `git rev-parse --abbrev-ref HEAD; git ls-remote --heads https://github.com/johnviklund/oma-key-trainer.git main | wc -l` (pre: `fix/top-right-trainer-widget` / 0 → expect `main` / 1)
  - Skills: none
  - Writer: OpenAI · GPT-5
- [x] Step 4 — Rename the local folder and re-point the dev symlink, last: `mv ~/Work/plugin-keys-helper ~/Work/oma-key-trainer && ln -sfn ~/Work/oma-key-trainer ~/.config/omarchy/plugins/oma-key-trainer && omarchy-shell shell rescanPlugins` — then reopen the session in `~/Work/oma-key-trainer` (F7)
  - Check: `readlink -f ~/.config/omarchy/plugins/oma-key-trainer; omarchy-shell shell listPlugins | jq -e '.[] | select(.id=="oma-key-trainer") | .enabled'` (pre: `/home/johnviklund/Work/plugin-keys-helper` / `true` → expect `/home/johnviklund/Work/oma-key-trainer` / `true`)
  - Skills: none
  - Writer: OpenAI · GPT-5

## Coverage

- Scaffold plugin folder (manifest, menu entry, overlay QML), loading via `omarchy plugin enable` → shipped in the previous plan (F1); entry point is now a bar widget + optional menu row (decision 1a) → Steps 2, 3
- Author the initial curated ~10 as static content → shipped (F1), verified in Step 2
- Render the box with `qs.Ui`/`qs.Commons` per DESIGN.md; wire the menu entry (R1–R3) → Steps 1, 2
- Distribution (id `oma-key-trainer`, GitHub repo, folder name — brainstorm open question) → Steps 3, 4
- Non-goal: usage tracking / counters / persistence / rotation → untouched
- Non-goal: `learn.keybindings` entry and `omarchy-menu-keybindings` script → untouched
- Non-goal: the two v2 counter-display questions in TODO.md → untouched

## Risks

- Riskiest: Step 3 — first push to an empty public repo with branch rename; `--ff-only` and `branch -d` refuse rather than lose history, but a failed `gh auth setup-git` leaves a half-done local rename with no remote — finish the branch steps, then retry the push.
- Outside its files: Step 4 breaks this session's cwd and any other symlink or shell pointing at `plugin-keys-helper`; the menu row depends on the icon staying in the bar layout (F3) — removing the icon via bar settings silently kills the row.
- Not taken: declaring both `overlay` and `bar-widget` kinds so the menu row works without the icon — extra shell wiring for a row that is optional by decision 1a.

## Deviations

- The sandbox cannot access the user session bus; outside it, `omarchy-shell` commands reach the running shell normally. QA completed through that session.
- Step 3 initially found an invalid token; after re-authentication, `main` fast-forwarded to the feature branch and pushed successfully.

## TODO impacts

- none (both open questions are v2 counter display). Optional adjacent: none.

## Product doc impacts

- `PRODUCT.md` — "Current: not yet built" → v1 built (bar icon + card, curated 10, published at `https://github.com/johnviklund/oma-key-trainer`); "v1 … reachable from Omarchy's existing top-right menu" → "reachable from a top-right bar icon (and, optionally, a user-added menu row)"; open decision "Plugin id / distribution name — not yet chosen" → resolved: `oma-key-trainer`. Not ESCALATE (decision 1a taken by the human).
- `DESIGN.md` — "Build the box from … `Panel`, …" → "`PanelWindow` + `BorderSurface` card with `PanelHero`/`PanelSeparator`, themed by `Color.menu.*`"; "summoned from a menu action, dismissed the same way" → "toggled from its bar icon (or `omarchy-shell shell toggle`), dismissed by Escape / click-outside". Not ESCALATE.
- `ROADMAP.md` — Phase 1's three items check off at wrap; the first item's "menu entry, overlay QML" wording → "bar widget + card QML".
- `AGENTS.md` — "walk AE1–AE4 by hand" covers v2 only; wrap scopes it "AE1–AE4 for v2; R1–R3 for v1".
