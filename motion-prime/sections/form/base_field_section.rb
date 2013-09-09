module MotionPrime
  class BaseFieldSection < BaseSection
    include BW::KVO
    attr_accessor :form

    after_render :on_section_render

    def initialize(options = {})
      @form = options.delete(:form)
      if options[:observe_errors_for]
        @observe_errors_for = self.send(:instance_eval, &options.delete(:observe_errors_for))
      end
      super
      @container_options = options.delete(:container)
      observe_model_errors
    end

    def render_element?(element_name)
      case element_name.to_sym
      when :error_message
        @observe_errors_for && @observe_errors_for.errors[name].present?
      when :label
        not @options[:label] === false
      else true
      end
    end

    def on_section_render
      @status_for_updated = :rendered
    end

    def observe_model_errors
      return unless @observe_errors_for
      observe @observe_errors_for.errors, name do |old_value, new_value|
        if @status_for_updated == :rendered
          clear_observer_and_reload
        else
          create_elements
          form.table_view.reloadData
        end
      end
    end

    def clear_observer_and_reload
      unobserve @observe_errors_for.errors, name
      reload_section
    end

    def build_options_for_element(opts)
      super.merge(observe_errors_for: @observe_errors_for)
    end

    def form_name
      form.name
    end

    def container_options
      @container_options || super
    end

    def focus(begin_editing = true)
      # scroll to cell
      path = form.table_view.indexPathForCell cell
      form.table_view.scrollToRowAtIndexPath path,
        atScrollPosition: UITableViewScrollPositionTop, animated: true
      # focus on text field
      return unless begin_editing
      elements.values.each do |element|
        if element.view.is_a?(UITextField)
          element.view.becomeFirstResponder && return
        end
      end
      self
    rescue
      puts "can't focus on element #{self.class.name}"
    end

    def blur
      elements.values.each do |element|
        if element.view.is_a?(UITextField)
          element.view.resignFirstResponder && return
        end
      end
      self
    rescue
      puts "can't blur on element #{self.class.name}"
    end

    def bind_text_input
      view(:input).on :change do |view|
        focus
        form.on_input_change(view(:input))
      end
      view(:input).delegate = self.form
    end

    def reload_section
      form.reload_cell(self)
    end

    def container_height
      error_height = element(:error_message).try(:content_height)
      super + error_height.to_i
    end
  end
end