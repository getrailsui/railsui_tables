# frozen_string_literal: true

require_relative "lib/railsui_tables/version"

Gem::Specification.new do |spec|
  spec.name = "railsui_tables"
  spec.version = RailsuiTables::VERSION
  spec.authors = ["Andy Leverenz"]
  spec.email = ["railsui@justalever.com"]
  spec.summary = "Rails-native data tables for SaaS applications"
  spec.description = "Accessible, responsive data tables with Rails, Turbo, Ransack, and Pagy adapters."
  spec.homepage = "https://railsui.com/tables"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1"
  spec.metadata = { "rubygems_mfa_required" => "true", "source_code_uri" => "https://github.com/getrailsui/railsui_tables" }
  spec.files = Dir.chdir(__dir__) { Dir["{app,config,lib,skills}/**/*", "README.md", "LICENSE.md", "CHANGELOG.md", "Rakefile", "package.json"].reject { |file| File.directory?(file) } }
  spec.require_paths = ["lib"]
  spec.add_dependency "rails", ">= 7.2", "< 9.0"
end
