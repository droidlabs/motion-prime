motion_require './page_view/page_view_delegate'

module MotionPrime
  class PageViewSection < AbstractCollectionSection
    before_render :render_collection

    def collection_styles_base
      :base_page_view
    end

    def collection_delegate
      @collection_delegate ||= PageViewDelegate.new(section: self)
    end

    def grid_element_options
      collection_element_options
    end

    def render_collection
      self.collection_element = screen.page_view_controller(grid_element_options)
    end

    def create_section_elements
      return
    end
  end
end