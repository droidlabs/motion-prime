motion_require '../table/table_delegate'
module MotionPrime
  class FormDelegate < TableDelegate
    def textField(text_field, shouldChangeCharactersInRange:range, replacementString:string)
      limit = (table_section.class.text_field_limits || {}).find do |field_name, limit|
        table_section.view("#{field_name}:input") == text_field
      end.try(:last)
      return true unless limit
      table_section.allow_string_replacement?(text_field, limit, range, string)
    end

    def textView(text_view, shouldChangeTextInRange:range, replacementText:string)
      textField(text_view, shouldChangeCharactersInRange:range, replacementString:string)
    end
  end
end
