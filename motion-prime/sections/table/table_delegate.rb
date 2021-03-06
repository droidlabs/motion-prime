module MotionPrime
  class TableDelegate
    include DelegateMixin
    attr_accessor :table_section

    def initialize(options)
      self.table_section = options[:section].try(:weak_ref)
      @_section_info = table_section.to_s
      @section_instance = table_section.to_s
    end

    def dealloc
      Prime.logger.dealloc_message :collection_delegate, @_section_info
      super
    end

    def init_pull_to_refresh
      return unless block = table_section.class.pull_to_refresh_block
      table_section.add_pull_to_refresh(table_section.class.pull_to_refresh_options || {}) do
        table_section.instance_eval(&block)
      end
    end

    def numberOfSectionsInTableView(table)
      table_section.number_of_groups
    end

    def tableView(table, cellForRowAtIndexPath: index)
      cur_call_time = Time.now.to_f
      cur_call_offset = table.contentOffset.y
      if @prev_call_time
        time_delta = cur_call_time - @prev_call_time
        offset_delta = cur_call_offset - @prev_call_offset
        @deceleration_speed = offset_delta/time_delta
      end
      @prev_call_time = cur_call_time
      @prev_call_offset = cur_call_offset

      table_section.cell_for_index(index)
    end

    def tableView(table, numberOfRowsInSection: group)
      table_section.cell_sections_for_group(group).try(:count).to_i
    end

    def tableView(table, heightForRowAtIndexPath: index)
      table_section.height_for_index(index)
    end

    def tableView(table, didSelectRowAtIndexPath:index)
      table_section.on_click(index)
    end

    def tableView(table, viewForHeaderInSection: group)
      table_section.header_cell_in_group(group)
    end

    def tableView(table, heightForHeaderInSection: group)
      table_section.height_for_header_in_group(group)
    end

    def scrollViewDidScroll(scroll)
      table_section.scroll_view_did_scroll(scroll)
      table_section.update_pull_to_refresh_after_scroll(scroll)
    end

    def scrollViewDidEndScrollingAnimation(scroll)
      table_section.scroll_view_did_end_scrolling_animation(scroll)
    end

    def scrollViewWillBeginDragging(scroll)
      table_section.scroll_view_will_begin_dragging(scroll)
    end

    def scrollViewWillBeginDecelerating(scroll)
      table_section.scroll_view_will_begin_decelerating(scroll)
    end

    def scrollViewDidEndDecelerating(scroll)
      table_section.scroll_view_did_end_decelerating(scroll)
    end

    def scrollViewDidEndDragging(scroll, willDecelerate: will_decelerate)
      table_section.scroll_view_did_end_dragging(scroll, willDecelerate: will_decelerate)
    end

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
    def textViewDidBeginEditing(text_view)
      table_section.on_input_edit_begin(text_view)
    end
    def textViewDidEndEditing(text_view)
      table_section.on_input_edit_end(text_view)
    end
    def textViewDidChange(text_view)
      unless IS_OS_8_OR_HIGHER
        # bug in iOS 7 - cursor is out of textView bounds
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
      table_section.on_input_did_change(text_view)
    end
  end
end