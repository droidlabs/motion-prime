# This Mixin will be included only to sections, which added as cell to collection section.
module MotionPrime
  module CellSectionMixin
    extend ::MotionSupport::Concern

    # include SectionWithContainerMixin # already included in draw_section_mixin

    attr_writer :collection_section
    attr_reader :pending_display

    included do
      class_attribute :custom_cell_section_name
      container_element type: :table_view_cell
    end

    def collection_section
      @collection_section ||= options[:collection_section].try(:weak_ref)
    end

    def table
      Prime.logger.info "Section#table is deprecated: #{caller[0]}"
      collection_section
    end

    def section_styles
      @section_styles ||= collection_section.try(:cell_section_styles, self) || {}
    end

    def cell_type
      @cell_type ||= begin
        self.is_a?(BaseFieldSection) ? :field : :cell
      end
    end

    def cell_section_name
      self.class.custom_cell_section_name || begin
        return name unless collection_section
        table_name = collection_section.name.gsub('_table', '')
        name.gsub("#{table_name}_", '')
      end
    end

    def container_bounds
      @container_bounds ||= CGRectMake(0, 0, collection_section.collection_view.bounds.size.width, container_height)
    end

    # should do nothing, because collection section will care about it.
    def render_container(options = {}, &block)
      block.call
    end

    def init_container_element(options = {})
      options[:styles] ||= []
      options[:styles] = [:"#{collection_section.name}_first_cell"] if collection_section.data.first == self
      options[:styles] = [:"#{collection_section.name}_last_cell"] if collection_section.data.last == self
      super(options)
    end

    def pending_display!
      @pending_display = true
      display unless collection_section.decelerating
    end

    def display
      @pending_display = false
      container_view.setNeedsDisplay
    end

    def cell
      container_view || begin
        first_element = elements.values.first
        return unless first_element.is_a?(BaseElement) && first_element.view
        first_element.view.superview.superview
      end
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
