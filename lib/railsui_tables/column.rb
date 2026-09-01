# frozen_string_literal: true

module RailsuiTables
  Column = Struct.new(:key, :label, :sortable, :value, :partial, :cell_class, :header_class, keyword_init: true) do
    def self.build(definition)
      return definition if definition.is_a?(self)

      definition = { key: definition } if definition.is_a?(Symbol) || definition.is_a?(String)
      definition = definition.transform_keys(&:to_sym)
      key = definition.fetch(:key).to_sym

      new(
        key: key,
        label: definition.fetch(:label, key.to_s.humanize),
        sortable: definition.fetch(:sortable, false),
        value: definition[:value],
        partial: definition[:partial],
        cell_class: definition[:cell_class],
        header_class: definition[:header_class]
      )
    end
  end
end
