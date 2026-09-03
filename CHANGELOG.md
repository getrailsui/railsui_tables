# Changelog

All notable changes to this project are documented here. This project follows
[Semantic Versioning](https://semver.org). While the version is below 1.0 the
public API may change between minor versions.

## [Unreleased]

### Added

- Rails helpers for responsive, Turbo Frame-aware index tables.
- Optional Ransack sort links and Pagy navigation integration, supporting both
  Pagy 43 object navigation and legacy view helpers.
- Token CSS, a Tailwind v4 token adapter, and Stimulus filter submission.
- Importmap and bundled-JavaScript integration paths.
- The `railsui_tables:install` generator and a versioned integration skill.
- `partial:` column option renders an ERB partial for a cell (the row is passed
  as `record`), so rich cells stay in readable markup instead of a value lambda.
- `sticky_header:`, `zebra:`, and `density:` options on `railsui_table`.
  Sticky headers turn the table viewport into a vertically scrolling box capped
  by the new `--railsui-table-sticky-max-height` token (28rem by default), since
  a sticky header can only pin to the container that actually scrolls.
- `frozen_first_column:` option to pin the first column while a wide table
  scrolls horizontally. The styling ships with Rails UI Tables Pro.
- `railsui_table_skeleton` renders a shimmering loading placeholder for a lazy
  Turbo Frame's default content.
- Real-time filtering: `railsui_table_filter_form` submits on input (debounced);
  pass `auto: false` to revert to a normal submit-button form.
- Accessible expandable rows with lazy Turbo Frame detail loading.
- Preserved nested GET parameters on filter forms.
- Advancing Turbo Frame navigation so table state is reflected in browser history.
- Sortable-header indicators with `aria-sort`, and `:focus-visible` rings.

### Fixed

- Dark mode now works under every strategy: the dark tokens answer to
  `prefers-color-scheme` (Tailwind's default `media` strategy compiles `dark:`
  utilities there and never sets a class) as well as the `.dark` class and
  `[data-theme="dark"]`, matching the charts gem.
- `bin/release` no longer stages the gitignored `Gemfile.lock`, which made
  `git add` abort the whole run.
- Pinned `packageManager: yarn@4.11.0` so Corepack (CI included) runs Yarn 4
  against the Yarn 4 lockfile instead of falling back to Yarn 1, which ignored
  `--immutable` and re-resolved dependencies.

### Changed

- Row hover is a clean full-row highlight; removed the fragile box-shadow bleed
  that misaligned inside padded containers.
- Roomier default row padding and a smoother hover transition.
- A cleaner circular expand button.
- Frame and inner table-wrapper IDs are kept unique.

### Fixed

- Small screens: collapsed expandable detail rows stay hidden (the stacked-card
  layout was overriding the `hidden` attribute), the expander has a larger tap
  target, and skeleton bars and detail panels align.
- The empty-state row no longer takes a data-row hover.
- One-page Pagy navigation is hidden.

[Unreleased]: https://github.com/getrailsui/railsui_tables/commits/main
