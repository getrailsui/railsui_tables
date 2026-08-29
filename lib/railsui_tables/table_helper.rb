# frozen_string_literal: true

module RailsuiTables
  module TableHelper
    def railsui_table(id:, records:, columns:, query: nil, pagy: nil, frame: true, empty: "No records found.", row_id: nil, row_url: nil, expandable: nil, &row_block)
      table_id = id.to_s
      built_columns = columns.map { |column| RailsuiTables::Column.build(column) }
      expandable_options = railsui_table_expandable_options(expandable)
      built_columns.unshift(railsui_table_expandable_column) if expandable_options
      body = content_tag(:div, class: "railsui-table__viewport") do
        content_tag(:div, class: "railsui-table__scroll") do
          content_tag(:table, class: "railsui-table", data: { railsui_table_target: "table" }) do
            safe_join([
              railsui_table_header(built_columns, query),
              railsui_table_body(records, built_columns, empty, row_id, row_url, expandable_options, table_id, row_block)
            ])
          end
        end
      end

      pagination = railsui_table_pagination(pagy) if pagy
      content_id = frame ? "#{table_id}_table" : table_id
      content = content_tag(:section, safe_join([body, pagination].compact), id: content_id, class: "railsui-table-wrap", data: { controller: "railsui-table" })
      frame && respond_to?(:turbo_frame_tag) ? turbo_frame_tag(table_id, data: { turbo_action: "advance" }) { content } : content
    end

    def railsui_table_filter_form(url: request.path, frame: nil, preserve: {}, html: {}, &block)
      options = { method: :get, class: "railsui-table-filter", data: { controller: "railsui-table-filter", turbo_frame: frame, turbo_action: ("advance" if frame) }.compact }.merge(html)
      form_with(url: url, **options) do |form|
        safe_join([railsui_table_hidden_fields(preserve), capture(form, &block)])
      end
    end

    private

    def railsui_table_header(columns, query)
      content_tag(:thead) do
        content_tag(:tr) do
          safe_join(columns.map do |column|
            sortable = query && column.sortable && respond_to?(:sort_link)
            label = sortable ? sort_link(query, column.key, column.label) : column.label
            direction = railsui_table_sort_direction(query, column.key) if sortable
            classes = [column.header_class]
            classes << "railsui-table__th--sortable" if sortable
            classes << "railsui-table__th--sorted-#{direction}" if direction
            content_tag(:th, label, scope: "col", class: classes.compact.presence&.join(" "), aria: { sort: railsui_table_aria_sort(direction) }.compact.presence)
          end)
        end
      end
    end

    def railsui_table_body(records, columns, empty, row_id, row_url, expandable, table_id, row_block)
      content_tag(:tbody, data: ({ controller: "railsui-table-expandable" } if expandable)) do
        if records.empty?
          content_tag(:tr) do
            content_tag(:td, empty, class: "railsui-table__empty", colspan: columns.length)
          end
        else
          safe_join(records.each_with_index.map do |record, index|
            attributes = { id: row_id&.call(record), data: { railsui_table_target: "row" } }.compact
            row_key = railsui_table_row_key(record, table_id, row_id, index)
            row_link_column = columns.find { |column| !column.key.to_s.start_with?("_railsui_table_") } || columns.first
            main_row = content_tag(:tr, attributes) do
              safe_join(columns.map do |column|
                value = if column.key == :_railsui_table_expand
                  railsui_table_expand_button(row_key, expandable)
                else
                  row_block ? row_block.call(record, column) : railsui_table_value(record, column)
                end
                value = link_to(value, row_url.call(record), class: "railsui-table__row-link") if row_url && column == row_link_column
                content_tag(:td, value, class: column.cell_class, data: { label: railsui_table_cell_label(column) })
              end)
            end
            expandable ? safe_join([main_row, railsui_table_detail_row(record, row_key, expandable, columns.length)]) : main_row
          end)
        end
      end
    end

    def railsui_table_expandable_options(expandable)
      return nil if expandable.blank?
      return expandable.transform_keys(&:to_sym) if expandable.respond_to?(:to_h)

      raise ArgumentError, "expandable must be a Hash with a callable or URL :url"
    end

    def railsui_table_expandable_column
      RailsuiTables::Column.new(key: :_railsui_table_expand, label: "", header_class: "railsui-table__expander-header", cell_class: "railsui-table__expander")
    end

    def railsui_table_row_key(record, table_id, row_id, index)
      key = row_id&.call(record)
      key = dom_id(record) if key.blank? && respond_to?(:dom_id) && record.respond_to?(:to_key)
      key = "#{table_id}_#{record.id}" if key.blank? && record.respond_to?(:id) && record.id
      key = "#{table_id}_row_#{index}" if key.blank?
      key.to_s
    end

    def railsui_table_expand_button(row_key, options)
      label = options.fetch(:label, "Show details")
      content_tag(:button, type: "button", class: "railsui-table__expand", aria: { expanded: "false", controls: "#{row_key}_details" }, data: { action: "click->railsui-table-expandable#toggle", detail_id: "#{row_key}_details" }) do
        content_tag(:span, label, class: "railsui-table__sr-only")
      end
    end

    def railsui_table_detail_row(record, row_key, options, colspan)
      url = options.fetch(:url)
      url = url.call(record) if url.respond_to?(:call)
      content_tag(:tr, id: "#{row_key}_details", hidden: true, class: "railsui-table__detail-row") do
        content_tag(:td, colspan: colspan) do
          content_tag("turbo-frame", nil, id: "#{row_key}_details_frame", data: { src: url })
        end
      end
    end

    def railsui_table_value(record, column)
      return column.value.call(record) if column.value

      record.public_send(column.key)
    end

    # Only expose a responsive stacked-card label for plain-text column labels.
    # Rich labels (e.g. a Pro select-all checkbox) are html_safe and would leak
    # escaped markup into the data-label attribute, so they opt out.
    def railsui_table_cell_label(column)
      label = column.label
      return nil if label.blank? || (label.respond_to?(:html_safe?) && label.html_safe?)

      label
    end

    def railsui_table_sort_direction(query, key)
      return nil unless query.respond_to?(:sorts)

      sort = query.sorts.find { |node| node.respond_to?(:name) && node.name.to_s == key.to_s }
      sort&.dir
    end

    def railsui_table_aria_sort(direction)
      case direction.to_s
      when "asc" then "ascending"
      when "desc" then "descending"
      end
    end

    def railsui_table_hidden_fields(fields, prefix = nil)
      tags = railsui_table_hash(fields).flat_map do |key, value|
        name = prefix ? "#{prefix}[#{key}]" : key.to_s

        case value
        when Hash
          railsui_table_hidden_fields(value, name)
        when Array
          value.map { |item| hidden_field_tag("#{name}[]", item, id: nil) }
        else
          if value.respond_to?(:to_unsafe_h)
            railsui_table_hidden_fields(value.to_unsafe_h, name)
          else
            hidden_field_tag(name, value, id: nil)
          end
        end
      end

      safe_join(tags)
    end

    def railsui_table_hash(value)
      value.respond_to?(:to_unsafe_h) ? value.to_unsafe_h : value.to_h
    end
  end
end
