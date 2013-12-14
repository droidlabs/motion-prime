motion_require './table.rb'
motion_require '../helpers/has_style_chain_builder'
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

    include HasClassFactory

    class_attribute :text_field_limits, :text_view_limits
    class_attribute :fields_options, :section_header_options
    attr_accessor :fields, :field_indexes, :keyboard_visible, :rendered_views, :section_headers, :section_header_options

    def table_data
      if @has_groups
        section_indexes = []
        data = fields.inject([]) do |result, (key, field)|
          section = self.class.fields_options[key][:group].to_i
          section_indexes[section] ||= 0
          result[section] ||= []
          result[section][section_indexes[section]] = field
          section_indexes[section] += 1
          result
        end
        self.section_header_options.delete_if.each_with_index { |opts, id| data[id].nil? }
        data.compact
      else
        fields.values
      end
    end

    def data
      @data ||= table_data
    end

    def render_table
      init_form_fields
      options = {
        styles: table_styles.values.flatten,
        delegate: self,
        dataSource: self,
        style: (UITableViewStyleGrouped unless flat_data?)}
      self.table_element = screen.table_view(options)
    end

    def reload_cell(section)
      field = section.name.to_sym
      index = field_indexes[field].split('_').map(&:to_i)
      path = NSIndexPath.indexPathForRow(index.last, inSection: index.first)
      section.cell.try(:removeFromSuperview)

      fields[field] = load_field(self.class.fields_options[field])
      fields[field].load_section
      if flat_data?
        @data[path.row] = fields[field]
      else
        @data[path.section][path.row] = fields[field]
      end

      set_data_stamp(field_indexes[field])

      # table_view.beginUpdates
      table_view.reloadRowsAtIndexPaths([path], withRowAnimation: UITableViewRowAnimationNone)
      # table_view.endUpdates
    end

    def reset_data_stamps
      set_data_stamp(self.field_indexes.values)
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
      self.table_view.height -= KEYBOARD_HEIGHT_PORTRAIT
      self.keyboard_visible = true
    end

    def set_height_without_keyboard
      return unless keyboard_visible
      self.table_view.height += KEYBOARD_HEIGHT_PORTRAIT
      self.keyboard_visible = false
    end

    def keyboard_will_show
      return if table_view.contentSize.height + table_view.top <= UIScreen.mainScreen.bounds.size.height - KEYBOARD_HEIGHT_PORTRAIT
      current_inset = table_view.contentInset
      current_inset.bottom = KEYBOARD_HEIGHT_PORTRAIT + (self.table_element.computed_options[:bottom_content_inset] || 0)
      table_view.contentInset = current_inset
    end

    def keyboard_will_hide
      current_inset = table_view.contentInset
      current_inset.bottom = self.table_element.computed_options[:bottom_content_inset] || 0
      table_view.contentInset = current_inset
    end

    # ALIASES
    def on_input_change(text_field); end
    def on_input_edit(text_field); end
    def on_input_return(text_field)
      text_field.resignFirstResponder
    end
    def textFieldShouldReturn(text_field)
      on_input_return(text_field)
    end
    def textFieldShouldBeginEditing(text_field)
      text_field.respond_to?(:readonly) ? !text_field.readonly : true
    end
    def textFieldDidBeginEditing(text_field)
      on_input_edit(text_field)
    end
    def textViewDidBeginEditing(text_view)
      on_input_edit(text_view)
    end
    def textViewDidChange(text_view) # bug in iOS 7 - cursor is out of textView bounds
      line = text_view.caretRectForPosition(text_view.selectedTextRange.start)
      overflow = line.origin.y + line.size.height -
        (text_view.contentOffset.y + text_view.bounds.size.height - text_view.contentInset.bottom - text_view.contentInset.top)
      if overflow > 0
        offset = text_view.contentOffset
        offset.y += overflow + text_view.textContainerInset.bottom
        UIView.animate(duration: 0.2) do
          text_view.setContentOffset(offset)
        end
      end
    end

    def textView(text_view, shouldChangeTextInRange:range, replacementText:string)
      textField(text_view, shouldChangeCharactersInRange:range, replacementString:string)
    end

    def textField(text_field, shouldChangeCharactersInRange:range, replacementString:string)
      limit = (self.class.text_field_limits || {}).find do |field_name, limit|
        view("#{field_name}:input") == text_field
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
      field_class = class_factory("#{field[:type]}_field_section", true)
      field_class.new(field.merge(screen: screen, table: self))
    end

    def render_field?(name, options)
      return true unless condition = options[:if]
      if condition.is_a?(Proc)
        self.instance_eval(&condition)
      else
        condition.to_proc.call(self)
      end
    end

    def render_header(section)
      return unless options = self.section_header_options.try(:[], section)
      self.section_headers[section] ||= BaseHeaderSection.new(options.merge(screen: screen, table: self))
    end

    def header_for_section(section)
      self.section_headers ||= []
      self.section_headers[section] || render_header(section)
    end

    def tableView(table, viewForHeaderInSection: section)
      return unless header = header_for_section(section)
      wrapper = MotionPrime::BaseElement.factory(:view, screen: screen, styles: cell_styles(header).values.flatten, parent_view: table_view)
      wrapper.render do |container_view, container_element|
        header.container_element = container_element
        header.render
      end
    end

    def tableView(table, heightForHeaderInSection: section)
      header_for_section(section).try(:container_height) || 0
    end

    class << self
      def field(name, options = {}, &block)
        options[:name] = name
        options[:type] ||= :string
        options[:block] = block
        self.fields_options ||= {}
        self.fields_options[name] = options
        self.fields_options[name]
      end

      def group_header(name, options)
        options[:name] = name
        self.section_header_options ||= []
        section = options.delete(:id)
        self.section_header_options[section] = options
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

    def reload_data
      @groups_count = nil
      reset_data
      init_form_fields
      table_view.reloadData
    end

    def reset_data
      super
      self.fields.values.each(&:clear_observers)
    end

    private
      def init_form_fields
        self.fields = {}
        self.field_indexes = {}
        section_indexes = []
        (self.class.fields_options || {}).each do |key, field|
          next unless render_field?(key, field)
          section_id = field[:group].to_i
          @groups_count = [@groups_count || 1, section_id + 1].max
          self.fields[key] = load_field(field)

          section_indexes[section_id] ||= 0
          self.field_indexes[key] = "#{section_id}_#{section_indexes[section_id]}"
          section_indexes[section_id] += 1
        end
        init_form_headers
        @has_groups = section_header_options.present? || @groups_count > 1
        reset_data_stamps
      end

      def init_form_headers
        self.section_header_options = Array.wrap(self.class.section_header_options).clone
      end
  end
end