# frozen_string_literal: true

require "test_helper"
require "action_view"

class TableHelperTest < Minitest::Test
  def test_wraps_table_content_in_a_frame_with_the_table_id
    view = ActionView::Base.empty
    view.extend(RailsuiTables::TableHelper)
    view.define_singleton_method(:turbo_frame_tag) do |id, &block|
      %(<turbo-frame id="#{id}">#{block.call}</turbo-frame>).html_safe
    end

    html = view.railsui_table(id: :users, records: [], columns: [{ key: :email }])

    assert_includes html, '<turbo-frame id="users">'
    assert_includes html, 'class="railsui-table-wrap"'
    refute_includes html, 'id="users_<section'
  end
end
