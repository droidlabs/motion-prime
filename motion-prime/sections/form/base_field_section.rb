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
      if options[:observe_errors]
        # Do not remove clone() after delete()
        @errors_observer_options = normalize_options(options.delete(:observe_errors).clone, self)
      end
    end

    # Returns true if we should render element in current state
    #
    # @param element_name [Symbol] name of element in field
    # @return [Boolean]
    def render_element?(element_name)
      case element_name.to_sym
      when :error_message
        has_errors?
      when :label
        not @options[:label] === false
      else true
      end
    end

    # Changes height of the field (the cell in table) with animation.
    #
    # @param height [Integet] new height of field
    # @return [MotionPrime::BaseFieldSection]
    def update_height(height)
      return if container_options[:height] == height
      container_options[:height] = height
      index = form.field_indexes[name]
      form.send :set_data_stamp, self.object_id
      form.table_view.reloadRowsAtIndexPaths([index], withRowAnimation: UITableViewRowAnimationFade)
      self
    end

    def on_section_render
      @status_for_updated = :rendered
      form.register_elements_from_section(self)
    end

    def observe_model_errors
      return unless observing_errors?
      on_error_change = proc { |old_value, new_value|
        changes = observing_errors_for.errors.changes
        errors_observer_fields.each do |field|
          next unless changes.has_key?(field)
          if @status_for_updated == :rendered
            reload_section
          else
            load_section!
            form.reload_table_data
          end
        end
      }.weak!

      observe observing_errors_for.errors, :info, &on_error_change
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
      path = form.table_view.indexPathForCell(cell)
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

    def default_label_options
      label_options = options[:label] || {}
      if label_options.has_key?(:text)
        label_options
      else
        {text: options[:name].to_s.titleize}.merge(label_options)
      end
    end

    def bind_text_input
      view(:input).on :change do |view|
        focus
        form.on_input_change(view(:input))
      end
    end

    def observing_errors?
      @errors_observer_options.present?
    end

    def has_errors?
      return false unless observing_errors?
      observing_errors_for.errors.info.slice(*errors_observer_fields).values.any?(&:present?)
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

      observing_errors_for.errors.info.slice(*errors_observer_fields).values.flatten
    end

    def reload_section
      clear_observers
      form.reload_cell_section(self)
    end

    def clear_observers
      return unless observing_errors?
      # unobserve_all cause double dealloc, following code is a replacement
      unobserve observing_errors_for.errors, :info
      # TODO: clear 'on' events
    end

    def container_height
      return 0 if container_options[:hidden]
      element = element(:error_message)
      error_height = element ? element.cached_content_height + 5 : 0
      super + error_height
    end
  end
end