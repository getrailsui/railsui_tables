# frozen_string_literal: true

module RailsuiTables
  class Engine < ::Rails::Engine
    isolate_namespace RailsuiTables

    initializer "railsui_tables.helpers" do
      ActiveSupport.on_load :action_controller do
        helper RailsuiTables::TableHelper
        helper RailsuiTables::Adapters::Pagy
      end
    end

    initializer "railsui_tables.assets" do |app|
      next unless app.config.respond_to?(:assets)

      app.config.assets.precompile << "railsui_tables.css"
      app.config.assets.paths << root.join("app/assets/javascripts")
      app.config.assets.precompile << "railsui_tables.js"
    end

    initializer "railsui_tables.importmap", before: "importmap" do |app|
      app.config.importmap.paths << root.join("config/importmap.rb") if app.config.respond_to?(:importmap)
    end
  end
end
