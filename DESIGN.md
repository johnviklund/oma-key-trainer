# Design

This plugin has a UI (a bar icon + a card, optionally also a menu row), but it does not own a design system — it inherits
Omarchy shell's, by requirement (PRD R1: match the visual and interaction style of other built-in
menu entries).

## Conform, don't invent

- Build the box from the shared `qs.Ui` component kit — browsable via `omarchy dev ui preview`.
  v1 as shipped: bar icon = `BarWidget` + `WidgetButton`; card = `PanelWindow` + `BorderSurface`
  with `PanelHero`/`PanelSeparator`, themed by `Color.menu.*`. Known gap (review C1-1, deferred to
  `TODO.md`): the card positions itself rather than through the kit's `PopupCard`/`Panel`, so bar
  position and multi-monitor are not yet handled by the kit — the non-goal below still stands.
- Colors, spacing, and borders come from the `qs.Commons` theme singletons (`Color`, `Style`,
  `Border`), never hardcoded, so the box matches whatever theme the user has active.
- Open/close interaction: toggled from its bar icon (or `omarchy-shell shell toggle
  oma-key-trainer '{}'`, which the optional menu row uses), dismissed by Escape or click-outside —
  the same scrim + Escape pattern the Emojis overlay uses.

## Box layout

- **v1:** one panel, one column. Each row = key combo + short description, in curated pool
  order, using the kit's existing row-list conventions.
- **v2 adds:** a usage counter per row, and a visual treatment for rows that have moved to the
  bottom as complete. Whether the counter keeps counting past 10 or switches to a fixed
  "Complete" badge is an open product decision (see `PRODUCT.md`) — resolve it during Planning,
  then record the answer here.
- **All-learned state:** a single terminal message in place of the row list once the whole
  curated pool is complete (R11) — exact copy is content curation, not a structural decision.

## Non-goals

- No custom color palette, iconography, or animation beyond what `qs.Ui`/`qs.Commons` already
  provide.
- No layout system independent of the panel/row conventions the kit already establishes.
