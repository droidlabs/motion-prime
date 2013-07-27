module MotionPrime
  class LabelElement < BaseElement
    include MotionPrime::ElementTextHeightMixin

    after_render :size_to_fit

    def size_to_fit
      if computed_options[:size_to_fit] || style_options[:size_to_fit]
        view.sizeToFit
      end
    end
  end
end