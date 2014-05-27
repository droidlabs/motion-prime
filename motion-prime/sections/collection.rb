motion_require './collection/collection_delegate'

module MotionPrime
  class CollectionSection < Section
    include HasStyleChainBuilder

    attr_accessor :collection_element, :did_appear
    attr_reader :decelerating
    before_render :render_collection
    delegate :set_options, :update_options, to: :collection_element, allow_nil: true

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
      Array.wrap(@data).each do |section|
        section.container_element.try(:update_options, reuse_identifier: nil)
      end
      @data = nil
      @data_stamp = nil
      true
    end

    # Get index path for cell section
    #
    # @param section [Prime::Section] cell section.
    # @return index [NSIndexPath] index of cell section.
    def index_for_cell_section(section)
      row = @data.try(:index, section)
      NSIndexPath.indexPathForRow(row, inSection: 0) if row
    end

    def collection_styles_base
      :base_collection
    end

    def collection_styles
      type = collection_styles_base

      base_styles = [type]
      base_styles << :"#{type}_with_sections"
      item_styles = [name.to_sym]
      item_styles += Array.wrap(@styles) if @styles.present?
      {common: base_styles, specific: item_styles}
    end

    def collection_delegate
      @collection_delegate ||= CollectionDelegate.new(section: self)
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
      self.collection_element = screen.collection_view(collection_element_options)
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
      collection_view.registerClass(MPCollectionCellWithSection, forCellWithReuseIdentifier: cell_name(index))
      view = collection_view.dequeueReusableCellWithReuseIdentifier(cell_name(index), forIndexPath: index)
      unless view.section
        section = cell_section_by_index(index)
        view.section = section
        section.render

        on_cell_render(view, index)
      end
      view
    end

    def on_cell_render(cell, index); end
    def on_appear; end
    def on_click(index); end

    def cell_section_by_index(index)
      data[index.row]
    end

    def cell_name(index)
      record = cell_section_by_index(index)
      "cell_#{record.object_id}_#{@data_stamp[record.object_id]}"
    end

    # Table View Delegate
    # ---------------------

    def count_of_cells_in_group
      3
    end

    def number_of_cells_in_group(group)
      if (group + 1) * count_of_cells_in_group >= fixed_collection_data.count
        fixed_collection_data.count % count_of_cells_in_group
      else
        count_of_cells_in_group
      end
    end

    def number_of_groups
      (fixed_collection_data.count.to_f / count_of_cells_in_group).ceil
    end

    def cell_for_index(index)
      cell = render_cell(index)
      # run collection view is appeared callback if needed
      if !@did_appear && index.row == fixed_collection_data.size - 1
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
    end

    def scroll_view_did_end_dragging(scroll, willDecelerate: will_decelerate)
      display_pending_cells unless @decelerating = will_decelerate
    end

    private
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
        Array.wrap(cells).each do |cell|
          # Prime::Config.prime.cell_section.mixins.each do |mixin|
          #   cell.class.send(:include, mixin) unless (class << cell; self; end).included_modules.include?(mixin)
          # end
          cell.screen ||= screen
          cell.collection ||= self.weak_ref if cell.respond_to?(:collection=)
        end
      end

      def container_element_options_for(index)
        cell_section = cell_section_by_index(index)
        {
          reuse_identifier: cell_name(index),
          parent_view: collection_view,
          bounds: {height: cell_section.container_height},
          type: :collection_view_cell
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
        data.each(&:create_elements)
      end

    class << self
      def async_collection_data(options = {})
        self.send :include, Prime::AsyncTableMixin
        self.set_async_data_options options
      end
    end
  end
end