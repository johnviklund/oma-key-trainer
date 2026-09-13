# Omarchy Keybindings Trainer

An Omarchy shell plugin that helps you learn Hyprland/Omarchy keybindings: v1 shows a curated
reference list from a dedicated top-right bar icon; v2 tracks real usage in the background and rotates in
new bindings as you master the current ones.

| Doc | What it holds |
|---|---|
| [PRODUCT.md](PRODUCT.md) | What this is, for whom, and why |
| [DESIGN.md](DESIGN.md) | UI conventions this plugin conforms to |
| [AGENTS.md](AGENTS.md) | Rules for any agent working in this repo |
| [ROADMAP.md](ROADMAP.md) | Build order |
| [MEMORY.md](MEMORY.md) | Durable cross-run patterns |
| [TODO.md](TODO.md) | Intake scratchpad |
| [WORKLOG.md](WORKLOG.md) | Rolling pointer into git history |

Built with the `workflow` skill (brainstorm → plan → execute → review → wrap).

## Install

```sh
omarchy plugin add https://github.com/johnviklund/oma-key-trainer.git --enable
```

The trainer icon is added to the right side of the bar, immediately after the system tray.

To enable background usage tracking, add this line to `~/.config/hypr/hyprland.lua` immediately
before `require("default.hypr.omarchy")`:

```lua
require("default.hypr.require_optional").module("omarchy.plugins.oma-key-trainer.hook")
```

Reload Hyprland after adding it:

```sh
hyprctl reload
hyprctl configerrors
```

Add this row to `~/.config/omarchy/extensions/omarchy-menu.jsonc` to make the
trainer available from the main menu's Learn submenu as well:

```jsonc
{
  "learn.keybindings-trainer": {"icon":"󰧑","label":"Keybindings Trainer","action":"omarchy-shell shell toggle oma-key-trainer '{}'"},
}
```
