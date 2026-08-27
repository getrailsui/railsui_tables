# Rails UI Tables

Use this skill when adding or upgrading `railsui_tables` in a Rails app.

1. Confirm the Ruby gem and `@getrailsui/tables` npm package resolve to the same version.
2. Run `rails g railsui_tables:install`; do not copy controllers or CSS into the host app.
3. Use a prepared relation. Add Ransack for filter/sort queries and Pagy for pagination when the app already uses them.
4. Keep table state in GET parameters. Wrap it in a Turbo Frame for partial navigation; it must still work without JavaScript.
5. Treat bulk authorization and record mutation as host application responsibilities.
