motion_require './table/refresh_mixin'
motion_require './table/table_delegate'

module MotionPrime
  class TableSection < Section
    include TableSectionRefreshMixin
    include HasStyleChainBuilder
    include HasSearchBar

    class_attribute :async_data_options, :section_header_options, :pull_to_refresh_block

    attr_accessor :table_element, :did_appear, :section_headers, :section_header_options
    attr_reader :decelerating
    before_render :render_table
    after_render :init_pull_to_refresh
    delegate :init_pull_to_refresh, to: :table_delegate

    def table_data
      @model || []
    end

    def dealloc
      Prime.logger.dealloc_message :table, self, self.table_view.to_s
      table_delegate.clear_delegated
      table_view.setDataSource nil
      super
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
      @preloader_next_starts_from = nil
      @preloader_cancelled = false
      @data_stamp = nil
      @preloader_queue[-1] = :cancelled if @preloader_queue.present?
    end

    def add_cells(cells)
      prepare_table_cells(cells)
      @data ||= []
      @data += cells
      reload_table_data
    end

    def reload_cell(section)
      section.elements.values.each(&:compute_options!)
      section.cached_draw_image = nil
      # TODO: reset date stamps, reload row
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

    def table_delegate
      @table_delegate ||= TableDelegate.new(section: self)
    end

    def render_table
      options = {
        styles: table_styles.values.flatten,
        delegate: table_delegate,
        data_source: table_delegate,
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
      on_row_render(view, index)
      preload_sections_after(index)
      view
    end

    def render_header(section)
      return unless options = self.section_header_options.try(:[], section)
      self.section_headers[section] ||= BaseHeaderSection.new(options.merge(screen: screen, table: self.weak_ref))
    end

    def header_for_section(section)
      self.section_headers ||= []
      self.section_headers[section] || render_header(section)
    end

    def on_row_render(cell, index); end
    def on_appear; end
    def on_click(table, index); end

    def has_many_sections?
      section_header_options.present? || data.try(:first).is_a?(Array)
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

    def number_of_sections(table = nil)
      has_many_sections? ? data.count : 1
    end

    def cell_for_index(table, index)
      cell = cached_cell(index, table) || render_cell(index, table)

      # run table view is appeared callback if needed
      if !@did_appear && index.row == rows_for_section(index.section).size - 1
        on_appear
      end
      cell.is_a?(UIView) ? cell : cell.view
    end

    def height_for_index(table, index)
      section = load_cell_by_index(index, preload: true)
      section.container_height
    end

    def view_for_header_in_section(table, section)
      return unless header = header_for_section(section)

      reuse_identifier = "header_#{section}"
      cached = table.dequeueReusableHeaderFooterViewWithIdentifier(reuse_identifier)
      return cached if cached.present?

      styles = cell_styles(header).values.flatten
      wrapper = MotionPrime::BaseElement.factory(:table_view_header_footer_view, screen: screen, styles: styles, parent_view: table_view, reuse_identifier: reuse_identifier)
      wrapper.render do |container_view, container_element|
        header.container_element = container_element
        header.render
      end
    end

    def height_for_header_in_section(table, section)
      header_for_section(section).try(:container_height) || 0
    end

    def scroll_view_will_begin_dragging(scroll)
      @decelerating = true
    end

    def scroll_view_did_end_decelerating(scroll)
      @decelerating = false
      display_pending_cells
    end

    def scroll_view_did_scroll(scroll)
    end

    def scroll_view_did_end_dragging(scroll, willDecelerate: will_decelerate)
      display_pending_cells unless @decelerating = will_decelerate
    end

    private
      def display_pending_cells
        table_view.visibleCells.each do |cell_view|
          if cell_view.section && cell_view.section.pending_display
            cell_view.section.display
          end
        end
      end

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
          Prime::Config.prime.cell_section.mixins.each do |mixin|
            cell.class.send(:include, mixin)
          end
          cell.screen ||= screen
          cell.table ||= WeakRef.new(self) if cell.respond_to?(:table=)
        end
      end

      def load_cell_by_index(index, options = {})
        section = rows_for_section(index.section)[index.row]
        if section.load_section && options[:preload] && !section.container_element && async_data? # perform only if just loaded
          section.load_container_element(container_element_options_for(index))
        end
        section
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
        end
        set_data_stamp(keys.flatten)
      end

      def load_sections
        return if async_data?
        if flat_data?
          data.each(&:load_section)
        else
          data.each { |section_data| section_data.each(&:load_section) }
        end
      end


      # Preloads sections after rendering cell in current sheduled index or given index.
      # TODO: probably should be in separate class.
      #
      # @param index [NSIndexPath] Value of first index to load if current sheduled index not exists.
      # @return [NSIndexPath, Boolean] Index of next sheduled index.
      def preload_sections_after(index)
        return if !async_data? || @preloader_next_starts_from == false
        service = preloader_index_service

        load_limit = self.class.async_data_options.try(:[], :preload_rows_count)
        @preloader_next_starts_from ||= index
        index_to_start_preloading = service.sum_index(@preloader_next_starts_from, load_limit ? -load_limit/2 : 0)
        if service.compare_indexes(index, index_to_start_preloading) >= 0
          load_count = preload_sections_schedule_next(@preloader_next_starts_from, load_limit)
          @preloader_next_starts_from = service.sum_index(@preloader_next_starts_from, load_count, false)
        else
          false
        end
      end

      # Schedules preloading sections starting with given index with given limit.
      # TODO: probably should be in separate class.
      #
      # @param index [NSIndexPath] Value of first index to load.
      # @param limit [Integer] Limit of sections to load.
      # @return [Integer] Count of sections scheduled to load.
      def preload_sections_schedule_next(index, limit)
        service = preloader_index_service

        left_to_load = rows_for_section(index.section).count - index.row
        load_count = [left_to_load, limit].compact.min
        @preloader_cancelled = false
        @preloader_queue ||= []
        @strong_refs ||= []

        # TODO: we do we need to keep screen ref too?
        queue_id = @preloader_queue.count
        @strong_refs[queue_id] = [screen.strong_ref, screen.main_controller.strong_ref]
        @preloader_queue[queue_id] = :in_progress
        BW::Reactor.schedule(queue_id) do |queue_id|
          result = load_count.times do |offset|
            if @preloader_queue[queue_id] == :cancelled
              @strong_refs[queue_id] = nil
              break
            end
            if screen.main_controller.retainCount == 1
              @strong_refs[queue_id] = nil
              @preloader_queue[queue_id] = :dealloc
              break
            end

            load_cell_by_index(index, preload: true)
            unless offset == load_count - 1
              index = service.sum_index(index, 1)
            end
          end

          if result
            on_async_data_preloaded(index)
            @preloader_queue[queue_id] = :completed
          end
          @strong_refs[queue_id] = nil
        end
        load_count
      end

      def preloader_index_service
        TableDataIndexes.new(@data)
      end

    class << self
      def inherited(subclass)
        super
        subclass.async_data_options = self.async_data_options.try(:clone)
        subclass.section_header_options = self.section_header_options.try(:clone)
        subclass.pull_to_refresh_block = self.pull_to_refresh_block.try(:clone)
      end

      def async_table_data(options = {})
        self.async_data_options = options
      end

      def group_header(name, options)
        options[:name] = name
        self.section_header_options ||= []
        section = options.delete(:id)
        self.section_header_options[section] = options
      end

      def pull_to_refresh(&block)
        self.pull_to_refresh_block = block
      end
    end
  end
end