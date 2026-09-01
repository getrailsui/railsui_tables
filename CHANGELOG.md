# Changelog

All notable changes to this project are documented here. This project follows
[Semantic Versioning](https://semver.org). While the version is below 1.0 the
public API may change between minor versions.

## [Unreleased]

### Added

- `partial:` column option renders an ERB partial for a cell (the row is passed
  as `record`), so rich cells stay in readable markup instead of a value lambda.
- `sticky_header:`, `zebra:`, and `density:` options on `railsui_table`.
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

## [0.1.0]

- Initial public release.
- Added Rails helpers for responsive, Turbo Frame-aware index tables.
- Added optional Ransack sort links and Pagy navigation integration.
- Added support for both Pagy 43 object navigation and legacy view helpers.
- Added token CSS, a Tailwind v4 token adapter, and Stimulus filter submission.
- Added dark-mode defaults for Rails UI applications.
- Added importmap and bundled-JavaScript integration paths.
- Added the `railsui_tables:install` generator and a versioned integration skill.

[Unreleased]: https://github.com/getrailsui/railsui_tables/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/getrailsui/railsui_tables/releases/tag/v0.1.0
