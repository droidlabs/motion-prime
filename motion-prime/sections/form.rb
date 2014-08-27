motion_require 'table.rb'
motion_require '../helpers/has_style_chain_builder'
module MotionPrime
  class FormSection < TableSection
    # MotionPrime::FormSection is container for Field Sections.
    # Forms are located inside Screen and can contain multiple Field Sections.
    # On render, each field will be added to parent screen.

    # == Basic Sample
    # class MyLoginForm < MotionPrime::FormSection
    #   field :email, label: { text: 'E-mail' },  input: { placeholder: 'Your E-mail' }
    #   field :submit, button: { title: 'Login' }, type: :submit, action: :on_submit
    #
    #   def on_submit
    #     email = view("email:input").text
    #     puts "Submitted email: #{email}"
    #   end
    # end
    #

    class_attribute :fields_options, :text_field_limits, :text_view_limits, :fields_callbacks
    attr_accessor :fields, :field_indexes, :keyboard_visible, :rendered_views, :grouped_data

    def collection_data
      if has_many_sections?
        grouped_data.reject(&:nil?)
      else
        fields.values
      end
    end

    def hard_reload_cell_section(section)
      field_name = section.name.to_sym
      path = field_indexes[field_name]
      deque_cell(section, at: path) # deque cached

      fields[field_name] = load_field(self.class.fields_options[field_name])
      fields[field_name].create_elements
      if flat_data?
        @data[path.row] = fields[field_name]
      else
        @data[path.section][path.row] = fields[field_name]
      end

      self.performSelectorOnMainThread(:reload_cells, withObject: path, waitUntilDone: false)
    end

    # Returns element based on field name and element name
    #
    # Examples:
    #   form.element("email:input")
    #
    # @param String name with format "fieldname:elementname"
    # @return MotionPrime::BaseElement element
    def element(name)
      field_name, element_name = name.split(':')
      if element_name.present?
        field(field_name).element(element_name.to_sym)
      else
        super(field_name)
      end
    end

    # Returns field by name
    #
    # Examples:
    #   form.field(:email)
    #
    # @param String field name
    # @return MotionPrime::BaseFieldSection field
    def field(field_name)
      self.fields[field_name.to_sym]
    end

    def fields_hash
      fields.to_hash
    end

    def field_values
      values = {}
      fields.each do |field_name, field|
        values[field_name.to_sym] = field.value if field.input?
      end
      values
    end

    def register_elements_from_section(section)
      self.rendered_views ||= {}
      section.elements.values.each do |element|
        self.rendered_views[element.view] = {element: element, section: section}
      end
    end

    # Set focus on field cell
    #
    # Examples:
    #   form.focus_on(:title)
    #
    # @param String field name
    # @return MotionPrime::BaseFieldSection field
    def focus_on(field_name, animated = true)
      # unfocus other field
      data.flatten.each do |item|
        item.blur
      end
      # focus on field
      field(field_name).focus
    end

    def set_height_with_keyboard
      return if keyboard_visible
      self.collection_view.height -= KEYBOARD_HEIGHT_PORTRAIT
      self.keyboard_visible = true
    end

    def set_height_without_keyboard
      return unless keyboard_visible
      self.collection_view.height += KEYBOARD_HEIGHT_PORTRAIT
      self.keyboard_visible = false
    end

    def keyboard_will_show
      current_inset = collection_view.contentInset
      return if collection_view.contentSize.height + collection_view.top + current_inset.top <= UIScreen.mainScreen.bounds.size.height - KEYBOARD_HEIGHT_PORTRAIT
      current_inset.bottom = KEYBOARD_HEIGHT_PORTRAIT + (self.collection_element.computed_options[:bottom_content_inset] || 0)
      collection_view.contentInset = current_inset
    end

    def keyboard_will_hide
      current_inset = collection_view.contentInset
      current_inset.bottom = self.collection_element.computed_options[:bottom_content_inset] || 0
      collection_view.contentInset = current_inset
    end

    def collection_delegate
      @collection_delegate ||= FormDelegate.new(section: self)
    end

    def collection_styles_base
      :base_form
    end

    def allow_string_replacement?(target, limit, range, string)
      if string.length.zero? || (range.length + limit - target.text.length) >= string.length
        true
      else
        target.text.length < limit
      end
    end

    def load_field(field)
      field_class = class_factory("#{field[:type]}_field_section", true)
      field_class.new(field.merge(screen: screen, collection_section: self.weak_ref))
    end

    def render_field?(name, options)
      return true unless condition = options[:if]
      if condition.is_a?(Proc)
        self.instance_eval(&condition)
      else
        condition.to_proc.call(self)
      end
    end

    def reload_data
      init_form_fields # must be before resetting to reflect changes on @data
      reset_collection_data
      reload_collection_data
    end

    def has_many_sections?
      group_header_options.present? || grouped_data.count > 1
    end

    def render_collection
      init_form_fields unless self.fields.present?
      super
    end

    def on_cell_render(cell, index)
      options = data[index.row].try(:options)
      if options && options[:after_render]
        self.send(options[:after_render])
      end

      section = cell_section_by_index(index)
      if callbacks = fields_callbacks.try(:[], section.name)
        callbacks.each do |options|
          options[:method].to_proc.call(options[:target] || self)
        end
      end
      super
    end

    # Table View Delegate
    # ---------------------

    def number_of_groups
      has_many_sections? ? grouped_data.reject(&:nil?).count : 1
    end

    class << self
      def inherited(subclass)
        super
        subclass.fields_options = self.fields_options.try(:clone)
        subclass.fields_callbacks = self.fields_callbacks.try(:clone)
        subclass.text_field_limits = self.text_field_limits.try(:clone)
        subclass.text_view_limits = self.text_view_limits.try(:clone)
      end

      def async_collection_data(options = {})
        super
        self.send :include, Prime::AsyncFormMixin
      end

      def field(name, options = {}, &block)
        options[:name] = name
        options[:type] ||= :string
        options[:block] = block
        self.fields_options ||= {}
        self.fields_options[name] = options
        self.fields_options[name]
      end

      def after_field_render(field_name, method, options = {})
        options.merge!(method: method)
        self.fields_callbacks ||= {}
        self.fields_callbacks[field_name] ||= []
        self.fields_callbacks[field_name] << options
      end

      def limit_text_field_length(name, limit)
        self.text_field_limits ||= {}
        self.text_field_limits[name] = limit
      end
      def limit_text_view_length(name, limit)
        self.text_view_limits ||= {}
        self.text_view_limits[name] = limit
      end
    end

    private
      def create_section_elements; end

      def init_form_fields
        self.fields.values.each(&:clear_observers) if fields.present?

        self.fields = {}
        self.field_indexes = {}
        self.grouped_data = []
        section_indexes = []

        grouped_fields = (self.class.fields_options || {}).inject([]) do |result, (key, field)|
          next result unless render_field?(key, field)
          group_id = field[:group].to_i
          result[group_id] ||= {}
          result[group_id][key] = field
          result
        end

        header_options = Array.wrap(self.class.group_header_options).map(&:clone)
        header_options.each { |opts| normalize_options(opts) if opts }
        self.group_header_options = header_options.delete_if.each_with_index { |opts, id| grouped_fields[id].blank? }

        grouped_fields.compact.each_with_index do |fields, group_id|
          fields.each_with_index do |(key, field), row_id|
            section = load_field(field)
            if section.options[:after_render].present?
              puts "DEPRECATION: form field's option :after_render is deprecated, please use Prime::Section#after_field_render instead"
            end
            self.fields[key] = section
            self.field_indexes[key] = NSIndexPath.indexPathForRow(row_id, inSection: group_id)
            grouped_data[group_id] ||= []
            grouped_data[group_id][row_id] = section
          end
        end

        reset_data_stamps
      end
  end
end