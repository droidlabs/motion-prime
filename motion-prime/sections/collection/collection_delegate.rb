module MotionPrime
  class CollectionDelegate
    include DelegateMixin
    attr_accessor :collection_section

    def initialize(options)
      self.collection_section = options[:section].try(:weak_ref)
      @section_instance = collection_section.to_s
    end

    # def dealloc
    #   pp 'Deallocating collection_delegate for ', @section_instance
    #   super
    # end

    def numberOfSectionsInCollectionView(table)
      collection_section.number_of_groups
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

      collection_section.cell_for_index(index)
    end

    def collectionView(table, numberOfItemsInSection: group)
      collection_section.number_of_cells_in_group(group)
    end

    def collectionView(table, heightForItemAtIndexPath: index)
      collection_section.height_for_index(index)
    end

    def collectionView(table, didSelectItemAtIndexPath:index)
      collection_section.on_click(index)
    end

    def scrollViewDidScroll(scroll)
      collection_section.scroll_view_did_scroll(scroll)
      collection_section.update_pull_to_refresh_after_scroll(scroll)
    end

    def scrollViewWillBeginDragging(scroll)
      collection_section.scroll_view_will_begin_dragging(scroll)
    end

    def scrollViewDidEndDecelerating(scroll)
      collection_section.scroll_view_did_end_decelerating(scroll)
    end

    def scrollViewDidEndDragging(scroll, willDecelerate: will_decelerate)
      collection_section.scroll_view_did_end_dragging(scroll, willDecelerate: will_decelerate)
    end
  end
end