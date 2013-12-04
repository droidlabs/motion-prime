module MotionPrime
  module CellSectionMixin
    attr_writer :table

    def table
      @table ||= options[:table]
    end

    def section_styles
      table.try(:cell_styles, self) || {}
    end

    def cell_type
      @cell_type ||= begin
        self.is_a?(BaseFieldSection) ? :field : :cell
      end
    end

    def cell_name
      return name unless table
      table_name = table.name.gsub('_table', '')
      name.gsub("#{table_name}_", '')
    end
  end
end
