Command: workflow plan plugin-scaffold-v1
Created: 2026-09-13
Base: f2c5365164d19fe59e51a72c0125925906167f49
Inputs: brainstorm.md @ 94d4abe2e2c74ea2d1761ded064c42f4a6bdc8a5
Status: complete

## Execution state

- Current: Step 5 — add the menu row and installation instructions.
- Step 1 @ efeccd7
- Step 2 @ 345039d
- Step 3 @ e62ef06
- Step 4 @ pending receipt commit
- Writer: OpenAI · GPT-5 (self-declared)
- Baseline: `omarchy plugin validate .` fails as expected (missing manifest); no automated QML test or lint harness is installed.
- In flight: plugin id `oma-key-trainer`; overlay entry point `KeyTrainer.qml`; data shape `{id, keys, description}`.
- Uncommitted: none.
- Pending: none.

Decided with the human (2026-09-13): plugin id `oma-key-trainer`; distribution repo
`https://github.com/johnviklund/oma-key-trainer`; menu row `learn.keybindings-trainer`, label
"Keybindings Trainer".

## Findings

| # | What is true (verified against the live install) | What it changes |
|---|---|---|
| F1 | `qs.Ui/Panel` is the *bar-widget popup* base (`PanelController`, `IpcHandler`, `bar` binding — `Ui/Panel.qml`). Overlays (Emojis, Clipboard) use `PanelWindow` + `BorderSurface` with `Color.menu.*` tokens. `PanelHero`/`PanelSectionHeader`/`PanelSeparator` are plain Items and work inside either. | The card is `PanelWindow` → scrim → `BorderSurface`; `Panel` is not used. DESIGN.md wording is stale (see Product doc impacts). |
| F2 | Overlay contract (`shell.qml:1152-1275`): the root Item must expose `property bool opened`, `open(payloadJson)`, `close()`; may declare `shell`, `manifest`, `omarchyPath` for injection. Third-party `shell` is a facade whose `hide(ownId)` works (`services/PluginShellApi.qml`). Dismiss = `shell.hide(manifest.id)`, as Emojis does. | Step 2 shape. |
| F3 | `omarchy-plugin-validate` refuses any symlink under the folder and, run on a symlinked *path*, reports the symlink itself and fails (tested). The shell's scan (`"$dir"/*/` glob) does discover a symlinked plugin dir; `inotifywait -r` does not follow it, so hot-reload will not fire — `omarchy-shell shell rescanPlugins` is required after edits. | Validate runs on the repo path; dev loop = symlink + manual rescan. |
| F4 | Id rules: `^[A-Za-z0-9][A-Za-z0-9._-]*$`, no `..`, not `omarchy.*`; ids are never rewritten (`Util.canonicalWidgetId` is identity). `oma-key-trainer` passes. `omarchy plugin add` clones into `~/.config/omarchy/plugins/<id>/` and needs `manifest.json` at the repo root. | Plugin files live at this repo's root, not a subfolder. |
| F5 | The menu reads exactly two files (`plugins/menu/Menu.qml:50-51`): the default jsonc and `~/.config/omarchy/extensions/omarchy-menu.jsonc`. No manifest field contributes menu rows. The user extension file currently holds only comments (brainstorm's "already-populated" is off — ours is the first live row). | The menu row is user config outside the repo; the repo ships it as a documented README snippet. |
| F6 | Plugin-local data is loaded with `FileView { path: Qt.resolvedUrl("x.json").toString().replace(/^file:\/\//, "") }` (radio-atlas) — first-party Emojis uses `omarchyPath` instead, which a third-party plugin cannot. | Curated pool = `keybindings.json` at plugin root, fields `id` (stable slug v2 will count against), `keys`, `description`. |
| F7 | Authoritative source for default combos + descriptions: `/usr/share/omarchy/default/hypr/bindings/*.lua` (`o.bind("SUPER + W", "Close window", …)`). | Curate from there; display text = shipped default (R7 groundwork). |
| F8 | `omarchy-shell shell summon <id> '{}'` returns `ok`/`unknown` and refuses a disabled plugin — a runnable load check. `AGENTS.md`'s "walk AE1–AE4" is v2-only (all four cover R5/R7/R8/R11); v1 QA is R1–R3. | Step 6 check; AGENTS.md note under Product doc impacts. |
| F9 | `keepLoaded: true` keeps the instance across hot-reload so code changes need a shell restart (`shell/README.md`). | Omit `keepLoaded` in v1; load on summon. |

## Checklist

- [x] Step 1 — Author the curated pool `keybindings.json`: array of ~10 `{id, keys, description}`, author-ordered, combos/descriptions copied from the default bindings (F6, F7)
  - Writer: OpenAI · GPT-5
  - Check: `jq -e 'length >= 8 and length <= 12 and all(.[]; has("id") and has("keys") and has("description"))' keybindings.json` (pre: exit 2 — file missing)
  - Skills: none
- [x] Step 2 — Scaffold `manifest.json` (id `oma-key-trainer`, name "Keybindings Trainer", version 0.1.0, homepage/repository = GitHub URL, `kinds: ["overlay"]`, `entryPoints.overlay: "KeyTrainer.qml"`, no `keepLoaded`) and the overlay lifecycle in `KeyTrainer.qml`: `opened`/`open()`/`close()`/`dismiss()`, injected `shell`/`manifest`/`omarchyPath`, fullscreen `PanelWindow` (Overlay layer, exclusive keyboard focus) with `Color.menu.scrim`, centered `BorderSurface` card, Escape and click-outside dismiss (F1, F2, F4, F9)
  - Writer: OpenAI · GPT-5
  - Check: `omarchy plugin validate . && grep -o 'function \(open\|close\|dismiss\)(' KeyTrainer.qml | wc -l` (pre: validate fails "missing manifest.json"; grep count 0 → expect exit 0 and 3)
  - Skills: none
- [x] Step 3 — Render the list in `KeyTrainer.qml`: `FileView` loads `keybindings.json` via `Qt.resolvedUrl` into a `ListModel`; `PanelHero` title "Keybindings Trainer" + `PanelSeparator`; `ListView` rows = key combo (left, fixed width) + description (right, elided), one column, pool order; all colors/spacing from `Color.menu.*`/`Style` (F1, F6)
  - Writer: OpenAI · GPT-5
  - Check: `grep -o 'Qt.resolvedUrl("keybindings.json")\|PanelHero\|ListView' KeyTrainer.qml | sort | uniq -c` (pre: no output → expect each ≥ 1) paired guard: `grep -o '#[0-9a-fA-F]\{6\}' KeyTrainer.qml | wc -l` (pre: 0 → stays 0)
  - Skills: none
- [x] Step 4 — Install for QA: `ln -sfn "$PWD" ~/.config/omarchy/plugins/oma-key-trainer && omarchy-shell shell rescanPlugins && omarchy plugin enable oma-key-trainer` (F3)
  - Writer: OpenAI · GPT-5
  - Check: `omarchy-shell shell listPlugins | jq -e '.[] | select(.id=="oma-key-trainer") | .enabled'` (pre: exit 4 — not discovered → expect `true`)
  - Skills: none
- [ ] Step 5 — Menu row: add `"learn.keybindings-trainer": {"icon":"󰧑","label":"Keybindings Trainer","action":"omarchy-shell shell toggle oma-key-trainer '{}'"}` to `~/.config/omarchy/extensions/omarchy-menu.jsonc`; add an "Install" section to `README.md` with `omarchy plugin add https://github.com/johnviklund/oma-key-trainer.git --enable` plus that exact snippet (F5)
  - Check: `grep -o '"learn.keybindings-trainer"' ~/.config/omarchy/extensions/omarchy-menu.jsonc | wc -l; grep -o 'learn.keybindings-trainer' README.md | wc -l` (pre: 0 / 0 → expect 1 / ≥ 1)
  - Skills: /home/johnviklund/.claude/skills/omarchy/SKILL.md
- [ ] Step 6 — Manual QA (R1–R3): from the top-right menu, Learn → Keybindings Trainer opens the box with all pool rows; Escape and click-outside close it; theme colors match the menu; no `console.warn` for `oma-key-trainer` in the shell output. Paste what was seen (F8)
  - Check: `omarchy-shell shell summon oma-key-trainer '{}'; omarchy-shell shell hide oma-key-trainer` (pre: `unknown` → expect `ok`)
  - Skills: none

## Coverage

- Scaffold plugin folder (manifest, menu entry, overlay QML), loading via `omarchy plugin enable` → Steps 2, 4, 5
- Author the initial curated ~10 as static content → Step 1
- Render the box with `qs.Ui`/`qs.Commons` per DESIGN.md; wire the menu entry (R1–R3) → Steps 3, 5, 6
- Non-goal: usage tracking / counters / persistence / rotation → untouched
- Non-goal: `learn.keybindings` entry and `omarchy-menu-keybindings` script → untouched
- Non-goal: the two v2 counter-display questions in TODO.md → untouched

## Risks

- Riskiest: Step 3 — the first QML in the repo with no lint/test harness; a binding typo only shows as a blank card at runtime, so Step 6's visual walk is the real gate.
- Outside its files: Step 5 edits user config (`~/.config/omarchy/extensions/omarchy-menu.jsonc`), hot-reloaded by the live menu; a JSONC syntax slip can break the whole menu until reverted.
- Not taken: `kind: "panel"` on the `qs.Ui/Panel` base — it is bar-anchored and needs a `bar`; the menu-summoned centered card is the overlay pattern (F1).

## Deviations

- Step 4 initially stopped because the shell control plane was not running. After the user restarted it, the planned rescan and enable command passed; no workspace code was changed.

## TODO impacts

- none (both open questions are v2 counter display). Optional adjacent: none.

## Product doc impacts

- `PRODUCT.md` — resolves "Plugin id / distribution name — not yet chosen": id `oma-key-trainer`, repo `https://github.com/johnviklund/oma-key-trainer`; "Current: not yet built" becomes v1 scaffolded once Step 6 passes. Not ESCALATE.
- `DESIGN.md` — "Build the box from … `Panel`, …" is stale for an overlay (F1): replace with "`PanelWindow` + `BorderSurface` card, using `PanelHero`/`PanelSectionHeader`/`PanelSeparator` inside it, themed by `Color.menu.*`". Principle "conform, don't invent" unchanged. Not ESCALATE.
- `ROADMAP.md` — Phase 1's three items check off at wrap; no wording change.
- `AGENTS.md` — "walk AE1–AE4 by hand" covers v2 only (F8); wrap should scope it "AE1–AE4 for v2; R1–R3 for v1".
