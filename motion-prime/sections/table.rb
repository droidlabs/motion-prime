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
      @data_stamp[id.to_i]
    end

    def set_data_stamp(cell_ids)
      @data_stamp ||= []
      cell_ids.each { |id| @data_stamp[id] = Time.now.to_f }
    end

    def reload_data
      @did_appear = false
      @data = nil
      set_data_stamp((0..elements_options.count-1).to_a)
      table_view.reloadData
    end

    def table_styles
      styles = [:base_table, name.to_sym]
      styles += @styles if @styles.present?
      styles
    end

    def render_table
      set_data_stamp((0..elements_options.count-1))

      self.table_view = screen.table_view(
        styles: table_styles, delegate: self, data_source: self
      ).view
    end

    def render_cell(index, table)
      item = data[index.row]

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
        screen.table_view_cell styles: [:base_table_cell] + styles, reuse_identifier: cell_name(table, index) do
          item.render(to: screen)
        end
      end
    end

    def on_click(table, index)
    end

    def on_appear
    end

    def cell_name(table, index)
      record = data[index.row]
      if record && record.model &&
         record.model.respond_to?(:id) && record.model.id.present?
        "cell_#{record.model.id}_#{data_stamp_for(index.row)}"
      else
        "cell_#{index.section}_#{index.row}_#{data_stamp_for(index.row)}"
      end
    end

    def cached_cell(index, table = nil)
      table ||= self.table_view
      table.dequeueReusableCellWithIdentifier(cell_name(table, index))
    end

    # ALIASES
    # ---------------------

    def tableView(table, cellForRowAtIndexPath:index)
      cell = cached_cell(index, table) || render_cell(index, table)

      # run table view is appeared callback if needed
      if index.row == data.size - 1 && !@did_appear
        @did_appear = true
        on_appear
      end

      cell.is_a?(UIView) ? cell : cell.view
    end

    def tableView(table, numberOfRowsInSection:section)
      data.length
    end

    def tableView(table, didSelectRowAtIndexPath:index)
      on_click(table, index)
    end

    def tableView(table, heightForRowAtIndexPath:index)
      data[index.row].container_height
    end
  end
end