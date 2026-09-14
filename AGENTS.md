# Agents

Operating rules for any coding agent working in this repo.

## Doc layer — who owns what

| Doc | Owns |
|---|---|
| `PRODUCT.md` | The north star: current + desired end state, purpose, users, core objects, workflows, principles, vocabulary, anti-goals |
| `DESIGN.md` | The UI/design system — here, conformance rules to Omarchy shell's own kit |
| `AGENTS.md` | This file: doc ownership, write scopes, command contracts, verification |
| `ROADMAP.md` | The sequence: phased initiatives, each sized to one future workflow run |
| `MEMORY.md` + `memory/` | Durable cross-run patterns, one page per pattern |
| `TODO.md` | Intake scratchpad for ideas not yet brainstormed — never a roadmap |
| `WORKLOG.md` | Bounded, rolling pointer index into git history |

A fact belongs in exactly one of these. If the same sentence could go in two, one of them is
wrong — fix the doc, don't duplicate the sentence.

## Write scopes

- `.workflow/<slug>/` — owned by the workflow run in progress; tracked in git, never deleted
  (wrap archives a run, it never removes the folder).
- Plugin source (QML, `manifest.json`, JS, curated-pool data) — the deliverable; this is what
  every workflow run is ultimately for.
- Canonical docs (`PRODUCT.md`, `DESIGN.md`, `ROADMAP.md`) — edited only through the workflow's
  own phases (plan/execute/wrap/realign), never as an incidental side effect of an unrelated fix.

## Command contracts

- `omarchy plugin validate <plugin-folder>` — validates a plugin folder against Omarchy's
  manifest schema. The closest thing this project has to a build check.
- `omarchy plugin enable <id>` and `omarchy-shell shell rescanPlugins` — load/reload the plugin
  for manual QA.
- `omarchy dev ui preview [section]` — browse the shared `qs.Ui` kit this plugin should build on.

## Verifying your work

- **Build:** `omarchy plugin validate <path-to-this-plugin-folder>` — healthy output is exit 0
  with no schema errors printed.
- **Test:** TODO — no automated test harness exists for Quickshell/QML plugins in this ecosystem
  yet. Until one is chosen, "test" means manual QA: `omarchy plugin enable <id>`, click the bar
  icon (or `omarchy-shell shell toggle oma-key-trainer '{}'`), and walk R1–R3 for v1 or the
  acceptance examples AE1–AE4 for v2 in `docs/archive/PRD-2026-09-13.md` by hand.
- **Lint:** TODO — no `qmllint` or equivalent is installed on this machine; revisit if one
  becomes available.
- **Shell log:** the running shell's stderr is at `/run/user/$(id -u)/quickshell/by-pid/$(pgrep -xo quickshell)/log.log`
  (`by-id/*` also exists but keeps dead instances around after a restart — prefer `by-pid`). It is
  also mirrored to the journal under tag `omarchy-shell` (`journalctl --user -t omarchy-shell`).
  "No warning mentioning `<plugin-id>`" means `grep -i <plugin-id>` on the by-pid log is empty
  after exercising the plugin.
- Run whatever of the above applies before reporting any step done, and paste the result.
- A failing test is fixed in the code, never by editing or deleting the test.
