# frozen_string_literal: true

module RailsuiTables
  class Configuration
    attr_accessor :default_per_page

    def initialize
      @default_per_page = 25
    end
  end
end
