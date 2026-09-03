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

  def test_renders_a_cell_from_a_partial
    view = ActionView::Base.empty
    view.extend(RailsuiTables::TableHelper)
    view.define_singleton_method(:render) do |partial, record:, column:|
      %(<span data-partial="#{partial}">#{record.email} (#{column.key})</span>).html_safe
    end
    record = Struct.new(:email).new("ada@example.com")

    html = view.railsui_table(
      id: :users,
      records: [record],
      frame: false,
      columns: [{ key: :email, partial: "users/email_cell" }]
    )

    assert_includes html, 'data-partial="users/email_cell"'
    assert_includes html, "ada@example.com (email)"
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

  def test_display_options_emit_table_classes
    view = ActionView::Base.empty
    view.extend(RailsuiTables::TableHelper)

    html = view.railsui_table(
      id: :users,
      records: [],
      frame: false,
      columns: [:name],
      sticky_header: true,
      zebra: true,
      density: :compact,
      frozen_first_column: true
    )

    assert_includes html, "railsui-table--sticky-header"
    assert_includes html, "railsui-table--zebra"
    assert_includes html, "railsui-table--compact"
    assert_includes html, "railsui-table--frozen-first"
    assert_includes html, "railsui-table__viewport--sticky"
  end

  def test_sticky_header_off_leaves_the_viewport_unconstrained
    view = ActionView::Base.empty
    view.extend(RailsuiTables::TableHelper)

    html = view.railsui_table(id: :users, records: [], frame: false, columns: [:name])

    refute_includes html, "railsui-table__viewport--sticky"
  end

  def test_skeleton_renders_placeholder_bars
    view = ActionView::Base.empty
    view.extend(RailsuiTables::TableHelper)

    html = view.railsui_table_skeleton(columns: 3, rows: 2)

    assert_includes html, "railsui-table--skeleton"
    assert_includes html, 'aria-hidden="true"'
    # 3 columns across the header row and each of the 2 body rows.
    assert_equal 9, html.scan("railsui-table__skeleton-bar").length
  end

  Account = Struct.new(:name, :plan, :mrr)

  def test_grouped_rows_render_group_headers_in_record_order
    view = ActionView::Base.empty
    view.extend(RailsuiTables::TableHelper)
    records = [Account.new("Ada", "Pro", 49), Account.new("Grace", "Pro", 49), Account.new("Joan", "Free", 0)]

    html = view.railsui_table(id: :accounts, records: records, frame: false, group_by: :plan, columns: [:name, :mrr])

    assert_includes html, "railsui-table--grouped"
    assert_includes html, '<tr class="railsui-table__group-header"><td colspan="2" data-railsui-table-group="Pro">Pro</td></tr>'
    # Records are chunked in the order given — the host controls ordering.
    assert_equal ["Pro", "Free"], html.scan(/data-railsui-table-group="([^"]+)"/).flatten
    refute_includes html, '<tr class="railsui-table__group-header" data-railsui-table-target'
  end

  def test_grouped_header_colspan_counts_the_expander_column
    view = ActionView::Base.empty
    view.extend(RailsuiTables::TableHelper)
    records = [Account.new("Ada", "Pro", 49)]

    html = view.railsui_table(
      id: :accounts,
      records: records,
      frame: false,
      group_by: ->(account) { account.plan },
      columns: [:name, :mrr],
      expandable: { url: ->(_account) { "/accounts/details" } }
    )

    assert_includes html, '<td colspan="3" data-railsui-table-group="Pro">Pro</td>'
    assert_includes html, "railsui-table__expand"
  end

  def test_group_totals_align_to_their_columns
    view = ActionView::Base.empty
    view.extend(RailsuiTables::TableHelper)
    records = [Account.new("Ada", "Pro", 49), Account.new("Grace", "Pro", 21), Account.new("Joan", "Free", 0)]

    html = view.railsui_table(
      id: :accounts,
      records: records,
      frame: false,
      group_by: :plan,
      group_totals: { mrr: ->(rows) { rows.sum(&:mrr) } },
      columns: [:name, { key: :mrr, cell_class: "railsui-table__actions" }]
    )

    assert_includes html, '<tr class="railsui-table__group-footer"><td>Pro total</td><td class="railsui-table__actions">70</td></tr>'
    assert_includes html, '<tr class="railsui-table__group-footer"><td>Free total</td><td class="railsui-table__actions">0</td></tr>'
  end

  def test_totals_render_a_grand_total_row_in_the_tfoot
    view = ActionView::Base.empty
    view.extend(RailsuiTables::TableHelper)
    records = [Account.new("Ada", "Pro", 49), Account.new("Joan", "Free", 21)]

    html = view.railsui_table(
      id: :accounts,
      records: records,
      frame: false,
      totals: { mrr: ->(rows) { rows.sum(&:mrr) } },
      columns: [:name, :mrr]
    )

    assert_includes html, '<tfoot><tr class="railsui-table__total-row"><td>Total</td><td>70</td></tr></tfoot>'
  end

  def test_group_by_rejects_a_row_block
    view = ActionView::Base.empty
    view.extend(RailsuiTables::TableHelper)

    error = assert_raises(ArgumentError) do
      view.railsui_table(id: :accounts, records: [], frame: false, group_by: :plan, columns: [:name]) { |record, _column| record.name }
    end

    assert_match(/group_by/, error.message)
  end

  def test_no_group_rows_without_group_by
    view = ActionView::Base.empty
    view.extend(RailsuiTables::TableHelper)
    records = [Account.new("Ada", "Pro", 49)]

    html = view.railsui_table(id: :accounts, records: records, frame: false, columns: [:name, :mrr])

    refute_includes html, "railsui-table--grouped"
    refute_includes html, "railsui-table__group-header"
    refute_includes html, "railsui-table__group-footer"
    refute_includes html, "<tfoot"
  end
end
