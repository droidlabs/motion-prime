motion_require '../table/table_delegate.rb'
module MotionPrime
  class FormDelegate < TableDelegate
    def textFieldShouldReturn(text_field)
      table_section.on_input_return(text_field)
    end
    def textFieldShouldBeginEditing(text_field)
      text_field.respond_to?(:readonly) ? !text_field.readonly : true
    end
    def textFieldDidBeginEditing(text_field)
      table_section.on_input_edit_begin(text_field)
    end
    def textFieldDidEndEditing(text_field)
      table_section.on_input_edit_end(text_field)
    end

    def textField(text_field, shouldChangeCharactersInRange:range, replacementString:string)
      limit = (table_section.class.text_field_limits || {}).find do |field_name, limit|
        table_section.view("#{field_name}:input") == text_field
      end.try(:last)
      return true unless limit
      table_section.allow_string_replacement?(text_field, limit, range, string)
    end


    def textViewDidBeginEditing(text_view)
      table_section.on_input_edit_begin(text_view)
    end
    def textViewDidEndEditing(text_view)
      table_section.on_input_edit_end(text_view)
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
  end
end
