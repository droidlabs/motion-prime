module MotionPrime
  class ErrorMessageElement < BaseElement
    include MotionPrime::ElementTextDimensionsMixin

    after_render :size_to_fit

    def view_class
      "UILabel"
    end

    def size_to_fit
      view.size.height = self.content_height
    end

    def computed_inner_top
      computed_options[:top].to_i
    end

    def computed_inner_bottom
      computed_options[:bottom].to_i
    end
  end
end