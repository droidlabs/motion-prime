module MotionPrime
  class TableDelegate
    include DelegateMixin
    attr_accessor :table_section
    def initialize(options)
      self.table_section = options[:section].try(:weak_ref)
      @section_instance = table_section.to_s
    end

    # def dealloc
    #   pp 'Deallocating table_delegate for ', @section_instance
    #   super
    # end

    def init_pull_to_refresh
      return unless block = table_section.class.pull_to_refresh_block
      table_section.add_pull_to_refresh do
        table_section.instance_eval(&block)
      end
    end

    def numberOfSectionsInTableView(table)
      table_section.number_of_groups(table)
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

      table_section.cell_for_index(table, index)
    end

    def tableView(table, numberOfRowsInSection: group)
      table_section.cell_sections_for_group(group).try(:count).to_i
    end

    def tableView(table, heightForRowAtIndexPath: index)
      table_section.height_for_index(table, index)
    end

    def tableView(table, didSelectRowAtIndexPath:index)
      table_section.on_click(table, index)
    end

    def tableView(table, viewForHeaderInSection: group)
      table_section.header_cell_in_group(table, group)
    end

    def tableView(table, heightForHeaderInSection: group)
      table_section.height_for_header_in_group(table, group)
    end

    def scrollViewDidScroll(scroll)
      table_section.scroll_view_did_scroll(scroll)
    end

    def scrollViewWillBeginDragging(scroll)
      table_section.scroll_view_will_begin_dragging(scroll)
    end

    def scrollViewDidEndDecelerating(scroll)
      table_section.scroll_view_did_end_decelerating(scroll)
    end

    def scrollViewDidEndDragging(scroll, willDecelerate: will_decelerate)
      table_section.scroll_view_did_end_dragging(scroll, willDecelerate: will_decelerate)
    end
  end
end