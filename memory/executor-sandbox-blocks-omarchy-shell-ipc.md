# `omarchy-shell` IPC fails inside the OpenAI executor CLI's sandbox, but works from the Anthropic CLI's
Applies when: a Phase 3 step (executor seat, OpenAI CLI) runs `omarchy-shell shell …` — summon/hide/toggle, `listPlugins`, `rescanPlugins` — for QA or a step check and gets no shell / "cannot connect" instead of `ok`.
Root cause: that CLI's sandbox has no access to the user session bus / `$XDG_RUNTIME_DIR` socket the running `quickshell` instance listens on. The Anthropic CLI's default sandbox on this machine does reach it (`omarchy-shell shell ping` → `ok`, run plugin-scaffold-v1 review + wrap).
Fix: in the executor session, run the IPC command outside the sandbox (its escape-hatch flag, or the human runs it and pastes the output) and record the observation in `plan.md` — don't mark the step blocked or stub the check; for review/wrap on the Anthropic side, just run it. Applies when: also covers `omarchy-restart-shell` — its internal `shell ping` readiness check fails the same way in-sandbox.
Evidence: plugin-scaffold-v1, usage-tracking-v2
Occurrences: 2 · Last confirmed: 2026-09-14 · Status: active
