Command: workflow spec usage-tracking-v2
Created: 2026-09-13
Base: fda38938f1c4c656f458b12c010de195c396a483
Inputs: .workflow/usage-tracking-v2/brainstorm.md @ fda38938f1c4c656f458b12c010de195c396a483
Status: complete

## Approach

- Add a kept-loaded `service` alongside the existing `bar-widget`; the service alone owns the pool, counts, completion order, and disk state.
- The widget passes its injected self-service facade to `KeyTrainer.qml`; the card renders the service model and never owns durable progress.
- Subscribe to Quickshell's `Hyprland.rawEvent` socket2 feed for the experiment, but admit only action mappings proven to distinguish a bind trigger from ordinary compositor activity.
- This is a feasibility gate: socket2 exposes downstream events, not a keybind-executed event. The current pool includes unobservable or ambiguous actions (split toggle, directional focus, terminal launch, menu, close, float, fullscreen), so no tracker may increment from an inferred correlation.
- Persist a versioned JSON snapshot under Omarchy's XDG state tree; derive visible order as incomplete pool entries then completed entries in authored order.
- Planning must either find a non-invasive exact action hook, or return the run for a product decision; silently reducing the pool or counting false positives violates the product principle.

## Interfaces

```jsonc
// manifest.json — verified: Omarchy loads both entry points and preserves a keepLoaded service
{ "kinds": ["service", "bar-widget"], "keepLoaded": true,
  "entryPoints": { "service": "UsageService.qml", "barWidget": "BarWidget.qml" } }
```

```qml
// BarWidget.qml — verified: injected PluginShellApi exposes only this plugin's service
property var shell
readonly property var usageService: shell ? shell.serviceFor("oma-key-trainer") : null
```

```qml
// UsageService.qml — verified: Hyprland.rawEvent supplies each socket2 event as HyprlandEvent
function handleHyprlandEvent(event) // event.name, event.data, event.parse(argumentCount)
```

```jsonc
// ~/.local/state/omarchy/oma-key-trainer.json — inferred durable-state contract
{ "version": 1, "entries": { "<binding-id>": { "count": 0, "complete": false } } }
```

```jsonc
// keybindings.json — inferred authored-pool extension
{ "id": "<stable-id>", "keys": "<display>", "description": "<label>", "action": "<exact-source-token>" }
```

```qml
// UsageService.qml / KeyTrainer.qml — inferred presentation contract
property ListModel visibleEntries // id, keys, description, count, complete; completion threshold = 10
```

## Impacted files

| Path | Change |
|---|---|
| `manifest.json` | Add kept-loaded service entry point. |
| `UsageService.qml` | New shared event, progress, rotation, and persistence owner. |
| `UsageModel.js` | New pure state and event-matching helpers. |
| `BarWidget.qml` | Inject and pass the self-service facade. |
| `KeyTrainer.qml` | Render service-backed counts, completion, and all-learned state. |
| `keybindings.json` | Expand ordered pool with stable action-source metadata. |
