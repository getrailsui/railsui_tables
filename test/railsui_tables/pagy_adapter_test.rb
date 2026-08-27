# frozen_string_literal: true

require "test_helper"

class PagyAdapterTest < Minitest::Test
  def setup
    @view = Object.new.extend(RailsuiTables::Adapters::Pagy)
  end

  def test_uses_object_navigation_for_current_pagy
    pagy = Object.new
    pagy.define_singleton_method(:series_nav) { "current navigation" }

    assert_equal "current navigation", @view.railsui_table_pagination(pagy)
  end

  def test_uses_view_helper_for_legacy_pagy
    pagy = Object.new
    received = nil
    @view.define_singleton_method(:pagy_nav) { |value| received = value; "legacy navigation" }

    assert_equal "legacy navigation", @view.railsui_table_pagination(pagy)
    assert_same pagy, received
  end
end
