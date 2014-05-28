module MotionPrime
  module TableSectionRefreshMixin
    def add_pull_to_refresh(options = {}, &block)
      screen.automaticallyAdjustsScrollViewInsets = false

      collection_view.addPullToRefreshWithActionHandler(block) # block must be a variable
      screen.set_options_for collection_view.pullToRefreshView, styles: [:base_pull_to_refresh]
    end

    def finish_pull_to_refresh
      reload_data
      collection_view.pullToRefreshView.stopAnimating
    end
  end
end