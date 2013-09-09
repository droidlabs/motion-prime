motion_require './table.rb'
module MotionPrime
  class FormSection < TableSection
    # MotionPrime::FormSection is container for Field Sections.
    # Forms are located inside Screen and can contain multiple Field Sections.
    # On render, each field will be added to parent screen.

    # == Basic Sample
    # class MyLoginForm < MotionPrime::FormSection
    #   field :email, label: { text: 'E-mail' },  input: { placeholder: 'Your E-mail' }
    #   field :submit, title: 'Login', type: :submit
    #
    #   def on_submit
    #     email = view("email:input").text
    #     puts "Submitted email: #{email}"
    #   end
    # end
    #

    KEYBOARD_HEIGHT_PORTRAIT = 216
    KEYBOARD_HEIGHT_LANDSCAPE = 162

    class_attribute :text_field_limits, :text_view_limits
    class_attribute :fields_options
    attr_accessor :fields, :field_indexes, :keyboard_visible

    after_render :bind_keyboard_events

    def table_data
      fields.values
    end

    def render_table
      init_form_fields
      set_data_stamp(self.field_indexes.values)
      self.table_view = screen.table_view(
        styles: [:base_form, name.to_sym], delegate: self, dataSource: self
      ).view
    end

    def render_cell(index, table)
      item = data[index.row]
      styles = [:base_form_field, :"#{name}_field"]
      if item.respond_to?(:container_styles) && item.container_styles.present?
        styles += Array.wrap(item.container_styles)
      end
      screen.table_view_cell styles: styles, reuse_identifier: cell_name(table, index) do |cell_element|
        item.cell_element = cell_element if item.respond_to?(:cell_element)
        item.render(to: screen)
      end
    end

    def reload_cell(section)
      field = section.name.to_sym
      path = table_view.indexPathForRowAtPoint(section.cell.center) # do not use indexPathForCell here as field may be invisibe
      table_view.beginUpdates
      section.cell.removeFromSuperview

      fields[field] = load_field(self.class.fields_options[field])
      @data = nil
      set_data_stamp([field_indexes[field]])
      table_view.reloadRowsAtIndexPaths([path], withRowAnimation: UITableViewRowAnimationNone)
      table_view.endUpdates
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

    # Set focus on field cell
    #
    # Examples:
    #   form.focus_on(:title)
    #
    # @param String field name
    # @return MotionPrime::BaseFieldSection field
    def focus_on(field_name, animated = true)
      # unfocus other field
      data.each do |item|
        item.blur
      end
      # focus on field
      field(field_name).focus
    end

    def set_height_with_keyboard
      return if keyboard_visible
      self.table_view.height -= KEYBOARD_HEIGHT_PORTRAIT
      self.keyboard_visible = true
    end

    def set_height_without_keyboard
      return unless keyboard_visible
      self.table_view.height += KEYBOARD_HEIGHT_PORTRAIT
      self.keyboard_visible = false
    end



    def on_keyboard_show; end
    def on_keyboard_hide; end
    def keyboard_will_show; end
    def keyboard_will_hide; end

    def bind_keyboard_events
      NSNotificationCenter.defaultCenter.addObserver self,
                                         selector: :on_keyboard_show,
                                             name: UIKeyboardDidShowNotification,
                                           object: nil
      NSNotificationCenter.defaultCenter.addObserver self,
                                         selector: :on_keyboard_hide,
                                             name: UIKeyboardDidHideNotification,
                                           object: nil
      NSNotificationCenter.defaultCenter.addObserver self,
                                         selector: :keyboard_will_show,
                                             name: UIKeyboardWillShowNotification,
                                           object: nil
      NSNotificationCenter.defaultCenter.addObserver self,
                                         selector: :keyboard_will_hide,
                                             name: UIKeyboardWillHideNotification,
                                           object: nil
    end
    # ALIASES
    def on_input_change(text_field); end
    def on_input_edit(text_field); end
    def on_input_return(text_field)
      text_field.resignFirstResponder
    end;
    def textFieldShouldReturn(text_field)
      on_input_return(text_field)
    end
    def textFieldDidBeginEditing(text_field)
      on_input_edit(text_field)
    end

    def textView(text_view, shouldChangeTextInRange:range, replacementText:string)
      limit = (self.class.text_view_limits || {}).find do |field_name, limit|
        view("#{field_name}:input")
      end.try(:last)
      return true unless limit
      allow_string_replacement?(text_view, limit, range, string)
    end

    def textField(text_field, shouldChangeCharactersInRange:range, replacementString:string)
      limit = (self.class.text_field_limits || {}).find do |field_name, limit|
        view("#{field_name}:input")
      end.try(:last)
      return true unless limit
      allow_string_replacement?(text_field, limit, range, string)
    end

    def allow_string_replacement?(target, limit, range, string)
      if string.length.zero? || (range.length + limit - target.text.length) >= string.length
        true
      else
        target.text.length < limit
      end
    end

    def load_field(field)
      klass = "MotionPrime::#{field[:type].classify}FieldSection".constantize
      klass.new(field.merge(form: self))
    end

    def render_field?(name)
      true
    end

    class << self
      def field(name, options = {})
        options[:name] = name
        options[:type] ||= :string
        self.fields_options ||= {}
        self.fields_options[name] = options
        self.fields_options[name]
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
      def init_form_fields
        self.fields = {}
        self.field_indexes = {}
        index = 0
        (self.class.fields_options || []).each do |key, field|
          next unless render_field?(key)
          self.fields[key] = load_field(field)
          self.field_indexes[key] = index
          index += 1
        end
      end
  end
end