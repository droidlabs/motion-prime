motion_require '../table.rb'
module MotionPrime
  class TableFieldSection < TableSection
    attr_accessor :form, :cell_element

    def initialize(options = {})
      @form = options.delete(:form)
      @container_options = options.delete(:container)
      super
    end

    def render_table
      @styles ||= []
      @styles += [
        :"#{form.name}_table",
        :"#{form.name}_#{name}_table"]
      super
    end

    def cell
      cell_element || begin
        first_element = elements.values.first
        first_element.view.superview
      end
    end

    def table_data
      form.send("#{name}_table_data")
    end

    def container_height
      form.send("#{name}_height")
    end

    def on_click(table, index)
      section = data[index.row]
      form.send("#{name}_selected", section)
    end
  end
end