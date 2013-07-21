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

    def cell
      first_element = elements.values.first
      first_element.view.superview
    end

    def focus(begin_editing = true)
      # scroll to cell
      path = form.table.indexPathForCell cell
      form.table.scrollToRowAtIndexPath path,
        atScrollPosition: UITableViewScrollPositionTop, animated: true
      # focus on text field
      return unless begin_editing
      elements.values.each do |element|
        if element.view.is_a?(UITextField)
          element.view.becomeFirstResponder && return
        end
      end
      self
    end

    def blur
      elements.values.each do |element|
        if element.view.is_a?(UITextField)
          element.view.resignFirstResponder && return
        end
      end
      self
    end
  end
end