motion_require './table/refresh_mixin'
module MotionPrime
  class TableSection < BaseSection
    include TableSectionRefreshMixin
    include HasSearchBar

    attr_accessor :table_view, :did_appear
    before_render :render_table

    def table_data
      []
    end

    def data
      @data ||= table_data
    end

    def data_stamp_for(id)
      @data_stamp[id]
    end

    def set_data_stamp(cell_ids)
      @data_stamp ||= {}
      [*cell_ids].each { |id| @data_stamp[id] = Time.now.to_f }
    end

    def reset_data_stamps
      keys = data.each_with_index.map do |row, id|
        if row.is_a?(Array)
          section = id
          rows = (0...row.count)
        else
          section = 0
          rows = [id]
        end
        rows.map { |row| "#{section}_#{row}" }
      end.flatten
      set_data_stamp(keys)
    end

    def reload_data
      @did_appear = false
      @data = nil
      reset_data_stamps
      table_view.reloadData
    end

    def table_styles
      styles = [:base_table, name.to_sym]
      styles += @styles if @styles.present?
      styles
    end

    def render_table
      reset_data_stamps
      self.table_view = screen.table_view(
        styles: table_styles, delegate: self, data_source: self, style: (UITableViewStyleGrouped unless flat_data?)
      ).view
    end

    def hide
      table_view.try(:hide)
    end

    def show
      table_view.try(:show)
    end

    def numberOfSectionsInTableView(tableView)
      number_of_sections
    end

    def number_of_sections
      has_many_sections? ? data.count : 1
    end

    def has_many_sections?
      data.any? && data.first.is_a?(Array)
    end

    def row_by_index(index)
      rows_for_section(index.section)[index.row]
    end

    def render_cell(index, table)
      item = row_by_index(index)

      # define default styles for cell
      styles = [:"#{name}_cell"]
      Array.wrap(@styles).each do |table_style|
        styles << :"#{table_style}_cell"
      end
      if item.respond_to?(:container_styles) && item.container_styles.present?
        styles += Array.wrap(item.container_styles)
      end
      if item.respond_to?(:name) && item.name.present?
        styles += [item.name.to_sym]
      end
      # DrawSection allows as to draw inside the cell view, so we can setup
      # to use cell view as container
      if item.is_a?(MotionPrime::DrawSection)
        item.render(to: screen, as: :cell,
          styles: [:base_table_cell] + styles,
          reuse_identifier: cell_name(table, index)
        )
      else
        screen.table_view_cell styles: [:base_table_cell] + styles, reuse_identifier: cell_name(table, index), parent_view: table_view do
          item.render(to: screen)
        end
      end
    end

    def on_click(table, index)
    end

    def on_appear
    end

    def cell_name(table, index)
      record = row_by_index(index)
      if record && record.model &&
         record.model.respond_to?(:id) && record.model.id.present?
        "cell_#{record.model.id}_#{data_stamp_for("#{index.section}_#{index.row}")}"
      else
        "cell_#{index.section}_#{index.row}_#{data_stamp_for("#{index.section}_#{index.row}")}"
      end
    end

    def cached_cell(index, table = nil)
      table ||= self.table_view
      table.dequeueReusableCellWithIdentifier(cell_name(table, index))
    end

    def tableView(table, viewForFooterInSection: section)
      UIView.new
    end

    def tableView(table, heightForFooterInSection: section)
      0.1
    end

    # ALIASES
    # ---------------------

    def tableView(table, cellForRowAtIndexPath:index)
      cell = cached_cell(index, table) || render_cell(index, table)

      # run table view is appeared callback if needed
      if !@did_appear && index.row == rows_for_section(index.section).size - 1
        on_appear
      end
      cell.is_a?(UIView) ? cell : cell.view
    end

    def tableView(table, numberOfRowsInSection:section)
      rows_for_section(section).length
    end

    def tableView(table, didSelectRowAtIndexPath:index)
      on_click(table, index)
    end

    def tableView(table, heightForRowAtIndexPath:index)
      rows_for_section(index.section)[index.row].container_height
    end

    def flat_data?
      number_of_sections == 1
    end

    def rows_for_section(section)
      flat_data? ? data : data[section]
    end
  end
end