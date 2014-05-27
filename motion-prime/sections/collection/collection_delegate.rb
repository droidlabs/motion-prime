module MotionPrime
  class CollectionDelegate
    include DelegateMixin
    attr_accessor :table_section

    def initialize(options)
      self.table_section = options[:section].try(:weak_ref)
      @section_instance = table_section.to_s
    end

    def init_pull_to_refresh
      return unless block = table_section.class.pull_to_refresh_block
      table_section.add_pull_to_refresh do
        table_section.instance_eval(&block)
      end
    end

    # def dealloc
    #   pp 'Deallocating collection_delegate for ', @section_instance
    #   super
    # end

    def numberOfSectionsInCollectionView(table)
      (table_section.fixed_table_data.count / 3).ceil
    end

    def collectionView(table, cellForItemAtIndexPath: index)
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

    def collectionView(table, numberOfItemsInSection: group)
      3
    end

    def collectionView(table, heightForItemAtIndexPath: index)
      table_section.height_for_index(index)
    end

    def collectionView(table, didSelectItemAtIndexPath:index)
      table_section.on_click(index)
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