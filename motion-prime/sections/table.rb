motion_require './table/refresh_mixin'
module MotionPrime
  class TableSection < BaseSection
    include TableSectionRefreshMixin
    include HasStyleChainBuilder
    include HasSearchBar

    attr_accessor :table_element, :did_appear
    before_render :render_table

    def table_data
      []
    end

    def data
      @data ||= table_data.tap { |cells| set_cells_table(cells) }
    end

    def set_cells_table(cells)
      cells.each { |cell| cell.table = self if cell.respond_to?(:table=) }
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
      type = self.is_a?(FormSection) ? :base_form : :base_table

      base_styles = [type]
      base_styles << :"#{type}_with_sections" unless flat_data?
      item_styles = [name.to_sym]
      item_styles << @styles if @styles.present?
      {common: base_styles, specific: item_styles}
    end

    def cell_styles(cell)
      # type: cell/field/header
      type = cell.respond_to?(:cell_type) ? cell.cell_type : 'cell'

      suffixes = [type]
      if cell.is_a?(BaseFieldSection)
        suffixes << cell.default_name
        suffixes << :"field_#{cell.name}"
      elsif cell.respond_to?(:cell_name)
        suffixes << cell.cell_name
      end

      styles = {
        common: build_styles_chain(table_styles[:common], suffixes),
        specific: build_styles_chain(table_styles[:specific], suffixes)
      }

      if cell.respond_to?(:container_styles) && cell.container_styles.present?
        styles[:specific] += Array.wrap(cell.container_styles)
      end
      styles
    end

    def render_table
      reset_data_stamps
      options = {
        styles: table_styles.values.flatten,
        delegate: self,
        data_source: self,
        style: (UITableViewStyleGrouped unless flat_data?)
      }
      self.table_element = screen.table_view(options)
    end

    def table_view
      table_element.view
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

      # DrawSection allows as to draw inside the cell view, so we can setup
      # to use cell view as container
      if item.is_a?(MotionPrime::DrawSection)
        item.render(to: screen, as: :cell,
          styles: cell_styles(item).values.flatten,
          reuse_identifier: cell_name(table, index)
        )
      else
        screen.table_view_cell section: item, styles: cell_styles(item).values.flatten, reuse_identifier: cell_name(table, index), parent_view: table_view do
          item.render(to: screen)
        end
      end
    end

    def on_click(table, index)
    end

    def on_appear; end
    def on_row_render(cell, index); end

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

    # def tableView(table, viewForFooterInSection: section) # cause bug in ios7.0.0-7.0.2
    #   UIView.new
    # end
    # def tableView(table, heightForFooterInSection: section)
    #   0.1
    # end

    # ALIASES
    # ---------------------

    def tableView(table, cellForRowAtIndexPath:index)
      @rendered_cells ||= []
      @rendered_cells[index.section] ||= []

      cell = cached_cell(index, table) || render_cell(index, table).tap do |cell|
        @rendered_cells[index.section][index.row] = cell
        on_row_render(cell, index)
      end

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