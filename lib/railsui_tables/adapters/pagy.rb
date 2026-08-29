# frozen_string_literal: true

module RailsuiTables
  module Adapters
    module Pagy
      def railsui_table_pagination(pagy)
        return unless pagy
        return if pagy.respond_to?(:pages) && pagy.pages.to_i <= 1
        return pagy.series_nav.html_safe if pagy.respond_to?(:series_nav)
        return pagy_nav(pagy) if respond_to?(:pagy_nav)

        raise ArgumentError, "Pagy navigation requires Pagy's frontend helpers to be included"
      end
    end
  end
end
