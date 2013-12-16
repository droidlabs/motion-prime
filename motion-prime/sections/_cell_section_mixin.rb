module MotionPrime
  module CellSectionMixin
    attr_writer :table

    def table
      @table ||= options[:table]
    end

    def section_styles
      @section_styles ||= table.try(:cell_styles, self) || {}
    end

    def cell_type
      @cell_type ||= begin
        self.is_a?(BaseFieldSection) ? :field : :cell
      end
    end

    def cell_name
      self.class.cell_name || begin
        return name unless table
        table_name = table.name.gsub('_table', '')
        name.gsub("#{table_name}_", '')
      end
    end

    def container_bounds
      @container_bounds ||= CGRectMake(0, 0, table.table_view.bounds.size.width, container_height)
    end

    def init_container_element(options = {})
      @container_element ||= begin
        options.merge!({
          screen: screen,
          section: self,
          has_drawn_content: true
        })
        MotionPrime::BaseElement.factory(:table_view_cell, options)
      end
    end

    def load_container_element(options = {})
      load_elements
      init_container_element(options)
      @container_element.compute_options! unless @container_element.computed_options
      prerender_elements if respond_to?(:prerender_elements)
    end
  end
end
