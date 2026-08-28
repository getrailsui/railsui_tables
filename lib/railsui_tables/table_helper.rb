# frozen_string_literal: true

module RailsuiTables
  module TableHelper
    def railsui_table(id:, records:, columns:, query: nil, pagy: nil, frame: true, empty: "No records found.", row_id: nil, row_url: nil, &row_block)
      table_id = id.to_s
      built_columns = columns.map { |column| RailsuiTables::Column.build(column) }
      body = content_tag(:div, class: "railsui-table__scroll") do
        content_tag(:table, class: "railsui-table", data: { railsui_table_target: "table" }) do
          safe_join([
            railsui_table_header(built_columns, query),
            railsui_table_body(records, built_columns, empty, row_id, row_url, row_block)
          ])
        end
      end

      pagination = railsui_table_pagination(pagy) if pagy
      content = content_tag(:section, safe_join([body, pagination].compact), id: table_id, class: "railsui-table-wrap", data: { controller: "railsui-table" })
      frame && respond_to?(:turbo_frame_tag) ? turbo_frame_tag(table_id) { content } : content
    end

    def railsui_table_filter_form(url: request.path, frame: nil, html: {}, &block)
      options = { method: :get, class: "railsui-table-filter", data: { controller: "railsui-table-filter", turbo_frame: frame }.compact }.merge(html)
      form_with(url: url, **options, &block)
    end

    private

    def railsui_table_header(columns, query)
      content_tag(:thead) do
        content_tag(:tr) do
          safe_join(columns.map do |column|
            label = if query && column.sortable && respond_to?(:sort_link)
              sort_link(query, column.key, column.label)
            else
              column.label
            end
            content_tag(:th, label, scope: "col", class: column.header_class)
          end)
        end
      end
    end

    def railsui_table_body(records, columns, empty, row_id, row_url, row_block)
      content_tag(:tbody) do
        if records.empty?
          content_tag(:tr) do
            content_tag(:td, empty, class: "railsui-table__empty", colspan: columns.length)
          end
        else
          safe_join(records.map do |record|
            attributes = { id: row_id&.call(record), data: { railsui_table_target: "row" } }.compact
            content_tag(:tr, attributes) do
              safe_join(columns.map do |column|
                value = row_block ? row_block.call(record, column) : railsui_table_value(record, column)
                value = link_to(value, row_url.call(record), class: "railsui-table__row-link") if row_url && column == columns.first
                content_tag(:td, value, class: column.cell_class, data: { label: column.label })
              end)
            end
          end)
        end
      end
    end

    def railsui_table_value(record, column)
      return column.value.call(record) if column.value

      record.public_send(column.key)
    end
  end
end
