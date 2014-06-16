module MotionPrime
  class PageViewControllerElement < BaseElement
    after_render :set_delegated
    def view_class
      "UIPageViewController"
    end

    def set_delegated
      if computed_options.has_key?(:delegate) && computed_options[:delegate].respond_to?(:delegated_by) && section.respond_to?(:page_controller)
        computed_options[:delegate].delegated_by(section.page_controller)
      end
    end
  end
end