motion_require './collection/collection_delegate'
motion_require './table.rb'

module MotionPrime
  class CollectionSection < TableSection
    def table_delegate
      @table_delegate ||= CollectionDelegate.new(section: self)
    end

    def render_table
      self.table_element = screen.collection_view(table_element_options)
    end

    def table_element_options
      container_options.slice(:render_target).merge({
        section: self.weak_ref,
        styles: table_styles.values.flatten,
        delegate: table_delegate,
        data_source: table_delegate
      })
    end

    def table_styles_base
      :base_collection
    end
  end
end