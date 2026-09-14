# Memory

Index of durable, cross-run patterns. Each line points at a page in `memory/<slug>.md` — nothing
here is a memory itself; the claim, root cause, and fix live on the page.

Entry shape and how pages get here: the workflow skill's `references/learning-worklog.md`. Don't
hand-add lines here; route learnings through `workflow learn` / `memory.remember`.

<!-- - [<slug>](memory/<slug>.md) — <one-line claim> · occurrences N · <last confirmed> -->

- [executor-sandbox-blocks-omarchy-shell-ipc](memory/executor-sandbox-blocks-omarchy-shell-ipc.md) — `omarchy-shell` IPC (incl. `omarchy-restart-shell`) fails in the OpenAI executor CLI's sandbox (no session bus); works from the Anthropic CLI — run it unsandboxed or via the human · occurrences 2 · 2026-09-14
- [swallowed-load-error-hides-empty-state](memory/swallowed-load-error-hides-empty-state.md) — a catch that only resets state on a config/data load leaves an empty UI with no trace; always `console.warn` alongside the reset · occurrences 2 · 2026-09-14
- [bind-hook-must-fallback-unknown-dispatcher-shape](memory/bind-hook-must-fallback-unknown-dispatcher-shape.md) — a hook wrapping `o.bind` must fall back to stock `o.bind` for a dispatcher shape it doesn't recognise, or the bind dies at press time · occurrences 1 · 2026-09-14
