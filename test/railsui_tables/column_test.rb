# frozen_string_literal: true

require "test_helper"

class ColumnTest < Minitest::Test
  def test_builds_a_symbol_column
    column = RailsuiTables::Column.build(:name)

    assert_equal :name, column.key
    assert_equal "Name", column.label
    refute column.sortable
  end

  def test_accepts_a_custom_value
    column = RailsuiTables::Column.build(key: :total, sortable: true, value: ->(record) { "$#{record.total}" })

    assert column.sortable
    assert_equal "$12", column.value.call(Struct.new(:total).new(12))
  end
end
