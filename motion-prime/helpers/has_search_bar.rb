# This module adds search functionality, to Screen or TableSection
module MotionPrime
  module HasSearchBar
    def add_search_bar(options = {}, &block)
      target = options.delete(:target)

      @_search_bar = create_search_bar(options)
      @_search_bar.setDelegate self

      if target
        target.addSubview @_search_bar
      elsif is_a?(TableSection)
        self.table_view.tableHeaderView = @_search_bar
      end

      @search_callback = block
      @_search_bar
    rescue
      NSLog("can't add search bar to #{self.class_name_without_kvo}")
    end

    def dealloc
      @_search_bar.try(:setDelegate, nil)
      @_search_bar = nil
      super
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