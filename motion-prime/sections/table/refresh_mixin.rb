module MotionPrime
  module TableSectionRefreshMixin
    def add_pull_to_refresh(options = {}, &block)
      screen.automaticallyAdjustsScrollViewInsets = false

      collection_view.addPullToRefreshWithActionHandler(block) # block must be a variable
      refresh_view = collection_view.pullToRefreshView

      options[:styles] ||= []
      options[:styles] += [:base_pull_to_refresh]
      # pass yOrigin to override view top
      base_options = {
        alpha: 0,
        custom_offset_threshold: - collection_view.contentInset.top - refresh_view.size.height,
        original_top_inset: collection_view.contentInset.top
      }
      screen.set_options_for refresh_view, base_options.deep_merge(options)
    end

    def finish_pull_to_refresh
      reload_data
      collection_view.pullToRefreshView.stopAnimating
    end
  end
end