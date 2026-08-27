# frozen_string_literal: true

require "test_helper"
require "rails/generators"
require "rails/generators/test_case"
require "generators/railsui_tables/install/install_generator"

class GeneratorsTest < Rails::Generators::TestCase
  tests RailsuiTables::Generators::InstallGenerator
  destination File.expand_path("../../tmp/generator", __dir__)
  setup :prepare_destination

  ROOT = File.expand_path("../..", __dir__)
  GENERATOR = RailsuiTables::Generators::InstallGenerator
  LAYOUT = <<~ERB
    <html>
      <head>
        <%= stylesheet_link_tag "application" %>
      </head>
      <body><%= yield %></body>
    </html>
  ERB

  def with_layout(contents = LAYOUT)
    path = File.join(destination_root, "app/views/layouts")
    FileUtils.mkdir_p(path)
    File.write(File.join(path, "application.html.erb"), contents)
  end

  def layout_contents
    File.read(File.join(destination_root, "app/views/layouts/application.html.erb"))
  end

  def test_the_layout_name_is_a_stylesheet_the_gem_ships
    logical = GENERATOR::STYLESHEET_TAG[/stylesheet_link_tag "([^"]+)"/, 1]

    assert File.exist?(File.join(ROOT, "app/assets/stylesheets", "#{logical}.css"))
  end

  def test_the_engine_precompiles_the_layout_stylesheet
    logical = GENERATOR::STYLESHEET_TAG[/stylesheet_link_tag "([^"]+)"/, 1]
    engine = File.read(File.join(ROOT, "lib/railsui_tables/engine.rb"))

    assert_includes engine, %(precompile << "#{logical}.css")
  end

  def test_it_links_the_stylesheet_once_inside_the_head
    with_layout
    run_generator
    run_generator

    head = layout_contents[/<head>(.*?)<\/head>/m, 1].to_s
    assert_includes head, "railsui_tables"
    assert_equal 1, layout_contents.scan(%(stylesheet_link_tag "railsui_tables")).length
  end

  def test_a_missing_layout_is_said_rather_than_created
    output = run_generator

    assert_match(/not found/, output)
    assert_no_file "app/views/layouts/application.html.erb"
  end

  def test_a_layout_without_a_head_is_said_rather_than_changed
    original = "<html><body><%= yield %></body></html>\n"
    with_layout(original)
    output = run_generator

    assert_match(/No <\/head>/, output)
    assert_equal original, layout_contents
  end
end
