motion_require './table/refresh_mixin'
motion_require './table/table_delegate'

module MotionPrime
  class TableSection < Section
    include TableSectionRefreshMixin
    include HasStyleChainBuilder
    include HasSearchBar

    class_attribute :group_header_options, :pull_to_refresh_block

    attr_accessor :table_element, :did_appear, :group_header_sections, :group_header_options
    attr_reader :decelerating
    before_render :render_table
    after_render :init_pull_to_refresh
    delegate :init_pull_to_refresh, to: :table_delegate
    delegate :set_options, :update_options, to: :table_element, allow_nil: true

    # Return sections which will be used to render as table cells.
    #
    # This method should be redefined in your table section and must return array.
    # @return [Array<Prime::Section>] array of sections
    def table_data
      @model || []
    end

    # Returns cached version of table data
    #
    # @return [Array<Prime::Section>] cached array of sections
    def data
      @data || set_table_data
    end

    # IMPORTANT: when you use #map in table_data,
    # then #dealloc of Prime::Section will not be called to section created on that #map.
    # We did not find yet why this happening, for now just using hack.
    def fixed_table_data
      table_data.to_enum.to_a
    end

    def dealloc
      Prime.logger.dealloc_message :table, self, self.table_element.try(:view).to_s
      table_delegate.clear_delegated
      table_view.setDataSource nil
      super
    end

    # Reset all table data and reload table view
    #
    # @return [Boolean] true
    def reload_data
      reset_table_data
      reload_table_data
    end

    # Alias for reload_data
    #
    # @return [Boolean] true
    def reload
      reload_data
    end

    # Reload table view data
    #
    # @return [Boolean] true
    def reload_table_data
      table_view.reloadData
      true
    end

    # Reload table view if data was empty before.
    #
    # @return [Boolean] true if reload was happened
    def refresh_if_needed
      @data.nil? ? reload_table_data : false
    end

    # Reset all table data.
    #
    # @return [Boolean] true
    def reset_table_data
      @did_appear = false
      @data = nil
      @data_stamp = nil
      @reusable_cells.each do |object_id, cell|
        cell.reuseIdentifier = nil
      end if @reusable_cells
      @reusable_cells = nil
      true
    end

    # Add cells to table view and reload table view.
    #
    # @param cell sections [Prime::Section, Array<Prime::Section>] cells which will be added to table view.
    # @return [Boolean] true
    def add_cell_sections(sections)
      prepare_table_cell_sections(sections)
      @data ||= []
      @data += sections
      reload_table_data
    end

    # Delete cells from table data and remove them from table view with animation.
    #
    # @param cell sections [Prime::Section, Array<Prime::Section>] cells which will be removed from table view.
    # @return [Array<NSIndexPath>] index paths of removed cells.
    def delete_cell_sections(sections, &block)
      paths = []
      Array.wrap(sections).each do |section|
        index = index_for_cell_section(section)
        next Prime.logger.debug("Delete cell section: `#{section.name}` is not in the list") unless index
        paths << index
        delete_from_data(index)
      end
      if paths.any?
        UIView.animate(duration: 0, after: block) do
          table_view.beginUpdates
          table_view.deleteRowsAtIndexPaths(paths, withRowAnimation: UITableViewRowAnimationLeft)
          table_view.endUpdates
        end
      end
      paths
    end

    # Reloads cells with animation, executes given block before reloading.
    #
    # @param cell sections [Prime::Section, Array<Prime::Section>] cells which will be updated.
    # @param around callback [Proc] Callback which will be executed before reloading.
    # @return [Array<NSIndexPath>] index paths of reloaded cells.
    def reload_cell_sections(sections, &block)
      paths = []
      Array.wrap(sections).each_with_index do |section, counter|
        index = index_for_cell_section(section)
        next Prime.logger.debug("Reload section: `#{section.name}` is not in the list") unless index
        paths << index
        block.call(section, index, counter)
        set_data_stamp(section.object_id)
        section.reload
      end
      table_view.reloadRowsAtIndexPaths(paths, withRowAnimation: UITableViewRowAnimationFade)
      paths
    end

    # Changes height of cells with animation.
    #
    # @param cell sections [Prime::Section, Array<Prime::Section>] cells which will be updated.
    # @param height [Integer, Array<Integer>] new height of all cells, or height for each cell.
    # @return [Array<NSIndexPath>] index paths of removed cells.
    def resize_cell_sections(sections, height)
      reload_cell_sections(sections) do |section, index, counter|
        container_height = height.is_a?(Array) ? height[counter] : height
        section.container_options[:height] = container_height
      end
    end

    # Delete section from data at index
    #
    # @param index [NSIndexPath] index of cell which will be removed from table data.
    def delete_from_data(index)
      if flat_data?
        delete_from_flat_data(index)
      else
        delete_from_grouped_data(index)
      end
    end

    # Get index path for cell section
    #
    # @param section [Prime::Section] cell section.
    # @return index [NSIndexPath] index of cell section.
    def index_for_cell_section(section)
      if flat_data?
        row = @data.try(:index, section)
        NSIndexPath.indexPathForRow(row, inSection: 0) if row
      else
        (@data || []).each_with_index do |cell_sections, group|
          row = cell_sections.index(section)
          return NSIndexPath.indexPathForRow(row, inSection: group) if row
        end
      end
    end

    def table_styles
      type = self.is_a?(FormSection) ? :base_form : :base_table

      base_styles = [type]
      base_styles << :"#{type}_with_sections" unless flat_data?
      item_styles = [name.to_sym]
      item_styles += Array.wrap(@styles) if @styles.present?
      {common: base_styles, specific: item_styles}
    end

    def cell_section_styles(section)
      # type = [`cell`, `header`, `field`]

      # UserFormSection example: field :email, type: :string
      # form_name = `user`
      # type = `field`
      # field_name = `email`
      # field_type = `string_field`

      # CategoriesTableSection example: table is a `CategoryTableSection`, cell is a `CategoryTitleSection`, element :icon, type: :image
      # table_name = `categories`
      # type = `cell` (always true)
      # table_cell_section_name = `title`
      type = section.respond_to?(:cell_type) ? section.cell_type : 'cell'
      suffixes = [type]
      if section.is_a?(BaseFieldSection)
        suffixes << section.default_name
      end

      styles = {}
      # table: base_table_<type>
      # form: base_form_<type>, base_form_<field_type>
      styles[:common] = build_styles_chain(table_styles[:common], suffixes)
      if section.is_a?(BaseFieldSection)
        # form cell: _<type>_<field_name> = `_field_email`
        suffixes << :"#{type}_#{section.name}" if section.name
      elsif section.respond_to?(:cell_section_name) # cell section came from table
        # table cell: _<table_cell_section_name> = `_title`
        suffixes << section.cell_section_name
      end
      # table: <table_name>_table_<type>, <table_name>_table_<table_cell_section_name> = `categories_table_cell`, `categories_table_title`
      # form: <form_name>_form_<type>, <form_name>_form_<field_type>, user_form_<type>_email = `user_form_field`, `user_form_string_field`, `user_form_field_email`
      styles[:specific] = build_styles_chain(table_styles[:specific], suffixes)

      container_options_styles = section.container_options[:styles]
      if container_options_styles.present?
        styles[:specific] += Array.wrap(container_options_styles)
      end

      styles
    end

    def table_delegate
      @table_delegate ||= TableDelegate.new(section: self)
    end

    def table_element_options
      container_options.slice(:render_target).merge({
        section: self.weak_ref,
        styles: table_styles.values.flatten,
        delegate: table_delegate,
        data_source: table_delegate,
        style: (UITableViewStyleGrouped unless flat_data?)
      })
    end

    def render_table
      self.table_element = screen.table_view(table_element_options)
    end

    def table_view
      table_element.try(:view)
    end

    def hide
      table_view.try(:hide)
    end

    def show
      table_view.try(:show)
    end

    def render_cell(index, table = nil)
      table ||= table_view
      section = cell_sections_for_group(index.section)[index.row]
      element = section.container_element || section.init_container_element(container_element_options_for(index))

      view = element.render do
        section.render
      end

      @reusable_cells ||= {}
      @reusable_cells[section.object_id] = view
      on_cell_render(view, index)
      view
    end

    def render_header(group)
      return unless options = self.group_header_options.try(:[], group)
      self.group_header_sections[group] ||= FormHeaderSection.new(options.merge(screen: screen, table: self.weak_ref))
    end

    def header_section_for_group(group)
      self.group_header_sections ||= []
      self.group_header_sections[group] || render_header(group)
    end

    def on_cell_render(cell, index); end
    def on_appear; end
    def on_click(table, index); end

    def has_many_sections?
      group_header_options.present? || data.try(:first).is_a?(Array)
    end

    def flat_data?
      !has_many_sections?
    end

    def cell_sections_for_group(section)
      flat_data? ? data : data[section]
    end

    def cell_section_by_index(index)
      cell_sections_for_group(index.section)[index.row]
    end

    def cell_name(table, index)
      record = cell_section_by_index(index)
      "cell_#{record.object_id}_#{@data_stamp[record.object_id]}"
    end

    # Table View Delegate
    # ---------------------

    def number_of_groups(table = nil)
      has_many_sections? ? data.count : 1
    end

    def cell_for_index(table, index)
      cell = cached_cell(index, table) || render_cell(index, table)
      # run table view is appeared callback if needed
      if !@did_appear && index.row == cell_sections_for_group(index.section).size - 1
        on_appear
      end
      cell.is_a?(UIView) ? cell : cell.view
    end

    def height_for_index(table, index)
      section = cell_section_by_index(index)
      section.create_elements
      section.container_height
    end

    def header_cell_in_group(table, group)
      return unless header = header_section_for_group(group)

      reuse_identifier = "header_#{group}_#{@header_stamp}"
      cached = table.dequeueReusableHeaderFooterViewWithIdentifier(reuse_identifier)
      return cached if cached.present?

      styles = cell_section_styles(header).values.flatten
      wrapper = MotionPrime::BaseElement.factory(:table_header,
        screen: screen,
        styles: styles,
        parent_view: table_view,
        reuse_identifier: reuse_identifier,
        section: header
      )
      wrapper.render do |container_view, container_element|
        header.container_element = container_element
        header.render
      end
    end

    def height_for_header_in_group(table, group)
      header_section_for_group(group).try(:container_height) || 0
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
      def delete_from_flat_data(index)
        @data[index.row] = nil
        @data.delete_at(index.row)
      end

      def delete_from_grouped_data(index)
        @data[index.section][index.row] = nil
        @data[index.section].delete_at(index.row)
      end

      def display_pending_cells
        table_view.visibleCells.each do |cell_view|
          if cell_view.section && cell_view.section.pending_display
            cell_view.section.display
          end
        end
      end

      def set_table_data
        sections = fixed_table_data
        prepare_table_cell_sections(sections)
        @data = sections
        reset_data_stamps
        create_section_elements
        @data
      end

      def cached_cell(index, table = nil)
        table ||= self.table_view
        table.dequeueReusableCellWithIdentifier(cell_name(table, index))
      end

      def prepare_table_cell_sections(cells)
        Array.wrap(cells.flatten).each do |cell|
          Prime::Config.prime.cell_section.mixins.each do |mixin|
            cell.class.send(:include, mixin)
          end
          cell.screen ||= screen
          cell.table ||= self.weak_ref if cell.respond_to?(:table=)
        end
      end

      def container_element_options_for(index)
        cell_section = cell_section_by_index(index)
        {
          reuse_identifier: cell_name(table_view, index),
          parent_view: table_view,
          bounds: {height: cell_section.container_height}
        }
      end

      def set_data_stamp(section_ids)
        @data_stamp ||= {}
        [*section_ids].each do |id|
          @data_stamp[id] = Time.now.to_f
        end
      end

      def set_header_stamp
        @header_stamp = Time.now.to_i
      end

      def reset_data_stamps
        keys = data.flatten.map(&:object_id)
        set_data_stamp(keys)
        set_header_stamp
      end

      def create_section_elements
        if flat_data?
          data.each(&:create_elements)
        else
          data.each { |group_sections| group_sections.each(&:create_elements) }
        end
      end

    class << self
      def inherited(subclass)
        super
        subclass.group_header_options = self.group_header_options.try(:clone)
      end

      def async_table_data(options = {})
        self.send :include, Prime::AsyncTableMixin
        self.set_async_data_options options
      end

      def group_header(name, options)
        options[:name] = name
        self.group_header_options ||= []
        section = options.delete(:id)
        self.group_header_options[section] = options
      end

      def pull_to_refresh(&block)
        self.pull_to_refresh_block = block
      end
    end
  end
end