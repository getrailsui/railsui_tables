# frozen_string_literal: true

require "rails/generators"

module RailsuiTables
  module Generators
    class InstallGenerator < Rails::Generators::Base
      LAYOUT = "app/views/layouts/application.html.erb"
      STYLESHEET_TAG = %q(<%= stylesheet_link_tag "railsui_tables" %>).freeze

      def add_stylesheet_link
        path = File.join(destination_root, LAYOUT)

        unless File.exist?(path)
          say "#{LAYOUT} not found. Add #{STYLESHEET_TAG} to your layout's <head>.", :yellow
          return
        end

        contents = File.read(path)
        return say "Rails UI Tables stylesheet already linked.", :green if contents.include?(%("railsui_tables"))

        unless contents.match?(%r{</head>})
          say "No </head> found in #{LAYOUT}. Add #{STYLESHEET_TAG} to your layout's <head>.", :yellow
          return
        end

        inject_into_file LAYOUT, "    #{STYLESHEET_TAG}\n", before: %r{^[ \t]*</head>}
      end

      def next_steps
        say "Rails UI Tables #{RailsuiTables::VERSION} installed.", :green
        return say "Register the importmap pin in your Stimulus controller index.", :cyan if File.exist?(File.join(destination_root, "config/importmap.rb"))

        say "Run: yarn add @getrailsui/tables", :cyan
        say 'Then: import { registerRailsuiTables } from "@getrailsui/tables"', :cyan
        say 'Optional Tailwind adapter: @import "@getrailsui/tables/tailwind.css";', :cyan
      end
    end
  end
end
