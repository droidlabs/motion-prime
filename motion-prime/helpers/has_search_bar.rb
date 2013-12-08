# This module adds search functionality, to Screen or TableSection
module MotionPrime
  module HasSearchBar
    def add_search_bar(options = {}, &block)
      target = options.delete(:target)

      search_bar = create_search_bar(options)
      search_bar.delegate = self

      if target
        target.addSubview search_bar
      elsif is_a?(TableSection)
        self.table_view.tableHeaderView = search_bar
      end

      @search_callback = block
      search_bar
    rescue
      NSLog("can't add search bar to #{self.class_name_without_kvo}")
    end

    def create_search_bar(options = {})
      name = is_a?(TableSection) ? name : self.class_name_without_kvo.underscore
      screen = is_a?(TableSection) ? self.screen : self
      options[:styles] ||= []
      options[:styles] += [:"base_search_bar", :"base_#{name}_search_bar"]

      screen.search_bar(options).view
    end

    def searchBar(search_bar, textDidChange: text)
      @search_callback.call(text)
    end

    def searchBarSearchButtonClicked(search_bar)
      search_bar.resignFirstResponder
    end
  end
end