module MotionPrime
  module CellSectionMixin
    extend ::MotionSupport::Concern

    attr_writer :table
    attr_reader :pending_display

    included do
      class_attribute :custom_cell_name
    end

    def table
      @table ||= options[:table].try(:weak_ref)
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
      self.class.custom_cell_name || begin
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
          screen: screen.try(:weak_ref),
          section: self.weak_ref,
          has_drawn_content: true
        })
        options[:styles] ||= []
        options[:styles] = [:"#{table.name}_first_cell"] if table.data.first == self
        options[:styles] = [:"#{table.name}_last_cell"] if table.data.last == self
        MotionPrime::BaseElement.factory(:table_view_cell, options)
      end
    end

    def load_container_element(options = {})
      init_container_element(options)
      load_elements
      @container_element.compute_options! unless @container_element.computed_options
      if respond_to?(:prerender_elements_for_state) && prerender_enabled?
        prerender_elements_for_state(:normal)
      end
    end

    def pending_display!
      @pending_display = true
      display unless table.decelerating
    end

    def display
      @pending_display = false
      container_view.setNeedsDisplay
    end

    module ClassMethods
      def set_cell_name(value)
        self.custom_cell_name = value
      end
    end
  end
end
