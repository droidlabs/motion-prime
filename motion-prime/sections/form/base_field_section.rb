module MotionPrime
  class BaseFieldSection < Section
    include CellSectionMixin
    include BW::KVO

    attr_reader :form
    after_render :on_section_render

    before_initialize :prepare_table_data
    after_initialize :observe_model_errors

    def prepare_table_data
      @form = @options[:table]
      @errors_observer_options = normalize_options(options.delete(:observe_errors).clone, self) if options[:observe_errors]
    end

    def render_element?(element_name)
      case element_name.to_sym
      when :error_message
        has_errors?
      when :label
        not @options[:label] === false
      else true
      end
    end

    def on_section_render
      @status_for_updated = :rendered
      form.register_elements_from_section(self)
    end

    def observe_model_errors
      return unless observing_errors?
      on_error_change = proc { |old_value, new_value|
        next if old_value == new_value
        if @status_for_updated == :rendered
          reload_section
        else
          load_section!
          form.reload_table_data
        end
      }.weak!

      errors_observer_fields.each do |field|
        observe observing_errors_for.errors, observing_errors_for.errors.unique_key(field), &on_error_change
      end
    end

    def dealloc
      clear_observers
      super
    end

    def form_name
      form.name
    end

    def focus(begin_editing = true)
      # scroll to cell
      path = form.table_view.indexPathForCell cell
      form.table_view.scrollToRowAtIndexPath path,
        atScrollPosition: UITableViewScrollPositionTop, animated: true
      # focus on text field
      return unless begin_editing
      elements.values.each do |element|
        if element.view.is_a?(UITextField) || element.view.is_a?(UITextView)
          element.view.becomeFirstResponder and return
        end
      end
      self
    rescue
      NSLog("can't focus on element #{self.class_name_without_kvo}")
    end

    def blur
      elements.values.each do |element|
        if element.view.is_a?(UITextField)
          element.view.resignFirstResponder && return
        end
      end
      self
    rescue
      NSLog("can't blur on element #{self.class_name_without_kvo}")
    end

    def bind_text_input
      view(:input).on :change do |view|
        focus
        form.on_input_change(view(:input))
      end
      view(:input).delegate = self.form.table_delegate
    end

    def observing_errors?
      @errors_observer_options.present?
    end

    def has_errors?
      return false unless observing_errors?
      errors_observer_fields.any? do |field|
        observing_errors_for.errors[field].present?
      end
    end

    def errors_observer_fields
      @errors_observer_fields ||= begin
        fields = Array.wrap(@errors_observer_options[:fields])
        fields << name if fields.empty?
        fields.uniq
      end
    end

    def observing_errors_for
      @errors_observer_options[:resource]
    end

    def all_errors
      return [] unless observing_errors?

      errors_observer_fields.map do |field|
        observing_errors_for.errors[field]
      end
    end

    def reload_section
      clear_observers
      form.reload_cell(self)
    end

    def clear_observers
      return unless observing_errors?
      # unobserve_all cause double dealloc, following code is a replacement
      block = proc { |field|
        unobserve observing_errors_for.errors, observing_errors_for.errors.unique_key(field)
      }.weak!
      errors_observer_fields.each(&block)
    end

    def container_height
      return 0 if container_options[:hidden]
      element = element(:error_message)
      error_height = element ? element.cached_content_height + 5 : 0
      super + error_height
    end
  end
end