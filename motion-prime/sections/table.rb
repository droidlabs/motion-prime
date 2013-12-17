motion_require './table/refresh_mixin'
module MotionPrime
  class TableSection < BaseSection
    include TableSectionRefreshMixin
    include HasStyleChainBuilder
    include HasSearchBar

    class_attribute :async_data_options
    attr_accessor :table_element, :did_appear
    before_render :render_table

    def table_data
      []
    end

    def async_data?
      self.class.async_data_options
    end

    def data
      @data || set_table_data
    end

    def reload_data
      reset_data
      @async_loaded_data = table_data if async_data?
      reload_table_data
    end

    def reload_table_data
      table_view.reloadData
    end

    def refresh_if_needed
      reload_table_data if @data.nil?
    end

    def reset_data
      @did_appear = false
      @data = nil
      @async_loaded_data = nil
      @next_portion_starts_from = nil
      @preloader_cancelled = false
      @data_stamp = nil
      @queue_states[-1] = :cancelled if @queue_states.present?
    end

    def table_styles
      type = self.is_a?(FormSection) ? :base_form : :base_table

      base_styles = [type]
      base_styles << :"#{type}_with_sections" #unless flat_data?
      item_styles = [name.to_sym]
      item_styles << @styles if @styles.present?
      {common: base_styles, specific: item_styles}
    end

    def cell_styles(cell)
      # type = [`cell`, `header`, `field`]

      # UserFormSection example: field :email, type: :string
      # form_name = `user`
      # type = `field`
      # field_name = `email`
      # field_type = `string_field`

      # CategoriesTableSection example: table is a `CategoryTableSection`, cell is a `CategoryTitleSection`, element :icon, type: :image
      # table_name = `categories`
      # type = `cell` (always true)
      # table_cell_name = `title`
      type = cell.respond_to?(:cell_type) ? cell.cell_type : 'cell'
      suffixes = [type]
      if cell.is_a?(BaseFieldSection)
        suffixes << cell.default_name
      end

      styles = {}
      # table: base_table_<type>
      # form: base_form_<type>, base_form_<field_type>
      styles[:common] = build_styles_chain(table_styles[:common], suffixes)
      if cell.is_a?(BaseFieldSection)
        # form cell: _<type>_<field_name> = `_field_email`
        suffixes << :"#{type}_#{cell.name}" if cell.name
      elsif cell.respond_to?(:cell_name) # cell section came from table
        # table cell: _<table_cell_name> = `_title`
        suffixes << cell.cell_name
      end
      # table: <table_name>_table_<type>, <table_name>_table_<table_cell_name> = `categories_table_cell`, `categories_table_title`
      # form: <form_name>_form_<type>, <form_name>_form_<field_type>, user_form_<type>_email = `user_form_field`, `user_form_string_field`, `user_form_field_email`
      styles[:specific] = build_styles_chain(table_styles[:specific], suffixes)

      container_options_styles = cell.container_options[:styles]
      if container_options_styles.present?
        styles[:specific] += Array.wrap(container_options_styles)
      end

      styles
    end

    def render_table
      options = {
        styles: table_styles.values.flatten,
        delegate: self,
        data_source: self,
        style: (UITableViewStyleGrouped unless flat_data?)
      }
      if async_data? && self.class.async_data_options.has_key?(:estimated_row_height)
        options[:estimated_row_height] = self.class.async_data_options[:estimated_row_height]
      end
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

    def render_cell(index, table)
      section = rows_for_section(index.section)[index.row]
      element = section.container_element || section.init_container_element(container_element_options_for(index))

      view = element.render do
        section.render
      end

      @rendered_cells[index.section][index.row] = view
      on_row_render(view, index)

      preload_sections_for(index)

      view
    end

    def on_row_render(cell, index); end
    def on_appear; end
    def on_click(table, index); end

    def number_of_sections
      has_many_sections? ? data.count : 1
    end

    def has_many_sections?
      data.any? && data.first.is_a?(Array)
    end

    def flat_data?
      !has_many_sections?
    end

    def rows_for_section(section)
      flat_data? ? data : data[section]
    end

    def row_by_index(index)
      rows_for_section(index.section)[index.row]
    end

    def self.async_table_data(options = {})
      self.async_data_options = options
    end

    def on_async_data_loaded; end
    def on_async_data_preloaded(loaded_index); end

    def cell_name(table, index)
      record = row_by_index(index)
      if record && record.model &&
         record.model.respond_to?(:id) && record.model.id.present?
        "cell_#{record.model.id}_#{data_stamp_for("#{index.section}_#{index.row}")}"
      else
        "cell_#{index.section}_#{index.row}_#{data_stamp_for("#{index.section}_#{index.row}")}"
      end
    end

    # Table View Delegate
    # ---------------------

    # def tableView(table, viewForFooterInSection: section) # cause bug in ios7.0.0-7.0.2
    #   UIView.new
    # end
    # def tableView(table, heightForFooterInSection: section)
    #   0.1
    # end

    def numberOfSectionsInTableView(tableView)
      number_of_sections
    end

    def tableView(table, cellForRowAtIndexPath:index)
      @rendered_cells ||= []
      @rendered_cells[index.section] ||= []

      cell = cached_cell(index, table) || render_cell(index, table)

      # run table view is appeared callback if needed
      if !@did_appear && index.row == rows_for_section(index.section).size - 1
        on_appear
      end
      cell.is_a?(UIView) ? cell : cell.view
    end

    def tableView(table, numberOfRowsInSection:section)
      rows_for_section(section).try(:count).to_i
    end

    def tableView(table, heightForRowAtIndexPath: index)
      load_cell_by_index(index, preload: true)
      section = rows_for_section(index.section)[index.row]
      section.container_height
    end

    def tableView(table, didSelectRowAtIndexPath:index)
      on_click(table, index)
    end

    private
      def set_table_data
        cells = async_data? ? load_sections_async : table_data
        prepare_table_cells(cells)
        @data = cells
        reset_data_stamps
        load_sections unless async_data?
        @data
      end

      def load_sections_async
        @async_loaded_data || begin
          BW::Reactor.schedule_on_main do
            @async_loaded_data = table_data
            @data = nil
            reload_table_data
            on_async_data_loaded
          end
          []
        end
      end

      def cached_cell(index, table = nil)
        table ||= self.table_view
        table.dequeueReusableCellWithIdentifier(cell_name(table, index))
      end

      def prepare_table_cells(cell)
        if cell.is_a?(Array)
          cell.each { |c| prepare_table_cells(c) }
        else
          cell.send(:extend, CellSectionMixin)
          cell.screen ||= screen
          cell.table ||= self if cell.respond_to?(:table=)
        end
      end

      def load_cell_by_index(index, options = {})
        section = rows_for_section(index.section)[index.row]
        return unless section.load_section # return if already loaded

        if options[:preload] && !section.container_element && async_data?
          section.load_container_element(container_element_options_for(index))
        end
      end

      def container_element_options_for(index)
        {
          reuse_identifier: cell_name(table_view, index),
          parent_view: table_view
        }
      end

      def data_stamp_for(id)
        @data_stamp[id]
      end

      def set_data_stamp(cell_ids)
        @data_stamp ||= {}
        [*cell_ids].each { |id| @data_stamp[id] = Time.now.to_f }
      end

      def reset_data_stamps
        keys = @data.each_with_index.map do |row, id|
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

      def load_sections
        return if async_data?
        if flat_data?
          data.each(&:load_section)
        else
          data.each { |section_data| section_data.each(&:load_section) }
        end
      end

      def preload_sections_for(index)
        return if !async_data? || @next_portion_starts_from == false
        service = index_service

        load_limit = self.class.async_data_options.try(:[], :preload_rows_count)
        @next_portion_starts_from ||= index
        start_preload_when_index_loaded = service.sum_index(@next_portion_starts_from, load_limit ? -load_limit/2 : 0)
        if service.compare_indexes(index, start_preload_when_index_loaded) >= 0
          section = @next_portion_starts_from.section
          next_row = @next_portion_starts_from.row
          left_to_load = rows_for_section(section).count - next_row

          load_count = [left_to_load, load_limit].compact.min

          next_index = @next_portion_starts_from
          @preloader_cancelled = false

          @queue_states ||= []
          BW::Reactor.schedule(@queue_states.count)  do |queue_id|
            @queue_states[queue_id] = :in_progress

            result = load_count.times do |offset|
              break if @queue_states[queue_id] == :cancelled
              load_cell_by_index(next_index, preload: true)
              next_index = service.sum_index(next_index, 1) unless offset == load_count - 1
            end

            if result
              on_async_data_preloaded(next_index)
              @queue_states[queue_id] = :completed
            end
          end

          @next_portion_starts_from = service.sum_index(@next_portion_starts_from, load_count, false)
        end
      end

      def index_service
        TableDataIndexes.new(@data)
      end
  end
end