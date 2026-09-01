# Rails UI Tables

Rails-native, accessible tables for SaaS index pages. `railsui_tables` keeps
index-page work in the Rails stack: Active Record relations, GET parameters,
Ransack when an app already uses it, Pagy when an app already uses it, and
Turbo Frames for partial navigation. It is not a spreadsheet or a client-side
data grid.

The Ruby gem and `@getrailsui/tables` package are MIT licensed. Saved views and
bulk-action controls live in the subscriber-only
[`railsui_tables_pro`](https://github.com/getrailsui/railsui_tables_pro)
companion.

## Requirements

- Ruby 3.1+
- Rails 7.2 or 8.x
- Stimulus 3+ for filter submission behavior

Ransack and Pagy are optional. Tables render without either; they only add
sorting/filtering and pagination integrations when present in the host app.

## Installation

```ruby
# Gemfile
gem "railsui_tables"
```

```bash
bundle install
bin/rails g railsui_tables:install
```

The installer links the stylesheet from the gem:

```erb
<%= stylesheet_link_tag "railsui_tables" %>
```

The engine places its CSS and compiled JavaScript on the Rails asset path, so
Propshaft and Sprockets applications do not copy asset files into the host app.

### JavaScript

**Importmap applications** receive the `railsui_tables` pin from the engine.
Register the controllers in the application controller index:

```js
import { registerRailsuiTables } from "railsui_tables"

registerRailsuiTables(application)
```

**Bundled applications** install and register the package:

```bash
yarn add @getrailsui/tables
```

```js
import { registerRailsuiTables } from "@getrailsui/tables"

registerRailsuiTables(application)
```

### Styling

The default stylesheet uses `--railsui-table-*` tokens, includes responsive row
labels for small screens, and supplies light and `.dark` defaults. Set those
tokens in the host design system to match a non-Rails-UI application.

Tailwind v4 applications can map the tokens to Tailwind color variables:

```css
/* app/assets/tailwind/application.css */
@import "@getrailsui/tables/tailwind.css";
```

Use either the asset-pipeline stylesheet or your own bundled CSS import, not
both.

## Basic Table

Prepare records in the controller, then use column definitions in the view:

```erb
<%= railsui_table id: :users,
      records: @users,
      row_id: ->(user) { dom_id(user) },
      row_url: ->(user) { user_path(user) },
      columns: [
        { key: :name, sortable: true },
        { key: :email, sortable: true },
        { key: :created_at, label: "Joined" }
      ] %>
```

Columns may be symbols, hashes, or `RailsuiTables::Column` objects. A hash can
provide `label:`, `sortable:`, `cell_class:`, `header_class:`, a `value:` lambda,
or a `partial:` for display values that do not map directly to a model method:

```erb
<%= railsui_table id: :subscriptions, records: @subscriptions,
      columns: [
        :customer_name,
        { key: :status, value: ->(subscription) { status_badge(subscription) } },
        { key: :mrr, label: "MRR", value: ->(subscription) { number_to_currency(subscription.mrr) } }
      ] %>
```

Pass a block for fully custom per-cell output. The block receives the record
and normalized column object.

For a rich cell, render a partial instead of a `value:` lambda — it keeps the
markup in readable ERB. The partial receives the row as `record` and the
normalized column as `column`:

```erb
<%= railsui_table id: :members, records: @members,
      columns: [{ key: :name, label: "Member", partial: "members/cell" }, :role] %>
```

```erb
<%# app/views/members/_cell.html.erb %>
<div class="flex items-center gap-3">
  <%= image_tag record.avatar_url, class: "size-8 rounded-full" %>
  <div>
    <div class="font-medium"><%= record.name %></div>
    <div class="text-sm text-neutral-500"><%= record.email %></div>
  </div>
</div>
```

### Display options

`railsui_table` takes a few presentational flags, all opt-in:

```erb
<%= railsui_table id: :users, records: @users, columns: [...],
      sticky_header: true,   # header stays pinned while the table scrolls
      zebra: true,           # striped rows
      density: :compact %>   # tighter rows (default :comfortable)
```

`sticky_header: true` turns the table's viewport into a vertically scrolling
box (a sticky header can only pin to the element that actually scrolls, and
the table's own overflow wrapper is always the nearest one). The height is
capped at the `--railsui-table-sticky-max-height` token, `28rem` by default —
override it per table, or set it to `none` to manage the height yourself:

```css
#orders_table { --railsui-table-sticky-max-height: 60vh; }
```

`frozen_first_column: true` pins the first column while a wide table scrolls
horizontally. The free helper emits the class; the styling that freezes it ships
with [`railsui_tables_pro`](https://github.com/getrailsui/railsui_tables_pro).

### Loading skeleton

Render a shimmering placeholder — for example as a lazy Turbo Frame's default
content while the real query loads:

```erb
<%= railsui_table_skeleton columns: 5, rows: 5 %>
```

### Expandable Detail Rows

Pass an allowlisted detail URL to add a collapsed row for each record. The
detail request is made only after the row is opened; the host endpoint should
render the matching Turbo Frame and perform its own authorization:

```erb
<%= railsui_table id: :users, records: @users, columns: [:name, :email],
      expandable: { url: ->(user) { user_details_path(user) } } %>
```

The helper provides the button, accessible state, and lazy frame loading. It
does not add a detail route, query the database, or authorize access.

## Filters, Sorting, and Pagination

Keep table state in the URL. This makes a filtered view linkable, works before
JavaScript loads, and lets Turbo replace only the table frame.

```ruby
# app/controllers/users_controller.rb
def index
  @q = User.order(created_at: :desc).ransack(params[:q])
  @pagy, @users = pagy(@q.result)
end
```

```erb
<%= railsui_table_filter_form(
      url: users_path,
      frame: :users,
      preserve: { columns: params[:columns] }
    ) do %>
  <%= search_field_tag "q[name_or_email_cont]", params.dig(:q, :name_or_email_cont),
        placeholder: "Search users" %>
<% end %>

<%= railsui_table id: :users, records: @users, query: @q, pagy: @pagy,
      columns: [{ key: :name, sortable: true }, { key: :email, sortable: true }] %>
```

With `query: @q`, sortable columns use Ransack's `sort_link`. With `pagy:
@pagy`, the helper uses `pagy_nav`; include Pagy's frontend helpers in the host
application as normal. The form submits on input (debounced 250ms) by default,
so no Search button is needed; pass `auto: false` to `railsui_table_filter_form`
for a standard submit-button GET form instead. Use `preserve:` for URL-backed
state owned by another control, such as `columns[]`; nested hashes and arrays are
emitted as hidden fields.

## Turbo Behavior

`railsui_table` wraps its content in a Turbo Frame by default. Its `id:` is the
frame identifier, while the inner section uses `<id>_table` so both DOM IDs
remain unique. The frame and targeted filter form use `data-turbo-action="advance"`
so sorting, filtering, and pagination update browser history. Pass `frame:
false` for a full-page table or when the surrounding template owns the frame.

Turbo Streams should replace the frame or row the host application owns. The
gem does not subscribe to model updates, reorder collections, or invent stream
targets; those decisions belong to the product using the table.

## What This Gem Does Not Do

- No client-side sorting, pagination, or full collection synchronization
- No inline spreadsheet editing, pivoting, grouping, or data virtualization
- No authorization or bulk mutation behavior
- No assumptions about a particular CSS framework, ORM query, or route shape

For selection checkboxes, personal saved views, and bulk-action form controls,
install `railsui_tables_pro`. The host application remains responsible for
authorizing each selected record and mutation.

## Development

```bash
bundle exec rake test
corepack yarn test
corepack yarn build
gem build railsui_tables.gemspec
npm pack --dry-run
```

The Ruby version, npm version, installer asset names, and generated JavaScript
are intentional release boundaries. Keep them aligned before publishing.

## License

MIT. See [LICENSE.md](LICENSE.md).
