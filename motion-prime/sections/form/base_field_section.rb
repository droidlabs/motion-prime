module MotionPrime
  class BaseFieldSection < BaseSection
    attr_accessor :form

    def initialize(options = {})
      super
      @form = WeakRef.new(options.delete(:form))
      @container_options = options.delete(:container)
    end

    def form_name
      form.name
    end

    def container_options
      @container_options || super
    end

    def scroll_to_and_make_visible
      first_element = elements.first.last
      path = form.table.indexPathForCell first_element.view.superview
      form.table.scrollToRowAtIndexPath path,
        atScrollPosition: UITableViewScrollPositionTop, animated: true
    end
  end
end