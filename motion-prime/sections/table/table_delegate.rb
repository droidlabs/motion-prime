module MotionPrime
  class TableDelegate
    attr_accessor :table_section
    def initialize(options)
      self.table_section = options[:section].try(:weak_ref)
    end

    # def dealloc
    #   pp '@@ dealloc table_delegate'
    #   super
    # end

    def init_pull_to_refresh
      return unless block = table_section.class.pull_to_refresh_block
      table_section.add_pull_to_refresh do
        table_section.instance_eval(&block)
      end
    end

    def numberOfSectionsInTableView(table)
      table_section.number_of_sections(table)
    end

    def tableView(table, cellForRowAtIndexPath: index)
      table_section.cell_for_index(table, index)
    end

    def tableView(table, numberOfRowsInSection: section)
      table_section.rows_for_section(section).try(:count).to_i
    end

    def tableView(table, heightForRowAtIndexPath: index)
      table_section.height_for_index(table, index)
    end

    def tableView(table, didSelectRowAtIndexPath:index)
      table_section.on_click(table, index)
    end

    def tableView(table, viewForHeaderInSection: section)
      table_section.view_for_header_in_section(table, section)
    end

    def tableView(table, heightForHeaderInSection: section)
      table_section.height_for_header_in_section(table, section)
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