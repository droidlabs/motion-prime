# This Mixin will be included only to sections, which added as cell to table section.
module MotionPrime
  module CellSectionMixin
    extend ::MotionSupport::Concern

    include SectionWithContainerMixin

    attr_writer :table
    attr_reader :pending_display

    included do
      class_attribute :custom_cell_section_name
      container_element type: :table_view_cell
    end

    def table
      @table ||= options[:table].try(:weak_ref)
    end

    def section_styles
      @section_styles ||= table.try(:cell_section_styles, self) || {}
    end

    def cell_type
      @cell_type ||= begin
        self.is_a?(BaseFieldSection) ? :field : :cell
      end
    end

    def cell_section_name
      self.class.custom_cell_section_name || begin
        return name unless table
        table_name = table.name.gsub('_table', '')
        name.gsub("#{table_name}_", '')
      end
    end

    def container_bounds
      @container_bounds ||= CGRectMake(0, 0, table.table_view.bounds.size.width, container_height)
    end

    # should do nothing, because table section will care about it.
    def render_container(options = {}, &block)
      block.call
    end

    def init_container_element(options = {})
      options[:styles] ||= []
      options[:styles] = [:"#{table.name}_first_cell"] if table.data.first == self
      options[:styles] = [:"#{table.name}_last_cell"] if table.data.last == self
      super(options)
    end

    def pending_display!
      @pending_display = true
      display unless table.decelerating
    end

    def display
      @pending_display = false
      container_view.setNeedsDisplay
    end

    def dealloc
      # TODO: remove this when solve this problem: dealloc TableCells on TableView.reloadData (in case when reuseIdentifier has been used)
      container_view.section = nil if container_view.respond_to?(:setSection)
      super
    end

    module ClassMethods
      def set_cell_section_name(value)
        self.custom_cell_section_name = value
      end
    end
  end
end
