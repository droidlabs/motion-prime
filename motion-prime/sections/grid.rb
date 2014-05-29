motion_require './collection/collection_delegate'

module MotionPrime
  class GridSection < AbstractCollectionSection
    DEFAULT_GRID_SIZE = 3

    class_attribute :grid_size_value

    before_render :render_collection

    # Get index path for cell section
    #
    # @param section [Prime::Section] cell section.
    # @return index [NSIndexPath] index of cell section.
    def index_for_cell_section(section)
      return unless item = @data.try(:index, section)
      group = item/grid_size
      row = cell_sections_for_group(group).index(section)
      NSIndexPath.indexPathForRow(row, inSection: group)
    end

    def collection_styles_base
      :base_collection
    end

    def collection_delegate
      @collection_delegate ||= CollectionDelegate.new(section: self)
    end

    def grid_element_options
      collection_element_options.merge({
        grid_size: grid_size
      })
    end

    def render_collection
      self.collection_element = screen.collection_view(grid_element_options)
    end

    def render_cell(index)
      collection_view.registerClass(MPCollectionCellWithSection, forCellWithReuseIdentifier: cell_name(index))
      view = collection_view.dequeueReusableCellWithReuseIdentifier(cell_name(index), forIndexPath: index)

      section = cell_section_by_index(index)
      element = section.container_element || section.init_container_element(container_element_options_for(index))
      unless view.section
        element.view = view
        screen.set_options_for view, element.computed_options.except(:parent_view) do
          section.render
        end

        on_cell_render(view, index)
      end
      view
    end

    def cell_sections_for_group(section)
      data[section, grid_size]
    end

    # Table View Delegate
    # ---------------------

    def grid_size
      self.class.grid_size || DEFAULT_GRID_SIZE
    end

    def number_of_cells_in_group(group)
      cell_sections_for_group(group).count.to_i
    end

    def number_of_groups
      (data.count.to_f / grid_size).ceil
    end

    private
      def container_element_options_for(index)
        super.merge({
          type: :collection_view_cell,
          view_class: 'MPCollectionCellWithSection'
        })
      end

    def self.grid_size(value = nil)
      if value
        self.grid_size_value = value
      else
        self.grid_size_value
      end
    end
  end
end