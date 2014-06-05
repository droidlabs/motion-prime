motion_require 'base_section'
module MotionPrime
  class AbstractCollectionSection < Section
    include HasStyleChainBuilder

    attr_accessor :collection_element, :did_appear
    attr_reader :decelerating

    before_render :render_collection

    delegate :set_options, :update_options, to: :collection_element, allow_nil: true

    %w[table_data
      fixed_table_data
      table_view
      reset_table_data
      async_table_data
      reload_table_data
      table_delegate
      table_styles
      table_styles_base
      prepare_table_cell_sections
      table_element_options
      render_table].each do |table_method|
      define_method table_method do |*args|
        Prime.logger.info "##{table_method} is deprecated: #{caller[0]}"
        send(table_method.gsub('table', 'collection'), *args)
      end
    end

    # Return sections which will be used to render as collection cells.
    #
    # This method should be redefined in your collection section and must return array.
    # @return [Array<Prime::Section>] array of sections
    def collection_data
      @model || []
    end

    # Returns cached version of collection data
    #
    # @return [Array<Prime::Section>] cached array of sections
    def data
      @data || set_collection_data
    end

    # IMPORTANT: when you use #map in collection_data,
    # then #dealloc of Prime::Section will not be called to section created on that #map.
    # We did not find yet why this happening, for now just using hack.
    def fixed_collection_data
      collection_data.to_enum.to_a
    end

    def dealloc
      Prime.logger.dealloc_message :collection, self, self.collection_element.try(:view).to_s
      collection_delegate.clear_delegated
      collection_view.setDataSource nil
      super
    end

    # Reset all collection data and reload collection view
    #
    # @return [Boolean] true
    def reload_data
      reset_collection_data
      reload_collection_data
    end

    # Alias for reload_data
    #
    # @return [Boolean] true
    def reload
      reload_data
    end

    # Reload collection view data
    #
    # @return [Boolean] true
    def reload_collection_data
      collection_view.reloadData
      true
    end

    # Reload collection view if data was empty before.
    #
    # @return [Boolean] true if reload was happened
    def refresh_if_needed
      @data.nil? ? reload_collection_data : false
    end

    # Reset all collection data.
    #
    # @return [Boolean] true
    def reset_collection_data
      @did_appear = false
      Array.wrap(@data).flatten.each do |section|
        section.container_element.try(:update_options, reuse_identifier: nil)
      end
      @data = nil
      @data_stamp = nil
      true
    end

    def collection_styles_base
      raise "Implement #collection_styles_base"
    end

    def collection_styles
      type = collection_styles_base

      base_styles = Array.wrap(type)
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
      styles[:common] = build_styles_chain(collection_styles[:common], suffixes)
      if section.is_a?(BaseFieldSection)
        # form cell: _<type>_<field_name> = `_field_email`
        suffixes << :"#{type}_#{section.name}" if section.name
      elsif section.respond_to?(:cell_section_name) # cell section came from table
        # table cell: _<table_cell_section_name> = `_title`
        suffixes << section.cell_section_name
      end
      # table: <table_name>_table_<type>, <table_name>_table_<table_cell_section_name> = `categories_table_cell`, `categories_table_title`
      # form: <form_name>_form_<type>, <form_name>_form_<field_type>, user_form_<type>_email = `user_form_field`, `user_form_string_field`, `user_form_field_email`
      styles[:specific] = build_styles_chain(collection_styles[:specific], suffixes)

      container_options_styles = section.container_options[:styles]
      if container_options_styles.present?
        styles[:specific] += Array.wrap(container_options_styles)
      end

      styles
    end

    def collection_element_options
      container_options.slice(:render_target).merge({
        section: self.weak_ref,
        styles: collection_styles.values.flatten,
        delegate: collection_delegate,
        data_source: collection_delegate
      })
    end

    def render_collection
      raise "Implement #render_collection"
    end

    def collection_view
      collection_element.try(:view)
    end

    def hide
      collection_view.try(:hide)
    end

    def show
      collection_view.try(:show)
    end

    def render_cell(index)
      raise "Implement #render_cell"
    end

    def on_cell_render(cell, index); end
    def on_appear; end
    def on_click(index); end

    def cell_name(index)
      record = cell_section_by_index(index)
      "cell_#{record.object_id}_#{@data_stamp[record.object_id]}"
    end

    def cell_sections_for_group(section)
      raise "Implement #cell_sections_for_group"
    end

    def cell_section_by_index(index)
      cell_sections_for_group(index.section)[index.row]
    end

    def cell_for_index(index)
      cell = cached_cell(index) || render_cell(index)
      # run table view is appeared callback if needed
      if !@did_appear && index.row == cell_sections_for_group(index.section).size - 1
        on_appear
      end
      cell.is_a?(UIView) ? cell : cell.view
    end

    def height_for_index(index)
      section = cell_section_by_index(index)
      section.create_elements
      section.container_height
    end

    def scroll_view_will_begin_dragging(scroll)
      @decelerating = true
    end

    def scroll_view_did_end_decelerating(scroll)
      @decelerating = false
      display_pending_cells
    end

    def scroll_view_did_scroll(scroll)
      return unless refresh_view = collection_view.try(:pullToRefreshView)
      return refresh_view.alpha = 1 if refresh_view.state == SVPullToRefreshStateLoading

      current_offset = scroll.contentOffset.y
      table_inset = collection_view.contentInset.top
      refresh_offset = refresh_view.yOrigin
      alpha = [[-(current_offset + table_inset)/refresh_view.size.height, 0].max, 1].min

      refresh_view.alpha = alpha
    end

    def scroll_view_did_end_dragging(scroll, willDecelerate: will_decelerate)
      display_pending_cells unless @decelerating = will_decelerate
    end

    private
      def cached_cell(index)
      end

      def display_pending_cells
        collection_view.visibleCells.each do |cell_view|
          if cell_view.section && cell_view.section.pending_display
            cell_view.section.display
          end
        end
      end

      def set_collection_data
        sections = fixed_collection_data
        prepare_collection_cell_sections(sections)
        @data = sections
        reset_data_stamps
        create_section_elements
        @data
      end

      def prepare_collection_cell_sections(cells)
        Array.wrap(cells.flatten).each do |cell|
          Prime::Config.prime.cell_section.mixins.each do |mixin|
            cell.class.send(:include, mixin) unless (class << cell; self; end).included_modules.include?(mixin)
          end
          cell.screen ||= screen
          cell.collection_section ||= self.weak_ref if cell.respond_to?(:collection_section=)
        end
      end

      def container_element_options_for(index)
        cell_section = cell_section_by_index(index)
        {
          reuse_identifier: cell_name(index),
          parent_view: collection_view,
          bounds: {height: cell_section.container_height}
        }
      end

      def set_data_stamp(section_ids)
        @data_stamp ||= {}
        [*section_ids].each do |id|
          @data_stamp[id] = Time.now.to_f
        end
      end

      def reset_data_stamps
        keys = data.map(&:object_id)
        set_data_stamp(keys)
      end

      def create_section_elements
        data.flatten.each(&:create_elements)
      end
  end
end
