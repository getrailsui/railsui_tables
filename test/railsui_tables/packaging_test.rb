# frozen_string_literal: true

require "test_helper"
require "json"

class PackagingTest < Minitest::Test
  def test_ruby_and_npm_versions_match
    package = JSON.parse(File.read(File.expand_path("../../package.json", __dir__)))

    assert_equal RailsuiTables::VERSION, package.fetch("version")
  end
end
