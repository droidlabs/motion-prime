module MotionPrime
  class LabelElement < BaseElement
    include MotionPrime::ElementTextHeightMixin

    after_render :size_to_fit

    def size_to_fit
      if computed_options[:size_to_fit] || style_options[:size_to_fit]
        view.sizeToFit
      end
    end

    def computed_inner_top
      computed_options[:top].to_i
    end

    def computed_inner_bottom
      computed_options[:bottom].to_i
    end
  end
end