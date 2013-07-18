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
    attr_accessor :table, :fields, :keyboard_visible

    after_render :bind_keyboard_events

    def table_data
      fields.values
    end

    def render_table
      init_form_fields
      screen.table_view styles: [:base_form, name.to_sym], delegate: self, dataSource: self do |table|
        self.table = table
      end
    end

    def render_cell(index, table)
      screen.table_view_cell styles: [:base_form_field, :"#{name}_field"], reuse_identifier: cell_name(table, index) do
        data[index.row].render(to: screen)
      end
    end

    # accepts following syntax to find field element:
    # element("fieldname:elementname"), e.g. element("email:input")
    def element(name)
      field_name, element_name = name.split(':')
      self.fields[field_name.to_sym].element(element_name.to_sym)
    end

    def on_edit(field); end

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
      self.table.height -= KEYBOARD_HEIGHT_PORTRAIT
      self.keyboard_visible = true
    end

    def set_height_without_keyboard
      return unless keyboard_visible
      self.table.height += KEYBOARD_HEIGHT_PORTRAIT
      self.keyboard_visible = false
    end

    def on_keyboard_show
    end

    def on_keyboard_hide
    end

    def bind_keyboard_events
      NSNotificationCenter.defaultCenter.addObserver self,
                                         selector: :on_keyboard_show,
                                             name: UIKeyboardDidShowNotification,
                                           object: nil
      NSNotificationCenter.defaultCenter.addObserver self,
                                         selector: :on_keyboard_hide,
                                             name: UIKeyboardDidHideNotification,
                                           object: nil
    end

    private

      def init_form_fields
        self.fields = {}
        (self.class.fields_options || []).each do |key, field|
          klass = "MotionPrime::#{field[:type].classify}FieldSection".constantize
          self.fields[key] = klass.new(field.merge(form: self))
        end
      end
  end
end