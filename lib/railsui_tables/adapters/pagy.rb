# frozen_string_literal: true

module RailsuiTables
  module Adapters
    module Pagy
      def railsui_table_pagination(pagy)
        return unless pagy
        return pagy.series_nav if pagy.respond_to?(:series_nav)
        return pagy_nav(pagy) if respond_to?(:pagy_nav)

        raise ArgumentError, "Pagy navigation requires Pagy's frontend helpers to be included"
      end
    end
  end
end
