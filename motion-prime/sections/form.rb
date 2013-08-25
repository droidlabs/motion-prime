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

    class_attribute :fields_options
    attr_accessor :fields, :field_indexes, :keyboard_visible

    after_render :bind_keyboard_events

    def table_data
      fields.values
    end

    def render_table
      @data_stamp = Time.now.to_i
      init_form_fields
      self.table_view = screen.table_view(
        styles: [:base_form, name.to_sym], delegate: self, dataSource: self
      ).view
    end

    def render_cell(index, table)
      item = data[index.row]

      screen.table_view_cell styles: [:base_form_field, :"#{name}_field"], reuse_identifier: cell_name(table, index) do
        item.render(to: screen)
      end
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

    class << self
      def field(name, options = {})
        options[:name] = name
        options[:type] ||= :string
        self.fields_options ||= {}
        self.fields_options[name] = options
        self.fields_options[name]
      end
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

    private

      def init_form_fields
        self.fields = {}
        self.field_indexes = {}
        index = 0
        (self.class.fields_options || []).each do |key, field|
          klass = "MotionPrime::#{field[:type].classify}FieldSection".constantize
          self.fields[key] = klass.new(field.merge(form: self))
          self.field_indexes[key] = index
          index += 1
        end
      end
  end
end