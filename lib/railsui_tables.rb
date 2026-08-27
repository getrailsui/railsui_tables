# frozen_string_literal: true

require "railsui_tables/version"
require "railsui_tables/configuration"
require "railsui_tables/column"
require "railsui_tables/adapters/pagy"
require "railsui_tables/table_helper"

module RailsuiTables
  mattr_accessor :config, default: Configuration.new

  def self.configure
    yield(config)
  end
end

require "railsui_tables/engine" if defined?(Rails)
