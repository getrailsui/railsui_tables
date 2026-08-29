# frozen_string_literal: true

require "test_helper"
require "action_view"

class TableHelperTest < Minitest::Test
  def test_wraps_table_content_in_a_frame_with_the_table_id
    view = ActionView::Base.empty
    view.extend(RailsuiTables::TableHelper)
    view.define_singleton_method(:turbo_frame_tag) do |id, data:, &block|
      %(<turbo-frame id="#{id}" data-turbo-action="#{data.fetch(:turbo_action)}">#{block.call}</turbo-frame>).html_safe
    end

    html = view.railsui_table(id: :users, records: [], columns: [{ key: :email }])

    assert_includes html, '<turbo-frame id="users"'
    assert_includes html, 'data-turbo-action="advance"'
    assert_includes html, '<section id="users_table" class="railsui-table-wrap"'
    assert_equal 1, html.scan('id="users"').length
    refute_includes html, 'id="users_<section'
  end

  def test_uses_the_table_id_for_an_unframed_table
    view = ActionView::Base.empty
    view.extend(RailsuiTables::TableHelper)

    html = view.railsui_table(id: :users, records: [], columns: [{ key: :email }], frame: false)

    assert_includes html, '<section id="users" class="railsui-table-wrap"'
  end

  def test_filter_form_preserves_nested_table_state
    view = ActionView::Base.empty
    view.extend(RailsuiTables::TableHelper)

    html = view.railsui_table_filter_form(
      url: "/users",
      frame: :users,
      preserve: { columns: ["", "email"], q: { status_eq: "active" } }
    ) { "Filters" }

    assert_includes html, 'name="columns[]" value="email"'
    assert_includes html, 'name="q[status_eq]" value="active"'
    assert_includes html, 'data-turbo-frame="users"'
    assert_includes html, 'data-turbo-action="advance"'
    assert_includes html, "Filters"
  end

  def test_renders_lazy_expandable_detail_rows
    view = ActionView::Base.empty
    view.extend(RailsuiTables::TableHelper)
    record = Struct.new(:id, :email).new(7, "ada@example.com")

    html = view.railsui_table(
      id: :users,
      records: [record],
      row_id: ->(user) { "user_#{user.id}" },
      columns: [:email],
      expandable: { url: ->(user) { "/users/#{user.id}/details" } }
    )

    assert_includes html, 'data-controller="railsui-table-expandable"'
    assert_includes html, 'aria-controls="user_7_details"'
    assert_includes html, 'id="user_7_details" hidden'
    assert_includes html, 'id="user_7_details_frame" data-src="/users/7/details"'
    assert_includes html, 'colspan="2"'
  end

  def test_row_url_skips_internal_columns
    view = ActionView::Base.empty
    view.extend(RailsuiTables::TableHelper)
    record = Struct.new(:id, :email).new(7, "ada@example.com")

    html = view.railsui_table(
      id: :users,
      records: [record],
      row_url: ->(user) { "/users/#{user.id}" },
      columns: [
        { key: :_railsui_table_selection, value: ->(_user) { "checkbox" } },
        :email
      ]
    )

    assert_includes html, '<td data-label="Railsui table selection">checkbox</td>'
    assert_includes html, '<td data-label="Email"><a class="railsui-table__row-link" href="/users/7">ada@example.com</a></td>'
  end
end
