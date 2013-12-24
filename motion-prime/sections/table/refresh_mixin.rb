module MotionPrime
  module TableSectionRefreshMixin
    def add_pull_to_refresh(options = {}, &block)
      screen.automaticallyAdjustsScrollViewInsets = false

      table_view.addPullToRefreshWithActionHandler(block) # block must be a variable
      screen.setup table_view.pullToRefreshView, styles: [:base_pull_to_refresh]
    end

    def finish_pull_to_refresh
      reload_data
      table_view.pullToRefreshView.stopAnimating
    end
  end
end