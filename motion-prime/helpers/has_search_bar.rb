# This module adds search functionality, to Screen or TableSection
module MotionPrime
  module HasSearchBar
    def add_search_bar(options = {}, &block)
      @_search_timeout = options.delete(:timeout)
      target = options.delete(:target)

      @_search_bar = create_search_bar(options)
      @_search_bar.setDelegate self

      if target
        target.addSubview @_search_bar
      elsif is_a?(TableSection)
        self.collection_view.tableHeaderView = @_search_bar
      end

      @search_callback = block
      @_search_bar
    rescue
      NSLog("can't add search bar to #{self.class_name_without_kvo}")
    end

    def dealloc
      BW::Reactor.cancel_timer(@_search_timer) if @_search_timer
      @_search_bar.try(:setDelegate, nil)
      @_search_bar = nil
      super
    end

    def create_search_bar(options = {})
      name = is_a?(TableSection) ? name : self.class_name_without_kvo.underscore
      screen = is_a?(TableSection) ? self.screen : self
      options[:styles] ||= []
      options[:styles] += [:"base_search_bar", :"base_#{name}_search_bar", :"#{name}_search_bar"]

      screen.search_bar(options).view
    end

    def searchBar(search_bar, textDidChange: text)
      BW::Reactor.cancel_timer(@_search_timer) if @_search_timer
      if @_search_timeout
        @_search_timer = BW::Reactor.add_timer(@_search_timeout.to_f/1000, proc{ @search_callback.call(text) }.weak!)
      else
        @search_callback.call(text)
      end
    end

    def searchBarSearchButtonClicked(search_bar)
      BW::Reactor.cancel_timer(@_search_timer) if @_search_timer
      @search_callback.call(search_bar.text)
      search_bar.resignFirstResponder
    end
  end
end