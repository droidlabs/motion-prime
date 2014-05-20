module Prime
  module AsyncFormMixin
    def reload_table_data
      # FIXME: duplicated cells (see cached_cell error)
      return super unless async_data?
      sections = NSMutableIndexSet.new
      number_of_groups.times do |section_id|
        sections.addIndex(section_id)
      end
      table_view.reloadSections sections, withRowAnimation: UITableViewRowAnimationFade
    end
  end
end